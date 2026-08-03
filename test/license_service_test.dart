import 'package:drift/drift.dart' hide Column, isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poultry_pms_desktop/data/local_db.dart';
import 'package:poultry_pms_desktop/services/license_service.dart';
import 'package:poultry_pms_desktop/utils/farm_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase db;
  late LicenseService licenseService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    licenseService = LicenseService(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedLicense({
    String mode = 'CLOUD_TRIAL',
    String? farmId = 'farm_id',
    String? userId = 'user_id',
    String? hardwareId = 'hardware_id',
    DateTime? installedAt,
    DateTime? expiresAt,
    DateTime? lastUsed,
    DateTime? lastCloudCheckAt,
  }) async {
    final now = DateTime.now();
    await db
        .into(db.licenseConfigs)
        .insert(
          LicenseConfigsCompanion.insert(
            id: 'singleton',
            mode: Value(mode),
            farmId: Value(farmId),
            userId: Value(userId),
            hardwareId: Value(hardwareId),
            installedAt: Value(installedAt ?? now),
            expiresAt: expiresAt ?? now.add(const Duration(days: 30)),
            lastUsed: Value(lastUsed ?? now),
            lastCloudCheckAt: Value(lastCloudCheckAt),
          ),
        );
  }

  test('checkLicense returns firstLaunch when empty', () async {
    final status = await licenseService.checkLicense();
    expect(status, LicenseStatus.firstLaunch);
  });

  test('checkLicense returns valid for an active cloud trial config', () async {
    await seedLicense();

    final config = await licenseService.getConfig();
    expect(config, isNotNull);
    expect(config!.id, 'singleton');
    expect(config.mode, 'CLOUD_TRIAL');
    expect(config.farmId, 'farm_id');
    expect(config.userId, 'user_id');
    expect(config.hardwareId, 'hardware_id');
    expect(config.expiresAt.difference(config.installedAt).inDays, 30);

    final status = await licenseService.checkLicense();
    expect(status, LicenseStatus.valid);
  });

  test('touchLastUsed updates lastUsed timestamp', () async {
    await seedLicense();

    // Explicitly set lastUsed to 10 seconds in the past
    final pastTime = DateTime.now().subtract(const Duration(seconds: 10));
    await (db.update(db.licenseConfigs)..where((t) => t.id.equals('singleton')))
        .write(LicenseConfigsCompanion(lastUsed: Value(pastTime)));

    await licenseService.touchLastUsed();

    final newConfig = await licenseService.getConfig();
    expect(newConfig!.lastUsed.isAfter(pastTime), isTrue);
  });

  test(
    'checkLicense returns clockTampered when system clock is rolled back',
    () async {
      await seedLicense();

      // Directly update lastUsed to the future in DB to simulate clock rollback
      final futureTime = DateTime.now().add(const Duration(minutes: 10));
      await (db.update(db.licenseConfigs)
            ..where((t) => t.id.equals('singleton')))
          .write(LicenseConfigsCompanion(lastUsed: Value(futureTime)));

      final status = await licenseService.checkLicense();
      expect(status, LicenseStatus.clockTampered);
    },
  );

  test(
    'checkLicense returns hardLocked after soft lock and offline tolerance expire',
    () async {
      final now = DateTime.now();
      await seedLicense(
        expiresAt: now.subtract(const Duration(days: 6)),
        lastCloudCheckAt: now.subtract(const Duration(days: 11)),
      );

      final status = await licenseService.checkLicense();
      expect(status, LicenseStatus.hardLocked);

      final config = await licenseService.getConfig();
      expect(config!.mode, 'HARD_LOCKED');
    },
  );

  test('checkLicense returns hardLocked when mode is HARD_LOCKED', () async {
    await seedLicense(
      mode: 'HARD_LOCKED',
      expiresAt: DateTime.now().add(const Duration(days: 30)),
    );

    final status = await licenseService.checkLicense();
    expect(status, LicenseStatus.hardLocked);
  });

  test('runFarmIdCascade cascades farm_id update across tables', () async {
    const localFarmId = 'local_farm_id';
    await db
        .into(db.farms)
        .insert(
          FarmsCompanion.insert(
            id: localFarmId,
            name: 'My Local Farm',
            capacity: 500,
            userId: 'local_user',
          ),
        );

    const batchId = 'batch_id';
    await db
        .into(db.batches)
        .insert(
          BatchesCompanion.insert(
            id: batchId,
            farmId: localFarmId,
            arrivalDate: DateTime.now(),
            currentCount: 100,
            initialCount: 100,
          ),
        );

    const houseId = 'house_id';
    await db
        .into(db.houses)
        .insert(
          HousesCompanion.insert(
            id: houseId,
            farmId: localFarmId,
            name: 'House A',
            capacity: 100,
          ),
        );

    await db
        .into(db.licenseConfigs)
        .insert(
          LicenseConfigsCompanion.insert(
            id: 'singleton',
            mode: const Value('PURE_OFFLINE'),
            farmId: const Value(localFarmId),
            installedAt: Value(DateTime.now()),
            expiresAt: DateTime.now().add(const Duration(days: 30)),
            lastUsed: Value(DateTime.now()),
          ),
        );

    const webFarmId = 'web_farm_id';
    await licenseService.runFarmIdCascade(
      localFarmId: localFarmId,
      webFarmId: webFarmId,
    );

    final farm = await (db.select(
      db.farms,
    )..where((t) => t.id.equals(webFarmId))).getSingleOrNull();
    expect(farm, isNotNull);
    final oldFarm = await (db.select(
      db.farms,
    )..where((t) => t.id.equals(localFarmId))).getSingleOrNull();
    expect(oldFarm, isNull);

    final batch = await (db.select(
      db.batches,
    )..where((t) => t.id.equals(batchId))).getSingle();
    expect(batch.farmId, webFarmId);

    final house = await (db.select(
      db.houses,
    )..where((t) => t.id.equals(houseId))).getSingle();
    expect(house.farmId, webFarmId);

    final config = await licenseService.getConfig();
    expect(config!.farmId, webFarmId);
  });

  test(
    'mergeLocalFarmIntoCloud merges genesis when cloud farm already exists',
    () async {
      const localFarmId = FarmUtils.localGenesisFarmId;
      const webFarmId = 'web_farm_id';
      const houseId = 'house_id';

      await db
          .into(db.farms)
          .insert(
            FarmsCompanion.insert(
              id: localFarmId,
              name: 'Local Offline Farm',
              capacity: 0,
              userId: 'local_user',
            ),
          );
      await db
          .into(db.farms)
          .insert(
            FarmsCompanion.insert(
              id: webFarmId,
              name: 'Cloud Farm',
              capacity: 1000,
              userId: 'cloud_user',
            ),
          );
      await db
          .into(db.houses)
          .insert(
            HousesCompanion.insert(
              id: houseId,
              farmId: localFarmId,
              name: 'House A',
              capacity: 100,
            ),
          );

      await licenseService.mergeLocalFarmIntoCloud(
        localFarmId: localFarmId,
        webFarmId: webFarmId,
      );

      final genesisFarm = await (db.select(
        db.farms,
      )..where((t) => t.id.equals(localFarmId))).getSingleOrNull();
      expect(genesisFarm, isNull);

      final house = await (db.select(
        db.houses,
      )..where((t) => t.id.equals(houseId))).getSingle();
      expect(house.farmId, webFarmId);
    },
  );
}
