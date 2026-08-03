import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poultry_pms_desktop/data/local_db.dart';
import 'package:poultry_pms_desktop/utils/farm_utils.dart';
import 'package:poultry_pms_desktop/utils/id_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
  });

  tearDown(() async {
    await db.close();
  });

  test('local schema version is 30 with text primary keys', () {
    expect(db.schemaVersion, 30);
    expect(db.houses.id, isA<GeneratedColumn<String>>());
    expect(db.batches.id, isA<GeneratedColumn<String>>());
    expect(db.batches.farmId, isA<GeneratedColumn<String>>());
    expect(db.expenses.id, isA<GeneratedColumn<String>>());
  });

  test('offline genesis farm row satisfies local farm binding', () async {
    const ownerId = 'local_owner';

    await FarmUtils.ensureLocalGenesisFarm(db, ownerId: ownerId);

    final row = await (db.select(
      db.farms,
    )..where((t) => t.id.equals(FarmUtils.localGenesisFarmId))).getSingle();

    expect(row.name, FarmUtils.localGenesisFarmName);
    expect(row.userId, ownerId);
    expect(row.syncStatus, FarmUtils.localOnlySyncStatus);
  });

  test('insert requires string id and satisfies not-null columns', () async {
    final farmId = newLocalId();
    final houseId = newLocalId();

    await db
        .into(db.houses)
        .insert(
          HousesCompanion.insert(
            id: houseId,
            farmId: farmId,
            name: 'Unit A',
            capacity: 1000,
            synced: const Value(false),
          ),
        );

    final row = await (db.select(
      db.houses,
    )..where((t) => t.id.equals(houseId))).getSingle();
    expect(row.id, isA<String>());
    expect(row.id, houseId);
    expect(row.farmId, farmId);
    expect(int.tryParse(row.id), isNull);
  });

  test('sync push payload builder uses string ids only', () {
    final farmId = newLocalId();
    final houseId = newLocalId();
    final batchId = newLocalId();

    final housePayload = {
      'id': safeIdString(houseId),
      'farmId': safeIdString(farmId),
      'name': 'House',
      'capacity': 500,
    };
    assertSyncPayloadUsesStringIds(housePayload);

    final batchPayload = {
      'id': safeIdString(batchId),
      'farmId': safeIdString(farmId),
      'houseId': optionalIdString(houseId),
      'batchName': 'B1',
      'currentCount': 100,
      'initialCount': 100,
    };
    assertSyncPayloadUsesStringIds(batchPayload);

    expect(
      () => assertSyncPayloadUsesStringIds({'id': 42, 'farmId': farmId}),
      throwsArgumentError,
    );
  });

  test('optionalIdString never returns int type', () {
    expect(optionalIdString(null), isNull);
    expect(optionalIdString(''), isNull);
    expect(optionalIdString(99), '99');
    expect(
      optionalIdString('cmpesg0a30006ks04punsibnf'),
      'cmpesg0a30006ks04punsibnf',
    );
  });

  test('mortality and expense rows round-trip with string fks', () async {
    final farmId = newLocalId();
    final batchId = newLocalId();
    final mortId = newLocalId();
    final expenseId = newLocalId();

    await db
        .into(db.batches)
        .insert(
          BatchesCompanion.insert(
            id: batchId,
            farmId: farmId,
            batchName: const Value('Layer 1'),
            arrivalDate: DateTime.utc(2025, 1, 1),
            currentCount: 100,
            initialCount: 100,
            synced: const Value(false),
          ),
        );

    await db
        .into(db.mortalities)
        .insert(
          MortalitiesCompanion.insert(
            id: mortId,
            farmId: farmId,
            batchId: batchId,
            count: 2,
            logDate: DateTime.utc(2025, 5, 1),
            synced: const Value(false),
          ),
        );

    await db
        .into(db.expenses)
        .insert(
          ExpensesCompanion.insert(
            id: expenseId,
            farmId: farmId,
            category: 'Feed',
            amount: 50.0,
            synced: const Value(false),
          ),
        );

    final mortPayload = {
      'id': safeIdString(mortId),
      'farmId': safeIdString(farmId),
      'batch_id': safeIdString(batchId),
      'count': 2,
    };
    assertSyncPayloadUsesStringIds(mortPayload);

    final pending = await (db.select(
      db.expenses,
    )..where((t) => t.synced.equals(false))).get();
    expect(pending, hasLength(1));
    expect(pending.first.id, expenseId);
    expect(pending.first.farmId, farmId);
  });

  test('onCreate builds all drift tables', () async {
    expect(db.allTables.length, 27);

    for (final table in db.allTables) {
      final rows = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
            variables: [Variable.withString(table.actualTableName)],
          )
          .get();
      expect(
        rows,
        isNotEmpty,
        reason: 'missing table ${table.actualTableName}',
      );
    }
  });

  test('core farm workflow inserts and queries with string ids', () async {
    final farmId = newLocalId();
    final userId = newLocalId();
    final houseId = newLocalId();
    final batchId = newLocalId();
    final inventoryId = newLocalId();
    final customerId = newLocalId();

    await db
        .into(db.farms)
        .insert(
          FarmsCompanion.insert(
            id: farmId,
            name: 'Test Farm',
            capacity: 5000,
            userId: userId,
          ),
        );

    await db
        .into(db.farmSettings)
        .insert(FarmSettingsCompanion.insert(id: newLocalId(), farmId: farmId));

    await db
        .into(db.houses)
        .insert(
          HousesCompanion.insert(
            id: houseId,
            farmId: farmId,
            name: 'House 1',
            capacity: 1000,
            synced: const Value(false),
          ),
        );

    await db
        .into(db.batches)
        .insert(
          BatchesCompanion.insert(
            id: batchId,
            farmId: farmId,
            houseId: Value(houseId),
            arrivalDate: DateTime.utc(2025, 3, 1),
            currentCount: 500,
            initialCount: 500,
            synced: const Value(false),
          ),
        );

    await db
        .into(db.inventory)
        .insert(
          InventoryCompanion.insert(
            id: inventoryId,
            farmId: farmId,
            itemName: 'Layer Feed',
            stockLevel: 100,
            unit: 'kg',
            synced: const Value(false),
          ),
        );

    await db
        .into(db.stockLogs)
        .insert(
          StockLogsCompanion.insert(
            id: newLocalId(),
            farmId: farmId,
            itemId: inventoryId,
            quantity: 10,
            logType: 'IN',
            synced: const Value(false),
          ),
        );

    await db
        .into(db.customers)
        .insert(
          CustomersCompanion.insert(
            id: customerId,
            farmId: farmId,
            name: 'Buyer Co',
            synced: const Value(false),
          ),
        );

    final batch = await (db.select(
      db.batches,
    )..where((t) => t.id.equals(batchId))).getSingle();
    expect(batch.houseId, houseId);

    final byFarm = await (db.select(
      db.houses,
    )..where((t) => t.farmId.equals(farmId))).get();
    expect(byFarm, hasLength(1));
    expect(byFarm.first.id, houseId);
  });

  test('farm member pull insert accepts role as Value', () async {
    final farmId = newLocalId();
    final userId = newLocalId();
    final memberId = newLocalId();

    await db
        .into(db.farmMembers)
        .insertOnConflictUpdate(
          FarmMembersCompanion.insert(
            id: memberId,
            farmId: farmId,
            userId: userId,
            role: const Value('MANAGER'),
            joinedAt: Value(DateTime.utc(2025, 5, 1)),
            synced: const Value(true),
          ),
        );

    final row = await (db.select(
      db.farmMembers,
    )..where((t) => t.id.equals(memberId))).getSingle();
    expect(row.role, 'MANAGER');
    expect(row.farmId, farmId);
    expect(row.userId, userId);
  });

  test('feeding log links formulation by string id', () async {
    final farmId = newLocalId();
    final formulationId = newLocalId();
    final logId = newLocalId();

    await db
        .into(db.feedFormulations)
        .insert(
          FeedFormulationsCompanion.insert(
            id: formulationId,
            farmId: farmId,
            name: 'Starter Mix',
            type: const Value('STARTER'),
            stockLevel: const Value(40),
            synced: const Value(false),
          ),
        );

    await db.into(db.feedFormulationIngredients).insert(
      FeedFormulationIngredientsCompanion.insert(
        id: newLocalId(),
        formulationId: formulationId,
        inventoryId: newLocalId(),
        quantity: 40,
        unit: const Value('bag'),
        synced: const Value(false),
      ),
    );

    await db
        .into(db.feedingLogs)
        .insert(
          FeedingLogsCompanion.insert(
            id: logId,
            farmId: farmId,
            formulationId: Value(formulationId),
            amountConsumed: 25,
            logDate: DateTime.utc(2025, 5, 1),
            synced: const Value(false),
          ),
        );

    final log = await (db.select(
      db.feedingLogs,
    )..where((t) => t.id.equals(logId))).getSingle();
    expect(log.formulationId, formulationId);

    final form = await (db.select(
      db.feedFormulations,
    )..where((t) => t.id.equals(log.formulationId!))).getSingle();
    expect(form.id.isNotEmpty, isTrue);
    expect(form.stockLevel, 40);
  });

  test('feeding log push payload uses string ids without cloud-only columns', () {
    final payload = {
      'id': newLocalId(),
      'farmId': newLocalId(),
      'batch_id': newLocalId(),
      'feed_type_id': newLocalId(),
      'formulation_id': null,
      'amount_consumed': 1.5,
      'log_date': DateTime.utc(2026, 7, 7).toIso8601String(),
      'user_id': newLocalId(),
    };

    assertSyncPayloadUsesStringIds(payload);
    expect(payload.containsKey('createdAt'), isFalse);
    expect(payload.containsKey('updatedAt'), isFalse);
  });
}
