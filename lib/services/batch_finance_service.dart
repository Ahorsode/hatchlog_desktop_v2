import 'package:drift/drift.dart' hide Batch;

import '../data/local_db.dart';
import '../models/batch_deep_dive_models.dart';
import 'batch_consumption_finance.dart';

class BatchFinanceBreakdown {
  const BatchFinanceBreakdown({
    required this.batchId,
    required this.batchLabel,
    required this.initial,
    required this.operating,
    required this.consumption,
    required this.general,
    required this.revenue,
  });

  final String batchId;
  final String batchLabel;
  final double initial;
  final double operating;
  final double consumption;
  final double general;
  final double revenue;

  double get totalExpense => initial + operating + consumption + general;
  double get netProfit => revenue - totalExpense;
}

class BatchFinanceService {
  BatchFinanceService(this._db);

  final AppDatabase _db;

  Future<List<FormulationInput>> _loadFormulationInputs(String farmId) async {
    final formulations = await (_db.select(_db.feedFormulations)
          ..where((t) => t.farmId.equals(farmId)))
        .get();
    if (formulations.isEmpty) {
      return const [];
    }
    final formulationIds = formulations.map((row) => row.id).toList();
    final ingredients = await (_db.select(_db.feedFormulationIngredients)
          ..where((t) => t.formulationId.isIn(formulationIds)))
        .get();
    final ingredientsByFormulation = <String, List<FormulationIngredientInput>>{};
    for (final row in ingredients) {
      ingredientsByFormulation
          .putIfAbsent(row.formulationId, () => [])
          .add((inventoryId: row.inventoryId, quantity: row.quantity));
    }
    return formulations
        .map(
          (row) => (
            id: row.id,
            name: row.name,
            createdAt: row.createdAt,
            ingredients: ingredientsByFormulation[row.id] ?? const [],
          ),
        )
        .toList();
  }


  Future<List<BatchFinanceBreakdown>> computeFarmBreakdown(String farmId) async {
    final batches = await (_db.select(_db.batches)
          ..where((t) => t.farmId.equals(farmId))
          ..where((t) => t.status.equals('active')))
        .get();
    if (batches.isEmpty) {
      return const [];
    }

    final expenses = await (_db.select(_db.expenses)
          ..where((t) => t.farmId.equals(farmId)))
        .get();
    final feedingLogs = await (_db.select(_db.feedingLogs)
          ..where((t) => t.farmId.equals(farmId)))
        .get();
    final vaccinations = await (_db.select(_db.vaccinationSchedules)
          ..where((t) => t.farmId.equals(farmId)))
        .get();
    final medications = await (_db.select(_db.medicationSchedules)
          ..where((t) => t.farmId.equals(farmId)))
        .get();
    final inventory = await (_db.select(_db.inventory)
          ..where((t) => t.farmId.equals(farmId)))
        .get();
    final formulations = await _loadFormulationInputs(farmId);

    final batchIds = batches.map((batch) => batch.id).toSet();
    final totals = {
      for (final batch in batches)
        batch.id: _BatchAccumulator(
          batchId: batch.id,
          batchLabel: batch.batchName,
          initial: _initialInvestment(batch),
        ),
    };


    final consumptionContext = buildConsumptionContext(
      feedingLogs: feedingLogs
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
      formulations: formulations,
      vaccinations: vaccinations
          .map(
            (row) => (
              batchId: row.batchId,
              name: row.vaccineName,
              quantity: row.quantity,
              status: row.status,
            ),
          )
          .toList(),
      medications: medications
          .map(
            (row) => (
              batchId: row.batchId,
              name: row.medicationName,
              quantity: row.quantity,
              status: row.status,
            ),
          )
          .toList(),
      inventoryItems: inventory
          .map(
            (item) => (
              id: item.id,
              itemName: item.itemName,
              costPerUnit: item.costPerUnit,
            ),
          )
          .toList(),
    );
    final consumptionExpensesForAlloc = expenses
        .where(
          (e) => isConsumptionBasedExpense(
            category: e.category,
            description: e.description,
          ),
        )
        .toList();
    final feedAllocationIndexes = buildFeedAllocationIndexes(
      expenses: consumptionExpensesForAlloc,
      ctx: consumptionContext,
    );
    final feedFifoAllocationsByExpenseId =
        feedAllocationIndexes.feedFifoAllocationsByExpenseId;

    for (final expense in expenses) {
      final description = expense.description ?? '';
      if (_isBatchInitialExpense(description)) {
        continue;
      }

      final batchId = expense.batchId;
      if (batchId != null && batchIds.contains(batchId)) {
        totals[batchId]!.operating += expense.amount;
        continue;
      }

      if (_isConsumptionBasedExpense(expense.category, description)) {
        _allocateConsumption(
          expense: expense,
          feedFifoAllocationsByExpenseId: feedFifoAllocationsByExpenseId,
          inventory: inventory,
          feedingLogs: feedingLogs,
          vaccinations: vaccinations,
          medications: medications,
          batches: batches,
          batchIds: batchIds,
          totals: totals,
        );
        continue;
      }

      if (batchId == null || batchId.isEmpty) {
        _splitByHeadcount(batches, expense.amount, (id, share) {
          totals[id]!.general += share;
        });
      }
    }

    for (final batch in batches) {
      final formulationFeed =
          feedAllocationIndexes.formulationFeedCostByBatchId[batch.id] ?? 0;
      if (formulationFeed > 0) {
        totals[batch.id]!.consumption += formulationFeed;
      }
    }

    final saleItemRows = await _db.customSelect(
      'SELECT * FROM sale_items WHERE farm_id = ?',
      variables: [Variable.withString(farmId)],
    ).get();
    final batchAllocationRows = await _db.customSelect(
      'SELECT * FROM order_item_batch_allocations WHERE farm_id = ?',
      variables: [Variable.withString(farmId)],
    ).get();
    final orderRows = await _db.customSelect(
      "SELECT id FROM orders WHERE farm_id = ? AND COALESCE(is_deleted, 0) = 0 AND upper(status) = 'CANCELLED'",
      variables: [Variable.withString(farmId)],
    ).get();
    final cancelledOrderIds = orderRows
        .map((row) => row.read<String>('id'))
        .toSet();

    _allocateRevenue(
      batches: batches,
      batchIds: batchIds,
      totals: totals,
      saleItems: saleItemRows,
      batchAllocations: batchAllocationRows,
      cancelledOrderIds: cancelledOrderIds,
    );

    return totals.values
        .map(
          (item) => BatchFinanceBreakdown(
            batchId: item.batchId,
            batchLabel: item.batchLabel,
            initial: item.initial,
            operating: item.operating,
            consumption: item.consumption,
            general: item.general,
            revenue: item.revenue,
          ),
        )
        .toList()
      ..sort((a, b) => a.batchLabel.compareTo(b.batchLabel));
  }

