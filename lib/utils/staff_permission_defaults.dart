/// Web-parity staff roles for farm team management (not platform admin).
const assignableStaffRoles = <String>[
  'WORKER',
  'CASHIER',
  'MANAGER',
  'ACCOUNTANT',
  'FINANCE_OFFICER',
];

const _allPermissionKeys = <String>{
  'can_view_finance',
  'can_edit_finance',
  'can_view_inventory',
  'can_edit_inventory',
  'can_view_batches',
  'can_edit_batches',
  'can_view_sales',
  'can_edit_sales',
  'can_view_eggs',
  'can_edit_eggs',
  'can_view_feeding',
  'can_edit_feeding',
  'can_view_houses',
  'can_edit_houses',
  'can_view_mortality',
  'can_edit_mortality',
  'can_view_health',
  'can_edit_health',
  'can_view_customers',
  'can_edit_customers',
  'can_view_team',
  'can_edit_team',
};

const _workerPreset = <String>{
  'can_view_eggs',
  'can_edit_eggs',
  'can_view_feeding',
  'can_edit_feeding',
  'can_view_mortality',
  'can_edit_mortality',
  'can_view_health',
  'can_edit_health',
  'can_view_batches',
};

const _managerPreset = <String>{..._allPermissionKeys};

const _accountantPreset = <String>{
  'can_view_finance',
  'can_edit_finance',
  'can_view_sales',
  'can_view_inventory',
};

const _financeOfficerPreset = <String>{
  'can_view_finance',
  'can_edit_finance',
  'can_view_sales',
  'can_edit_sales',
  'can_view_inventory',
};

const _cashierPreset = <String>{
  'can_view_sales',
  'can_edit_sales',
  'can_view_finance',
};

String normalizeStaffRole(String role) {
  final cleaned = role.trim().toUpperCase();
  switch (cleaned) {
    case 'MANAGER':
    case 'ACCOUNTANT':
    case 'FINANCE_OFFICER':
    case 'CASHIER':
    case 'WORKER':
      return cleaned;
    default:
      return 'WORKER';
  }
}

Set<String> defaultPermissionsForRole(String role) {
  switch (normalizeStaffRole(role)) {
    case 'MANAGER':
      return {..._managerPreset};
    case 'ACCOUNTANT':
      return {..._accountantPreset};
    case 'FINANCE_OFFICER':
      return {..._financeOfficerPreset};
    case 'CASHIER':
      return {..._cashierPreset};
    case 'WORKER':
    default:
      return {..._workerPreset};
  }
}

Set<String> applyPermissionToggle(
  Set<String> current,
  String key,
  bool enabled,
) {
  final next = {...current};
  if (enabled) {
    next.add(key);
    if (key.startsWith('can_edit_')) {
      next.add(key.replaceFirst('can_edit_', 'can_view_'));
    }
  } else {
    next.remove(key);
    if (key.startsWith('can_view_')) {
      next.remove(key.replaceFirst('can_view_', 'can_edit_'));
    }
  }
  return next;
}

String formatRoleLabel(String? role) {
  if (role == null || role.trim().isEmpty) {
    return 'Unknown';
  }
  return role
      .trim()
      .toUpperCase()
      .split('_')
      .map((part) {
        if (part.isEmpty) {
          return part;
        }
        return part[0] + part.substring(1).toLowerCase();
      })
      .join(' ');
}
