import 'package:flutter_test/flutter_test.dart';
import 'package:poultry_pms_desktop/utils/settings_profile_contract.dart';

void main() {
  group('Settings profile contract — farm settings', () {
    test('defaults match web FarmSettings model', () {
      expect(SettingsProfileContract.defaultCurrency, 'GHS');
      expect(SettingsProfileContract.defaultEggsPerCrate, 30);
      expect(SettingsProfileContract.defaultEggReminder, '18:00');
      expect(SettingsProfileContract.defaultFeedReminder, '18:00');
    });

    test('currency normalization matches web', () {
      expect(SettingsProfileContract.normalizeCurrency('GHC'), 'GHS');
      expect(SettingsProfileContract.normalizeCurrency('NGN'), 'NGN');
    });
  });

  group('Settings profile contract — trash', () {
    test('remote tables align with web trash-actions prisma maps', () {
      final tables = SettingsProfileContract.trashTabs
          .map((tab) => tab.remoteTable)
          .toList();
      expect(tables, containsAll([
        'batches',
        'egg_production',
        'daily_feeding_logs',
        'mortality',
        'expenses',
        'sales',
        'orders',
        'inventory',
      ]));
    });

    test('mortality restore is disabled', () {
      expect(SettingsProfileContract.canRestoreTrashTab('mortality'), isFalse);
      expect(SettingsProfileContract.canRestoreTrashTab('inventory'), isTrue);
    });
  });

  group('Settings profile contract — profile edit', () {
    test('profile name validation matches web EditProfileModal', () {
      expect(
        SettingsProfileContract.validateProfileNames(
          firstName: 'Jo',
          surname: 'Smith',
        ),
        isNull,
      );
      expect(
        SettingsProfileContract.validateProfileNames(
          firstName: 'J',
          surname: 'Smith',
        ),
        isNotNull,
      );
    });
  });
}