  void _allocateConsumption({
    required Expense expense,
    required Map<String, Map<String, double>> feedFifoAllocationsByExpenseId,
    required List<InventoryItem> inventory,
    required List<FeedingLog> feedingLogs,
    required List<VaccinationSchedule> vaccinations,
    required List<MedicationSchedule> medications,
    required List<Batch> batches,
    required Set<String> batchIds,
    required Map<String, _BatchAccumulator> totals,
  }) {
    final description = expense.description ?? '';
    final category = expense.category.toUpperCase();
    final inventoryPurchase = _parseInventoryPurchaseExpense(description);
    final healthStock = _parseHealthStockExpense(description);
    final itemName = inventoryPurchase?.itemName ?? healthStock?.itemName;
    final usageByBatch = <String, double>{};

    if (inventoryPurchase != null && category == 'FEED') {
      final fifoCosts = feedFifoAllocationsByExpenseId[expense.id];
      if (fifoCosts != null && fifoCosts.isNotEmpty) {
        usageByBatch.addAll(fifoCosts);
      } else {
        final inventoryId = _inventoryIdForName(itemName, inventory);
        final purchasedQty = inventoryPurchase.purchasedQty;
        if (purchasedQty > 0) {
          final sortedLogs = feedingLogs
              .where((log) {
                final batchId = log.batchId;
                if (batchId == null || !batchIds.contains(batchId)) return false;
                if (inventoryId != null && log.feedTypeId != inventoryId) {
                  return false;
                }
                return true;
              })
              .toList()
            ..sort((a, b) => a.logDate.compareTo(b.logDate));
          var remainingQty = purchasedQty;
          for (final log in sortedLogs) {
            if (remainingQty <= 0) break;
            if (log.logDate.isBefore(expense.date)) continue;
            final consumed = log.amountConsumed;
            if (consumed <= 0) continue;
            final allocatedQty =
                consumed < remainingQty ? consumed : remainingQty;
            remainingQty -= allocatedQty;
            final batchId = log.batchId!;
            usageByBatch[batchId] = (usageByBatch[batchId] ?? 0) + allocatedQty;
          }
        }
      }
    } else if ((inventoryPurchase != null && category == 'MEDICATION') ||
        healthStock != null) {
      final normalizedName = _normalizeName(itemName ?? '');
      for (final schedule in vaccinations) {
        if (!_isCompleted(schedule.status)) {
          continue;
        }
        if (_normalizeName(schedule.vaccineName) != normalizedName) {
          continue;
        }
        if (!batchIds.contains(schedule.batchId)) {
          continue;
        }
        usageByBatch[schedule.batchId] =
            (usageByBatch[schedule.batchId] ?? 0) + schedule.quantity;
      }
      for (final schedule in medications) {
        if (!_isCompleted(schedule.status)) {
          continue;
        }
        if (_normalizeName(schedule.medicationName) != normalizedName) {
          continue;
        }
        if (!batchIds.contains(schedule.batchId)) {
          continue;
        }
        usageByBatch[schedule.batchId] =
            (usageByBatch[schedule.batchId] ?? 0) + schedule.quantity;
      }
    }

    final totalUsage = usageByBatch.values.fold<double>(0, (sum, v) => sum + v);
    if (totalUsage <= 0) {
      _splitByHeadcount(batches, expense.amount, (id, share) {
        totals[id]!.consumption += share;
      });
      return;
    }

    if (inventoryPurchase != null && category == 'FEED' && inventoryPurchase.purchasedQty > 0) {
      final fifoCosts = feedFifoAllocationsByExpenseId[expense.id];
      if (fifoCosts != null && fifoCosts.isNotEmpty) {
        for (final entry in fifoCosts.entries) {
          totals[entry.key]!.consumption += entry.value;
        }
        return;
      }
      final purchasedQty = inventoryPurchase.purchasedQty;
      for (final entry in usageByBatch.entries) {
        final share = (entry.value / purchasedQty).clamp(0, 1);
        totals[entry.key]!.consumption += expense.amount * share;
      }
      return;
    }

    for (final entry in usageByBatch.entries) {
      totals[entry.key]!.consumption += expense.amount * (entry.value / totalUsage);
    }
  }

