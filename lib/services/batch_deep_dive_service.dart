import 'package:drift/drift.dart' hide Batch;
import 'package:intl/intl.dart';

import '../data/local_db.dart';
import '../models/batch_deep_dive_models.dart';
import '../utils/farm_utils.dart';
import '../utils/mortality_log_utils.dart';
import '../utils/user_role.dart';
import 'batch_consumption_finance.dart';
import 'batch_finance_service.dart';
import 'batch_revenue_service.dart';
import 'ledger_allocation_service.dart';

class BatchDeepDiveService {
  BatchDeepDiveService(this._db);

  final AppDatabase _db;

  Future<BatchDeepDivePayload?> load(String batchId, String farmId) async {
    final batch = await (_db.select(_db.batches)
          ..where((t) => t.id.equals(batchId) & t.farmId.equals(farmId)))
        .getSingleOrNull();
    if (batch == null) return null;

    final role = await FarmUtils.getUserRole();
    final normalizedRole = UserRoleUtils.normalize(role);
    final canViewFinance = UserRoleUtils.canViewFinancials(role);
    final canEditFinance = canViewFinance &&
        (normalizedRole == UserRoleUtils.owner ||
            normalizedRole == UserRoleUtils.manager ||
            normalizedRole == UserRoleUtils.financial);
    final canEditHealth = normalizedRole == UserRoleUtils.owner ||
        normalizedRole == UserRoleUtils.manager ||
        normalizedRole == UserRoleUtils.operational;

    final house = batch.houseId == null
        ? null
        : await (_db.select(_db.houses)
              ..where((t) => t.id.equals(batch.houseId!)))
            .getSingleOrNull();

    final feedingLogs = await (_db.select(_db.feedingLogs)
          ..where((t) => t.batchId.equals(batchId))
          ..orderBy([(t) => OrderingTerm.desc(t.logDate)]))
        .get();
    final mortalities = await (_db.select(_db.mortalities)
          ..where((t) => t.batchId.equals(batchId))
          ..orderBy([(t) => OrderingTerm.desc(t.logDate)]))
        .get();
    final eggProduction = await (_db.select(_db.eggProductions)
          ..where((t) => t.batchId.equals(batchId))
          ..orderBy([(t) => OrderingTerm.desc(t.logDate)]))
        .get();
    final weightRecords = await (_db.select(_db.weightRecords)
          ..where((t) => t.batchId.equals(batchId))
          ..orderBy([(t) => OrderingTerm.desc(t.logDate)]))
        .get();
    final vaccinations = await (_db.select(_db.vaccinationSchedules)
          ..where((t) => t.batchId.equals(batchId))
          ..orderBy([(t) => OrderingTerm.asc(t.scheduledDate)]))
        .get();
    final medications = await (_db.select(_db.medicationSchedules)
          ..where((t) => t.batchId.equals(batchId))
          ..orderBy([(t) => OrderingTerm.asc(t.scheduledDate)]))
        .get();

    final inventoryItems = await (_db.select(_db.inventory)
          ..where((t) => t.farmId.equals(farmId)))
        .get();
    final inventoryById = {for (final item in inventoryItems) item.id: item};

    final activeBatches = await (_db.select(_db.batches)
          ..where(
            (t) => t.farmId.equals(farmId) & t.status.equals('active'),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.batchName)]))
        .get();

    final activeHeadcount = activeBatches
        .map((b) => HeadcountBatch(id: b.id, currentCount: b.currentCount))
        .toList();

    BatchFinanceResult? financeResult;
    List<BatchRevenueItem> revenueItems = const [];
    if (canViewFinance) {
      final expenses = await (_db.select(_db.expenses)
            ..where((t) => t.farmId.equals(farmId)))
          .get();

      final directExpenses = expenses
          .where(
            (e) =>
                e.batchId == batchId &&
                !e.isSharedAllocation &&
                (e.batchId?.isNotEmpty ?? false),
          )
          .toList();
      final allocatedExpenses = expenses
          .where((e) => e.batchId == batchId && e.isSharedAllocation)
          .toList();
      final generalExpenses = expenses
          .where((e) => e.batchId == null || e.batchId!.isEmpty)
          .toList();

      final farmFeedingLogs = await (_db.select(_db.feedingLogs)
            ..where((t) => t.farmId.equals(farmId)))
          .get();
      final farmVaccinations = await (_db.select(_db.vaccinationSchedules)
            ..where((t) => t.farmId.equals(farmId)))
          .get();
      final farmMedications = await (_db.select(_db.medicationSchedules)
            ..where((t) => t.farmId.equals(farmId)))
          .get();
      final formulationRows = await (_db.select(_db.feedFormulations)
            ..where((t) => t.farmId.equals(farmId)))
          .get();
      final formulationIngredientRows = formulationRows.isEmpty
          ? <FeedFormulationIngredient>[]
          : await (_db.select(_db.feedFormulationIngredients)
                ..where(
                  (t) => t.formulationId.isIn(
                    formulationRows.map((row) => row.id),
                  ),
                ))
              .get();
      final ingredientsByFormulation =
          <String, List<FormulationIngredientInput>>{};
      for (final row in formulationIngredientRows) {
        ingredientsByFormulation
            .putIfAbsent(row.formulationId, () => [])
            .add((inventoryId: row.inventoryId, quantity: row.quantity));
      }
      final formulationInputs = formulationRows
          .map(
            (row) => (
              id: row.id,
              name: row.name,
              createdAt: row.createdAt,
              ingredients: ingredientsByFormulation[row.id] ?? const [],
            ),
          )
          .toList();

      final consumptionContext = buildConsumptionContext(
        feedingLogs: farmFeedingLogs
            .map(
              (log) => (
                batchId: log.batchId,
                feedTypeId: log.feedTypeId,
                formulationId: log.formulationId,
                amountConsumed: log.amountConsumed,
                logDate: log.logDate,
              ),
            )
            .toList(),
        formulations: formulationInputs,
        vaccinations: farmVaccinations
            .map(
              (row) => (
                batchId: row.batchId,
                name: row.vaccineName,
                quantity: row.quantity,
                status: row.status,
              ),
            )
            .toList(),
        medications: farmMedications
            .map(
              (row) => (
                batchId: row.batchId,
                name: row.medicationName,
                quantity: row.quantity,
                status: row.status,
              ),
            )
            .toList(),
        inventoryItems: inventoryItems
            .map(
              (item) => (
                id: item.id,
                itemName: item.itemName,
                costPerUnit: item.costPerUnit,
              ),
            )
            .toList(),
      );

      final orderItemRows = await _db.customSelect(
        '''
        SELECT si.*, o.order_date, o.status
        FROM sale_items si
        INNER JOIN orders o ON o.id = si.sale_id
        WHERE si.farm_id = ? AND COALESCE(o.is_deleted, 0) = 0
        ''',
        variables: [Variable.withString(farmId)],
      ).get();

      final batchAllocationRows = await _db.customSelect(
        '''
        SELECT * FROM order_item_batch_allocations WHERE farm_id = ?
        ''',
        variables: [Variable.withString(farmId)],
      ).get();

      final ledgerRows = await _db.customSelect(
        '''
        SELECT id, amount, transaction_date, description
        FROM financial_transactions
        WHERE farm_id = ?
          AND COALESCE(is_deleted, 0) = 0
          AND upper(type) = 'REVENUE'
          AND order_id IS NULL
          AND description LIKE ?
        ''',
        variables: [
          Variable.withString(farmId),
          Variable.withString('%${LedgerAllocationService.ledgerAllocPrefix}%'),
        ],
      ).get();

      revenueItems = buildBatchRevenueItems(
        batchId,
        orderItems: orderItemRows.map((row) {
          return (
            id: row.read<String>('id'),
            description: row.read<String?>('description'),
            quantity: row.read<int>('quantity'),
            unitPrice: row.read<double>('unit_price'),
            totalPrice: row.read<double>('total_price'),
            livestockId: row.read<String?>('livestock_id'),
            eggAllocationMode: row.read<String?>('egg_allocation_mode'),
            eggBatchId: row.read<String?>('egg_batch_id'),
            orderDate: DateTime.parse(row.read<String>('order_date')),
            orderStatus: row.read<String?>('status'),
          );
        }).toList(),
        batchAllocations: batchAllocationRows.map((row) {
          return (
            id: row.read<String>('id'),
            orderItemId: row.read<String>('order_item_id'),
            batchId: row.read<String>('batch_id'),
            revenueAmount: row.read<double>('revenue_amount'),
            eggsUsed: row.read<int?>('eggs_used'),
            description: null,
            orderDate: DateTime.parse(
              row.read<String?>('created_at') ??
                  DateTime.now().toIso8601String(),
            ),
            orderStatus: 'COMPLETED',
          );
        }).toList(),
        manualLedgerTransactions: ledgerRows.map((row) {
          return (
            id: row.read<String>('id'),
            amount: row.read<double>('amount'),
            transactionDate: DateTime.parse(row.read<String>('transaction_date')),
            description: row.read<String?>('description'),
          );
        }).toList(),
        activeBatches: activeHeadcount,
      );

      financeResult = BatchFinanceService(_db).computeBatchFinance(
        batchId: batchId,
        arrivalDate: batch.arrivalDate,
        initialActualCost: batch.initialActualCost ?? 0,
        directExpenses: directExpenses,
        allocatedExpenses: allocatedExpenses,
        generalExpenses: generalExpenses,
        revenueItems: revenueItems,
        activeBatches: activeHeadcount,
        consumptionContext: consumptionContext,
      );
    }

    final deadCount = mortalities
        .where(
          (m) => isDeadMortalityRecord(
            healthType: m.healthType,
            category: m.category,
          ),
        )
        .fold<int>(0, (sum, m) => sum + m.count);
    final totalFeed =
        feedingLogs.fold<double>(0, (sum, log) => sum + log.amountConsumed);
    final totalEggs =
        eggProduction.fold<int>(0, (sum, row) => sum + row.eggsCollected);
    final latestWeight =
        weightRecords.isNotEmpty ? weightRecords.first.averageWeight : 0.0;
    final fcr = latestWeight > 0 && batch.currentCount > 0
        ? totalFeed / (batch.currentCount * latestWeight)
        : 0.0;
    final mortalityRate = batch.initialCount > 0
        ? (deadCount / batch.initialCount) * 100
        : 0.0;
    final ageInDays =
        DateTime.now().difference(batch.arrivalDate).inDays.clamp(0, 99999);
    final isLayer = batch.type.toUpperCase() == 'POULTRY_LAYER';

    final eggDaily = _buildEggDaily(eggProduction);
    final mortalityDaily = _buildMortalityDaily(mortalities, batch.initialCount);
    final salesDaily = _buildSalesDaily(revenueItems);

    final feedInventory = inventoryItems
        .where((item) {
          final category = (item.category ?? '').toUpperCase();
          return category.contains('FEED');
        })
        .map(
          (item) => FeedInventoryOption(
            id: item.id,
            itemName: item.itemName,
            stockLevel: item.stockLevel,
            unit: item.unit,
          ),
        )
        .toList();

    final vaccineInventory = inventoryItems
        .where((item) => (item.usageType ?? '').toUpperCase() == 'VACCINE')
        .map(
          (item) => HealthInventoryOption(
            id: item.id,
            itemName: item.itemName,
            stockLevel: item.stockLevel,
            unit: item.unit,
          ),
        )
        .toList();

    final medicineInventory = inventoryItems
        .where((item) {
          final usage = (item.usageType ?? '').toUpperCase();
          return usage == 'MEDICINE' || usage == 'MEDICATION';
        })
        .map(
          (item) => HealthInventoryOption(
            id: item.id,
            itemName: item.itemName,
            stockLevel: item.stockLevel,
            unit: item.unit,
          ),
        )
        .toList();

    final salesRecords = revenueItems
        .map(
          (item) => {
            'id': item.id,
            'description': item.description,
            'quantity': item.quantity ?? 0,
            'unitPrice': item.unitPrice ?? 0,
            'totalPrice': item.totalPrice,
            'logDate': item.orderDate.toIso8601String(),
            'orderStatus': item.orderStatus,
          },
        )
        .toList();

    return BatchDeepDivePayload(
      batch: BatchDeepDiveBatch(
        id: batch.id,
        batchName: batch.batchName,
        breedType: batch.breedType,
        type: batch.type,
        status: batch.status,
        arrivalDate: batch.arrivalDate,
        initialCount: batch.initialCount,
        currentCount: batch.currentCount,
        isolationCount: batch.isolationCount,
        house: house == null
            ? null
            : BatchDeepDiveHouse(id: house.id, name: house.name),
        initialActualCost: batch.initialActualCost ?? 0,
        growthTarget: batch.growthTarget,
      ),
      metrics: BatchDeepDiveMetrics(
        ageInDays: ageInDays,
        totalFeed: totalFeed,
        totalEggs: totalEggs,
        totalMortality: deadCount,
        mortalityRate: double.parse(mortalityRate.toStringAsFixed(2)),
        latestWeight: latestWeight,
        fcr: double.parse(fcr.toStringAsFixed(2)),
        isLayer: isLayer,
      ),
      finance: BatchDeepDiveFinance(
        canViewFinance: canViewFinance,
        canEditFinance: canEditFinance,
        result: financeResult,
      ),
      series: BatchDeepDiveSeries(
        eggDaily: eggDaily,
        mortalityDaily: mortalityDaily,
        salesDaily: salesDaily,
      ),
      forms: BatchDeepDiveForms(
        canEditHealth: canEditHealth,
        feedInventory: feedInventory,
        vaccineInventory: vaccineInventory,
        medicineInventory: medicineInventory,
        allocationBatches: activeBatches
            .map(
              (b) => AllocationBatchOption(
                id: b.id,
                name: b.batchName,
                currentCount: b.currentCount,
              ),
            )
            .toList(),
      ),
      logs: BatchDeepDiveLogs(
        weightRecords: weightRecords
            .map(
              (row) => {
                'id': row.id,
                'logDate': row.logDate.toIso8601String(),
                'averageWeight': row.averageWeight,
                'userId': row.userId,
              },
            )
            .toList(),
        feedingLogs: feedingLogs
            .map(
              (row) => {
                'id': row.id,
                'logDate': row.logDate.toIso8601String(),
                'amountConsumed': row.amountConsumed,
                'feedTypeId': row.feedTypeId,
                'inventory': inventoryById[row.feedTypeId] == null
                    ? null
                    : {
                        'itemName': inventoryById[row.feedTypeId]!.itemName,
                        'unit': inventoryById[row.feedTypeId]!.unit,
                      },
                'userId': row.userId,
              },
            )
            .toList(),
        eggProduction: eggProduction
            .map(
              (row) => {
                'id': row.id,
                'logDate': row.logDate.toIso8601String(),
                'eggsCollected': row.eggsCollected,
                'userId': row.userId,
              },
            )
            .toList(),
        mortalityRecords: mortalities
            .map(
              (row) => {
                'id': row.id,
                'logDate': row.logDate.toIso8601String(),
                'count': row.count,
                'type': row.healthType,
                'category': row.category,
                'userId': row.userId,
              },
            )
            .toList(),
        vaccinations: vaccinations
            .map(
              (row) => {
                'id': row.id,
                'scheduledDate': row.scheduledDate.toIso8601String(),
                'status': row.status,
                'vaccineName': row.vaccineName,
                'quantity': row.quantity,
                'unit': row.unit,
                'notes': row.notes,
              },
            )
            .toList(),
        medications: medications
            .map(
              (row) => {
                'id': row.id,
                'scheduledDate': row.scheduledDate.toIso8601String(),
                'status': row.status,
                'medicationName': row.medicationName,
                'quantity': row.quantity,
                'unit': row.unit,
                'notes': row.notes,
              },
            )
            .toList(),
        salesRecords: salesRecords,
      ),
    );
  }

  List<DailyEggPoint> _buildEggDaily(List<EggProduction> rows) {
    final map = <String, int>{};
    for (final row in rows) {
      final key = _dayKey(row.logDate);
      map[key] = (map[key] ?? 0) + row.eggsCollected;
    }
    final sorted = map.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return sorted
        .take(sorted.length > 30 ? 30 : sorted.length)
        .skip(sorted.length > 30 ? sorted.length - 30 : 0)
        .map(
          (entry) => DailyEggPoint(
            label: _dayLabel(entry.key),
            eggs: entry.value,
          ),
        )
        .toList();
  }

  List<DailyMortalityPoint> _buildMortalityDaily(
    List<Mortality> rows,
    int initialCount,
  ) {
    final deadRows = rows.where(
      (row) => isDeadMortalityRecord(
        healthType: row.healthType,
        category: row.category,
      ),
    );
    final map = <String, int>{};
    for (final row in deadRows) {
      final key = _dayKey(row.logDate);
      map[key] = (map[key] ?? 0) + row.count;
    }
    final sorted = map.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final slice = sorted.length > 30
        ? sorted.sublist(sorted.length - 30)
        : sorted;
    var cumulative = 0;
    return slice
        .map((entry) {
          cumulative += entry.value;
          final rate = initialCount > 0
              ? double.parse(
                  ((cumulative / initialCount) * 100).toStringAsFixed(2),
                )
              : 0.0;
          return DailyMortalityPoint(
            label: _dayLabel(entry.key),
            deaths: entry.value,
            rate: rate,
          );
        })
        .toList();
  }

  List<DailySalesPoint> _buildSalesDaily(List<BatchRevenueItem> items) {
    final map = <String, ({double revenue, int units})>{};
    for (final item in items) {
      if ((item.orderStatus ?? '').toUpperCase() == 'CANCELLED') continue;
      final key = _dayKey(item.orderDate);
      final current = map[key] ?? (revenue: 0.0, units: 0);
      map[key] = (
        revenue: current.revenue + item.totalPrice,
        units: current.units + (item.quantity ?? 0),
      );
    }
    final sorted = map.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final slice = sorted.length > 30
        ? sorted.sublist(sorted.length - 30)
        : sorted;
    return slice
        .map(
          (entry) => DailySalesPoint(
            label: _dayLabel(entry.key),
            revenue: double.parse(entry.value.revenue.toStringAsFixed(2)),
            units: entry.value.units,
          ),
        )
        .toList();
  }

  String _dayKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _dayLabel(String key) {
    final parts = key.split('-');
    final date = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    return DateFormat('MMM d').format(date);
  }
}
