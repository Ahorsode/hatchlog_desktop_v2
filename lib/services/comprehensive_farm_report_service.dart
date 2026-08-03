import 'package:drift/drift.dart';

import '../data/local_db.dart';
import '../utils/navigation_permissions.dart';
import 'finance_ledger_service.dart';

class ReportKpis {
  const ReportKpis({
    required this.totalRevenue,
    required this.totalExpense,
    required this.netIncome,
    required this.totalFeedConsumed,
    required this.totalEggsCollected,
    required this.totalMortality,
    required this.mortalityRate,
    required this.averageFcr,
  });

  final double totalRevenue;
  final double totalExpense;
  final double netIncome;
  final double totalFeedConsumed;
  final int totalEggsCollected;
  final int totalMortality;
  final double mortalityRate;
  final double averageFcr;
}

class ReportFinancialRow {
  const ReportFinancialRow({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.transactionDate,
    required this.description,
    required this.referenceNum,
    required this.userName,
  });

  final String id;
  final String type;
  final String category;
  final double amount;
  final String paymentStatus;
  final String paymentMethod;
  final DateTime transactionDate;
  final String? description;
  final String? referenceNum;
  final String userName;
}

class DailyReportTrend {
  const DailyReportTrend({
    required this.date,
    required this.revenue,
    required this.expense,
    required this.eggs,
    required this.feed,
    required this.mortality,
  });

  final String date;
  final double revenue;
  final double expense;
  final int eggs;
  final double feed;
  final int mortality;
}

class ReportBatchRow {
  const ReportBatchRow({
    required this.id,
    required this.batchName,
    required this.initialCount,
    required this.currentCount,
    required this.status,
    required this.mortalityCount,
    required this.feedConsumed,
  });

  final String id;
  final String batchName;
  final int initialCount;
  final int currentCount;
  final String status;
  final int mortalityCount;
  final double feedConsumed;
}

class AuditTimelineEntry {
  const AuditTimelineEntry({
    required this.id,
    required this.actionType,
    required this.description,
    required this.createdAt,
    required this.userName,
  });

  final String id;
  final String? actionType;
  final String? description;
  final DateTime createdAt;
  final String userName;
}

class ComprehensiveFarmReport {
  const ComprehensiveFarmReport({
    required this.startDate,
    required this.endDate,
    required this.kpis,
    required this.financials,
    required this.revenueByCategory,
    required this.expenseByCategory,
    required this.paymentStatusMatrix,
    required this.dailyTrends,
    required this.batches,
    required this.auditTimeline,
  });

  final DateTime startDate;
  final DateTime endDate;
  final ReportKpis kpis;
  final List<ReportFinancialRow> financials;
  final Map<String, double> revenueByCategory;
  final Map<String, double> expenseByCategory;
  final Map<String, ({int count, double total})> paymentStatusMatrix;
  final List<DailyReportTrend> dailyTrends;
  final List<ReportBatchRow> batches;
  final List<AuditTimelineEntry> auditTimeline;
}

/// Offline-first comprehensive farm report — mirrors web `generateComprehensiveFarmReport`.
class ComprehensiveFarmReportService {
  ComprehensiveFarmReportService(this._db);

  final AppDatabase _db;

  Future<ComprehensiveFarmReport?> generate({
    required String farmId,
    required DateTime startDate,
    required DateTime endDate,
    required String? role,
    required Set<String> permissions,
    required List<String> assignableRoles,
  }) async {
    final canAccess = canShowNavigationItem(
      name: 'Reports',
      role: role,
      roles: assignableRoles,
      permissions: permissions,
    );
    if (!canAccess) return null;

    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      23,
      59,
      59,
    );

    final ledger = FinanceLedgerService(_db);
    final allEntries = await ledger.loadEntries(farmId);
    final periodEntries = allEntries
        .where(
          (entry) =>
              !entry.transactionDate.isBefore(start) &&
              !entry.transactionDate.isAfter(end),
        )
        .toList();

