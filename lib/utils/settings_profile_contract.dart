/// Shared data contract aligned with web `SettingsContent`, profile page, and trash.
class SettingsProfileContract {
  SettingsProfileContract._();

  static const defaultEggReminder = '18:00';
  static const defaultFeedReminder = '18:00';
  static const defaultCurrency = 'GHS';
  static const defaultEggsPerCrate = 30;
  static const defaultReorderLevelKg = 500.0;

  static const currencyOptions = <String, String>{
    'GHS': 'Ghanaian Cedi (GHS)',
    'USD': 'US Dollar (USD)',
    'NGN': 'Nigerian Naira (NGN)',
    'KES': 'Kenyan Shilling (KES)',
  };

  static const trashTabs = <TrashTabDefinition>[
    TrashTabDefinition(
      key: 'batches',
      label: 'Batches',
      remoteTable: 'batches',
      restoreAllowed: true,
    ),
    TrashTabDefinition(
      key: 'eggProduction',
      label: 'Egg Logs',
      remoteTable: 'egg_production',
      restoreAllowed: true,
    ),
    TrashTabDefinition(
      key: 'feedingLogs',
      label: 'Feed Logs',
      remoteTable: 'daily_feeding_logs',
      restoreAllowed: true,
    ),
    TrashTabDefinition(
      key: 'mortality',
      label: 'Mortality',
      remoteTable: 'mortality',
      restoreAllowed: false,
    ),
    TrashTabDefinition(
      key: 'expenses',
      label: 'Expenses',
      remoteTable: 'expenses',
      restoreAllowed: true,
    ),
    TrashTabDefinition(
      key: 'sales',
      label: 'Sales',
      remoteTable: 'sales',
      restoreAllowed: true,
    ),
    TrashTabDefinition(
      key: 'orders',
      label: 'Orders',
      remoteTable: 'orders',
      restoreAllowed: true,
    ),
    TrashTabDefinition(
      key: 'inventory',
      label: 'Inventory',
      remoteTable: 'inventory',
      restoreAllowed: true,
    ),
  ];

  static TrashTabDefinition? tabByKey(String key) {
    for (final tab in trashTabs) {
      if (tab.key == key) return tab;
    }
    return null;
  }

  static bool canRestoreTrashTab(String key) =>
      tabByKey(key)?.restoreAllowed ?? false;

  static String normalizeCurrency(String? raw) {
    if (raw == null || raw.trim().isEmpty) return defaultCurrency;
    final value = raw.trim().toUpperCase();
    if (value == 'GH₵' || value == 'GHC') return 'GHS';
    return currencyOptions.containsKey(value) ? value : defaultCurrency;
  }

  static String? validateProfileNames({
    required String firstName,
    required String surname,
  }) {
    if (firstName.trim().length < 2) {
      return 'First name is required';
    }
    if (surname.trim().length < 2) {
      return 'Surname is required';
    }
    return null;
  }

  static String buildDisplayName({
    required String firstName,
    String? middleName,
    required String surname,
  }) {
    final middle = middleName?.trim();
    if (middle != null && middle.isNotEmpty) {
      return '${firstName.trim()} $middle ${surname.trim()}';
    }
    return '${firstName.trim()} ${surname.trim()}';
  }
}

class TrashTabDefinition {
  const TrashTabDefinition({
    required this.key,
    required this.label,
    required this.remoteTable,
    required this.restoreAllowed,
  });

  final String key;
  final String label;
  final String remoteTable;
  final bool restoreAllowed;
}

class FarmSettingsData {
  const FarmSettingsData({
    required this.farmId,
    required this.farmName,
    required this.farmLocation,
    required this.farmCapacity,
    required this.currency,
    required this.eggsPerCrate,
    required this.eggRecordReminderTime,
    required this.feedRecordReminderTime,
    this.growthTargetStandard,
  });

  final String farmId;
  final String farmName;
  final String farmLocation;
  final int farmCapacity;
  final String currency;
  final int eggsPerCrate;
  final String eggRecordReminderTime;
  final String feedRecordReminderTime;
  final int? growthTargetStandard;

  factory FarmSettingsData.defaults({required String farmId}) {
    return FarmSettingsData(
      farmId: farmId,
      farmName: '',
      farmLocation: '',
      farmCapacity: 0,
      currency: SettingsProfileContract.defaultCurrency,
      eggsPerCrate: SettingsProfileContract.defaultEggsPerCrate,
      eggRecordReminderTime: SettingsProfileContract.defaultEggReminder,
      feedRecordReminderTime: SettingsProfileContract.defaultFeedReminder,
    );
  }
}

class ProfileEditData {
  const ProfileEditData({
    required this.firstName,
    this.middleName = '',
    required this.surname,
    required this.email,
    required this.roleLabel,
  });

  final String firstName;
  final String middleName;
  final String surname;
  final String email;
  final String roleLabel;
}