  void _allocateRevenue({
    required List<Batch> batches,
    required Set<String> batchIds,
    required Map<String, _BatchAccumulator> totals,
    required List<QueryRow> saleItems,
    required List<QueryRow> batchAllocations,
    required Set<String> cancelledOrderIds,
  }) {
    final allocatedItemIds = <String>{};
    for (final row in batchAllocations) {
      final batchId = row.read<String?>('batch_id') ?? '';
      if (batchId.isEmpty || !batchIds.contains(batchId)) {
        continue;
      }
      totals[batchId]!.revenue += row.read<double>('revenue_amount');
      final orderItemId = row.read<String?>('order_item_id') ?? '';
      if (orderItemId.isNotEmpty) {
        allocatedItemIds.add(orderItemId);
      }
    }

    final linked = <String, double>{};
    var unlinked = 0.0;
    for (final item in saleItems) {
      final saleId = item.read<String?>('sale_id') ?? '';
      if (cancelledOrderIds.contains(saleId)) {
        continue;
      }
      final itemId = item.read<String?>('id') ?? '';
      if (allocatedItemIds.contains(itemId)) {
        continue;
      }
      final total = item.read<double>('total_price');
      final eggMode = item.read<String?>('egg_allocation_mode') ?? '';
      final eggBatchId = item.read<String?>('egg_batch_id') ?? '';
      if (eggMode == 'batch' &&
          eggBatchId.isNotEmpty &&
          batchIds.contains(eggBatchId)) {
        linked[eggBatchId] = (linked[eggBatchId] ?? 0) + total;
        continue;
      }
      final batchId = item.read<String?>('livestock_id') ?? '';
      if (batchId.isNotEmpty && batchIds.contains(batchId)) {
        linked[batchId] = (linked[batchId] ?? 0) + total;
      } else {
        unlinked += total;
      }
    }

    for (final entry in linked.entries) {
      totals[entry.key]!.revenue += entry.value;
    }
    if (unlinked > 0) {
      _splitByHeadcount(batches, unlinked, (id, share) {
        totals[id]!.revenue += share;
      });
    }
  }

