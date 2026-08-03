import 'dart:math' as math;

import 'package:drift/drift.dart' hide Batch;
import 'package:flutter/foundation.dart';

import '../data/local_db.dart';

class WeeklyFcrPoint {
  final int week;
  final double fcr;
  final double feedKg;
  final double outputKg;

  const WeeklyFcrPoint({
    required this.week,
    required this.fcr,
    required this.feedKg,
    required this.outputKg,
  });

  factory WeeklyFcrPoint.fromMap(Map<String, dynamic> map) {
    return WeeklyFcrPoint(
      week: map['week'] as int,
      fcr: (map['fcr'] as num).toDouble(),
      feedKg: (map['feedKg'] as num).toDouble(),
      outputKg: (map['outputKg'] as num).toDouble(),
    );
  }
}

class BatchPerformanceSnapshot {
  final String batchId;
  final String batchName;
  final String type;
  final String status;
  final int initialCount;
  final int currentCount;
  final double totalFeedKg;
  final double totalEggOutputKg;
  final double biomassGainKg;
  final int totalEggs;
  final int totalDeadBirds;
  final double mortalityRate;
  final double grossRevenue;
  final double directExpenses;
  final double allocatedSharedExpenses;
  final double totalCosts;
  final double netProfitability;
  final double currentFcr;
  final List<WeeklyFcrPoint> weeklyFcr;

  const BatchPerformanceSnapshot({
    required this.batchId,
    required this.batchName,
    required this.type,
    required this.status,
    required this.initialCount,
    required this.currentCount,
    required this.totalFeedKg,
    required this.totalEggOutputKg,
    required this.biomassGainKg,
    required this.totalEggs,
    required this.totalDeadBirds,
    required this.mortalityRate,
    required this.grossRevenue,
    required this.directExpenses,
    required this.allocatedSharedExpenses,
    required this.totalCosts,
    required this.netProfitability,
    required this.currentFcr,
    required this.weeklyFcr,
  });

