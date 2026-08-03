import 'dart:async';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../data/local_db.dart';
import '../utils/farm_utils.dart';
import '../utils/id_utils.dart';

/// All possible license states the app can be in at boot time.
enum LicenseStatus {
  /// First ever launch - no install record found.
  firstLaunch,

  /// License is valid (trial or active paid subscription).
  valid,

  /// Subscription expired, within the 5-day soft-lock window.
  /// App still fully works but shows a prominent banner.
  softLocked,

  /// Subscription expired by more than 5 days AND offline tolerance
  /// window (10 days since last cloud check) is also exhausted.
  /// Shows full lockout screen, app is not accessible.
  hardLocked,

  /// System clock was rolled back past last_used - fraud lockdown.
  clockTampered,
}

/// Tables that carry a `farm_id` column and need to be cascade-updated
/// when a local farm_id is overwritten by the cloud web_farm_id.
const _farmIdChildTables = [
  'batches',
  'inventory',
  'daily_feeding_logs',
  'egg_production',
  'mortality',
  'houses',
  'customers',
  'farm_settings',
  'weight_records',
  'device_registrations',
  'farm_members',
  'feed_formulations',
  'vaccination_schedules',
  'medication_schedules',
  'sales',
  'expenses',
  'settlements',
  'pending_deletions',
  'stock_logs',
  'license_configs',
];

/// Single source of truth for all licensing operations.
class LicenseService {
  final AppDatabase _db;

  LicenseService(this._db);

  // -------------------------------------------------------------------------
  // BOOT CHECK
  // -------------------------------------------------------------------------

  Future<LicenseStatus> checkLicense() async {
    final config = await _loadConfig();
    if (config == null) return LicenseStatus.firstLaunch;

    final now = DateTime.now();

    // Anti-clock-tamper
    if (now.isBefore(config.lastUsed.subtract(const Duration(minutes: 2)))) {
      debugPrint(
        '[License] CLOCK TAMPER: now=$now lastUsed=${config.lastUsed}',
      );
      return LicenseStatus.clockTampered;
    }

    if (config.mode == 'HARD_LOCKED') {
      return LicenseStatus.hardLocked;
    }

    // Still within subscription period -> valid.
    if (now.isBefore(config.expiresAt)) {
      return LicenseStatus.valid;
    }

    // Past expires_at: check offline tolerance first.
    final lastCheck = config.lastCloudCheckAt;
    if (lastCheck != null) {
      final daysSinceCheck = now.difference(lastCheck).inDays;
      if (daysSinceCheck < 10) {
        return LicenseStatus.valid;
      }
    }

    final daysPastExpiry = now.difference(config.expiresAt).inDays;

    if (daysPastExpiry <= 5) {
      return LicenseStatus.softLocked;
    }

    await _setMode('HARD_LOCKED');
    return LicenseStatus.hardLocked;
  }

  // -------------------------------------------------------------------------
  // CLOUD TRIAL REGISTRATION
  // -------------------------------------------------------------------------

