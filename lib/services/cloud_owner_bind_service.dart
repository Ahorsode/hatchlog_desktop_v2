import 'package:drift/drift.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../data/local_db.dart';
import '../utils/id_utils.dart';
import '../utils/user_role.dart';
import 'auth_service.dart';

const localProfileOwnerIdKey = 'LOCAL_PROFILE_OWNER_ID';

const _syncedUserIdTables = [
  'batches',
  'houses',
  'inventory',
  'daily_feeding_logs',
  'egg_production',
  'mortality',
  'weight_records',
  'sales',
  'expenses',
  'settlements',
];

const _plainUserIdTables = ['device_registrations'];

class CloudOwnerBindService {
  final AppDatabase db;

  CloudOwnerBindService(this.db);

  Future<String?> resolveCloudOwnerId(String farmId) async {
    final farmIdFilter = safeIdString(farmId);

    final farm = await (db.select(db.farms)
          ..where((f) => f.id.equals(farmIdFilter)))
        .getSingleOrNull();
    final fromFarm = farm?.userId.trim();
    if (fromFarm != null && fromFarm.isNotEmpty) {
      return safeIdString(fromFarm);
    }

    final ownerMember = await (db.select(db.farmMembers)
          ..where(
            (m) =>
                m.farmId.equals(farmIdFilter) &
                m.role.equals(UserRoleUtils.owner),
          )
          ..limit(1))
        .getSingleOrNull();
    if (ownerMember != null) {
      return safeIdString(ownerMember.userId);
    }

    final authUser = Supabase.instance.client.auth.currentUser;
    if (authUser != null && authUser.id.trim().isNotEmpty) {
      return safeIdString(authUser.id);
    }

    return null;
  }

  Future<String?> rebindLocalOwnerToCloud({
    required String farmId,
    String? localOwnerId,
  }) async {
    final farmIdFilter = safeIdString(farmId);
    final cloudOwnerId = await resolveCloudOwnerId(farmIdFilter);
    if (cloudOwnerId == null || cloudOwnerId.isEmpty) {
      debugPrint('[CloudOwnerBind] No cloud owner found for farm $farmIdFilter');
      return null;
    }

    final localId = safeIdString(
      localOwnerId ?? await _readLocalOwnerIdFromPrefs(),
    );
    if (localId.isEmpty || localId == cloudOwnerId) {
      await _persistOwnerSession(cloudOwnerId);
      return cloudOwnerId;
    }

    debugPrint(
      '[CloudOwnerBind] Rebinding local owner $localId -> cloud owner $cloudOwnerId',
    );

    await db.transaction(() async {
      await db.customStatement('PRAGMA foreign_keys = OFF;');
      try {
        for (final table in _syncedUserIdTables) {
          await db.customStatement(
            'UPDATE $table SET user_id = ?, synced = 0 '
            'WHERE farm_id = ? AND user_id = ?',
            [cloudOwnerId, farmIdFilter, localId],
          );
        }

        for (final table in _plainUserIdTables) {
          await db.customStatement(
            'UPDATE $table SET user_id = ? WHERE farm_id = ? AND user_id = ?',
            [cloudOwnerId, farmIdFilter, localId],
          );
        }

        await db.customStatement(
          'DELETE FROM farm_members WHERE farm_id = ? AND user_id = ?',
          [farmIdFilter, localId],
        );

        final cloudMember = await (db.select(db.farmMembers)
              ..where(
                (m) =>
                    m.farmId.equals(farmIdFilter) &
                    m.userId.equals(cloudOwnerId),
              ))
            .getSingleOrNull();
        if (cloudMember == null) {
          await db.into(db.farmMembers).insert(
                FarmMembersCompanion.insert(
                  id: newLocalId(),
                  farmId: farmIdFilter,
                  userId: cloudOwnerId,
                  role: const Value('OWNER'),
                  synced: const Value(true),
                ),
              );
        }

        final cloudUser = await (db.select(db.users)
              ..where((u) => u.id.equals(cloudOwnerId)))
            .getSingleOrNull();
        if (cloudUser != null) {
          await db.customStatement('DELETE FROM users WHERE id = ?', [localId]);
        }

        await (db.update(db.licenseConfigs)
              ..where((c) => c.id.equals('singleton')))
            .write(LicenseConfigsCompanion(userId: Value(cloudOwnerId)));
      } finally {
        await db.customStatement('PRAGMA foreign_keys = ON;');
      }
    });

    await _persistOwnerSession(cloudOwnerId);
    return cloudOwnerId;
  }