    final feedLogs = await (_db.select(_db.feedingLogs)
          ..where(
            (t) =>
                t.farmId.equals(farmId) &
                t.logDate.isBiggerOrEqualValue(start) &
                t.logDate.isSmallerOrEqualValue(end),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.logDate)]))
        .get();

    final eggLogs = await (_db.select(_db.eggProductions)
          ..where(
            (t) =>
                t.farmId.equals(farmId) &
                t.logDate.isBiggerOrEqualValue(start) &
                t.logDate.isSmallerOrEqualValue(end),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.logDate)]))
        .get();

    final mortalityLogs = await (_db.select(_db.mortalities)
          ..where(
            (t) =>
                t.farmId.equals(farmId) &
                t.logDate.isBiggerOrEqualValue(start) &
                t.logDate.isSmallerOrEqualValue(end),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.logDate)]))
        .get();

    final batches = await (_db.select(_db.batches)
          ..where((t) => t.farmId.equals(farmId)))
        .get();

    var totalRevenue = 0.0;
    var totalExpense = 0.0;
    final revenueByCategory = <String, double>{};
    final expenseByCategory = <String, double>{};
    final paymentStatusMatrix = <String, ({int count, double total})>{};
    final financials = <ReportFinancialRow>[];

    for (final entry in periodEntries) {
      final amount = entry.amount;
      final type = entry.type.toUpperCase();
      if (type == 'REVENUE') {
        totalRevenue += amount;
        revenueByCategory[entry.category] =
            (revenueByCategory[entry.category] ?? 0) + amount;
      } else {
        totalExpense += amount;
        expenseByCategory[entry.category] =
            (expenseByCategory[entry.category] ?? 0) + amount;
      }

      final status = entry.paymentStatus.isEmpty ? 'UNPAID' : entry.paymentStatus;
      final matrix = paymentStatusMatrix[status];
      paymentStatusMatrix[status] = (
        count: (matrix?.count ?? 0) + 1,
        total: (matrix?.total ?? 0) + amount,
      );

      financials.add(
        ReportFinancialRow(
          id: entry.id,
          type: type,
          category: entry.category,
          amount: amount,
          paymentStatus: status,
          paymentMethod: entry.paymentMethod,
          transactionDate: entry.transactionDate,
          description: entry.description,
          referenceNum: entry.referenceNum,
          userName: 'System',
        ),
      );
    }

    financials.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

    final totalFeedConsumed = feedLogs.fold<double>(
      0,
      (sum, log) => sum + log.amountConsumed,
    );
    final totalEggsCollected = eggLogs.fold<int>(
      0,
      (sum, log) => sum + log.eggsCollected,
    );
    final totalMortality = mortalityLogs.fold<int>(
      0,
      (sum, log) => sum + log.count,
    );

    var totalInitialBirds = 0;
    var totalCurrentBirds = 0;
    final batchRows = <ReportBatchRow>[];

    for (final batch in batches) {
      final status = batch.status.toLowerCase();
      if (status == 'active') {
        totalInitialBirds += batch.initialCount;
        totalCurrentBirds += batch.currentCount;
      }

      final batchFeed = await (_db.select(_db.feedingLogs)
            ..where((t) => t.batchId.equals(batch.id)))
          .get();
      final batchMortality = await (_db.select(_db.mortalities)
            ..where((t) => t.batchId.equals(batch.id)))
          .get();

      final batchName = batch.batchName.trim().isEmpty
          ? 'Batch ${batch.id.length > 5 ? batch.id.substring(0, 5) : batch.id}'
          : batch.batchName;

      batchRows.add(
        ReportBatchRow(
          id: batch.id,
          batchName: batchName,
          initialCount: batch.initialCount,
          currentCount: batch.currentCount,
          status: status,
          mortalityCount: batchMortality.fold(0, (sum, row) => sum + row.count),
          feedConsumed: batchFeed.fold(
            0.0,
            (sum, row) => sum + row.amountConsumed,
          ),
        ),
      );
    }

    final mortalityRate = totalInitialBirds > 0
        ? double.parse(
            (((totalInitialBirds - totalCurrentBirds) / totalInitialBirds) *
                    100)
                .toStringAsFixed(2),
          )
        : 0.0;

    var totalFcrSum = 0.0;
    var batchesWithFcrCount = 0;
    for (final batch in batchRows) {
      if (batch.feedConsumed > 0 && batch.currentCount > 0) {
        const avgWeight = 1.8;
        totalFcrSum += batch.feedConsumed / (batch.currentCount * avgWeight);
        batchesWithFcrCount++;
      }
    }
    final averageFcr = batchesWithFcrCount > 0
        ? double.parse(
            (totalFcrSum / batchesWithFcrCount).toStringAsFixed(2),
          )
        : 1.65;

    final trendsMap = <String, ({double revenue, double expense, int eggs, double feed, int mortality})>{};
    var day = start;
    while (!day.isAfter(end)) {
      final dateStr = _dateKey(day);
      trendsMap[dateStr] = (
        revenue: 0,
        expense: 0,
        eggs: 0,
        feed: 0,
        mortality: 0,
      );
      day = day.add(const Duration(days: 1));
    }

    for (final entry in periodEntries) {
      final dateStr = _dateKey(entry.transactionDate);
      final slot = trendsMap[dateStr];
      if (slot == null) continue;
      if (entry.type.toUpperCase() == 'REVENUE') {
        trendsMap[dateStr] = (
          revenue: slot.revenue + entry.amount,
          expense: slot.expense,
          eggs: slot.eggs,
          feed: slot.feed,
          mortality: slot.mortality,
        );
      } else {
        trendsMap[dateStr] = (
          revenue: slot.revenue,
          expense: slot.expense + entry.amount,
          eggs: slot.eggs,
          feed: slot.feed,
          mortality: slot.mortality,
        );
      }
    }

    for (final log in eggLogs) {
      final dateStr = _dateKey(log.logDate);
      final slot = trendsMap[dateStr];
      if (slot == null) continue;
      trendsMap[dateStr] = (
        revenue: slot.revenue,
        expense: slot.expense,
        eggs: slot.eggs + log.eggsCollected,
        feed: slot.feed,
        mortality: slot.mortality,
      );
    }

    for (final log in feedLogs) {
      final dateStr = _dateKey(log.logDate);
      final slot = trendsMap[dateStr];
      if (slot == null) continue;
      trendsMap[dateStr] = (
        revenue: slot.revenue,
        expense: slot.expense,
        eggs: slot.eggs,
        feed: slot.feed + log.amountConsumed,
        mortality: slot.mortality,
      );
    }

    for (final log in mortalityLogs) {
      final dateStr = _dateKey(log.logDate);
      final slot = trendsMap[dateStr];
      if (slot == null) continue;
      trendsMap[dateStr] = (
        revenue: slot.revenue,
        expense: slot.expense,
        eggs: slot.eggs,
        feed: slot.feed,
        mortality: slot.mortality + log.count,
      );
    }

    final dailyTrends = trendsMap.entries
        .map(
          (entry) => DailyReportTrend(
            date: entry.key,
            revenue: entry.value.revenue,
            expense: entry.value.expense,
            eggs: entry.value.eggs,
            feed: entry.value.feed,
            mortality: entry.value.mortality,
          ),
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return ComprehensiveFarmReport(
      startDate: start,
      endDate: end,
      kpis: ReportKpis(
        totalRevenue: totalRevenue,
        totalExpense: totalExpense,
        netIncome: totalRevenue - totalExpense,
        totalFeedConsumed: totalFeedConsumed,
        totalEggsCollected: totalEggsCollected,
        totalMortality: totalMortality,
        mortalityRate: mortalityRate,
        averageFcr: averageFcr,
      ),
      financials: financials,
      revenueByCategory: revenueByCategory,
      expenseByCategory: expenseByCategory,
      paymentStatusMatrix: paymentStatusMatrix,
      dailyTrends: dailyTrends,
      batches: batchRows,
      auditTimeline: const [],
    );
  }

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
