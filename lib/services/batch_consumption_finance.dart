import '../data/local_db.dart';
import '../models/batch_deep_dive_models.dart';

typedef FormulationIngredientInput = ({String inventoryId, double quantity});

typedef FormulationInput = ({
  String id,
  String name,
  DateTime createdAt,
  List<FormulationIngredientInput> ingredients,
});

class UsageTotals {
  UsageTotals();

  double total = 0;
  final Map<String, double> byBatch = {};
}

class ConsumptionContext {
  ConsumptionContext({
    required this.feedByInventoryId,
    required this.feedLogsByInventoryId,
    required this.feedLogsByFormulationId,
    required this.formulations,
    required this.formulationNameById,
    required this.healthByItemName,
    required this.inventoryIdByName,
    required this.inventoryCostPerUnitById,
  });

  final Map<String, UsageTotals> feedByInventoryId;
  final Map<String, List<FeedUsageLog>> feedLogsByInventoryId;
  final Map<String, List<FeedUsageLog>> feedLogsByFormulationId;
  final List<FormulationInput> formulations;
  final Map<String, String> formulationNameById;
  final Map<String, UsageTotals> healthByItemName;
  final Map<String, String> inventoryIdByName;
  final Map<String, double> inventoryCostPerUnitById;
}

class FeedUsageLog {
  const FeedUsageLog({
    required this.batchId,
    required this.quantity,
    required this.logDate,
  });

  final String batchId;
  final double quantity;
  final DateTime logDate;
}

class FeedLot {
  FeedLot({
    required this.expenseId,
    required this.itemName,
    required this.inventoryId,
    required this.expenseDate,
    required this.purchasedQty,
    required this.totalCost,
    required this.unitCost,
    required this.remainingQty,
  });

  final String expenseId;
  final String itemName;
  final String inventoryId;
  final DateTime expenseDate;
  final double purchasedQty;
  final double totalCost;
  final double unitCost;
  double remainingQty;
}

class FormulationLot {
  FormulationLot({
    required this.formulationId,
    required this.name,
    required this.createdAt,
    required this.unitCost,
    required this.remainingQty,
  });

  final String formulationId;
  final String name;
  final DateTime createdAt;
  final double unitCost;
  double remainingQty;
}

class FeedAllocationIndexes {
  const FeedAllocationIndexes({
    required this.feedFifoAllocationsByExpenseId,
    required this.formulationFeedCostByBatchId,
    required this.formulationFeedMonthlyByBatchId,
  });

  final Map<String, Map<String, double>> feedFifoAllocationsByExpenseId;
  final Map<String, double> formulationFeedCostByBatchId;
  final Map<String, Map<String, double>> formulationFeedMonthlyByBatchId;
}

double roundBatchMoney(double value) =>
    (value * 100).roundToDouble() / 100;

String normalizeConsumptionName(String value) => value.trim().toLowerCase();

void _addUsage(
  Map<String, UsageTotals> map,
  String key,
  String batchId,
  double qty,
) {
  if (batchId.isEmpty || qty <= 0) return;
  final row = map.putIfAbsent(key, UsageTotals.new);
  row.total += qty;
  row.byBatch[batchId] = (row.byBatch[batchId] ?? 0) + qty;
}