  Future<String> _readLocalOwnerIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(localProfileOwnerIdKey)?.trim() ??
        prefs.getString('owner_id')?.trim() ??
        prefs.getString('user_id')?.trim() ??
        '';
  }

  Future<void> _persistOwnerSession(String cloudOwnerId) async {
    final owner = await (db.select(db.users)
          ..where((u) => u.id.equals(cloudOwnerId)))
        .getSingleOrNull();

    final role = UserRoleUtils.normalize(owner?.role ?? 'OWNER');
    final displayName = owner?.name?.trim().isNotEmpty == true
        ? owner!.name!.trim()
        : (owner?.email?.trim().isNotEmpty == true
            ? owner!.email!.trim()
            : 'Farm Owner');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(localProfileOwnerIdKey, cloudOwnerId);
    await prefs.setString('owner_id', cloudOwnerId);
    await prefs.setString('user_id', cloudOwnerId);
    await prefs.setString('user_email', owner?.email ?? '');
    await prefs.setString('user_name', displayName);
    await prefs.setString('user_role', role);
    await prefs.setBool('is_bound', true);

    UserSession().startSession(id: cloudOwnerId, name: displayName, role: role);
    await UserSession().persistToPrefs();
  }

  Future<User?> cloudOwnerUser(String farmId) async {
    final cloudOwnerId = await resolveCloudOwnerId(farmId);
    if (cloudOwnerId == null) return null;
    return (db.select(db.users)..where((u) => u.id.equals(cloudOwnerId)))
        .getSingleOrNull();
  }
}

/// Maps offline genesis owner id → cloud owner id for sync push only.
///
/// Workers/managers log in with the same phone + password as the web app, so
/// their local `users.id` is already the cloud id and is not remapped here.
class CloudUserIdMapService {
  final AppDatabase db;

  CloudUserIdMapService(this.db);

  final Map<String, String> _cache = {};

  Future<void> rebuildForFarm(String farmId) async {
    final farmIdFilter = farmId.trim();
    if (farmIdFilter.isEmpty) return;

    await (db.delete(db.cloudUserIdMappings)
          ..where((m) => m.farmId.equals(farmIdFilter)))
        .go();
    _cache.clear();

    final members = await (db.select(db.farmMembers)
          ..where((m) => m.farmId.equals(farmIdFilter)))
        .get();

    String? cloudOwnerId;
    for (final member in members) {
      if (UserRoleUtils.normalize(member.role) != UserRoleUtils.owner) {
        continue;
      }
      final id = member.userId.trim();
      if (id.isNotEmpty) {
        cloudOwnerId = id;
        break;
      }
    }
    if (cloudOwnerId == null) {
      debugPrint(
        '[CloudUserIdMap] no cloud owner in farm_members for $farmIdFilter',
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final localOwnerId = prefs.getString(localProfileOwnerIdKey)?.trim();
    if (localOwnerId == null || localOwnerId.isEmpty) {
      debugPrint('[CloudUserIdMap] no local owner id in prefs');
      return;
    }
    if (localOwnerId == cloudOwnerId) {
      debugPrint('[CloudUserIdMap] owner ids already aligned');
      return;
    }

    await _upsertMapping(
      farmId: farmIdFilter,
      localUserId: localOwnerId,
      cloudUserId: cloudOwnerId,
      matchKey: 'owner',
    );

    debugPrint(
      '[CloudUserIdMap] owner map $localOwnerId -> $cloudOwnerId (farm $farmIdFilter)',
    );
  }

  Future<void> _upsertMapping({
    required String farmId,
    required String localUserId,
    required String cloudUserId,
    String? matchKey,
  }) async {
    if (localUserId == cloudUserId) return;
    await db.into(db.cloudUserIdMappings).insertOnConflictUpdate(
          CloudUserIdMappingsCompanion.insert(
            localUserId: localUserId,
            cloudUserId: cloudUserId,
            farmId: farmId,
            matchKey: Value(matchKey),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
    _cache[localUserId] = cloudUserId;
  }

  Future<void> warmCacheForFarm(String farmId) async {
    _cache.clear();
    final rows = await (db.select(db.cloudUserIdMappings)
          ..where((m) => m.farmId.equals(farmId.trim())))
        .get();
    for (final row in rows) {
      _cache[row.localUserId] = row.cloudUserId;
    }
  }

  /// Remaps only when [localUserId] (or [sessionUserId] if null) is the offline owner.
  String? resolveForPush(String? localUserId, {String? sessionUserId}) {
    final raw = localUserId?.trim();
    if (raw != null && raw.isNotEmpty) {
      return _cache[raw] ?? raw;
    }
    final session = sessionUserId?.trim();
    if (session == null || session.isEmpty) return null;
    return _cache[session] ?? session;
  }
}