  factory BatchPerformanceSnapshot.fromMap(Map<String, dynamic> map) {
    final weekly = (map['weeklyFcr'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(WeeklyFcrPoint.fromMap)
        .toList();

    return BatchPerformanceSnapshot(
      batchId: map['batchId'] as String,
      batchName: map['batchName'] as String,
      type: map['type'] as String,
      status: map['status'] as String,
      initialCount: map['initialCount'] as int,
      currentCount: map['currentCount'] as int,
      totalFeedKg: (map['totalFeedKg'] as num).toDouble(),
      totalEggOutputKg: (map['totalEggOutputKg'] as num).toDouble(),
      biomassGainKg: (map['biomassGainKg'] as num).toDouble(),
      totalEggs: map['totalEggs'] as int,
      totalDeadBirds: map['totalDeadBirds'] as int,
      mortalityRate: (map['mortalityRate'] as num).toDouble(),
      grossRevenue: (map['grossRevenue'] as num).toDouble(),
      directExpenses: (map['directExpenses'] as num).toDouble(),
      allocatedSharedExpenses: (map['allocatedSharedExpenses'] as num)
          .toDouble(),
      totalCosts: (map['totalCosts'] as num).toDouble(),
      netProfitability: (map['netProfitability'] as num).toDouble(),
      currentFcr: (map['currentFcr'] as num).toDouble(),
      weeklyFcr: weekly,
    );
  }
}

class BatchAnalyticsProcessor {
  const BatchAnalyticsProcessor._();

  static Future<List<BatchPerformanceSnapshot>> load(AppDatabase db) async {
    final batches = await (db.select(
      db.batches,
    )..orderBy([(t) => OrderingTerm.asc(t.batchName)])).get();

    final results = await Future.wait([
      _sumFeedByBatch(db),
      _sumEggsByBatch(db),
      _sumMortalityByBatch(db),
      _sumRevenueByBatch(db),
      _sumExpensesByBatch(db, shared: false),
      _sumExpensesByBatch(db, shared: true),
      db.select(db.feedingLogs).get(),
      db.select(db.eggProductions).get(),
      db.select(db.weightRecords).get(),
    ]);

    final payload = <String, dynamic>{
      'batches': batches.map(_batchToMap).toList(),
      'feedTotals': results[0],
      'eggTotals': results[1],
      'mortalityTotals': results[2],
      'revenueTotals': results[3],
      'directExpenseTotals': results[4],
      'allocatedExpenseTotals': results[5],
      'feedRecords': (results[6] as List<FeedingLog>)
          .map(_feedingToMap)
          .toList(),
      'eggRecords': (results[7] as List<EggProduction>)
          .map(_eggProductionToMap)
          .toList(),
      'weightRecords': (results[8] as List<WeightRecord>)
          .map(_weightRecordToMap)
          .toList(),
    };

    final rows = await compute(_buildBatchPerformancePayload, payload);
    return rows.map(BatchPerformanceSnapshot.fromMap).toList();
  }

  static Map<String, dynamic> _batchToMap(Batch batch) {
    return <String, dynamic>{
      'id': batch.id,
      'batchName': batch.batchName,
      'type': batch.type,
      'status': batch.status,
      'initialCount': batch.initialCount,
      'currentCount': batch.currentCount,
      'arrivalMs': batch.arrivalDate.millisecondsSinceEpoch,
      'initialActualCost': batch.initialActualCost ?? 0.0,
    };
  }

  static Map<String, dynamic> _feedingToMap(FeedingLog log) {
    return <String, dynamic>{
      'batchId': log.batchId,
      'amount': log.amountConsumed,
      'dateMs': log.logDate.millisecondsSinceEpoch,
    };
  }

  static Map<String, dynamic> _eggProductionToMap(EggProduction log) {
    return <String, dynamic>{
      'batchId': log.batchId,
      'eggs': log.eggsCollected,
      'dateMs': log.logDate.millisecondsSinceEpoch,
    };
  }

  static Map<String, dynamic> _weightRecordToMap(WeightRecord record) {
    return <String, dynamic>{
      'batchId': record.batchId,
      'averageWeight': record.averageWeight,
      'dateMs': record.logDate.millisecondsSinceEpoch,
    };
  }

  static Future<Map<String, double>> _sumFeedByBatch(AppDatabase db) async {
    final amount = db.feedingLogs.amountConsumed.sum();
    final query = db.selectOnly(db.feedingLogs)
      ..addColumns([db.feedingLogs.batchId, amount])
      ..where(db.feedingLogs.batchId.isNotNull())
      ..groupBy([db.feedingLogs.batchId]);

    final rows = await query.get();
    return {
      for (final row in rows)
        if (row.read(db.feedingLogs.batchId) != null)
          row.read(db.feedingLogs.batchId)!: row.read(amount) ?? 0.0,
    };
  }

  static Future<Map<String, int>> _sumEggsByBatch(AppDatabase db) async {
    final eggs = db.eggProductions.eggsCollected.sum();
    final query = db.selectOnly(db.eggProductions)
      ..addColumns([db.eggProductions.batchId, eggs])
      ..groupBy([db.eggProductions.batchId]);

    final rows = await query.get();
    return {
      for (final row in rows)
        if (row.read(db.eggProductions.batchId) != null)
          row.read(db.eggProductions.batchId)!: row.read(eggs) ?? 0,
    };
  }

  static Future<Map<String, int>> _sumMortalityByBatch(AppDatabase db) async {
    final deaths = db.mortalities.count.sum();
    final query = db.selectOnly(db.mortalities)
      ..addColumns([db.mortalities.batchId, deaths])
      ..groupBy([db.mortalities.batchId]);

    final rows = await query.get();
    return {
      for (final row in rows)
        if (row.read(db.mortalities.batchId) != null)
          row.read(db.mortalities.batchId)!: row.read(deaths) ?? 0,
    };
  }

  static Future<Map<String, double>> _sumRevenueByBatch(AppDatabase db) async {
    final total = db.sales.totalAmount.sum();
    final query = db.selectOnly(db.sales)
      ..addColumns([db.sales.batchId, total])
      ..where(db.sales.batchId.isNotNull())
      ..groupBy([db.sales.batchId]);

    final rows = await query.get();
    return {
      for (final row in rows)
        if (row.read(db.sales.batchId) != null)
          row.read(db.sales.batchId)!: row.read(total) ?? 0.0,
    };
  }

  static Future<Map<String, double>> _sumExpensesByBatch(
    AppDatabase db, {
    required bool shared,
  }) async {
    final total = db.expenses.amount.sum();
    final query = db.selectOnly(db.expenses)
      ..addColumns([db.expenses.batchId, total])
      ..where(
        db.expenses.batchId.isNotNull() &
            db.expenses.isSharedAllocation.equals(shared),
      )
      ..groupBy([db.expenses.batchId]);

    final rows = await query.get();
    return {
      for (final row in rows)
        if (row.read(db.expenses.batchId) != null)
          row.read(db.expenses.batchId)!: row.read(total) ?? 0.0,
    };
  }
}

List<Map<String, dynamic>> _buildBatchPerformancePayload(
  Map<String, dynamic> payload,
) {
  final batches = (payload['batches'] as List<dynamic>).cast<Map>();
  final feedTotals = _doubleMap(payload['feedTotals']);
  final eggTotals = _intMap(payload['eggTotals']);
  final mortalityTotals = _intMap(payload['mortalityTotals']);
  final revenueTotals = _doubleMap(payload['revenueTotals']);
  final directExpenseTotals = _doubleMap(payload['directExpenseTotals']);
  final allocatedExpenseTotals = _doubleMap(payload['allocatedExpenseTotals']);

  final feedRecords = _groupByBatch(payload['feedRecords'] as List<dynamic>);
  final eggRecords = _groupByBatch(payload['eggRecords'] as List<dynamic>);
  final weightRecords = _groupByBatch(
    payload['weightRecords'] as List<dynamic>,
  );

  return batches.map((batch) {
    final id = batch['id'] as String;
    final type = batch['type'] as String;
    final isLayer = type.toUpperCase().contains('LAYER');
    final initialCount = batch['initialCount'] as int;
    final currentCount = batch['currentCount'] as int;
    final initialCost = (batch['initialActualCost'] as num).toDouble();
    final totalFeed = feedTotals[id] ?? 0.0;
    final totalEggs = eggTotals[id] ?? 0;
    final deadBirds = mortalityTotals[id] ?? 0;
    final revenue = revenueTotals[id] ?? 0.0;
    final directExpenses = (directExpenseTotals[id] ?? 0.0) + initialCost;
    final allocatedExpenses = allocatedExpenseTotals[id] ?? 0.0;
    final totalCosts = directExpenses + allocatedExpenses;
    final eggOutputKg = totalEggs * 0.06;
    final biomassGainKg = _biomassGainKg(
      weightRecords[id] ?? const [],
      currentCount,
    );
    final outputKg = isLayer ? eggOutputKg : biomassGainKg;
    final currentFcr = calculateBatchFeedConversionRatio(
      livestockType: type,
      totalFeed: totalFeed,
      eggOutput: totalEggs,
      birdBiomassGain: biomassGainKg,
    );
    final mortalityRate = calculateBatchMortalityRatePercentage(
      totalDeadBirds: deadBirds,
      initialPopulation: initialCount,
    );

    return <String, dynamic>{
      'batchId': id,
      'batchName': batch['batchName'] as String,
      'type': type,
      'status': batch['status'] as String,
      'initialCount': initialCount,
      'currentCount': currentCount,
      'totalFeedKg': totalFeed,
      'totalEggOutputKg': eggOutputKg,
      'biomassGainKg': biomassGainKg,
      'totalEggs': totalEggs,
      'totalDeadBirds': deadBirds,
      'mortalityRate': mortalityRate,
      'grossRevenue': revenue,
      'directExpenses': directExpenses,
      'allocatedSharedExpenses': allocatedExpenses,
      'totalCosts': totalCosts,
      'netProfitability': revenue - totalCosts,
      'currentFcr': currentFcr,
      'weeklyFcr': _weeklyFcr(
        batch: batch,
        isLayer: isLayer,
        currentCount: currentCount,
        feedRecords: feedRecords[id] ?? const [],
        eggRecords: eggRecords[id] ?? const [],
        weightRecords: weightRecords[id] ?? const [],
      ),
    };
  }).toList();
}

Map<String, double> _doubleMap(dynamic value) {
  final source = (value as Map).cast<String, dynamic>();
  return source.map((key, val) => MapEntry(key, (val as num).toDouble()));
}

Map<String, int> _intMap(dynamic value) {
  final source = (value as Map).cast<String, dynamic>();
  return source.map((key, val) => MapEntry(key, (val as num).toInt()));
}

Map<String, List<Map<String, dynamic>>> _groupByBatch(List<dynamic> rows) {
  final grouped = <String, List<Map<String, dynamic>>>{};
  for (final row in rows.cast<Map<String, dynamic>>()) {
    final batchId = row['batchId'] as String?;
    if (batchId == null || batchId.isEmpty) continue;
    grouped.putIfAbsent(batchId, () => []).add(row);
  }
  return grouped;
}

double _biomassGainKg(List<Map<String, dynamic>> records, int currentCount) {
  if (records.isEmpty || currentCount <= 0) return 0.0;
  final sorted = [...records]..sort(_byDateMs);
  final firstWeight = (sorted.first['averageWeight'] as num).toDouble();
  final latestWeight = (sorted.last['averageWeight'] as num).toDouble();
  final gainPerBird = latestWeight > firstWeight
      ? latestWeight - firstWeight
      : latestWeight;
  return math.max(gainPerBird, 0.0) * currentCount;
}

List<Map<String, dynamic>> _weeklyFcr({
  required Map batch,
  required bool isLayer,
  required int currentCount,
  required List<Map<String, dynamic>> feedRecords,
  required List<Map<String, dynamic>> eggRecords,
  required List<Map<String, dynamic>> weightRecords,
}) {
  final arrivalMs = batch['arrivalMs'] as int;
  final arrival = DateTime.fromMillisecondsSinceEpoch(arrivalMs);
  final ageDays = math.max(DateTime.now().difference(arrival).inDays, 7);
  final maxWeeks = math.min(26, math.max(1, (ageDays / 7).ceil()));
  final sortedWeights = [...weightRecords]..sort(_byDateMs);
  final points = <Map<String, dynamic>>[];

  for (var week = 1; week <= maxWeeks; week++) {
    final cutoffMs = arrival
        .add(Duration(days: week * 7))
        .millisecondsSinceEpoch;
    final feedKg = feedRecords
        .where((row) => (row['dateMs'] as int) <= cutoffMs)
        .fold<double>(
          0.0,
          (sum, row) => sum + (row['amount'] as num).toDouble(),
        );

    double outputKg;
    if (isLayer) {
      final eggs = eggRecords
          .where((row) => (row['dateMs'] as int) <= cutoffMs)
          .fold<int>(0, (sum, row) => sum + (row['eggs'] as int));
      outputKg = eggs * 0.06;
    } else {
      final recordsToDate = sortedWeights
          .where((row) => (row['dateMs'] as int) <= cutoffMs)
          .toList();
      outputKg = _biomassGainKg(recordsToDate, currentCount);
    }

    if (feedKg <= 0 || outputKg <= 0) continue;
    points.add(<String, dynamic>{
      'week': week,
      'fcr': feedKg / outputKg,
      'feedKg': feedKg,
      'outputKg': outputKg,
    });
  }

  return points;
}

int _byDateMs(Map<String, dynamic> a, Map<String, dynamic> b) {
  return (a['dateMs'] as int).compareTo(b['dateMs'] as int);
}

double calculateBatchFeedConversionRatio({
  required String livestockType,
  required double totalFeed,
  required int eggOutput,
  required double birdBiomassGain,
}) {
  final isLayer = livestockType.toUpperCase().contains('LAYER');
  final denominator = isLayer ? eggOutput.toDouble() : birdBiomassGain;
  if (denominator <= 0 || totalFeed <= 0) return 0;
  return _roundMetric(totalFeed / denominator);
}

double calculateBatchMortalityRatePercentage({
  required int totalDeadBirds,
  required int initialPopulation,
}) {
  if (initialPopulation <= 0) return 0;
  return _roundMetric((totalDeadBirds / initialPopulation) * 100);
}

double _roundMetric(double value, {int decimals = 2}) {
  if (!value.isFinite) return 0;
  final factor = math.pow(10, decimals).toDouble();
  return (value * factor).roundToDouble() / factor;
}