ConsumptionContext buildConsumptionContext({
  required List<({
    String? batchId,
    String? feedTypeId,
    String? formulationId,
    double amountConsumed,
    DateTime? logDate,
  })> feedingLogs,
  required List<({String batchId, String name, double quantity, String? status})>
      vaccinations,
  required List<({String batchId, String name, double quantity, String? status})>
      medications,
  required List<({String id, String itemName, double? costPerUnit})>
      inventoryItems,
  List<FormulationInput> formulations = const [],
}) {
  final feedByInventoryId = <String, UsageTotals>{};
  final feedLogsByInventoryId = <String, List<FeedUsageLog>>{};
  final feedLogsByFormulationId = <String, List<FeedUsageLog>>{};
  final healthByItemName = <String, UsageTotals>{};
  final inventoryIdByName = <String, String>{};
  final inventoryCostPerUnitById = <String, double>{};
  final formulationNameById = <String, String>{};

  for (final item in inventoryItems) {
    inventoryIdByName[normalizeConsumptionName(item.itemName)] = item.id;
    final cost = item.costPerUnit ?? 0;
    if (cost.isFinite && cost > 0) {
      inventoryCostPerUnitById[item.id] = cost;
    }
  }

  for (final formulation in formulations) {
    formulationNameById[formulation.id] = formulation.name;
  }

  for (final log in feedingLogs) {
    final batchId = log.batchId ?? '';
    final qty = log.amountConsumed;
    if (batchId.isEmpty || qty <= 0) continue;

    final feedTypeId = log.feedTypeId;
    if (feedTypeId != null && feedTypeId.isNotEmpty) {
      _addUsage(feedByInventoryId, feedTypeId, batchId, qty);
      final logDate = log.logDate;
      if (logDate != null) {
        final entries = feedLogsByInventoryId.putIfAbsent(feedTypeId, () => []);
        entries.add(
          FeedUsageLog(
            batchId: batchId,
            quantity: qty,
            logDate: logDate,
          ),
        );
      }
      continue;
    }

    final formulationId = log.formulationId;
    if (formulationId != null && formulationId.isNotEmpty) {
      _addUsage(
        feedByInventoryId,
        'formulation:',
        batchId,
        qty,
      );
      final logDate = log.logDate;
      if (logDate != null) {
        final entries =
            feedLogsByFormulationId.putIfAbsent(formulationId, () => []);
        entries.add(
          FeedUsageLog(
            batchId: batchId,
            quantity: qty,
            logDate: logDate,
          ),
        );
      }
    }
  }

  for (final entry in feedLogsByInventoryId.entries) {
    entry.value.sort((a, b) => a.logDate.compareTo(b.logDate));
  }

  for (final entry in feedLogsByFormulationId.entries) {
    entry.value.sort((a, b) => a.logDate.compareTo(b.logDate));
  }

  for (final row in [...vaccinations, ...medications]) {
    if ((row.status ?? '').toUpperCase() == 'CANCELLED') continue;
    if (row.batchId.isEmpty || row.quantity <= 0 || row.name.isEmpty) continue;
    _addUsage(
      healthByItemName,
      normalizeConsumptionName(row.name),
      row.batchId,
      row.quantity,
    );
  }

  return ConsumptionContext(
    feedByInventoryId: feedByInventoryId,
    feedLogsByInventoryId: feedLogsByInventoryId,
    feedLogsByFormulationId: feedLogsByFormulationId,
    formulations: formulations,
    formulationNameById: formulationNameById,
    healthByItemName: healthByItemName,
    inventoryIdByName: inventoryIdByName,
    inventoryCostPerUnitById: inventoryCostPerUnitById,
  );
}

({String itemName, double purchasedQty})? parseInventoryPurchaseExpense(
  String? description,
) {
  final match = RegExp(
    r'^Inventory Purchase:\s*(.+?)\s*\(([0-9.]+)\s',
    caseSensitive: false,
  ).firstMatch(description ?? '');
  if (match == null) return null;
  return (
    itemName: match.group(1)!.trim(),
    purchasedQty: double.tryParse(match.group(2)!) ?? 0,
  );
}

({String itemName, double stockQty})? parseHealthStockExpense(String? description) {
  final match = RegExp(
    r'^Health stock cost:\s*(.+?)\s*\(([0-9.]+)\s',
    caseSensitive: false,
  ).firstMatch(description ?? '');
  if (match == null) return null;
  return (
    itemName: match.group(1)!.trim(),
    stockQty: double.tryParse(match.group(2)!) ?? 0,
  );
}

bool isConsumptionBasedExpense({
  required String category,
  required String? description,
}) {
  final normalized = category.toUpperCase();
  if (parseInventoryPurchaseExpense(description) != null) {
    return normalized == 'FEED' || normalized == 'MEDICATION';
  }
  if (parseHealthStockExpense(description) != null) {
    return normalized == 'MEDICATION';
  }
  return false;
}

bool isBatchInitialExpense(String? description) {
  final text = description ?? '';
  return RegExp(r'^Initial cost for ', caseSensitive: false).hasMatch(text) ||
      RegExp(r'^Carriage for ', caseSensitive: false).hasMatch(text) ||
      RegExp(r'\(Initial for ', caseSensitive: false).hasMatch(text);
}

double computeHeadcountShare(String batchId, List<HeadcountBatch> batches) {
  final total = batches.fold<int>(
    0,
    (sum, batch) => sum + batch.currentCount,
  );
  if (total <= 0) return 0;
  final count = batches
      .where((batch) => batch.id == batchId)
      .map((batch) => batch.currentCount)
      .firstOrNull;
  return (count ?? 0) / total;
}