  /// Registers this device on Supabase via RPC and persists a 30-day
  /// CLOUD_TRIAL license locally. Idempotent - safe to call again if the
  /// device is already registered.
  ///
  /// Returns null on success, or an error string.
  Future<String?> initTrialFromCloud({
    required String userId,
    required String farmId,
    required String hardwareId,
  }) async {
    try {
      final result = await Supabase.instance.client.rpc(
        'register_device_trial',
        params: {
          'p_user_id': userId,
          'p_farm_id': farmId,
          'p_hardware_id': hardwareId,
          'p_device_name': 'Flutter Desktop',
          'p_device_type': 'Desktop',
        },
      );

      if (result == null) {
        return 'Trial registration returned no data.';
      }

      final data = Map<String, dynamic>.from(result as Map);

      if (data['success'] != true) {
        final errorCode = data['error_code']?.toString() ?? '';

        if (errorCode == 'TRIAL_EXHAUSTED') {
          final now = DateTime.now();
          await _upsertConfig(
            mode: 'HARD_LOCKED',
            farmId: farmId,
            userId: userId,
            hardwareId: hardwareId,
            installedAt: now,
            expiresAt: now.subtract(const Duration(days: 36)),
            lastCloudCheckAt: now,
          );
          debugPrint(
            '[License] TRIAL_EXHAUSTED - farm has no remaining trial.',
          );
          return 'TRIAL_EXHAUSTED';
        }

        return data['error']?.toString() ?? 'Trial registration failed.';
      }

      final rawExpiry = data['license_expires_at'];
      final expiresAt = rawExpiry != null
          ? DateTime.tryParse(rawExpiry.toString()) ??
                DateTime.now().add(const Duration(days: 30))
          : DateTime.now().add(const Duration(days: 30));

      await _upsertConfig(
        mode: 'CLOUD_TRIAL',
        farmId: farmId,
        userId: userId,
        hardwareId: hardwareId,
        installedAt: DateTime.now(),
        expiresAt: expiresAt,
        lastCloudCheckAt: DateTime.now(),
      );

      debugPrint('[License] Trial registered. Expires: $expiresAt');
      return null;
    } catch (e) {
      debugPrint('[License] initTrialFromCloud error: $e');
      await _upsertConfig(
        mode: 'CLOUD_TRIAL',
        farmId: farmId,
        userId: userId,
        hardwareId: hardwareId,
        installedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 30)),
        lastCloudCheckAt: null,
      );
      return null;
    }
  }

  // -------------------------------------------------------------------------
  // CLOUD SUBSCRIPTION STATUS CHECK
  // -------------------------------------------------------------------------

  /// Called on every boot (when online) and every 6 hours while the app runs.
  /// Fetches current subscription status from Supabase and syncs locally.
  /// Stamps last_cloud_check_at on every successful contact with the server.
  Future<void> renewFromCloud(String hardwareId) async {
    try {
      final result = await Supabase.instance.client.rpc(
        'get_device_subscription_status',
        params: {'p_hardware_id': hardwareId},
      );

      if (result == null) return;

      final data = Map<String, dynamic>.from(result as Map);
      if (data['success'] != true) {
        debugPrint('[License] Status check failed: ${data['error']}');
        return;
      }

      final rawExpiry = data['license_expires_at'];
      final statusStr = data['license_status']?.toString();
      final serverExpiry = rawExpiry != null
          ? DateTime.tryParse(rawExpiry.toString())
          : null;
      final trialExhausted = data['trial_exhausted'] == true;
      final serverMode = statusStr != null
          ? _serverStatusToLocalMode(statusStr)
          : null;
      final isActive = serverMode == 'CLOUD_ACTIVE';

      final now = DateTime.now();
      final config = await _loadConfig();
      if (config == null) return;

      if (trialExhausted && !isActive) {
        await _setMode('HARD_LOCKED');
        debugPrint(
          '[License] Server reports trial exhausted - forcing hard lock.',
        );
        return;
      }

      LicenseConfigsCompanion update = LicenseConfigsCompanion(
        lastUsed: Value(now),
        lastCloudCheckAt: Value(now),
      );

      if (serverExpiry != null && serverExpiry.isAfter(config.expiresAt)) {
        update = update.copyWith(expiresAt: Value(serverExpiry));
        debugPrint('[License] Renewed expiry to $serverExpiry from cloud.');
      }

      if (serverMode != null) {
        update = update.copyWith(mode: Value(serverMode));
      }

      await (_db.update(
        _db.licenseConfigs,
      )..where((t) => t.id.equals('singleton'))).write(update);
    } catch (e) {
      debugPrint('[License] Cloud renewal skipped (offline?): $e');
    }
  }

  String _serverStatusToLocalMode(String serverStatus) {
    switch (serverStatus) {
      case 'ACTIVE':
      case 'PAID_STANDARD':
      case 'PAID_PREMIUM':
        return 'CLOUD_ACTIVE';
      case 'CLOUD_TRIAL':
        return 'CLOUD_TRIAL';
      case 'EXPIRED':
      case 'TRIAL_EXPIRED':
        return 'EXPIRED';
      case 'REVOKED':
        return 'HARD_LOCKED';
      default:
        debugPrint('[License] Unrecognised server status: $serverStatus');
        return 'CLOUD_TRIAL';
    }
  }

  // -------------------------------------------------------------------------
  // ANTI-CLOCK-TAMPER STAMP
  // -------------------------------------------------------------------------

  /// Call this on every local DB write operation to keep `last_used` fresh.
  /// If the clock is later rolled back, `checkLicense()` will catch it.
  Future<void> touchLastUsed() async {
    try {
      await (_db.update(_db.licenseConfigs)
            ..where((t) => t.id.equals('singleton')))
          .write(LicenseConfigsCompanion(lastUsed: Value(DateTime.now())));
    } catch (_) {
      // Silent - license row may not exist yet on very first boot.
    }
  }

  // -------------------------------------------------------------------------
  // FARM ID CASCADE MIGRATION ENGINE
  // -------------------------------------------------------------------------

  /// Rewrites `farm_id` on child tables without changing the parent `farms` row.
  Future<void> remapFarmIdReferences(String fromFarmId, String toFarmId) async {
    final from = safeIdString(fromFarmId);
    final to = safeIdString(toFarmId);
    if (from == to) return;

    for (final tableName in _farmIdChildTables) {
      await _db.customStatement(
        'UPDATE $tableName SET farm_id = ? WHERE farm_id = ?',
        [to, from],
      );
    }
  }

  /// Ensures local rows and [FarmUtils] binding use [webFarmId] before cloud sync.
  Future<void> reconcileToCloudFarmId(String webFarmId) async {
    final web = safeIdString(webFarmId);
    final bound = await FarmUtils.getBoundFarmId();
    final config = await _loadConfig();
    final configFarmId = config?.farmId?.trim();

    final localSources = <String>{
      FarmUtils.localGenesisFarmId,
      if (bound != null && bound.isNotEmpty) bound,
      if (configFarmId != null && configFarmId.isNotEmpty) configFarmId,
    }..remove(web);

    final cloudFarmExists = await (_db.select(
      _db.farms,
    )..where((f) => f.id.equals(web))).getSingleOrNull();

    for (final local in localSources) {
      final localFarm = await (_db.select(
        _db.farms,
      )..where((f) => f.id.equals(local))).getSingleOrNull();

      if (localFarm == null) {
        await remapFarmIdReferences(local, web);
        continue;
      }

      if (cloudFarmExists != null) {
        await mergeLocalFarmIntoCloud(localFarmId: local, webFarmId: web);
      } else {
        await runFarmIdCascade(localFarmId: local, webFarmId: web);
      }
      return;
    }

    await FarmUtils.setBoundFarmId(web);
  }

  /// Moves child rows from [localFarmId] to an existing cloud [webFarmId] row.
  Future<void> mergeLocalFarmIntoCloud({
    required String localFarmId,
    required String webFarmId,
  }) async {
    final local = safeIdString(localFarmId);
    final web = safeIdString(webFarmId);
    if (local == web) return;

    debugPrint(
      '[License] Merging local farm $local into existing cloud farm $web',
    );

    await _db.transaction(() async {
      await _db.customStatement('PRAGMA foreign_keys = OFF;');
      try {
        for (final tableName in _farmIdChildTables) {
          await _db.customStatement(
            'UPDATE $tableName SET farm_id = ? WHERE farm_id = ?',
            [web, local],
          );
        }
        await _db.customStatement('DELETE FROM farms WHERE id = ?', [local]);
      } finally {
        await _db.customStatement('PRAGMA foreign_keys = ON;');
      }
    });

    await FarmUtils.setBoundFarmId(web);
  }

  /// Renames the local `farms` primary key to [webFarmId] when cloud row is absent.
  Future<void> runFarmIdCascade({
    required String localFarmId,
    required String webFarmId,
  }) async {
    debugPrint('[License] Running farm_id cascade: $localFarmId -> $webFarmId');

    await _db.transaction(() async {
      await _db.customStatement('PRAGMA foreign_keys = OFF;');

      try {
        await _db.customStatement(
          'UPDATE farms SET id = ?, sync_status = ? WHERE id = ?',
          [webFarmId, 'CLOUD_SYNCED', localFarmId],
        );

        for (final tableName in _farmIdChildTables) {
          await _db.customStatement(
            'UPDATE $tableName SET farm_id = ? WHERE farm_id = ?',
            [webFarmId, localFarmId],
          );
        }

        debugPrint('[License] Cascade complete for $localFarmId -> $webFarmId');
      } finally {
        await _db.customStatement('PRAGMA foreign_keys = ON;');
      }
    });

    await FarmUtils.setBoundFarmId(webFarmId);
  }

  // -------------------------------------------------------------------------
  // HELPERS
  // -------------------------------------------------------------------------

  Future<LicenseConfig?> _loadConfig() async {
    return (_db.select(
      _db.licenseConfigs,
    )..where((t) => t.id.equals('singleton'))).getSingleOrNull();
  }

  Future<void> _upsertConfig({
    required String mode,
    required String? farmId,
    required String? userId,
    required String? hardwareId,
    required DateTime installedAt,
    required DateTime expiresAt,
    DateTime? lastCloudCheckAt,
  }) async {
    final now = DateTime.now();
    await _db
        .into(_db.licenseConfigs)
        .insertOnConflictUpdate(
          LicenseConfigsCompanion.insert(
            id: 'singleton',
            mode: Value(mode),
            farmId: Value(farmId),
            userId: Value(userId),
            hardwareId: Value(hardwareId),
            installedAt: Value(installedAt),
            expiresAt: expiresAt,
            lastUsed: Value(now),
            lastCloudCheckAt: Value(lastCloudCheckAt),
          ),
        );
  }

  Future<void> _setMode(String mode) async {
    await (_db.update(
      _db.licenseConfigs,
    )..where((t) => t.id.equals('singleton'))).write(
      LicenseConfigsCompanion(
        mode: Value(mode),
        lastUsed: Value(DateTime.now()),
      ),
    );
  }

  /// Reads the persisted license config. Exposed for UI inspection.
  Future<LicenseConfig?> getConfig() => _loadConfig();
}