  void _splitByHeadcount(
    List<Batch> batches,
    double amount,
    void Function(String batchId, double share) apply,
  ) {
    final totalHeadcount = batches.fold<int>(
      0,
      (sum, batch) => sum + batch.currentCount,
    );
    if (totalHeadcount <= 0) {
      final share = amount / batches.length;
      for (final batch in batches) {
        apply(batch.id, share);
      }
      return;
    }

    for (final batch in batches) {
      apply(
        batch.id,
        amount * (batch.currentCount / totalHeadcount),
      );
    }
  }

  bool _isBatchInitialExpense(String description) {
    return RegExp(r'^Initial cost for ', caseSensitive: false).hasMatch(description) ||
        RegExp(r'^Carriage for ', caseSensitive: false).hasMatch(description) ||
        RegExp(r'\(Initial for ', caseSensitive: false).hasMatch(description);
  }

  bool _isConsumptionBasedExpense(String category, String description) {
    final normalized = category.toUpperCase();
    if (_parseInventoryPurchaseExpense(description) != null) {
      return normalized == 'FEED' || normalized == 'MEDICATION';
    }
    if (_parseHealthStockExpense(description) != null) {
      return normalized == 'MEDICATION';
    }
    return false;
  }

  ({String itemName, double purchasedQty})? _parseInventoryPurchaseExpense(
    String description,
  ) {
    final match = RegExp(
      r'^Inventory Purchase:\s*(.+?)\s*\(([0-9.]+)\s',
      caseSensitive: false,
    ).firstMatch(description);
    if (match == null) {
      return null;
    }
    return (
      itemName: match.group(1)!.trim(),
      purchasedQty: double.tryParse(match.group(2)!) ?? 0,
    );
  }

  ({String itemName, double stockQty})? _parseHealthStockExpense(
    String description,
  ) {
    final match = RegExp(
      r'^Health stock cost:\s*(.+?)\s*\(([0-9.]+)\s',
      caseSensitive: false,
    ).firstMatch(description);
    if (match == null) {
      return null;
    }
    return (
      itemName: match.group(1)!.trim(),
      stockQty: double.tryParse(match.group(2)!) ?? 0,
    );
  }

  String? _inventoryIdForName(String? itemName, List<InventoryItem> inventory) {
    if (itemName == null || itemName.isEmpty) {
      return null;
    }
    final normalized = _normalizeName(itemName);
    for (final item in inventory) {
      if (_normalizeName(item.itemName) == normalized) {
        return item.id;
      }
    }
    return null;
  }

  String _normalizeName(String value) => value.trim().toLowerCase();

  bool _isCompleted(String? status) {
    final normalized = status?.toUpperCase() ?? '';
    return normalized == 'COMPLETED' || normalized == 'DONE';
  }

  double _initialInvestment(Batch batch) => batch.initialActualCost ?? 0;