({double share, String basis}) _usageShare(
  String batchId,
  UsageTotals? usage,
  double headcountShare,
) {
  if (usage == null || usage.total <= 0) {
    return (share: headcountShare, basis: 'headcount');
  }
  final batchQty = usage.byBatch[batchId] ?? 0;
  if (batchQty <= 0) {
    return (share: 0, basis: 'consumption');
  }
  return (share: batchQty / usage.total, basis: 'consumption');
}

({double share, String basis}) _purchasedQuantityShare(
  String batchId,
  UsageTotals? usage,
  double purchasedQty,
) {
  if (!purchasedQty.isFinite || purchasedQty <= 0) {
    return (share: 0, basis: 'none');
  }
  final batchQty = usage?.byBatch[batchId] ?? 0;
  if (batchQty <= 0) {
    return (share: 0, basis: 'consumption');
  }
  final share = (batchQty / purchasedQty).clamp(0.0, 1.0);
  return (share: share.toDouble(), basis: 'consumption');
}

Map<String, List<FeedLot>> _buildIngredientLotsFromExpenses(
  List<Expense> feedExpenses,
  ConsumptionContext ctx,
) {
  final lotsByInventoryId = <String, List<FeedLot>>{};

  for (final expense in feedExpenses) {
    final parsed = parseInventoryPurchaseExpense(expense.description);
    if (parsed == null || parsed.itemName.isEmpty || parsed.purchasedQty <= 0) {
      continue;
    }
    final inventoryId =
        ctx.inventoryIdByName[normalizeConsumptionName(parsed.itemName)];
    if (inventoryId == null || inventoryId.isEmpty) continue;
    final amount = expense.amount;
    if (amount <= 0) continue;
    final purchasedQty = parsed.purchasedQty;
    final unitCost = amount / purchasedQty;
    final lots = lotsByInventoryId.putIfAbsent(inventoryId, () => []);
    lots.add(
      FeedLot(
        expenseId: expense.id,
        itemName: parsed.itemName,
        inventoryId: inventoryId,
        expenseDate: expense.date,
        purchasedQty: purchasedQty,
        totalCost: amount,
        unitCost: unitCost,
        remainingQty: purchasedQty,
      ),
    );
  }

  for (final entry in lotsByInventoryId.entries) {
    entry.value.sort((a, b) {
      final byDate = a.expenseDate.compareTo(b.expenseDate);
      if (byDate != 0) return byDate;
      return a.expenseId.compareTo(b.expenseId);
    });
  }

  return lotsByInventoryId;
}

({double cost, double qtyUsed}) _depleteIngredientLots(
  List<FeedLot>? lots,
  double qty,
  DateTime asOfDate, {
  double? fallbackUnitCost,
}) {
  var remaining = qty;
  var cost = 0.0;

  while (remaining > 0 && lots != null && lots.isNotEmpty) {
    FeedLot? lot;
    for (final candidate in lots) {
      if (candidate.remainingQty <= 0) continue;
      if (!candidate.expenseDate.isAfter(asOfDate)) {
        lot = candidate;
        break;
      }
    }
  lot ??= lots.cast<FeedLot?>().firstWhere(
      (candidate) => candidate!.remainingQty > 0,
      orElse: () => null,
    );
    if (lot == null) break;

    final usedQty = remaining < lot.remainingQty ? remaining : lot.remainingQty;
    if (usedQty <= 0) break;
    lot.remainingQty -= usedQty;
    remaining -= usedQty;
    cost += usedQty * lot.unitCost;
  }

  if (remaining > 0 && fallbackUnitCost != null && fallbackUnitCost > 0) {
    cost += remaining * fallbackUnitCost;
    remaining = 0;
  }

  return (cost: cost, qtyUsed: qty - remaining);
}

