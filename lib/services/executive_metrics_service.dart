import 'package:drift/drift.dart' show OrderingTerm;

import '../data/local_db.dart';

class ExecutiveStatsSnapshot {
  const ExecutiveStatsSnapshot({
    required this.totalProfit,
    required this.profitTrend,
    required this.globalFcr,
    required this.totalDebt,
    required this.supplierDebt,
    required this.customerDebt,
    required this.activeLivestock,
    required this.mortalityRatePercent,
  });

  final double totalProfit;
  final double profitTrend;
  final double globalFcr;
  final double totalDebt;
  final double supplierDebt;
  final double customerDebt;
  final int activeLivestock;
  final double mortalityRatePercent;
}

class StrategicPriorityInfo {
  const StrategicPriorityInfo({
    required this.title,
    required this.detail,
    required this.type,
  });

  final String title;
  final String detail;
  final String type;
}

class ExecutiveMetricsService {
  ExecutiveMetricsService(this._db);

  final AppDatabase _db;

  Future<ExecutiveStatsSnapshot> loadExecutiveStats(String farmId) async {
    final today = _dayStart(DateTime.now());
    final windowStart = today.subtract(const Duration(days: 6));
    final previousStart = windowStart.subtract(const Duration(days: 7));
    final previousEnd = windowStart.subtract(const Duration(days: 1));

    final currentRevenue = await _sumSales(farmId, windowStart, today);
    final previousRevenue = await _sumSales(farmId, previousStart, previousEnd);
    final currentExpenses = await _sumExpenses(farmId, windowStart, today);
    final totalProfit = currentRevenue - currentExpenses;
    final profitTrend = previousRevenue <= 0
        ? (currentRevenue > 0 ? 100.0 : 0.0)
        : ((currentRevenue - previousRevenue) / previousRevenue) * 100;

    final batches = await (_db.select(_db.batches)
          ..where((t) => t.farmId.equals(farmId))
          ..where((t) => t.status.equals('active')))
        .get();
    final activeLivestock = batches.fold<int>(
      0,
      (sum, batch) => sum + batch.currentCount,
    );
    final initialBirds = batches.fold<int>(
      0,
      (sum, batch) => sum + batch.initialCount,
    );
    final mortalities = await (_db.select(_db.mortalities)
          ..where((t) => t.farmId.equals(farmId)))
        .get();
    final overallDead = mortalities.fold<int>(0, (sum, m) => sum + m.count);
    final mortalityRatePercent = initialBirds == 0
        ? 0.0
        : (overallDead / initialBirds) * 100;

    final fcrValues = <double>[];
    for (final batch in batches) {
      final fcr = await _batchFcr(farmId, batch.id, batch.type);
      if (fcr > 0) {
        fcrValues.add(fcr);
      }
    }
    final globalFcr = fcrValues.isEmpty
        ? 0.0
        : fcrValues.reduce((a, b) => a + b) / fcrValues.length;

    final customers = await (_db.select(_db.customers)
          ..where((t) => t.farmId.equals(farmId)))
        .get();
    final customerDebt = customers.fold<double>(
      0,
      (sum, c) => sum + c.balanceOwed,
    );

    return ExecutiveStatsSnapshot(
      totalProfit: totalProfit,
      profitTrend: profitTrend,
      globalFcr: globalFcr,
      totalDebt: customerDebt,
      supplierDebt: 0,
      customerDebt: customerDebt,
      activeLivestock: activeLivestock,
      mortalityRatePercent: mortalityRatePercent,
    );
  }

  Future<double> _batchFcr(String farmId, String batchId, String type) async {
    final feedLogs = await (_db.select(_db.feedingLogs)
          ..where((t) => t.farmId.equals(farmId))
          ..where((t) => t.batchId.equals(batchId)))
        .get();
    final totalFeed = feedLogs.fold<double>(
      0,
      (sum, log) => sum + log.amountConsumed,
    );
    if (totalFeed <= 0) {
      return 0;
    }

    if (type.toUpperCase().contains('LAYER')) {
      final eggs = await (_db.select(_db.eggProductions)
            ..where((t) => t.farmId.equals(farmId))
            ..where((t) => t.batchId.equals(batchId)))
          .get();
      final totalEggs = eggs.fold<int>(0, (sum, e) => sum + e.eggsCollected);
      return totalEggs <= 0 ? 0 : totalFeed / totalEggs;
    }

    final weights = await (_db.select(_db.weightRecords)
          ..where((t) => t.farmId.equals(farmId))
          ..where((t) => t.batchId.equals(batchId))
          ..orderBy([(t) => OrderingTerm.asc(t.logDate)]))
        .get();
    if (weights.length < 2) {
      return 0;
    }
    final batch = await (_db.select(_db.batches)
          ..where((t) => t.id.equals(batchId)))
        .getSingle();
    final gain = (weights.last.averageWeight - weights.first.averageWeight) *
        batch.currentCount;
    return gain <= 0 ? 0 : totalFeed / gain;
  }

  Future<double> _sumSales(
    String farmId,
    DateTime start,
    DateTime end,
  ) async {
    final sales = await (_db.select(_db.sales)
          ..where((t) => t.farmId.equals(farmId)))
        .get();
    return sales
        .where(
          (sale) =>
              !sale.saleDate.isBefore(start) && !sale.saleDate.isAfter(end),
        )
        .fold<double>(0, (sum, sale) => sum + sale.totalAmount);
  }

  Future<double> _sumExpenses(
    String farmId,
    DateTime start,
    DateTime end,
  ) async {
    final expenses = await (_db.select(_db.expenses)
          ..where((t) => t.farmId.equals(farmId)))
        .get();
    return expenses
        .where(
          (expense) =>
              !expense.date.isBefore(start) && !expense.date.isAfter(end),
        )
        .fold<double>(0, (sum, e) => sum + e.amount);
  }

  DateTime _dayStart(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