  BatchFinanceResult computeBatchFinance({
    required String batchId,
    required DateTime arrivalDate,
    required double initialActualCost,
    required List<Expense> directExpenses,
    required List<Expense> allocatedExpenses,
    required List<Expense> generalExpenses,
    required List<BatchRevenueItem> revenueItems,
    required List<HeadcountBatch> activeBatches,
    required ConsumptionContext consumptionContext,
  }) {
    final initialInvestment = roundBatchMoney(initialActualCost);
    final headcountShare = computeHeadcountShare(batchId, activeBatches);
    final headcountSharePct = roundBatchMoney(headcountShare * 100);

    final farmGeneralPool =
        generalExpenses.where((e) => !isBatchInitialExpense(e.description)).toList();
    final consumptionExpenses = farmGeneralPool
        .where(
          (e) => isConsumptionBasedExpense(
            category: e.category,
            description: e.description,
          ),
        )
        .toList();
    final feedAllocationIndexes = buildFeedAllocationIndexes(
      expenses: consumptionExpenses,
      ctx: consumptionContext,
    );
    final feedFifoAllocationsByExpenseId =
        feedAllocationIndexes.feedFifoAllocationsByExpenseId;
    final formulationFeedCost = roundBatchMoney(
      feedAllocationIndexes.formulationFeedCostByBatchId[batchId] ?? 0,
    );
    final formulationFeedMonthly =
        feedAllocationIndexes.formulationFeedMonthlyByBatchId[batchId] ??
            const {};
    final consumptionIds = consumptionExpenses.map((e) => e.id).toSet();
    final headcountExpenses = farmGeneralPool
        .where((e) => !consumptionIds.contains(e.id))
        .toList();

    final directOperatingExpenses = directExpenses
        .where((e) => !isBatchInitialExpense(e.description))
        .toList();
    final directExpenseTotal = directOperatingExpenses.fold<double>(
      0,
      (sum, e) => sum + e.amount,
    );
    final allocatedExpenseTotal = allocatedExpenses.fold<double>(
      0,
      (sum, e) => sum + e.amount,
    );

    final consumptionAllocations = consumptionExpenses
        .map(
          (expense) => (
            expense: expense,
            allocation: allocateConsumptionExpense(
              expenseId: expense.id,
              expenseAmount: expense.amount,
              category: expense.category,
              description: expense.description,
              batchId: batchId,
              ctx: consumptionContext,
              activeBatches: activeBatches,
              feedFifoAllocationsByExpenseId: feedFifoAllocationsByExpenseId,
            ),
          ),
        )
        .toList();
    final consumptionAllocatedTotal = consumptionAllocations.fold<double>(
          0,
          (sum, row) => sum + row.allocation.amount,
        ) +
        formulationFeedCost;

    final headcountPoolTotal = headcountExpenses.fold<double>(
      0,
      (sum, e) => sum + e.amount,
    );
    final generalAllocatedTotal = headcountPoolTotal * headcountShare;
    final generalPoolTotal = farmGeneralPool.fold<double>(
      0,
      (sum, e) => sum + e.amount,
    );

    final operatingExpenses = directExpenseTotal +
        allocatedExpenseTotal +
        consumptionAllocatedTotal +
        generalAllocatedTotal;
    final totalExpenses = initialInvestment + operatingExpenses;

    final validRevenueItems =
        revenueItems.where((item) => !_isCancelled(item.orderStatus)).toList();
    final totalRevenue = validRevenueItems.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );
    final netProfit = totalRevenue - totalExpenses;

    final financeMap = <String, _MonthRow>{};
    void bump(String key, String field, double value) {
      final row = financeMap.putIfAbsent(key, _MonthRow.new);
      switch (field) {
        case 'revenue':
          row.revenue += value;
        case 'initial':
          row.initial += value;
        case 'operating':
          row.operating += value;
        case 'consumption':
          row.consumption += value;
        case 'general':
          row.general += value;
      }
    }

    if (initialInvestment > 0) {
      bump(_monthKey(arrivalDate), 'initial', initialInvestment);
    }

    for (final item in validRevenueItems) {
      bump(_monthKey(item.orderDate), 'revenue', item.totalPrice);
    }
    for (final expense in directOperatingExpenses) {
      bump(_monthKey(expense.date), 'operating', expense.amount);
    }
    for (final expense in allocatedExpenses) {
      bump(_monthKey(expense.date), 'operating', expense.amount);
    }
    for (final row in consumptionAllocations) {
      bump(
        _monthKey(row.expense.date),
        'consumption',
        row.allocation.amount,
      );
    }
    for (final entry in formulationFeedMonthly.entries) {
      bump(entry.key, 'consumption', entry.value);
    }
    for (final expense in headcountExpenses) {
      bump(
        _monthKey(expense.date),
        'general',
        expense.amount * headcountShare,
      );
    }

    final financeMonthly = financeMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final monthlyPoints = financeMonthly.map((entry) {
      final row = entry.value;
      final expenses =
          row.initial + row.operating + row.consumption + row.general;
      return FinanceMonthlyPoint(
        label: _monthLabel(entry.key),
        revenue: roundBatchMoney(row.revenue),
        initial: roundBatchMoney(row.initial),
        operating: roundBatchMoney(row.operating),
        consumption: roundBatchMoney(row.consumption),
        general: roundBatchMoney(row.general),
        expenses: roundBatchMoney(expenses),
        profit: roundBatchMoney(row.revenue - expenses),
      );
    }).toList();

    final financeSummary = [
      FinanceSummaryPoint(
        label: 'Initial Investment',
        key: 'initial',
        amount: roundBatchMoney(initialInvestment),
      ),
      FinanceSummaryPoint(
        label: 'Operating',
        key: 'operating',
        amount: roundBatchMoney(directExpenseTotal + allocatedExpenseTotal),
      ),
      FinanceSummaryPoint(
        label: 'Feed & Med (by usage)',
        key: 'consumption',
        amount: roundBatchMoney(consumptionAllocatedTotal),
      ),
      FinanceSummaryPoint(
        label: 'General Share',
        key: 'general',
        amount: roundBatchMoney(generalAllocatedTotal),
      ),
      FinanceSummaryPoint(
        label: 'Revenue',
        key: 'revenue',
        amount: roundBatchMoney(totalRevenue),
      ),
    ];

