import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'local_db.g.dart';

// 1. Users Table (Aligned with Supabase)
@DataClassName('User')
class Users extends Table {
  @override
  String get tableName => 'users';

  TextColumn get id => text()();
  TextColumn get firstname => text().nullable()();
  TextColumn get surname => text().nullable()();
  TextColumn get middleName => text().nullable()();
  TextColumn get name => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get image => text().nullable()();
  TextColumn get password => text().nullable()();
  TextColumn get phoneNumber => text().nullable()();
  BoolColumn get mustChangePassword =>
      boolean().withDefault(const Constant(false))();
  TextColumn get role => text().withDefault(const Constant('OWNER'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// 1.7. Profiles Table (Worker provisioning: pending → active on mobile registration)
@DataClassName('Profile')
class Profiles extends Table {
  @override
  String get tableName => 'profiles';

  TextColumn get id => text()();
  TextColumn get farmId => text()();
  TextColumn get phoneNumber => text()();
  TextColumn get role => text().withDefault(const Constant('WORKER'))();
  TextColumn get firstName => text().nullable()();
  TextColumn get lastName => text().nullable()();
  TextColumn get status => text().withDefault(
    const Constant('PENDING'),
  )(); // PENDING, ACTIVE, INACTIVE
  TextColumn get customPermissionsJson =>
      text().nullable()(); // JSON array of permission keys
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// 1.5. User Permissions (pulled from cloud `user_permissions`)
@DataClassName('UserPermission')
class UserPermissions extends Table {
  @override
  String get tableName => 'user_permissions';

  TextColumn get id => text()();
  TextColumn get farmId => text()();
  TextColumn get userId => text()();
  TextColumn get permissionKey => text()();
  BoolColumn get allowed => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// 2. Farms Table
@DataClassName('Farm')
class Farms extends Table {
  @override
  String get tableName => 'farms';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get location => text().nullable()();
  IntColumn get capacity => integer()();
  TextColumn get userId => text()();
  TextColumn get subscriptionTier =>
      text().withDefault(const Constant('FREE'))();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('CLOUD_SYNCED'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// 3. Batches Table
@DataClassName('Batch')
class Batches extends Table {
  @override
  String get tableName => 'batches';

  TextColumn get id => text()();
  TextColumn get farmId => text()();
  TextColumn get houseId => text().nullable()();
  TextColumn get userId => text().nullable()();
  TextColumn get batchName => text().withDefault(const Constant('New Batch'))();
  TextColumn get type =>
      text().withDefault(const Constant('POULTRY_BROILER'))();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get breedType => text().nullable()();
  DateTimeColumn get arrivalDate => dateTime()();
  IntColumn get currentCount => integer()();
  IntColumn get initialCount => integer()();
  IntColumn get isolationCount => integer().withDefault(const Constant(0))();
  RealColumn get initialActualCost => real().nullable()();
  TextColumn get growthTarget => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// 4. Inventory Table
@DataClassName('InventoryItem')
class Inventory extends Table {
  @override
  String get tableName => 'inventory';

  TextColumn get id => text()();
  TextColumn get farmId => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get itemName => text()();
  RealColumn get stockLevel => real()();
  RealColumn get reorderLevel => real().nullable()();
  TextColumn get unit => text()();
  TextColumn get category => text().nullable()();
  RealColumn get costPerUnit => real().nullable()();
  TextColumn get eggCategoryId => text().nullable()();
  TextColumn get usageType => text().nullable()();
  TextColumn get supplierId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// 5. Feeding Logs
@DataClassName('FeedingLog')
class FeedingLogs extends Table {
  @override
  String get tableName => 'daily_feeding_logs';

  TextColumn get id => text()();
  TextColumn get farmId => text()();
  TextColumn get batchId => text().nullable()();
  TextColumn get feedTypeId => text().nullable()();
  TextColumn get formulationId => text().nullable()();
  RealColumn get amountConsumed => real()();
  DateTimeColumn get logDate => dateTime()();
  TextColumn get userId => text().nullable()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// 6. Egg Production
@DataClassName('EggProduction')
class EggProductions extends Table {
  @override
  String get tableName => 'egg_production';

  TextColumn get id => text()();
  TextColumn get farmId => text()();
  TextColumn get batchId => text()();
  TextColumn get categoryId => text().nullable()();
  IntColumn get eggsCollected => integer()();
  IntColumn get unusableCount => integer().withDefault(const Constant(0))();
  IntColumn get eggsRemaining => integer().withDefault(const Constant(0))();
  RealColumn get cratesCollected => real().nullable()();
  TextColumn get qualityGrade => text().nullable()();
  BoolColumn get isSorted => boolean().withDefault(const Constant(false))();
  IntColumn get smallCount => integer().withDefault(const Constant(0))();
  IntColumn get mediumCount => integer().withDefault(const Constant(0))();
  IntColumn get largeCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get logDate => dateTime()();
  TextColumn get userId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// 7. Mortality
@DataClassName('Mortality')
class Mortalities extends Table {
  @override
  String get tableName => 'mortality';

  TextColumn get id => text()();
  TextColumn get farmId => text()();
  TextColumn get batchId => text()();
  IntColumn get count => integer()();
  TextColumn get reason => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get subCategory => text().nullable()();
  TextColumn get healthType =>
      text().named('type').withDefault(const Constant('DEAD'))();
  TextColumn get isolationRoomId =>
      text().nullable().named('isolation_room_id')();
  DateTimeColumn get logDate => dateTime()();
  TextColumn get userId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// 8. Houses
@DataClassName('House')
class Houses extends Table {
  @override
  String get tableName => 'houses';

  TextColumn get id => text()();
  TextColumn get farmId => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get name => text()();
  IntColumn get capacity => integer()();
  RealColumn get currentTemperature => real().nullable()();
  RealColumn get currentHumidity => real().nullable()();
  BoolColumn get isIsolation => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// 9. Customers
@DataClassName('Customer')
class Customers extends Table {
  @override
  String get tableName => 'customers';

  TextColumn get id => text()();
  TextColumn get farmId => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  RealColumn get balanceOwed => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get customerType =>
      text().withDefault(const Constant('CUSTOMER'))();
  TextColumn get supplyItems => text().nullable()();
  TextColumn get contactPerson => text().nullable()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// 10. Farm Settings
@DataClassName('FarmSetting')
class FarmSettings extends Table {
  @override
  String get tableName => 'farm_settings';

  TextColumn get id => text()();
  TextColumn get farmId => text()();
  TextColumn get currency => text().withDefault(const Constant('GHS'))();
  TextColumn get eggRecordReminderTime => text().nullable()();
  TextColumn get feedRecordReminderTime => text().nullable()();
  IntColumn get growthTargetStandard => integer().nullable()();
  IntColumn get eggsPerCrate => integer().withDefault(const Constant(30))();
  BoolColumn get synced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

// 11. Weight Records
@DataClassName('WeightRecord')
class WeightRecords extends Table {
  @override
  String get tableName => 'weight_records';

  TextColumn get id => text()();
  TextColumn get farmId => text()();
  TextColumn get batchId => text()();
  RealColumn get averageWeight => real()();
  DateTimeColumn get logDate => dateTime()();
  TextColumn get userId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// 12. Device Registrations (Hardware Binding)
@DataClassName('DeviceRegistration')
class DeviceRegistrations extends Table {
  @override
  String get tableName => 'device_registrations';

  TextColumn get id => text()();
  TextColumn get farmId => text()();
  TextColumn get userId => text()();
  TextColumn get deviceIdentifier => text()();
  TextColumn get deviceName => text().nullable()();
  DateTimeColumn get registeredAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// 13. Owner-only local ↔ cloud user id mapping (offline genesis owner → cloud owner)
@DataClassName('CloudUserIdMapping')
class CloudUserIdMappings extends Table {
  @override
  String get tableName => 'cloud_user_id_mappings';

  /// Local owner id (offline onboarding / genesis farm)
  TextColumn get localUserId => text()();

  /// Cloud owner `users.id` from pulled farm_members
  TextColumn get cloudUserId => text()();

  TextColumn get farmId => text()();

  /// Email or username used to link local ↔ cloud (audit / debug)
  TextColumn get matchKey => text().nullable()();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {localUserId};
}

// 14. Farm Members
@DataClassName('FarmMember')
class FarmMembers extends Table {
  @override
  String get tableName => 'farm_members';

  TextColumn get id => text()();
  TextColumn get farmId => text()();
  TextColumn get userId => text()();
  TextColumn get role => text().withDefault(const Constant('WORKER'))();
  DateTimeColumn get joinedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// 14. Feed Formulations (ingredient stock lives in `inventory` with category FEED)
@DataClassName('FeedFormulation')
class FeedFormulations extends Table {
  @override
  String get tableName => 'feed_formulations';

  TextColumn get id => text()();
  TextColumn get farmId => text()();
  TextColumn get name => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get type => text().withDefault(const Constant('CUSTOM'))();
  TextColumn get targetLivestock => text().nullable()();
  RealColumn get stockLevel => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('FeedFormulationIngredient')
class FeedFormulationIngredients extends Table {
  @override
  String get tableName => 'feed_formulation_ingredients';

  TextColumn get id => text()();
  TextColumn get formulationId => text()();
  TextColumn get inventoryId => text()();
  RealColumn get quantity => real()();
  TextColumn get unit => text().withDefault(const Constant('bag'))();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// 16. Vaccination Schedules
@DataClassName('VaccinationSchedule')
class VaccinationSchedules extends Table {
  @override
  String get tableName => 'vaccination_schedules';

  TextColumn get id => text()();
  TextColumn get batchId => text()();
  TextColumn get vaccineName => text()();
  DateTimeColumn get scheduledDate => dateTime()();
  TextColumn get status => text().withDefault(const Constant('PENDING'))();
  TextColumn get notes => text().nullable()();
  RealColumn get quantity => real().withDefault(const Constant(1))();
  TextColumn get usageType => text().nullable()();
  TextColumn get unit => text().nullable()();
  TextColumn get farmId => text()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// 17. Medication Schedules
@DataClassName('MedicationSchedule')
class MedicationSchedules extends Table {
  @override
  String get tableName => 'medication_schedules';

  TextColumn get id => text()();
  TextColumn get batchId => text()();
  TextColumn get medicationName => text()();
  DateTimeColumn get scheduledDate => dateTime()();
  TextColumn get status => text().withDefault(const Constant('PENDING'))();
  TextColumn get notes => text().nullable()();
  RealColumn get quantity => real().withDefault(const Constant(1))();
  TextColumn get usageType => text().nullable()();
  TextColumn get unit => text().nullable()();
  TextColumn get farmId => text()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// 17b. Health Records
@DataClassName('HealthRecord')
class HealthRecords extends Table {
  @override
  String get tableName => 'health_records';

  TextColumn get id => text()();
  TextColumn get batchId => text().nullable()();
  TextColumn get recordType => text().nullable()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get recordDate => dateTime()();
  TextColumn get farmId => text()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// 18. Sales Table
@DataClassName('Sale')
class Sales extends Table {
  @override
  String get tableName => 'sales';

  TextColumn get id => text()();
  TextColumn get farmId => text()();
  TextColumn get batchId => text().nullable()();
  TextColumn get customerId => text().nullable()();
  IntColumn get quantity => integer()();
  RealColumn get unitPrice => real()();
  RealColumn get totalAmount => real()();
  DateTimeColumn get saleDate => dateTime().withDefault(currentDateAndTime)();
  TextColumn get userId => text().nullable()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// 19. Expenses
@DataClassName('Expense')
class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text()();
  TextColumn get batchId => text().nullable()();
  TextColumn get supplierId => text().nullable()();
  TextColumn get category => text()();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  TextColumn get description => text().nullable()();
  TextColumn get allocationGroupId => text().nullable()();
  RealColumn get allocationPercent => real().nullable()();
  BoolColumn get isSharedAllocation =>
      boolean().withDefault(const Constant(false))();
  TextColumn get userId => text().nullable()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// 20. Settlements (local ledger; cloud uses customers.balanceOwed + expenses)
@DataClassName('Settlement')
class Settlements extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text()();
  TextColumn get customerId => text()();
  RealColumn get amount => real()();
  DateTimeColumn get settlementDate =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get settlementType => text()();
  TextColumn get userId => text().nullable()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// 21. Pending Deletions
@DataClassName('PendingDeletion')
class PendingDeletions extends Table {
  TextColumn get id => text()();
  TextColumn get targetTableName => text()();
  TextColumn get recordId => text()();
  TextColumn get farmId => text()();
  DateTimeColumn get deletedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// 21. Stock Logs (local movement history; cloud uses inventory.stockLevel)
@DataClassName('StockLog')
class StockLogs extends Table {
  @override
  String get tableName => 'stock_logs';

  TextColumn get id => text()();
  TextColumn get farmId => text()();
  TextColumn get itemId => text()();
  RealColumn get quantity => real()();
  TextColumn get logType => text()();
  TextColumn get batchId => text().nullable()();
  TextColumn get supplierId => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get logDate => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// 22. License Configuration (singleton row – id always 'singleton')
@DataClassName('LicenseConfig')
class LicenseConfigs extends Table {
  @override
  String get tableName => 'license_configs';

  /// Always 'singleton' – only one row ever exists.
  TextColumn get id => text()();

  /// 'CLOUD_TRIAL' | 'CLOUD_ACTIVE' | 'EXPIRED' | 'HARD_LOCKED'
  TextColumn get mode => text().withDefault(const Constant('OFFLINE'))();

  /// Local SQLite farm_id (may be overwritten by webFarmId after cascade)
  TextColumn get farmId => text().nullable()();

  /// Cloud user id after authentication
  TextColumn get userId => text().nullable()();

  /// Hardware fingerprint for this machine
  TextColumn get hardwareId => text().nullable()();

  /// Timestamp when the app was first installed/activated
  DateTimeColumn get installedAt =>
      dateTime().withDefault(currentDateAndTime)();

  /// Timestamp when the license expires; compared on every boot
  DateTimeColumn get expiresAt => dateTime()();

  /// Updated on every DB write; used for anti-clock-tamper detection
  DateTimeColumn get lastUsed => dateTime().withDefault(currentDateAndTime)();

  /// Timestamp of the last successful cloud subscription check.
  /// Used for the 10-day offline tolerance window.
  /// Null means never successfully checked.
  DateTimeColumn get lastCloudCheckAt =>
      dateTime().named('last_cloud_check_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'poultry_pms.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(
  tables: [
    Users,
    Farms,
    Batches,
    Inventory,
    FeedingLogs,
    EggProductions,
    Mortalities,
    Houses,
    Customers,
    FarmSettings,
    WeightRecords,
    DeviceRegistrations,
    FarmMembers,
    CloudUserIdMappings,
    FeedFormulations,
    FeedFormulationIngredients,
    VaccinationSchedules,
    MedicationSchedules,
    HealthRecords,
    Sales,
    Expenses,
    Settlements,
    PendingDeletions,
    StockLogs,
    LicenseConfigs,
    UserPermissions,
    Profiles,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// In-memory database for tests (schema v15 string primary keys).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 30;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _ensureSalesLedgerTables(m);
      await _ensureFifoSalesLedgerTables(m);
    },
    onUpgrade: (m, from, to) async {
      if (from < 15) {
        for (final table in allTables) {
          await m.drop(table);
          await m.create(table);
        }
      } else {
        if (from < 10) {
          for (final table in allTables) {
            await m.drop(table);
            await m.create(table);
          }
        }
        if (from < 12) {
          await m.addColumn(customers, customers.supplyItems);
          await m.addColumn(customers, customers.contactPerson);
        }
        if (from < 13) {
          await m.createTable(expenses);
          await m.createTable(settlements);
        }
        if (from < 14) {
          await m.createTable(stockLogs);
        }
        if (from < 16) {
          // feed_types merged into inventory (cloud has no feed_types table)
          await m.database.customStatement('''
                INSERT OR IGNORE INTO inventory (
                  id, farm_id, item_name, stock_level, unit, category,
                  cost_per_unit, synced, created_at, updated_at
                )
                SELECT
                  id, farm_id, name, current_stock, 'kg', 'FEED',
                  cost_per_kg, synced, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
                FROM feed_types
                WHERE EXISTS (
                  SELECT 1 FROM sqlite_master
                  WHERE type = 'table' AND name = 'feed_types'
                )
              ''');
          try {
            await m.database.customStatement('DROP TABLE IF EXISTS feed_types');
          } catch (_) {}
        }
        if (from < 17) {
          await m.createTable(licenseConfigs);
        }
        if (from < 18) {
          await m.addColumn(farms, farms.syncStatus);
        }
        if (from < 19) {
          await m.createTable(cloudUserIdMappings);
        }
        if (from < 20) {
          await m.addColumn(expenses, expenses.batchId);
          await m.addColumn(expenses, expenses.supplierId);
          await m.addColumn(expenses, expenses.allocationGroupId);
          await m.addColumn(expenses, expenses.allocationPercent);
          await m.addColumn(expenses, expenses.isSharedAllocation);
        }
      }
      if (from < 22) {
        await _ensureProvisioningLocalTables(m);
      }
      if (from >= 17 && from < 23) {
        await m.addColumn(licenseConfigs, licenseConfigs.lastCloudCheckAt);
      }
      if (from < 24) {
        await m.addColumn(eggProductions, eggProductions.isSorted);
        await m.addColumn(eggProductions, eggProductions.smallCount);
        await m.addColumn(eggProductions, eggProductions.mediumCount);
        await m.addColumn(eggProductions, eggProductions.largeCount);
      }
      if (from < 25) {
        await m.addColumn(mortalities, mortalities.healthType);
        await m.addColumn(mortalities, mortalities.isolationRoomId);
        await m.database.customStatement('''
          UPDATE mortality
          SET type = 'SICK'
          WHERE upper(category) = 'ISOLATION'
        ''');
        await m.database.customStatement('''
          UPDATE mortality
          SET type = 'DEAD'
          WHERE type IS NULL OR trim(type) = ''
        ''');
      }
      if (from < 26) {
        await m.addColumn(inventory, inventory.usageType);
        await m.addColumn(vaccinationSchedules, vaccinationSchedules.quantity);
        await m.addColumn(vaccinationSchedules, vaccinationSchedules.usageType);
        await m.addColumn(vaccinationSchedules, vaccinationSchedules.unit);
        await m.addColumn(medicationSchedules, medicationSchedules.quantity);
        await m.addColumn(medicationSchedules, medicationSchedules.usageType);
        await m.addColumn(medicationSchedules, medicationSchedules.unit);
        await m.createTable(healthRecords);
      }
      if (from < 27) {
        await _ensureSalesLedgerTables(m);
      }
      if (from < 28) {
        await _ensureEggCategoryTables(m);
        await m.addColumn(inventory, inventory.eggCategoryId);
      }
      if (from < 29) {
        await _ensureFifoSalesLedgerTables(m);
      }
      if (from < 30) {
        await _ensureFeedFormulationParityTables(m);
        await m.createTable(feedFormulationIngredients);
      }
    },
  );
}

Future<void> _ensureFeedFormulationParityTables(Migrator m) async {
  await m.database.customStatement('''
    CREATE TABLE IF NOT EXISTS feed_formulations_new (
      id TEXT NOT NULL PRIMARY KEY,
      farm_id TEXT NOT NULL,
      name TEXT NOT NULL,
      notes TEXT,
      type TEXT NOT NULL DEFAULT 'CUSTOM',
      target_livestock TEXT,
      stock_level REAL NOT NULL DEFAULT 0,
      created_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', 'now') AS INTEGER) * 1000000),
      updated_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', 'now') AS INTEGER) * 1000000),
      synced INTEGER NOT NULL DEFAULT 0 CHECK (synced IN (0, 1))
    )
  ''');

  await m.database.customStatement('''
    INSERT OR IGNORE INTO feed_formulations_new (
      id, farm_id, name, notes, type, stock_level, synced
    )
    SELECT
      id,
      farm_id,
      name,
      description,
      'CUSTOM',
      0,
      synced
    FROM feed_formulations
  ''');

  await m.database.customStatement('DROP TABLE IF EXISTS feed_formulations');
  await m.database.customStatement(
    'ALTER TABLE feed_formulations_new RENAME TO feed_formulations',
  );
}

Future<void> _ensureEggCategoryTables(Migrator m) async {
  await m.database.customStatement('''
    CREATE TABLE IF NOT EXISTS egg_categories (
      id TEXT NOT NULL PRIMARY KEY,
      farm_id TEXT NOT NULL,
      name TEXT NOT NULL,
      selling_price REAL NOT NULL DEFAULT 0,
      unit_size INTEGER NOT NULL DEFAULT 30
    )
  ''');
}

Future<void> _ensureFifoSalesLedgerTables(Migrator m) async {
  await m.database.customStatement('''
    CREATE TABLE IF NOT EXISTS orders (
      id TEXT NOT NULL PRIMARY KEY,
      farm_id TEXT NOT NULL,
      customer_id TEXT,
      invoice_number INTEGER,
      subtotal_amount REAL NOT NULL DEFAULT 0,
      tax_amount REAL NOT NULL DEFAULT 0,
      total_amount REAL NOT NULL,
      cash_received REAL NOT NULL DEFAULT 0,
      currency TEXT NOT NULL DEFAULT 'GHS',
      status TEXT NOT NULL DEFAULT 'PENDING',
      discount_amount REAL NOT NULL DEFAULT 0,
      payment_method TEXT,
      payment_reference TEXT,
      payment_account_name TEXT,
      order_date TEXT NOT NULL,
      paid_at TEXT,
      user_id TEXT NOT NULL,
      is_deleted INTEGER NOT NULL DEFAULT 0,
      deleted_at TEXT,
      created_at TEXT,
      updated_at TEXT
    )
  ''');

  await m.database.customStatement('''
    CREATE TABLE IF NOT EXISTS order_items (
      id TEXT NOT NULL PRIMARY KEY,
      order_id TEXT NOT NULL,
      description TEXT NOT NULL,
      quantity INTEGER NOT NULL,
      unit_price REAL NOT NULL,
      total_price REAL NOT NULL,
      inventory_id TEXT,
      livestock_id TEXT,
      egg_allocation_mode TEXT,
      egg_batch_id TEXT,
      line_discount_amount REAL NOT NULL DEFAULT 0,
      line_discount_type TEXT,
      egg_quantity_unit TEXT
    )
  ''');

  await m.database.customStatement('''
    CREATE TABLE IF NOT EXISTS order_item_batch_allocations (
      id TEXT NOT NULL PRIMARY KEY,
      order_item_id TEXT NOT NULL,
      batch_id TEXT NOT NULL,
      farm_id TEXT NOT NULL,
      eggs_used INTEGER NOT NULL,
      revenue_amount REAL NOT NULL,
      created_at TEXT,
      updated_at TEXT
    )
  ''');

  final columns = [
    ('financial_transactions', 'order_id', 'TEXT'),
    ('sale_items', 'egg_allocation_mode', 'TEXT'),
    ('sale_items', 'egg_batch_id', 'TEXT'),
    ('sale_items', 'line_discount_amount', 'REAL NOT NULL DEFAULT 0'),
    ('sale_items', 'line_discount_type', "TEXT NOT NULL DEFAULT 'flat'"),
    ('sale_items', 'egg_quantity_unit', 'TEXT'),
  ];
  for (final entry in columns) {
    try {
      await m.database.customStatement(
        'ALTER TABLE ${entry.$1} ADD COLUMN ${entry.$2} ${entry.$3}',
      );
    } catch (_) {}
  }
}

Future<void> _ensureSalesLedgerTables(Migrator m) async {
  await m.database.customStatement('''
    CREATE TABLE IF NOT EXISTS sale_items (
      id TEXT NOT NULL PRIMARY KEY,
      sale_id TEXT NOT NULL,
      description TEXT NOT NULL,
      quantity INTEGER NOT NULL,
      unit_price REAL NOT NULL,
      total_price REAL NOT NULL,
      farm_id TEXT NOT NULL,
      inventory_id TEXT,
      livestock_id TEXT,
      synced INTEGER NOT NULL DEFAULT 0 CHECK (synced IN (0, 1))
    )
  ''');

  await m.database.customStatement('''
    CREATE TABLE IF NOT EXISTS financial_transactions (
      id TEXT NOT NULL PRIMARY KEY,
      farm_id TEXT NOT NULL,
      user_id TEXT,
      type TEXT NOT NULL,
      category TEXT NOT NULL,
      amount REAL NOT NULL,
      payment_status TEXT NOT NULL,
      payment_method TEXT,
      reference_num TEXT,
      transaction_date TEXT NOT NULL,
      description TEXT,
      customer_id TEXT,
      deposit_amount REAL NOT NULL DEFAULT 0,
      outstanding_credit REAL NOT NULL DEFAULT 0,
      expense_outlay REAL NOT NULL DEFAULT 0,
      is_deleted INTEGER NOT NULL DEFAULT 0,
      settled_at TEXT,
      created_at TEXT,
      updated_at TEXT,
      synced INTEGER NOT NULL DEFAULT 0 CHECK (synced IN (0, 1))
    )
  ''');
}

Future<void> _ensureProvisioningLocalTables(Migrator m) async {
  await m.database.customStatement('''
    CREATE TABLE IF NOT EXISTS user_permissions (
      id TEXT NOT NULL PRIMARY KEY,
      farm_id TEXT NOT NULL,
      user_id TEXT NOT NULL,
      permission_key TEXT NOT NULL,
      allowed INTEGER NOT NULL DEFAULT 1 CHECK (allowed IN (0, 1)),
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      synced INTEGER NOT NULL DEFAULT 0 CHECK (synced IN (0, 1))
    )
  ''');

  await m.database.customStatement('''
    CREATE TABLE IF NOT EXISTS profiles (
      id TEXT NOT NULL PRIMARY KEY,
      farm_id TEXT NOT NULL,
      phone_number TEXT NOT NULL,
      role TEXT NOT NULL DEFAULT 'WORKER',
      first_name TEXT,
      last_name TEXT,
      status TEXT NOT NULL DEFAULT 'PENDING',
      custom_permissions_json TEXT,
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      synced INTEGER NOT NULL DEFAULT 0 CHECK (synced IN (0, 1))
    )
  ''');
}
