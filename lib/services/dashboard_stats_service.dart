import 'package:drift/drift.dart';

import '../data/local_db.dart';

class DashboardAlertInfo {
  const DashboardAlertInfo({
    required this.iconName,
    required this.message,
    required this.severity,
  });

  final String iconName;
  final String message;
  final String severity;
}

class DashboardStatsSnapshot {
  const DashboardStatsSnapshot({
    required this.totalBirds,
    required this.mortalityRatePercent,
    required this.todayDead,
    required this.overallDead,
    required this.todayEggs,
    required this.totalEggStock,
    required this.weeklyFeedBags,
    required this.alerts,
    required this.lowFeedCount,
  });

  final int totalBirds;
  final double mortalityRatePercent;
  final int todayDead;
  final int overallDead;
  final int todayEggs;
  final int totalEggStock;
  final double weeklyFeedBags;
  final List<DashboardAlertInfo> alerts;
  final int lowFeedCount;
}

class DashboardStatsService {
  DashboardStatsService(this._db);

  final AppDatabase _db;

  Future<DashboardStatsSnapshot> loadForFarm(String farmId) async {
    final today = _dayStart(DateTime.now());
    final tomorrow = today.add(const Duration(days: 1));
    final sevenDaysAgo = today.subtract(const Duration(days: 6));
    final threeDaysAhead = today.add(const Duration(days: 3));

    final batches = await (_db.select(_db.batches)
          ..where((t) => t.farmId.equals(farmId))
          ..where((t) => t.status.equals('active')))
        .get();
    final totalBirds = batches.fold<int>(0, (sum, b) => sum + b.currentCount);
    final initialBirds = batches.fold<int>(0, (sum, b) => sum + b.initialCount);

    final farmVar = Variable.withString(farmId);
    final todayVar = Variable.withDateTime(today);
    final tomorrowVar = Variable.withDateTime(tomorrow);
    final weekVar = Variable.withDateTime(sevenDaysAgo);

    final totals = await Future.wait([
      _db
          .customSelect(
            'SELECT COALESCE(SUM(count), 0) AS total FROM mortality WHERE farm_id = ?',
            variables: [farmVar],
            readsFrom: {_db.mortalities},
          )
          .getSingle(),
      _db
          .customSelect(
            'SELECT COALESCE(SUM(count), 0) AS total FROM mortality '
            'WHERE farm_id = ? AND log_date >= ? AND log_date < ?',
            variables: [farmVar, todayVar, tomorrowVar],
            readsFrom: {_db.mortalities},
          )
          .getSingle(),
      _db
          .customSelect(
            'SELECT COALESCE(SUM(eggs_collected), 0) AS total FROM egg_production '
            'WHERE farm_id = ? AND log_date >= ? AND log_date < ?',
            variables: [farmVar, todayVar, tomorrowVar],
            readsFrom: {_db.eggProductions},
          )
          .getSingle(),
      _db
          .customSelect(
            'SELECT COALESCE(stock_level, 0) AS total FROM inventory '
            'WHERE farm_id = ? AND category = ? LIMIT 1',
            variables: [farmVar, Variable.withString('EGGS')],
            readsFrom: {_db.inventory},
          )
          .getSingleOrNull(),
      _db
          .customSelect(
            'SELECT COALESCE(SUM(amount_consumed), 0) AS total FROM daily_feeding_logs '
            'WHERE farm_id = ? AND log_date >= ?',
            variables: [farmVar, weekVar],
            readsFrom: {_db.feedingLogs},
          )
          .getSingle(),
      _db
          .customSelect(
            'SELECT item_name, stock_level FROM inventory '
            'WHERE farm_id = ? AND lower(category) = ? AND stock_level < 500',
            variables: [farmVar, Variable.withString('feed')],
            readsFrom: {_db.inventory},
          )
          .get(),
      _db
          .customSelect(
            'SELECT DISTINCT batch_id FROM egg_production '
            'WHERE farm_id = ? AND log_date >= ? AND log_date < ?',
            variables: [farmVar, todayVar, tomorrowVar],
            readsFrom: {_db.eggProductions},
          )
          .get(),
      (_db.select(_db.vaccinationSchedules)
            ..where((t) => t.farmId.equals(farmId))
            ..where((t) => t.status.equals('PENDING')))
          .get(),
      (_db.select(_db.medicationSchedules)
            ..where((t) => t.farmId.equals(farmId))
            ..where((t) => t.status.equals('PENDING')))
          .get(),
    ]);

    final overallDead = (totals[0] as QueryRow).read<int>('total');
    final todayDead = (totals[1] as QueryRow).read<int>('total');
    final todayEggs = (totals[2] as QueryRow).read<int>('total');
    final eggStockRow = totals[3] as QueryRow?;
    final totalEggStock = eggStockRow == null
        ? 0
        : eggStockRow.read<double>('total').round();
    final weeklyFeedBags = (totals[4] as QueryRow).read<double>('total');
    final lowFeedRows = totals[5] as List<QueryRow>;
    final todayEggBatchIds = {
      for (final row in totals[6] as List<QueryRow>) row.read<String>('batch_id'),
    };
    final vaccinations = totals[7] as List<VaccinationSchedule>;
    final medications = totals[8] as List<MedicationSchedule>;

    final mortalityRatePercent = initialBirds == 0
        ? 0.0
        : (overallDead / initialBirds) * 100;

    final alerts = <DashboardAlertInfo>[];

    for (final v in vaccinations.where(
      (v) => !v.scheduledDate.isAfter(threeDaysAhead),
    )) {
      final batch = batches.where((b) => b.id == v.batchId).firstOrNull;
      alerts.add(
        DashboardAlertInfo(
          iconName: 'vaccine',
          message:
              'Upcoming Vaccination: ${v.vaccineName} for ${batch?.batchName ?? v.batchId}',
          severity: 'warning',
        ),
      );
    }

    for (final m in medications) {
      final batch = batches.where((b) => b.id == m.batchId).firstOrNull;
      alerts.add(
        DashboardAlertInfo(
          iconName: 'medication',
          message:
              'Medication Due: ${m.medicationName} for ${batch?.batchName ?? m.batchId}',
          severity: 'error',
        ),
      );
    }

    for (final batch in batches) {
      if (!todayEggBatchIds.contains(batch.id)) {
        alerts.add(
          DashboardAlertInfo(
            iconName: 'eggs',
            message: 'Egg Collection Due: Flock ${batch.batchName} needs collection',
            severity: 'info',
          ),
        );
      }
    }

    for (final item in lowFeedRows) {
      alerts.add(
        DashboardAlertInfo(
          iconName: 'feed',
          message:
              'Low Stock: ${item.read<String>('item_name')} (${item.read<double>('stock_level').toStringAsFixed(0)} bags remaining)',
          severity: 'error',
        ),
      );
    }

    return DashboardStatsSnapshot(
      totalBirds: totalBirds,
      mortalityRatePercent: mortalityRatePercent,
      todayDead: todayDead,
      overallDead: overallDead,
      todayEggs: todayEggs,
      totalEggStock: totalEggStock,
      weeklyFeedBags: weeklyFeedBags,
      alerts: alerts,
      lowFeedCount: lowFeedRows.length,
    );
  }

  Future<bool> isPremiumFarm(String farmId) async {
    final farm = await (_db.select(_db.farms)
          ..where((t) => t.id.equals(farmId)))
        .getSingleOrNull();
    if (farm == null) {
      return false;
    }
    final tier = farm.subscriptionTier.toUpperCase();
    return tier == 'PREMIUM' || tier == 'PAID_PREMIUM';
  }

  DateTime _dayStart(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
