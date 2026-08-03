import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poultry_pms_desktop/data/local_db.dart';
import 'package:poultry_pms_desktop/services/cloud_owner_bind_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      localProfileOwnerIdKey: 'local-owner',
      'user_id': 'local-owner',
    });
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
  });

  tearDown(() async {
    await db.close();
  });

  test('rebuild maps offline owner id to cloud owner only', () async {
    const farmId = 'farm_cloud';
    const cloudOwnerId = 'cloud-owner-id';

    await db.into(db.users).insert(
          UsersCompanion.insert(
            id: cloudOwnerId,
            email: const Value('owner@farm.test'),
            synced: const Value(true),
          ),
        );
    await db.into(db.farmMembers).insert(
          FarmMembersCompanion.insert(
            id: 'member-owner',
            farmId: farmId,
            userId: cloudOwnerId,
            role: const Value('OWNER'),
            synced: const Value(true),
          ),
        );

    final service = CloudUserIdMapService(db);
    await service.rebuildForFarm(farmId);

    expect(service.resolveForPush('local-owner'), cloudOwnerId);
    expect(service.resolveForPush(cloudOwnerId), cloudOwnerId);
  });

  test('does not remap worker ids even when email matches cloud user', () async {
    const farmId = 'farm_cloud';
    const cloudWorkerId = 'cloud-worker-id';
    const localWorkerId = 'local-worker-id';

    await db.into(db.users).insert(
          UsersCompanion.insert(
            id: cloudWorkerId,
            email: const Value('worker@farm.test'),
            role: const Value('WORKER'),
            synced: const Value(true),
          ),
        );
    await db.into(db.users).insert(
          UsersCompanion.insert(
            id: localWorkerId,
            email: const Value('worker@farm.test'),
            role: const Value('WORKER'),
            synced: const Value(false),
          ),
        );
    await db.into(db.farmMembers).insert(
          FarmMembersCompanion.insert(
            id: 'member-worker',
            farmId: farmId,
            userId: cloudWorkerId,
            role: const Value('WORKER'),
            synced: const Value(true),
          ),
        );

    final service = CloudUserIdMapService(db);
    await service.rebuildForFarm(farmId);

    expect(service.resolveForPush(localWorkerId), localWorkerId);
    expect(service.resolveForPush(cloudWorkerId), cloudWorkerId);
  });
}