List<FormulationLot> _buildFormulationLots(
  Map<String, List<FeedLot>> lotsByInventoryId,
  ConsumptionContext ctx,
) {
  final formulationLots = <FormulationLot>[];
  final sortedFormulations = [...ctx.formulations]
    ..sort((a, b) {
      final byDate = a.createdAt.compareTo(b.createdAt);
      if (byDate != 0) return byDate;
      return a.id.compareTo(b.id);
    });

  for (final formulation in sortedFormulations) {
    final createdAt = formulation.createdAt;
    if (formulation.ingredients.isEmpty) continue;

    var totalCost = 0.0;
    var totalProducedQty = 0.0;

    for (final ingredient in formulation.ingredients) {
      final qty = ingredient.quantity;
      if (ingredient.inventoryId.isEmpty || qty <= 0) continue;
      final lots = lotsByInventoryId[ingredient.inventoryId];
      final fallbackUnitCost = ctx.inventoryCostPerUnitById[ingredient.inventoryId];
      final depleted = _depleteIngredientLots(
        lots,
        qty,
        createdAt,
        fallbackUnitCost: fallbackUnitCost,
      );
      totalCost += depleted.cost;
      totalProducedQty += qty;
    }

    if (totalProducedQty <= 0 || totalCost <= 0) continue;

    formulationLots.add(
      FormulationLot(
        formulationId: formulation.id,
        name: formulation.name,
        createdAt: createdAt,
        unitCost: totalCost / totalProducedQty,
        remainingQty: totalProducedQty,
      ),
    );
  }

  return formulationLots;
}

Map<String, Map<String, double>> _allocateDirectFeedLotsFifo(
  Map<String, List<FeedLot>> lotsByInventoryId,
  ConsumptionContext ctx,
) {
  final allocationsByExpenseId = <String, Map<String, double>>{};

  for (final entry in ctx.feedLogsByInventoryId.entries) {
    final lots = lotsByInventoryId[entry.key];
    if (lots == null || lots.isEmpty || entry.value.isEmpty) continue;

    for (final log in entry.value) {
      var qtyToAllocate = log.quantity;
      while (qtyToAllocate > 0) {
        FeedLot? lot;
        for (final candidate in lots) {
          if (candidate.remainingQty <= 0) continue;
          if (!candidate.expenseDate.isAfter(log.logDate)) {
            lot = candidate;
            break;
          }
        }
        lot ??= lots.cast<FeedLot?>().firstWhere(
          (candidate) => candidate!.remainingQty > 0,
          orElse: () => null,
        );
        if (lot == null) break;

        final usedQty =
            qtyToAllocate < lot.remainingQty ? qtyToAllocate : lot.remainingQty;
        if (usedQty <= 0) break;
        lot.remainingQty -= usedQty;
        qtyToAllocate -= usedQty;

        final batchCosts = allocationsByExpenseId.putIfAbsent(
          lot.expenseId,
          () => {},
        );
        final cost = usedQty * lot.unitCost;
        batchCosts[log.batchId] = (batchCosts[log.batchId] ?? 0) + cost;
      }
    }
  }

  return allocationsByExpenseId;
}

({
  Map<String, double> costByBatchId,
  Map<String, Map<String, double>> monthlyByBatchId,
}) _allocateFormulationFeedToBatches(
  List<FormulationLot> formulationLots,
  ConsumptionContext ctx,
) {
  final costByBatchId = <String, double>{};
  final monthlyByBatchId = <String, Map<String, double>>{};

  final lotsByFormulationId = <String, List<FormulationLot>>{};
  for (final lot in formulationLots) {
    lotsByFormulationId.putIfAbsent(lot.formulationId, () => []).add(lot);
  }

  for (final entry in ctx.feedLogsByFormulationId.entries) {
    final lots = lotsByFormulationId[entry.key];
    if (lots == null || lots.isEmpty || entry.value.isEmpty) continue;

    for (final log in entry.value) {
      var qtyToAllocate = log.quantity;
      while (qtyToAllocate > 0) {
        FormulationLot? lot;
        for (final candidate in lots) {
          if (candidate.remainingQty <= 0) continue;
          if (!candidate.createdAt.isAfter(log.logDate)) {
            lot = candidate;
            break;
          }
        }
        lot ??= lots.cast<FormulationLot?>().firstWhere(
          (candidate) => candidate!.remainingQty > 0,
          orElse: () => null,
        );
        if (lot == null) break;

        final usedQty =
            qtyToAllocate < lot.remainingQty ? qtyToAllocate : lot.remainingQty;
        if (usedQty <= 0) break;
        lot.remainingQty -= usedQty;
        qtyToAllocate -= usedQty;

        final cost = roundBatchMoney(usedQty * lot.unitCost);
        costByBatchId[log.batchId] = (costByBatchId[log.batchId] ?? 0) + cost;

        final monthKey =
            '-';
        final monthMap = monthlyByBatchId.putIfAbsent(log.batchId, () => {});
        monthMap[monthKey] = (monthMap[monthKey] ?? 0) + cost;
      }
    }
  }

  return (costByBatchId: costByBatchId, monthlyByBatchId: monthlyByBatchId);
}