    final expenseBreakdown = <ExpenseBreakdownItem>[
      if (initialInvestment > 0)
        ExpenseBreakdownItem(
          id: '$batchId-initial-investment',
          date: arrivalDate,
          category: 'LIVESTOCK_PURCHASE',
          description: 'Initial investment (purchase + carriage + setup)',
          amount: roundBatchMoney(initialInvestment),
          kind: 'Initial',
        ),
      ...directOperatingExpenses.map(
        (e) => ExpenseBreakdownItem(
          id: e.id,
          date: e.date,
          category: e.category,
          description: e.description ?? '—',
          amount: roundBatchMoney(e.amount),
          kind: 'Direct',
        ),
      ),
      ...allocatedExpenses.map(
        (e) => ExpenseBreakdownItem(
          id: e.id,
          date: e.date,
          category: e.category,
          description: e.description ?? '—',
          amount: roundBatchMoney(e.amount),
          kind: 'Allocated',
          percentage: e.allocationPercent,
        ),
      ),
      ...consumptionAllocations
          .where((row) => row.allocation.amount > 0)
          .map(
            (row) => ExpenseBreakdownItem(
              id: row.expense.id,
              date: row.expense.date,
              category: row.expense.category,
              description: row.allocation.itemName != null
                  ? '${row.expense.description ?? '—'} → ${row.allocation.itemName}'
                  : row.expense.description ?? '—',
              amount: roundBatchMoney(row.allocation.amount),
              kind: 'Consumption',
              percentage: row.allocation.sharePct,
            ),
          ),
      ...headcountExpenses.map(
        (e) => ExpenseBreakdownItem(
          id: e.id,
          date: e.date,
          category: e.category,
          description: e.description ?? '—',
          amount: roundBatchMoney(e.amount * headcountShare),
          kind: 'General',
          percentage: headcountSharePct,
        ),
      ),
    ]..sort((a, b) => b.date.compareTo(a.date));

    final revenueBreakdown = validRevenueItems
        .map(
          (item) => RevenueBreakdownItem(
            id: item.id,
            date: item.orderDate,
            description: item.description,
            amount: roundBatchMoney(item.totalPrice),
            quantity: item.quantity,
            kind: item.kind,
            percentage: item.percentage,
          ),
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return BatchFinanceResult(
      initialInvestment: roundBatchMoney(initialInvestment),
      directExpenseTotal: roundBatchMoney(directExpenseTotal),
      allocatedExpenseTotal: roundBatchMoney(allocatedExpenseTotal),
      generalPoolTotal: roundBatchMoney(generalPoolTotal),
      generalAllocatedTotal: roundBatchMoney(generalAllocatedTotal),
      consumptionAllocatedTotal: roundBatchMoney(consumptionAllocatedTotal),
      operatingExpenses: roundBatchMoney(operatingExpenses),
      totalExpenses: roundBatchMoney(totalExpenses),
      totalRevenue: roundBatchMoney(totalRevenue),
      netProfit: roundBatchMoney(netProfit),
      headcountSharePct: headcountSharePct,
      financeMonthly: monthlyPoints,
      financeSummary: financeSummary,
      expenseBreakdown: expenseBreakdown.take(25).toList(),
      revenueBreakdown: revenueBreakdown.take(25).toList(),
    );
  }

  bool _isCancelled(String? status) =>
      (status ?? '').toUpperCase() == 'CANCELLED';

  String _monthKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';

  String _monthLabel(String key) {
    final parts = key.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final shortYear = (year % 100).toString().padLeft(2, '0');
    return '${months[month - 1]} $shortYear';
  }
}

class _MonthRow {
  double revenue = 0;
  double initial = 0;
  double operating = 0;
  double consumption = 0;
  double general = 0;
}

class _BatchAccumulator {
  _BatchAccumulator({
    required this.batchId,
    required this.batchLabel,
    required this.initial,
  });

  final String batchId;
  final String batchLabel;
  final double initial;
  double operating = 0;
  double consumption = 0;
  double general = 0;
  double revenue = 0;
}
