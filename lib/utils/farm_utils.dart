import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/local_db.dart';
import 'id_utils.dart';
import '../services/auth_service.dart';
import 'user_role.dart';

class FarmUtils {
  static const _farmIdKey = 'bound_farm_id';
  static const localGenesisFarmId = 'local_genesis_farm';
  static const localGenesisFarmName = 'Local Offline Farm';
  static const localOnlySyncStatus = 'LOCAL_ONLY';

  /// Returns the bound farm Cuid2 (migrates legacy integer prefs).
  static Future<String?> getBoundFarmId() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_farmIdKey)) {
      final stored = prefs.get(_farmIdKey);
      if (stored is String && stored.trim().isNotEmpty) {
        return stored.trim();
      }
      if (stored is int) {
        final migrated = stored.toString();
        await prefs.setString(_farmIdKey, migrated);
        return migrated;
      }
    }
    if (prefs.getBool('LOCAL_PROFILE_ESTABLISHED') == true ||
        prefs.getBool('is_bound') == true) {
      await prefs.setString(_farmIdKey, localGenesisFarmId);
      return localGenesisFarmId;
    }
    return null;
  }

  static Future<void> setBoundFarmId(String farmId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_farmIdKey, safeIdString(farmId));
  }

  static Future<void> ensureLocalGenesisFarm(
    AppDatabase db, {
    required String ownerId,
  }) async {
    await db
        .into(db.farms)
        .insertOnConflictUpdate(
          FarmsCompanion.insert(
            id: localGenesisFarmId,
            name: localGenesisFarmName,
            capacity: 0,
            userId: ownerId,
            subscriptionTier: const Value(localOnlySyncStatus),
            syncStatus: const Value(localOnlySyncStatus),
          ),
        );
    await setBoundFarmId(localGenesisFarmId);
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  static Future<bool> canViewFinancials() async {
    final role = await getUserRole();
    return UserRoleUtils.canViewFinancials(role);
  }

  static Future<String?> getUserId() async {
    final inMemory = UserSession().currentWorkerId;
    if (inMemory != null && inMemory.trim().isNotEmpty) {
      return inMemory.trim();
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  static Future<String> getRequiredUserId() async {
    final userId = await getUserId();
    if (userId == null || userId.trim().isEmpty) {
      throw Exception(
        'Security Exception: No active worker detected for validation stamp.',
      );
    }
    return userId.trim();
  }
}
