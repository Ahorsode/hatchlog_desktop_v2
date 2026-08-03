import 'package:drift/drift.dart' hide Column, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poultry_pms_desktop/data/local_db.dart';
import 'package:poultry_pms_desktop/services/cloud_owner_bind_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase db;
  late CloudOwnerBindService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      localProfileOwnerIdKey: 'local_owner_id',
      'user_id': 'local_owner_id',
    });
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    service = CloudOwnerBindService(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('rebindLocalOwnerToCloud rewrites batch user_id and prefs', () async {
    const farmId = 'cloud_farm_id';
    const localOwnerId = 'local_owner_id';
    const cloudOwnerId = 'cloud_owner_id';
    const batchId = 'batch_1';

    await db.into(db.farms).insert(
          FarmsCompanion.insert(
            id: farmId,
            name: 'Cloud Farm',
            capacity: 1000,
            userId: cloudOwnerId,
          ),
        );
    await db.into(db.users).insert(
          UsersCompanion.insert(
            id: cloudOwnerId,
            name: const Value('Cloud Owner'),
            role: const Value('OWNER'),
          ),
        );
    await db.into(db.users).insert(
          UsersCompanion.insert(
            id: localOwnerId,
            name: const Value('Local Owner'),
            role: const Value('OWNER'),
          ),
        );
    await db.into(db.batches).insert(
          BatchesCompanion.insert(
            id: batchId,
            farmId: farmId,
            userId: const Value(localOwnerId),
            arrivalDate: DateTime.utc(2025, 1, 1),
            currentCount: 100,
            initialCount: 100,
            synced: const Value(true),
          ),
        );

    final result = await service.rebindLocalOwnerToCloud(
      farmId: farmId,
      localOwnerId: localOwnerId,
    );

    expect(result, cloudOwnerId);

    final batch = await (db.select(db.batches)
          ..where((t) => t.id.equals(batchId)))
        .getSingle();
    expect(batch.userId, cloudOwnerId);
    expect(batch.synced, false);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('user_id'), cloudOwnerId);
    expect(prefs.getString(localProfileOwnerIdKey), cloudOwnerId);

    final localUser = await (db.select(db.users)
          ..where((t) => t.id.equals(localOwnerId)))
        .getSingleOrNull();
    expect(localUser, isNull);
  });
}
