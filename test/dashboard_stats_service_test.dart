import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poultry_pms_desktop/data/local_db.dart';
import 'package:poultry_pms_desktop/services/dashboard_stats_service.dart';
import 'package:poultry_pms_desktop/services/executive_metrics_service.dart';

void main() {
  group('DashboardStatsService', () {
    late AppDatabase db;
    late DashboardStatsService statsService;
    late ExecutiveMetricsService executiveService;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      statsService = DashboardStatsService(db);
      executiveService = ExecutiveMetricsService(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('returns empty snapshot for unknown farm', () async {
      final snapshot = await statsService.loadForFarm('missing-farm');
      expect(snapshot.totalBirds, 0);
      expect(snapshot.alerts, isEmpty);
      expect(snapshot.mortalityRatePercent, 0);
    });

    test('executive stats compute zero profit without activity', () async {
      final snapshot = await executiveService.loadExecutiveStats('missing-farm');
      expect(snapshot.totalProfit, 0);
      expect(snapshot.profitTrend, 0);
      expect(snapshot.globalFcr, 0);
    });
  });
}
