import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/local_db.dart';
import 'navigation_permissions.dart';
import 'secure_auth_storage.dart';
import 'staff_permission_defaults.dart';

/// Resolves effective worker permission flags from local cache + secure storage.
Future<Set<String>> loadWorkerPermissions(AppDatabase db) async {
  final prefs = await SharedPreferences.getInstance();
  final role = prefs.getString('user_role') ?? 'OWNER';
  final normalized = normalizeStaffRole(role);
  if (normalized == 'MANAGER' || role.toUpperCase() == 'OWNER') {
    return defaultPermissionsForRole(normalized);
  }

  final userId = prefs.getString('user_id') ?? '';
  final sources = <String?>[
    await SecureAuthStorage.getWorkerPermissionsJson(),
  ];

  if (userId.isNotEmpty) {
    final rows = await (db.select(db.userPermissions)
          ..where((p) => p.userId.equals(userId)))
        .get();
    sources.add(
      jsonEncode(
        rows
            .where((permission) => permission.allowed)
            .map((permission) => permission.permissionKey)
            .toList(),
      ),
    );
  }

  final decoded = <String>{};
  for (final source in sources) {
    if (source == null || source.trim().isEmpty) continue;
    try {
      final value = jsonDecode(source);
      if (value is List) {
        decoded.addAll(value.map((item) => item.toString()));
      }
    } catch (_) {}
  }

  if (decoded.isEmpty) {
    return defaultPermissionsForRole(normalized);
  }
  return decoded;
}

bool canViewReports({
  required String? role,
  required Set<String> permissions,
}) {
  return canShowNavigationItem(
    name: 'Reports',
    role: role,
    roles: assignableStaffRoles,
    permissions: permissions,
  );
}
