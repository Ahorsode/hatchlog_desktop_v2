import 'package:flutter_test/flutter_test.dart';
import 'package:poultry_pms_desktop/utils/navigation_permissions.dart';
import 'package:poultry_pms_desktop/utils/staff_permission_defaults.dart';

void main() {
  group('Team contract — staff permission defaults', () {
    test('worker defaults match web poultry-pms', () {
      final defaults = defaultPermissionsForRole('WORKER');
      expect(defaults.contains('can_view_eggs'), isTrue);
      expect(defaults.contains('can_edit_eggs'), isTrue);
      expect(defaults.contains('can_view_sales'), isFalse);
      expect(defaults.contains('can_view_houses'), isFalse);
    });

    test('manager defaults include all permission keys', () {
      final defaults = defaultPermissionsForRole('MANAGER');
      expect(defaults.contains('can_view_finance'), isTrue);
      expect(defaults.contains('can_edit_team'), isTrue);
    });

    test('finance officer defaults match web', () {
      final defaults = defaultPermissionsForRole('FINANCE_OFFICER');
      expect(defaults.contains('can_edit_finance'), isTrue);
      expect(defaults.contains('can_edit_sales'), isTrue);
      expect(defaults.contains('can_view_inventory'), isTrue);
      expect(defaults.contains('can_edit_inventory'), isFalse);
    });

    test('permission toggle enforces view before edit', () {
      var permissions = defaultPermissionsForRole('MANAGER');
      permissions = applyPermissionToggle(
        permissions,
        'can_view_sales',
        false,
      );
      expect(permissions.contains('can_view_sales'), isFalse);
      expect(permissions.contains('can_edit_sales'), isFalse);
    });
  });

  group('Team contract — navigation permissions', () {
    test('reports map to finance permissions', () {
      expect(
        canShowNavigationItem(
          name: 'Reports',
          role: 'ACCOUNTANT',
          roles: const ['OWNER', 'MANAGER', 'ACCOUNTANT'],
          permissions: const {'can_view_finance'},
        ),
        isTrue,
      );
      expect(
        canShowNavigationItem(
          name: 'Reports & Logs',
          role: 'WORKER',
          roles: const ['OWNER', 'MANAGER', 'WORKER'],
          permissions: const {},
        ),
        isFalse,
      );
    });

    test('team module gates use can_view_team / can_edit_team', () {
      expect(
        canViewTeamModule(
          role: 'WORKER',
          permissions: const {'can_view_team'},
        ),
        isTrue,
      );
      expect(
        canEditTeamModule(
          role: 'WORKER',
          permissions: const {'can_view_team'},
        ),
        isFalse,
      );
    });
  });
}
