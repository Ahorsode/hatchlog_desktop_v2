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
    final sevenDaysAgo = today.subtract(const Duration(days: 6));
    final threeDaysAhead = today.add(const Duration(days: 3));

    final batches = await (_db.select(_db.batches)
          ..where((t) => t.farmId.equals(farmId))
          ..where((t) => t.status.equals('active')))
        .get();
    final totalBirds = batches.fold<int>(0, (sum, b) => sum + b.currentCount);
    final initialBirds = batches.fold<int>(0, (sum, b) => sum + b.initialCount);

    final mortalities = await (_db.select(_db.mortalities)
          ..where((t) => t.farmId.equals(farmId)))
        .get();
    final overallDead = mortalities.fold<int>(0, (sum, m) => sum + m.count);
    final todayDead = mortalities
        .where((m) => _isSameDay(m.logDate, today))
        .fold<int>(0, (sum, m) => sum + m.count);
    final mortalityRatePercent = initialBirds == 0
        ? 0.0
        : (overallDead / initialBirds) * 100;

    final eggLogs = await (_db.select(_db.eggProductions)
          ..where((t) => t.farmId.equals(farmId)))
        .get();
    final todayEggs = eggLogs
        .where((e) => _isSameDay(e.logDate, today))
        .fold<int>(0, (sum, e) => sum + e.eggsCollected);

    final eggInventory = await (_db.select(_db.inventory)
          ..where((t) => t.farmId.equals(farmId))
          ..where((t) => t.category.equals('EGGS')))
        .get();
    final totalEggStock = eggInventory.isEmpty
        ? 0
        : eggInventory.first.stockLevel.round();

    final feedLogs = await (_db.select(_db.feedingLogs)
          ..where((t) => t.farmId.equals(farmId)))
        .get();
    final weeklyFeedBags = feedLogs
        .where((log) => !log.logDate.isBefore(sevenDaysAgo))
        .fold<double>(0, (sum, log) => sum + log.amountConsumed);

    final inventory = await (_db.select(_db.inventory)
          ..where((t) => t.farmId.equals(farmId)))
        .get();
    final lowFeedItems = inventory
        .where(
          (item) =>
              (item.category?.toLowerCase() ?? '') == 'feed' &&
              item.stockLevel < 500,
        )
        .toList();

    final alerts = <DashboardAlertInfo>[];

    final vaccinations = await (_db.select(_db.vaccinationSchedules)
          ..where((t) => t.farmId.equals(farmId))
          ..where((t) => t.status.equals('PENDING')))
        .get();
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

    final medications = await (_db.select(_db.medicationSchedules)
          ..where((t) => t.farmId.equals(farmId))
          ..where((t) => t.status.equals('PENDING')))
        .get();
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
      final loggedToday = eggLogs.any(
        (e) => e.batchId == batch.id && _isSameDay(e.logDate, today),
      );
      if (!loggedToday) {
        alerts.add(
          DashboardAlertInfo(
            iconName: 'eggs',
            message: 'Egg Collection Due: Flock ${batch.batchName} needs collection',
            severity: 'info',
          ),
        );
      }
    }

    for (final item in lowFeedItems) {
      alerts.add(
        DashboardAlertInfo(
          iconName: 'feed',
          message:
              'Low Stock: ${item.itemName} (${item.stockLevel.toStringAsFixed(0)} bags remaining)',
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
      lowFeedCount: lowFeedItems.length,
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

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
