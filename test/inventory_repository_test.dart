import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poultry_pms_desktop/data/local_db.dart';
import 'package:poultry_pms_desktop/services/inventory_repository.dart';
import 'package:poultry_pms_desktop/utils/id_utils.dart';
import 'package:poultry_pms_desktop/utils/inventory_constants.dart';

void main() {
  late AppDatabase db;
  late InventoryRepository repo;
  const farmId = 'farm-inv-test';

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = InventoryRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<String> seedInventory({
    required String name,
    required String category,
    required double stock,
    String? usageType,
  }) async {
    final id = newLocalId();
    await db.into(db.inventory).insert(
          InventoryCompanion.insert(
            id: id,
            farmId: farmId,
            itemName: name,
            category: Value(category),
            stockLevel: stock,
            unit: defaultUnitForInventoryCategory(category),
            usageType: Value(usageType),
            synced: const Value(false),
          ),
        );
    return id;
  }

  test('active filter excludes zero stock and one-time consumed items', () async {
    await seedInventory(name: 'Grower Feed', category: kFeedInventoryCategory, stock: 5);
    await seedInventory(name: 'Empty Med', category: kMedicineInventoryCategory, stock: 0);
    final oneTimeId = await seedInventory(
      name: 'Newcastle Vaccine',
      category: kVaccineInventoryCategory,
      stock: 1,
      usageType: 'ONE_TIME',
    );

    await db.into(db.vaccinationSchedules).insert(
          VaccinationSchedulesCompanion.insert(
            id: newLocalId(),
            farmId: farmId,
            batchId: 'batch-1',
            vaccineName: 'Newcastle Vaccine',
            scheduledDate: DateTime(2026, 1, 10),
            status: const Value('COMPLETED'),
            synced: const Value(false),
          ),
        );

    final active = await repo.getAllInventory(
      farmId: farmId,
      filter: InventoryListFilter.active,
    );
    expect(active.map((e) => e.itemName), ['Grower Feed']);

    final usedUp = await repo.getAllInventory(
      farmId: farmId,
      filter: InventoryListFilter.usedUp,
    );
    expect(usedUp.map((e) => e.itemName), containsAll(['Empty Med', 'Newcastle Vaccine']));
    expect(await repo.getUsedUpInventoryCount(farmId), 2);
    expect(await repo.isItemUsedUp(
      (await (db.select(db.inventory)..where((t) => t.id.equals(oneTimeId))).getSingle()),
      farmId,
    ), isTrue);
  });

  test('usage history includes feed logs and non-cancelled health schedules', () async {
    final feedId = await seedInventory(
      name: 'Layer Mash',
      category: kFeedInventoryCategory,
      stock: 10,
    );
    await seedInventory(
      name: 'Tylosin',
      category: kMedicineInventoryCategory,
      stock: 3,
      usageType: 'QUANTITY',
    );

    await db.into(db.batches).insert(
          BatchesCompanion.insert(
            id: 'batch-1',
            farmId: farmId,
            batchName: const Value('Layers A'),
            arrivalDate: DateTime(2026, 1, 1),
            currentCount: 100,
            initialCount: 100,
            synced: const Value(false),
          ),
        );

    await db.into(db.feedingLogs).insert(
          FeedingLogsCompanion.insert(
            id: newLocalId(),
            farmId: farmId,
            batchId: const Value('batch-1'),
            feedTypeId: Value(feedId),
            amountConsumed: 2.5,
            logDate: DateTime(2026, 2, 1, 8),
            synced: const Value(false),
          ),
        );

    await db.into(db.medicationSchedules).insert(
          MedicationSchedulesCompanion.insert(
            id: newLocalId(),
            farmId: farmId,
            batchId: 'batch-1',
            medicationName: 'Tylosin',
            scheduledDate: DateTime(2026, 2, 2),
            status: const Value('PENDING'),
            quantity: const Value(1),
            synced: const Value(false),
          ),
        );

    await db.into(db.medicationSchedules).insert(
          MedicationSchedulesCompanion.insert(
            id: newLocalId(),
            farmId: farmId,
            batchId: 'batch-1',
            medicationName: 'Tylosin',
            scheduledDate: DateTime(2026, 1, 1),
            status: const Value('CANCELLED'),
            quantity: const Value(1),
            synced: const Value(false),
          ),
        );

    final feedDetail = await repo.getInventoryItemWithUsage(farmId, feedId);
    expect(feedDetail!.usageEvents, hasLength(1));
    expect(feedDetail.usageEvents.first.kind, InventoryUsageKind.feed);
    expect(feedDetail.usageEvents.first.batchName, 'Layers A');

    final medItem = await (db.select(db.inventory)
          ..where((t) => t.itemName.equals('Tylosin')))
        .getSingle();
    final medDetail = await repo.getInventoryItemWithUsage(farmId, medItem.id);
    expect(medDetail!.usageEvents, hasLength(1));
    expect(medDetail.usageEvents.first.kind, InventoryUsageKind.medication);
    expect(medDetail.usageEvents.first.status, 'PENDING');
  });

  test('normalizeHealthInventoryStock caps one-time health stock at 1', () {
    expect(
      normalizeHealthInventoryStock(
        category: kVaccineInventoryCategory,
        usageType: 'ONE_TIME',
        stockLevel: 50,
      ),
      1,
    );
    expect(
      normalizeHealthInventoryStock(
        category: kFeedInventoryCategory,
        usageType: 'ONE_TIME',
        stockLevel: 50,
      ),
      50,
    );
  });

  test('category filter matches medicine and vaccine separately', () {
    expect(matchesInventoryCategoryFilter('MEDICINE', kMedicineInventoryCategory), isTrue);
    expect(matchesInventoryCategoryFilter('VACCINE', kMedicineInventoryCategory), isFalse);
    expect(matchesInventoryCategoryFilter('EQUIPMENT', kOtherInventoryCategory), isTrue);
  });
}