FeedAllocationIndexes buildFeedAllocationIndexes({
  required List<Expense> expenses,
  required ConsumptionContext ctx,
}) {
  final feedExpenses =
      expenses.where((e) => e.category.toUpperCase() == 'FEED').toList();
  final lotsByInventoryId = _buildIngredientLotsFromExpenses(feedExpenses, ctx);
  final formulationLots = _buildFormulationLots(lotsByInventoryId, ctx);
  final feedFifoAllocationsByExpenseId =
      _allocateDirectFeedLotsFifo(lotsByInventoryId, ctx);
  final formulationAllocation =
      _allocateFormulationFeedToBatches(formulationLots, ctx);

  return FeedAllocationIndexes(
    feedFifoAllocationsByExpenseId: feedFifoAllocationsByExpenseId,
    formulationFeedCostByBatchId: formulationAllocation.costByBatchId,
    formulationFeedMonthlyByBatchId: formulationAllocation.monthlyByBatchId,
  );
}

Map<String, Map<String, double>> buildFeedFifoAllocationIndex({
  required List<Expense> expenses,
  required ConsumptionContext ctx,
}) {
  return buildFeedAllocationIndexes(expenses: expenses, ctx: ctx)
      .feedFifoAllocationsByExpenseId;
}

({
  double amount,
  double sharePct,
  String basis,
  String? itemName,
}) allocateConsumptionExpense({
  required double expenseAmount,
  required String category,
  required String? description,
  required String batchId,
  required ConsumptionContext ctx,
  required List<HeadcountBatch> activeBatches,
  Map<String, Map<String, double>>? feedFifoAllocationsByExpenseId,
  String? expenseId,
}) {
  if (expenseAmount <= 0) {
    return (amount: 0, sharePct: 0, basis: 'none', itemName: null);
  }

  final headcountShare = computeHeadcountShare(batchId, activeBatches);
  final inventoryPurchase = parseInventoryPurchaseExpense(description);
  final healthStock = parseHealthStockExpense(description);
  final itemName = inventoryPurchase?.itemName ?? healthStock?.itemName;

  if (inventoryPurchase != null && itemName != null) {
    final inventoryId =
        ctx.inventoryIdByName[normalizeConsumptionName(itemName)];
    final usage =
        inventoryId != null ? ctx.feedByInventoryId[inventoryId] : null;
    final normalized = category.toUpperCase();

    if (normalized == 'FEED') {
      final batchCosts = expenseId == null
          ? null
          : feedFifoAllocationsByExpenseId?[expenseId];
      if (batchCosts != null) {
        final allocatedAmount = roundBatchMoney(batchCosts[batchId] ?? 0);
        final share = expenseAmount > 0
            ? (allocatedAmount / expenseAmount).clamp(0, 1)
            : 0.0;
        return (
          amount: allocatedAmount,
          sharePct: roundBatchMoney(share * 100),
          basis: 'consumption',
          itemName: itemName,
        );
      }
      final shareRow = _purchasedQuantityShare(
        batchId,
        usage,
        inventoryPurchase.purchasedQty,
      );
      return (
        amount: roundBatchMoney(expenseAmount * shareRow.share),
        sharePct: roundBatchMoney(shareRow.share * 100),
        basis: shareRow.basis,
        itemName: itemName,
      );
    }

    if (normalized == 'MEDICATION') {
      final medUsage = ctx.healthByItemName[normalizeConsumptionName(itemName)];
      final shareRow = _usageShare(batchId, medUsage, headcountShare);
      return (
        amount: roundBatchMoney(expenseAmount * shareRow.share),
        sharePct: roundBatchMoney(shareRow.share * 100),
        basis: shareRow.basis,
        itemName: itemName,
      );
    }
  }

  if (healthStock != null && itemName != null) {
    final medUsage = ctx.healthByItemName[normalizeConsumptionName(itemName)];
    final shareRow = _usageShare(batchId, medUsage, headcountShare);
    return (
      amount: roundBatchMoney(expenseAmount * shareRow.share),
      sharePct: roundBatchMoney(shareRow.share * 100),
      basis: shareRow.basis,
      itemName: itemName,
    );
  }

  return (
    amount: roundBatchMoney(expenseAmount * headcountShare),
    sharePct: roundBatchMoney(headcountShare * 100),
    basis: 'headcount',
    itemName: itemName,
  );
}
