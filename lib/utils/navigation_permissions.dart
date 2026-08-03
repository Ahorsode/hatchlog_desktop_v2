const _navPermissionMap = <String, List<String>>{
  'Finance Control': ['can_view_finance', 'can_edit_finance'],
  'Finance Hub': ['can_view_finance', 'can_edit_finance'],
  'Reports': ['can_view_finance', 'can_edit_finance'],
  'Reports & Logs': ['can_view_finance', 'can_edit_finance'],
  'Livestock': ['can_view_batches', 'can_edit_batches'],
  'Analytics': ['can_view_batches', 'can_edit_batches'],
  'Inventory': ['can_view_inventory', 'can_edit_inventory'],
  'Sales': ['can_view_sales', 'can_edit_sales'],
  'Eggs': ['can_view_eggs', 'can_edit_eggs'],
  'Feeding': ['can_view_feeding', 'can_edit_feeding'],
  'Houses': ['can_view_houses', 'can_edit_houses'],
  'Mortality': ['can_view_mortality', 'can_edit_mortality'],
  'Quarantine': ['can_view_mortality', 'can_edit_mortality'],
  'Health': ['can_view_health', 'can_edit_health'],
  'Customers': ['can_view_customers', 'can_edit_customers'],
  'Suppliers': ['can_view_customers', 'can_edit_customers'],
  'Team Management': ['can_view_team', 'can_edit_team'],
  'Team': ['can_view_team', 'can_edit_team'],
};

bool canShowNavigationItem({
  required String name,
  required String? role,
  required List<String> roles,
  Set<String>? permissions,
}) {
  final normalizedRole = role?.trim().toUpperCase();
  if (normalizedRole == 'OWNER' || normalizedRole == 'MANAGER') {
    return true;
  }
  if (normalizedRole == null ||
      normalizedRole.isEmpty ||
      !roles.map((r) => r.toUpperCase()).contains(normalizedRole)) {
    return false;
  }

  final permissionKeys = _navPermissionMap[name];
  if (permissionKeys == null) {
    return true;
  }
  if (permissions == null || permissions.isEmpty) {
    return false;
  }

  return permissionKeys.any(permissions.contains);
}

bool canViewTeamModule({
  required String role,
  required Set<String> permissions,
}) {
  final normalized = role.trim().toUpperCase();
  if (normalized == 'OWNER' || normalized == 'MANAGER') {
    return true;
  }
  return permissions.contains('can_view_team') ||
      permissions.contains('can_edit_team');
}

bool canEditTeamModule({
  required String role,
  required Set<String> permissions,
}) {
  final normalized = role.trim().toUpperCase();
  if (normalized == 'OWNER' || normalized == 'MANAGER') {
    return true;
  }
  return permissions.contains('can_edit_team');
}
