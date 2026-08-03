import 'dart:math';

import 'package:drift/drift.dart' show OrderingTerm, QueryRow, Variable;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/local_db.dart';
import '../services/auth_service.dart';
import '../services/dashboard_stats_service.dart';
import '../services/executive_metrics_service.dart';
import '../services/license_service.dart';
import '../utils/farm_utils.dart';
import '../utils/user_role.dart';
import 'egg_production_screen.dart';
import 'feed_management_screen.dart';
import 'main_scaffold.dart';
import 'mortality_screen.dart';
import '../widgets/financial_init_wizard.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  bool _checkedFinancialInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_checkedFinancialInit) return;
    _checkedFinancialInit = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await FinancialInitWizard.promptIfNeeded(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _currentRole(),
      builder: (context, snapshot) {
        final role = UserRoleUtils.normalize(snapshot.data ?? '');
        if (role == UserRoleUtils.operational) {
          return const _OperationalDashboard();
        }
        return const _OwnerDashboard();
      },
    );
  }

  Future<String> _currentRole() async {
    final session = UserSession();
    if (session.currentWorkerRole == null) {
      await session.hydrateFromPrefs();
    }
    return session.currentWorkerRole ?? '';
  }
}

class _OwnerDashboard extends StatelessWidget {
  const _OwnerDashboard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 32, 40, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Farm Command Centre',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat(
                            'EEEE, d MMMM yyyy',
                          ).format(DateTime.now()),
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const _SyncBadge(),
                  const SizedBox(width: 12),
                  const _SubscriptionBadge(),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: _ExecutiveSummarySection(),
            ),
            const SizedBox(height: 28),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: _OwnerKpiStrip(),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 1100;
                  if (stacked) {
                    return Column(
                      children: const [
                        _ActiveBatchesSection(),
                        SizedBox(height: 24),
                        _AlertsAndSummaryColumn(),
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Expanded(flex: 3, child: _ActiveBatchesSection()),
                      SizedBox(width: 24),
                      Expanded(flex: 2, child: _AlertsAndSummaryColumn()),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 1100) {
                    return const SizedBox.shrink();
                  }
                  return Row(
                    children: const [
                      Expanded(
                        child: _TrendChartCard(
                          title: 'Egg Production',
                          tableName: 'egg_production',
                          dateColumn: 'log_date',
                          valueColumn: 'eggs_collected',
                          accent: Colors.amber,
                          suffix: '',
                        ),
                      ),
                      SizedBox(width: 18),
                      Expanded(
                        child: _TrendChartCard(
                          title: 'Feed Consumption',
                          tableName: 'daily_feeding_logs',
                          dateColumn: 'log_date',
                          valueColumn: 'amount_consumed',
                          accent: Colors.teal,
                          suffix: ' kg',
                        ),
                      ),
                      SizedBox(width: 18),
                      Expanded(
                        child: _TrendChartCard(
                          title: 'Revenue',
                          tableName: 'sales',
                          dateColumn: 'sale_date',
                          valueColumn: 'total_amount',
                          accent: Colors.green,
                          suffix: '',
                          currency: true,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 1100;
                  if (stacked) {
                    return Column(
                      children: const [
                        _RecentActivityPanel(),
                        SizedBox(height: 24),
                        _HousesAtGlancePanel(),
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Expanded(flex: 3, child: _RecentActivityPanel()),
                      SizedBox(width: 24),
                      Expanded(flex: 2, child: _HousesAtGlancePanel()),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OperationalDashboard extends StatelessWidget {
  const _OperationalDashboard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Operations",
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('EEEE, d MMMM').format(DateTime.now()),
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 15),
            ),
            const SizedBox(height: 24),
            const _OperationalKpiStrip(),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 900;
                if (stacked) {
                  return Column(
                    children: const [
                      _OperationalBatchList(),
                      SizedBox(height: 20),
                      _QuickLogPanel(),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Expanded(flex: 3, child: _OperationalBatchList()),
                    SizedBox(width: 20),
                    Expanded(flex: 2, child: _QuickLogPanel()),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            const _TodayActivityPanel(),
          ],
        ),
      ),
    );
  }
}

class _ExecutiveSummarySection extends StatelessWidget {
  const _ExecutiveSummarySection();

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    return FutureBuilder<String?>(
      future: FarmUtils.getBoundFarmId(),
      builder: (context, farmSnapshot) {
        final farmId = farmSnapshot.data;
        if (farmId == null || farmId.isEmpty) {
          return const SizedBox.shrink();
        }
        final statsService = DashboardStatsService(db);
        final executiveService = ExecutiveMetricsService(db);
        return FutureBuilder<bool>(
          future: statsService.isPremiumFarm(farmId),
          builder: (context, premiumSnapshot) {
            if (premiumSnapshot.data != true) {
              return const SizedBox.shrink();
            }
            return FutureBuilder<ExecutiveStatsSnapshot>(
              future: executiveService.loadExecutiveStats(farmId),
              builder: (context, execSnapshot) {
                final stats = execSnapshot.data;
                if (stats == null) {
                  return const SizedBox.shrink();
                }
                final money = NumberFormat.currency(
                  locale: 'en_GH',
                  symbol: 'GHS ',
                );
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: _cardDecoration(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Executive Summary',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _ExecutiveMetric(
                            label: '7d Net Profit',
                            value: money.format(stats.totalProfit),
                            detail:
                                '${stats.profitTrend.toStringAsFixed(1)}% revenue vs prior week',
                          ),
                          _ExecutiveMetric(
                            label: 'Global FCR',
                            value: stats.globalFcr > 0
                                ? stats.globalFcr.toStringAsFixed(2)
                                : '—',
                            detail: '${stats.activeLivestock} active birds',
                          ),
                          _ExecutiveMetric(
                            label: 'Customer Debt',
                            value: money.format(stats.customerDebt),
                            detail:
                                'Mortality ${stats.mortalityRatePercent.toStringAsFixed(1)}%',
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ExecutiveMetric extends StatelessWidget {
  const _ExecutiveMetric({
    required this.label,
    required this.value,
    required this.detail,
  });

  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _OwnerKpiStrip extends StatelessWidget {
  const _OwnerKpiStrip();

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    final money = NumberFormat.currency(locale: 'en_GH', symbol: 'GHS ');

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            StreamBuilder<List<Batch>>(
              stream: db.select(db.batches).watch(),
              builder: (context, snapshot) {
                final active = (snapshot.data ?? const <Batch>[])
                    .where((b) => b.status == 'active')
                    .toList();
                final birds = active.fold(0, (sum, b) => sum + b.currentCount);
                return _KpiCard(
                  label: 'Total Live Birds',
                  value: NumberFormat.decimalPattern().format(birds),
                  subLabel: 'across ${active.length} active batches',
                  icon: Icons.pets_rounded,
                  color: Colors.orange,
                  parentWidth: width,
                );
              },
            ),
            StreamBuilder<List<EggProduction>>(
              stream: db.select(db.eggProductions).watch(),
              builder: (context, snapshot) {
                final logs = snapshot.data ?? const <EggProduction>[];
                final today = _todayRange();
                final yesterday = today.$1.subtract(const Duration(days: 1));
                final yesterdayEnd = today.$1.subtract(
                  const Duration(milliseconds: 1),
                );
                final todayEggs = logs
                    .where((e) => _inRange(e.logDate, today.$1, today.$2))
                    .fold(0, (sum, e) => sum + e.eggsCollected);
                final yesterdayEggs = logs
                    .where((e) => _inRange(e.logDate, yesterday, yesterdayEnd))
                    .fold(0, (sum, e) => sum + e.eggsCollected);
                final diff = todayEggs - yesterdayEggs;
                return _KpiCard(
                  label: "Today's Eggs",
                  value: NumberFormat.decimalPattern().format(todayEggs),
                  subLabel: diff == 0
                      ? 'Same as yesterday'
                      : diff > 0
                      ? 'up ${NumberFormat.decimalPattern().format(diff)} vs yesterday'
                      : 'down ${NumberFormat.decimalPattern().format(diff.abs())} vs yesterday',
                  trend: diff == 0
                      ? 0
                      : diff > 0
                      ? 1
                      : -1,
                  icon: Icons.egg_rounded,
                  color: Colors.amber,
                  parentWidth: width,
                );
              },
            ),
            StreamBuilder<List<Sale>>(
              stream: db.select(db.sales).watch(),
              builder: (context, snapshot) {
                final sales = (snapshot.data ?? const <Sale>[])
                    .where((s) => _isThisMonth(s.saleDate))
                    .toList();
                final revenue = sales.fold(
                  0.0,
                  (sum, s) => sum + s.totalAmount,
                );
                return _KpiCard(
                  label: 'Revenue This Month',
                  value: money.format(revenue),
                  subLabel: '${sales.length} sales this month',
                  icon: Icons.trending_up_rounded,
                  color: Colors.green,
                  parentWidth: width,
                );
              },
            ),
            StreamBuilder<List<FeedingLog>>(
              stream: db.select(db.feedingLogs).watch(),
              builder: (context, snapshot) {
                final cutoff = DateTime.now().subtract(const Duration(days: 7));
                final logs = (snapshot.data ?? const <FeedingLog>[])
                    .where((f) => !f.logDate.isBefore(cutoff))
                    .toList();
                final total = logs.fold(
                  0.0,
                  (sum, f) => sum + f.amountConsumed,
                );
                return _KpiCard(
                  label: 'Feed This Week',
                  value: '${total.toStringAsFixed(1)} kg',
                  subLabel: 'daily avg: ${(total / 7).toStringAsFixed(1)} kg',
                  icon: Icons.restaurant_rounded,
                  color: Colors.teal,
                  parentWidth: width,
                );
              },
            ),
            StreamBuilder<double>(
              stream:
                  CombineLatestStream.list([
                    db.select(db.sales).watch(),
                    db.select(db.expenses).watch(),
                  ]).map((lists) {
                    final sales = (lists[0] as List<Sale>)
                        .where((s) => _isThisMonth(s.saleDate))
                        .fold(0.0, (sum, s) => sum + s.totalAmount);
                    final expenses = (lists[1] as List<Expense>)
                        .where((e) => _isThisMonth(e.date))
                        .fold(0.0, (sum, e) => sum + e.amount);
                    return sales - expenses;
                  }),
              builder: (context, snapshot) {
                final net = snapshot.data ?? 0;
                return _KpiCard(
                  label: 'Net Income This Month',
                  value: money.format(net),
                  subLabel: 'Revenue minus expenses',
                  icon: Icons.account_balance_wallet_rounded,
                  color: Colors.purple,
                  valueColor: net >= 0
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFDC2626),
                  parentWidth: width,
                );
              },
            ),
            StreamBuilder<(int, double)>(
              stream:
                  CombineLatestStream.list([
                    db.select(db.mortalities).watch(),
                    db.select(db.batches).watch(),
                  ]).map((lists) {
                    final mortalities = lists[0] as List<Mortality>;
                    final batches = lists[1] as List<Batch>;
                    final overallDead = mortalities.fold(
                      0,
                      (sum, m) => sum + m.count,
                    );
                    final todayDead = mortalities
                        .where((m) => _isToday(m.logDate))
                        .fold(0, (sum, m) => sum + m.count);
                    final initialBirds = batches.fold(
                      0,
                      (sum, b) => sum + b.initialCount,
                    );
                    final rate = initialBirds == 0
                        ? 0.0
                        : overallDead / initialBirds * 100;
                    return (todayDead, rate);
                  }),
              builder: (context, snapshot) {
                final data = snapshot.data ?? (0, 0.0);
                final rateColor = data.$2 > 5
                    ? Colors.red
                    : data.$2 > 2
                    ? Colors.amber
                    : Colors.green;
                return _KpiCard(
                  label: 'Mortality Rate',
                  value: '${data.$2.toStringAsFixed(1)}%',
                  subLabel: '${data.$1} today · ${data.$2.toStringAsFixed(1)}% overall',
                  icon: Icons.warning_rounded,
                  color: Colors.red,
                  subLabelColor: rateColor,
                  parentWidth: width,
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _ActiveBatchesSection extends StatelessWidget {
  const _ActiveBatchesSection();

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    return StreamBuilder<List<dynamic>>(
      stream: CombineLatestStream.list([
        db.select(db.batches).watch(),
        db.select(db.houses).watch(),
        db.select(db.eggProductions).watch(),
      ]),
      builder: (context, snapshot) {
        final lists = snapshot.data;
        final batches = ((lists?[0] ?? const <Batch>[]) as List<Batch>)
            .where((b) => b.status == 'active')
            .toList();
        final houses = {
          for (final h in ((lists?[1] ?? const <House>[]) as List<House>))
            h.id: h.name,
        };
        final eggs =
            (lists?[2] ?? const <EggProduction>[]) as List<EggProduction>;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              title: 'Active Batches',
              icon: Icons.grid_view_rounded,
              actionLabel: 'View All',
              badgeLabel: '${batches.length}',
              onAction: () => MainScaffold.of(context)?.setSelectedIndex(1),
            ),
            const SizedBox(height: 14),
            if (batches.isEmpty)
              _EmptyPanel(
                icon: Icons.pets_outlined,
                message: 'No active batches registered.',
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final columns = width > 1200
                      ? 3
                      : width > 800
                      ? 2
                      : 1;
                  final gap = 16.0;
                  final cardWidth = (width - (columns - 1) * gap) / columns;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: batches
                        .take(9)
                        .map(
                          (batch) => SizedBox(
                            width: cardWidth,
                            child: _OwnerBatchCard(
                              batch: batch,
                              houseName: batch.houseId == null
                                  ? null
                                  : houses[batch.houseId],
                              todayEggs: _todayEggsForBatch(eggs, batch.id),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

class _OwnerBatchCard extends StatelessWidget {
  final Batch batch;
  final String? houseName;
  final int todayEggs;

  const _OwnerBatchCard({
    required this.batch,
    required this.houseName,
    required this.todayEggs,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLayer = batch.type.contains('LAYER');
    final ageDays = max(0, DateTime.now().difference(batch.arrivalDate).inDays);
    final targetDays = isLayer ? 70 : 42;
    final progress = (ageDays / targetDays).clamp(0.0, 1.0);
    final typeLabel = batch.type
        .replaceAll('POULTRY_', '')
        .replaceAll('_', ' ');

    return InkWell(
      onTap: () => MainScaffold.of(context)?.setSelectedIndex(1),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 236,
        padding: const EdgeInsets.all(18),
        decoration: _cardDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _SmallBadge(
                  label: typeLabel,
                  color: isLayer ? Colors.purple : Colors.blue,
                ),
                const Spacer(),
                if (houseName != null)
                  Flexible(
                    child: _SmallBadge(
                      label: houseName!,
                      color: cs.primary,
                      icon: Icons.home_work_rounded,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              batch.batchName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Age: $ageDays days',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(999),
                    backgroundColor: cs.outline.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Week ${(ageDays / 7).ceil().clamp(1, 99)} of ${(targetDays / 7).ceil()}',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            ),
            const Spacer(),
            Divider(color: cs.outline.withValues(alpha: 0.15), height: 18),
            Row(
              children: [
                Icon(Icons.pets_rounded, size: 16, color: cs.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${NumberFormat.decimalPattern().format(batch.currentCount)} birds',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (isLayer) ...[
                  const SizedBox(width: 10),
                  const Icon(Icons.egg_rounded, size: 16, color: Colors.amber),
                  const SizedBox(width: 6),
                  Text(
                    '$todayEggs today',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertsAndSummaryColumn extends StatelessWidget {
  const _AlertsAndSummaryColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _AlertsPanel(),
        SizedBox(height: 20),
        _MonthlySummaryPanel(),
      ],
    );
  }
}

class _AlertsPanel extends StatelessWidget {
  const _AlertsPanel();

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    return FutureBuilder<LicenseConfig?>(
      future: LicenseService(db).getConfig(),
      builder: (context, licenseSnapshot) {
        final license = licenseSnapshot.data;
        return FutureBuilder<String?>(
          future: FarmUtils.getBoundFarmId(),
          builder: (context, farmSnapshot) {
            final farmId = farmSnapshot.data;
            if (farmId == null || farmId.isEmpty) {
              return _alertsContainer(context, const []);
            }
            return FutureBuilder<DashboardStatsSnapshot>(
              future: DashboardStatsService(db).loadForFarm(farmId),
              builder: (context, statsSnapshot) {
                final stats = statsSnapshot.data;
                final alerts = <_DashboardAlert>[];
                if (stats != null) {
                  for (final alert in stats.alerts) {
                    alerts.add(
                      _DashboardAlert(
                        icon: _alertIconForName(alert.iconName),
                        color: _alertColorForSeverity(alert.severity),
                        message: alert.message,
                        onTap: () => _openAlertTarget(context, alert.iconName),
                      ),
                    );
                  }
                }

                if (license != null &&
                    license.expiresAt.difference(DateTime.now()).inDays < 7) {
                  alerts.add(
                    _DashboardAlert(
                      icon: Icons.workspace_premium_rounded,
                      color: Colors.red,
                      message: 'Expiring Subscription: renew soon to keep access',
                      onTap: _openUpgrade,
                    ),
                  );
                }

                return _alertsContainer(context, alerts);
              },
            );
          },
        );
      },
    );
  }

  Widget _alertsContainer(BuildContext context, List<_DashboardAlert> alerts) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Alerts',
            icon: Icons.notifications_active_rounded,
            badgeLabel: '${alerts.length}',
            badgeColor: Colors.red,
          ),
          const SizedBox(height: 14),
          if (alerts.isEmpty)
            const _AlertItem(
              icon: Icons.check_circle_rounded,
              color: Colors.green,
              message: 'No urgent alerts.',
            )
          else
            ...alerts
                .take(5)
                .map(
                  (alert) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AlertItem(
                      icon: alert.icon,
                      color: alert.color,
                      message: alert.message,
                      onTap: alert.onTap,
                    ),
                  ),
                ),
          if (alerts.length > 5)
            TextButton(
              onPressed: alerts.first.onTap,
              child: Text('See ${alerts.length - 5} more...'),
            ),
        ],
      ),
    );
  }
}

IconData _alertIconForName(String name) {
  switch (name) {
    case 'vaccine':
      return Icons.vaccines_rounded;
    case 'medication':
      return Icons.medical_services_rounded;
    case 'eggs':
      return Icons.egg_rounded;
    case 'feed':
      return Icons.inventory_2_rounded;
    default:
      return Icons.notifications_active_rounded;
  }
}

Color _alertColorForSeverity(String severity) {
  switch (severity) {
    case 'error':
      return Colors.red;
    case 'warning':
      return Colors.amber;
    default:
      return Colors.blue;
  }
}

void _openAlertTarget(BuildContext context, String iconName) {
  final scaffold = MainScaffold.of(context);
  switch (iconName) {
    case 'feed':
      scaffold?.setSelectedIndex(13);
    case 'vaccine':
    case 'medication':
      scaffold?.setSelectedIndex(8);
    case 'eggs':
      scaffold?.setSelectedIndex(3);
    default:
      return;
  }
}


class _MonthlySummaryPanel extends StatelessWidget {
  const _MonthlySummaryPanel();

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    final money = NumberFormat.currency(locale: 'en_GH', symbol: 'GHS ');
    return StreamBuilder<List<dynamic>>(
      stream: CombineLatestStream.list([
        db.select(db.eggProductions).watch(),
        db.select(db.feedingLogs).watch(),
        db.select(db.sales).watch(),
        db.select(db.expenses).watch(),
      ]),
      builder: (context, snapshot) {
        final lists = snapshot.data;
        final eggs =
            ((lists?[0] ?? const <EggProduction>[]) as List<EggProduction>)
                .where((e) => _isThisMonth(e.logDate))
                .fold(0, (sum, e) => sum + e.eggsCollected);
        final feed = ((lists?[1] ?? const <FeedingLog>[]) as List<FeedingLog>)
            .where((f) => _isThisMonth(f.logDate))
            .fold(0.0, (sum, f) => sum + f.amountConsumed);
        final revenue = ((lists?[2] ?? const <Sale>[]) as List<Sale>)
            .where((s) => _isThisMonth(s.saleDate))
            .fold(0.0, (sum, s) => sum + s.totalAmount);
        final expenses = ((lists?[3] ?? const <Expense>[]) as List<Expense>)
            .where((e) => _isThisMonth(e.date))
            .fold(0.0, (sum, e) => sum + e.amount);
        final net = revenue - expenses;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(DateTime.now()).toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),
              Divider(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.15),
              ),
              _summaryRow(
                context,
                'Eggs',
                NumberFormat.decimalPattern().format(eggs),
              ),
              _summaryRow(
                context,
                'Feed Used',
                '${feed.toStringAsFixed(1)} kg',
              ),
              _summaryRow(context, 'Revenue', money.format(revenue)),
              _summaryRow(context, 'Expenses', money.format(expenses)),
              _summaryRow(
                context,
                'Net',
                money.format(net),
                color: net >= 0
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFDC2626),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryRow(
    BuildContext context,
    String label,
    String value, {
    Color? color,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? cs.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendChartCard extends StatelessWidget {
  final String title;
  final String tableName;
  final String dateColumn;
  final String valueColumn;
  final Color accent;
  final String suffix;
  final bool currency;

  const _TrendChartCard({
    required this.title,
    required this.tableName,
    required this.dateColumn,
    required this.valueColumn,
    required this.accent,
    required this.suffix,
    this.currency = false,
  });

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    final start = _dayStart(DateTime.now().subtract(const Duration(days: 6)));
    return StreamBuilder<List<_DailyTotal>>(
      stream: _dailyTrendStream(db, tableName, dateColumn, valueColumn, start),
      builder: (context, snapshot) {
        final points = _fillSevenDays(snapshot.data ?? const [], start);
        final total = points.fold(0.0, (sum, point) => sum + point.total);
        final totalText = currency
            ? 'Total this week: ${NumberFormat.currency(locale: 'en_GH', symbol: 'GHS ').format(total)}'
            : 'Total this week: ${total.toStringAsFixed(total % 1 == 0 ? 0 : 1)}$suffix';

        return Container(
          height: 250,
          padding: const EdgeInsets.all(18),
          decoration: _cardDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    '7-day trend',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: _MiniBarChart(
                  values: points.map((p) => p.total).toList(),
                  labels: points
                      .map((p) => DateFormat('E').format(p.day))
                      .toList(),
                  barColor: accent,
                  totalLabel: totalText,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RecentActivityPanel extends StatelessWidget {
  const _RecentActivityPanel();

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Recent Activity',
            icon: Icons.history_rounded,
            actionLabel: 'View All',
            onAction: () => MainScaffold.of(context)?.setSelectedIndex(9),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<_ActivityItem>>(
            stream: _activityStream(db, todayOnly: false),
            builder: (context, snapshot) {
              final items = snapshot.data ?? const <_ActivityItem>[];
              if (items.isEmpty) {
                return const _EmptyPanel(
                  icon: Icons.history_rounded,
                  message: 'No activity logs yet.',
                );
              }
              return Column(
                children: items
                    .take(12)
                    .map((item) => _ActivityTile(item: item))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HousesAtGlancePanel extends StatelessWidget {
  const _HousesAtGlancePanel();

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    return FutureBuilder<String?>(
      future: FarmUtils.getBoundFarmId(),
      builder: (context, farmSnapshot) {
        final farmId = farmSnapshot.data;
        final query = db.select(db.houses)
          ..orderBy([(h) => OrderingTerm.asc(h.name)]);
        if (farmId != null) {
          query.where((h) => h.farmId.equals(farmId));
        }
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                title: 'Houses',
                icon: Icons.home_work_rounded,
                actionLabel: 'Manage',
                onAction: () => MainScaffold.of(context)?.setSelectedIndex(7),
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<House>>(
                stream: query.watch(),
                builder: (context, snapshot) {
                  final houses = snapshot.data ?? const <House>[];
                  if (houses.isEmpty) {
                    return const _EmptyPanel(
                      icon: Icons.home_work_outlined,
                      message: 'No houses registered.',
                    );
                  }
                  return ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 420),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: houses.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) => _HouseStatusRow(
                        house: houses[index],
                        onTap: () =>
                            MainScaffold.of(context)?.setSelectedIndex(7),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OperationalKpiStrip extends StatelessWidget {
  const _OperationalKpiStrip();

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            StreamBuilder<List<EggProduction>>(
              stream: db.select(db.eggProductions).watch(),
              builder: (context, snapshot) => _KpiCard(
                label: 'Eggs Collected Today',
                value: '${_todayEggs(snapshot.data ?? const [])}',
                icon: Icons.egg_rounded,
                color: Colors.amber,
                parentWidth: width,
                compactMaxColumns: 3,
              ),
            ),
            StreamBuilder<List<FeedingLog>>(
              stream: db.select(db.feedingLogs).watch(),
              builder: (context, snapshot) {
                final range = _todayRange();
                final total = (snapshot.data ?? const <FeedingLog>[])
                    .where((f) => _inRange(f.logDate, range.$1, range.$2))
                    .fold(0.0, (sum, f) => sum + f.amountConsumed);
                return _KpiCard(
                  label: 'Feed Logged Today',
                  value: '${total.toStringAsFixed(1)} kg',
                  icon: Icons.restaurant_rounded,
                  color: Colors.teal,
                  parentWidth: width,
                  compactMaxColumns: 3,
                );
              },
            ),
            StreamBuilder<List<Mortality>>(
              stream: db.select(db.mortalities).watch(),
              builder: (context, snapshot) {
                final range = _todayRange();
                final total = (snapshot.data ?? const <Mortality>[])
                    .where((m) => _inRange(m.logDate, range.$1, range.$2))
                    .fold(0, (sum, m) => sum + m.count);
                return _KpiCard(
                  label: 'Mortality Today',
                  value: '$total',
                  icon: Icons.warning_rounded,
                  color: Colors.red,
                  parentWidth: width,
                  compactMaxColumns: 3,
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _OperationalBatchList extends StatelessWidget {
  const _OperationalBatchList();

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Active Batches',
            icon: Icons.pets_rounded,
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<Batch>>(
            stream: db.select(db.batches).watch(),
            builder: (context, snapshot) {
              final batches = (snapshot.data ?? const <Batch>[])
                  .where((b) => b.status == 'active')
                  .toList();
              if (batches.isEmpty) {
                return const _EmptyPanel(
                  icon: Icons.pets_outlined,
                  message: 'No active batches.',
                );
              }
              return Column(
                children: batches
                    .map(
                      (batch) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(Icons.home_work_rounded, color: cs.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                batch.batchName,
                                style: TextStyle(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Text(
                              '${batch.currentCount} birds',
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickLogPanel extends StatelessWidget {
  const _QuickLogPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionHeader(
            title: 'Quick Log',
            icon: Icons.add_task_rounded,
          ),
          const SizedBox(height: 16),
          _quickButton(
            context,
            '+ Log Eggs',
            Icons.egg_rounded,
            Colors.amber,
            const EggProductionScreen(),
          ),
          const SizedBox(height: 12),
          _quickButton(
            context,
            '+ Log Feed',
            Icons.restaurant_rounded,
            Colors.teal,
            const FeedManagementScreen(),
          ),
          const SizedBox(height: 12),
          _quickButton(
            context,
            '+ Log Mortality',
            Icons.warning_rounded,
            Colors.red,
            const MortalityScreen(),
          ),
        ],
      ),
    );
  }

  Widget _quickButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    Widget screen,
  ) {
    return SizedBox(
      height: 54,
      child: FilledButton.icon(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => screen)),
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
        style: FilledButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

class _TodayActivityPanel extends StatelessWidget {
  const _TodayActivityPanel();

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: "Today's Activity",
            icon: Icons.history_rounded,
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<_ActivityItem>>(
            stream: _activityStream(db, todayOnly: true),
            builder: (context, snapshot) {
              final items = snapshot.data ?? const <_ActivityItem>[];
              if (items.isEmpty) {
                return const _EmptyPanel(
                  icon: Icons.history_rounded,
                  message: 'No activity logged today.',
                );
              }
              return Column(
                children: items
                    .map((item) => _ActivityTile(item: item))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? badgeLabel;
  final Color? badgeColor;

  const _SectionHeader({
    required this.title,
    required this.icon,
    this.actionLabel,
    this.onAction,
    this.badgeLabel,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: cs.primary),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: cs.onSurface,
            fontWeight: FontWeight.w900,
            fontSize: 17,
          ),
        ),
        if (badgeLabel != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (badgeColor ?? cs.primary).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              badgeLabel!,
              style: TextStyle(
                color: badgeColor ?? cs.primary,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
        const Spacer(),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text('$actionLabel ->')),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subLabel;
  final IconData icon;
  final Color color;
  final Color? valueColor;
  final Color? subLabelColor;
  final int trend;
  final double parentWidth;
  final int compactMaxColumns;

  const _KpiCard({
    required this.label,
    required this.value,
    this.subLabel,
    required this.icon,
    required this.color,
    required this.parentWidth,
    this.valueColor,
    this.subLabelColor,
    this.trend = 0,
    this.compactMaxColumns = 6,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final width = _cardWidth();
    final trendColor =
        subLabelColor ??
        (trend > 0
            ? const Color(0xFF16A34A)
            : trend < 0
            ? const Color(0xFFDC2626)
            : cs.onSurfaceVariant);

    return Container(
      width: width,
      height: 178,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor ?? cs.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subLabel != null) ...[
            const SizedBox(height: 4),
            Text(
              subLabel!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: trendColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }

  double _cardWidth() {
    if (compactMaxColumns == 3) {
      if (parentWidth > 900) return (parentWidth - 32) / 3;
      if (parentWidth > 620) return (parentWidth - 16) / 2;
      return parentWidth;
    }
    if (parentWidth > 1400) return (parentWidth - 100) / 6;
    if (parentWidth > 900) return (parentWidth - 40) / 3;
    if (parentWidth > 620) return (parentWidth - 20) / 2;
    return parentWidth;
  }
}

class _AlertItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;
  final VoidCallback? onTap;

  const _AlertItem({
    required this.icon,
    required this.color,
    required this.message,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final Color barColor;
  final String totalLabel;

  const _MiniBarChart({
    required this.values,
    required this.labels,
    required this.barColor,
    required this.totalLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomPaint(
            painter: _MiniBarChartPainter(
              values: values,
              labels: labels,
              barColor: barColor,
              labelColor: cs.onSurfaceVariant,
            ),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          totalLabel,
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _MiniBarChartPainter extends CustomPainter {
  final List<double> values;
  final Color barColor;
  final Color labelColor;
  final List<String> labels;

  const _MiniBarChartPainter({
    required this.values,
    required this.barColor,
    required this.labelColor,
    required this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxVal = values.reduce(max);
    final barWidth = size.width / (values.length * 2);
    final chartHeight = size.height - 24;
    final paint = Paint()..color = barColor.withValues(alpha: 0.85);

    for (var i = 0; i < values.length; i++) {
      final barHeight = maxVal == 0 ? 0.0 : (values[i] / maxVal) * chartHeight;
      final x = i * (size.width / values.length) + barWidth / 2;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, chartHeight - barHeight, barWidth, barHeight),
        const Radius.circular(4),
      );
      canvas.drawRRect(rect, paint);
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(color: labelColor, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - 2, chartHeight + 4));
    }
  }

  @override
  bool shouldRepaint(covariant _MiniBarChartPainter oldDelegate) =>
      oldDelegate.values != values;
}

class _HouseStatusRow extends StatelessWidget {
  final House house;
  final VoidCallback onTap;

  const _HouseStatusRow({required this.house, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final status = _climateStatus(
      house.currentTemperature,
      house.currentHumidity,
    );
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(Icons.home_rounded, color: cs.primary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                house.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'T ${house.currentTemperature == null ? '--' : house.currentTemperature!.toStringAsFixed(0)}C',
              style: TextStyle(
                color: _tempColor(house.currentTemperature),
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'H ${house.currentHumidity == null ? '--' : house.currentHumidity!.toStringAsFixed(0)}%',
              style: TextStyle(
                color: _humidityColor(house.currentHumidity),
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 8),
            _SmallBadge(label: status.$1, color: status.$2),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final _ActivityItem item;

  const _ActivityTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.color, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  DateFormat('MMM d, HH:mm').format(item.date),
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncBadge extends StatelessWidget {
  const _SyncBadge();

  @override
  Widget build(BuildContext context) {
    return _Pill(
      icon: Icons.cloud_done_rounded,
      label: 'Local data live',
      color: const Color(0xFF22C55E),
    );
  }
}

class _SubscriptionBadge extends StatelessWidget {
  const _SubscriptionBadge();

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return FutureBuilder<LicenseConfig?>(
      future: LicenseService(db).getConfig(),
      builder: (context, snapshot) {
        final config = snapshot.data;
        if (config == null) {
          return const _Pill(
            icon: Icons.workspace_premium_rounded,
            label: 'Subscription unknown',
            color: Colors.grey,
          );
        }
        final days = config.expiresAt.difference(DateTime.now()).inDays;
        final safeDays = max(0, days);
        final expiring = days < 7;
        final active = config.mode == 'CLOUD_ACTIVE';
        final label = expiring
            ? 'Expiring'
            : active
            ? 'Active · renews ${DateFormat('MMM d').format(config.expiresAt)}'
            : 'Trial · $safeDays days';
        final color = expiring
            ? Colors.red
            : active
            ? const Color(0xFF22C55E)
            : Colors.amber;
        return InkWell(
          onTap: _openUpgrade,
          borderRadius: BorderRadius.circular(999),
          child: _Pill(
            icon: Icons.workspace_premium_rounded,
            label: label,
            color: color,
          ),
        );
      },
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Pill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _SmallBadge({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyPanel({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: cs.outline, size: 28),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  return BoxDecoration(
    color: Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: cs.outline.withValues(alpha: 0.12)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ],
  );
}

Stream<List<_ActivityItem>> _activityStream(
  AppDatabase db, {
  required bool todayOnly,
}) {
  return CombineLatestStream.list([
    db.select(db.feedingLogs).watch(),
    db.select(db.mortalities).watch(),
    db.select(db.eggProductions).watch(),
    db.select(db.sales).watch(),
    db.select(db.expenses).watch(),
  ]).map((lists) {
    final items = <_ActivityItem>[];
    final range = _todayRange();

    bool include(DateTime date) =>
        !todayOnly || _inRange(date, range.$1, range.$2);

    for (final log in lists[0] as List<FeedingLog>) {
      if (include(log.logDate)) {
        items.add(
          _ActivityItem(
            title: 'Feeding: ${log.amountConsumed.toStringAsFixed(1)} kg',
            date: log.logDate,
            icon: Icons.restaurant_rounded,
            color: Colors.teal,
          ),
        );
      }
    }
    for (final log in lists[1] as List<Mortality>) {
      if (include(log.logDate)) {
        items.add(
          _ActivityItem(
            title: 'Mortality: ${log.count} birds',
            date: log.logDate,
            icon: Icons.warning_rounded,
            color: Colors.red,
          ),
        );
      }
    }
    for (final log in lists[2] as List<EggProduction>) {
      if (include(log.logDate)) {
        items.add(
          _ActivityItem(
            title: 'Eggs: ${log.eggsCollected} collected',
            date: log.logDate,
            icon: Icons.egg_rounded,
            color: Colors.amber,
          ),
        );
      }
    }
    for (final sale in lists[3] as List<Sale>) {
      if (include(sale.saleDate)) {
        items.add(
          _ActivityItem(
            title: 'Sale: GHS ${sale.totalAmount.toStringAsFixed(2)}',
            date: sale.saleDate,
            icon: Icons.receipt_long_rounded,
            color: Colors.green,
          ),
        );
      }
    }
    for (final expense in lists[4] as List<Expense>) {
      if (include(expense.date)) {
        items.add(
          _ActivityItem(
            title: 'Expense: GHS ${expense.amount.toStringAsFixed(2)}',
            date: expense.date,
            icon: Icons.money_off_rounded,
            color: Colors.purple,
          ),
        );
      }
    }
    items.sort((a, b) => b.date.compareTo(a.date));
    return items.take(todayOnly ? 8 : 12).toList();
  });
}

Stream<List<_DailyTotal>> _dailyTrendStream(
  AppDatabase db,
  String tableName,
  String dateColumn,
  String valueColumn,
  DateTime start,
) {
  final sql =
      '''
    SELECT date($dateColumn, 'unixepoch') AS day, SUM($valueColumn) AS total
    FROM $tableName
    WHERE $dateColumn >= ?
    GROUP BY date($dateColumn, 'unixepoch')
    ORDER BY day
    ''';

  if (tableName == 'egg_production') {
    return db
        .customSelect(
          sql,
          variables: [Variable<DateTime>(start)],
          readsFrom: {db.eggProductions},
        )
        .watch()
        .map(_rowsToDailyTotals);
  }
  if (tableName == 'daily_feeding_logs') {
    return db
        .customSelect(
          sql,
          variables: [Variable<DateTime>(start)],
          readsFrom: {db.feedingLogs},
        )
        .watch()
        .map(_rowsToDailyTotals);
  }
  return db
      .customSelect(
        sql,
        variables: [Variable<DateTime>(start)],
        readsFrom: {db.sales},
      )
      .watch()
      .map(_rowsToDailyTotals);
}

List<_DailyTotal> _rowsToDailyTotals(List<QueryRow> rows) {
  return rows
      .map(
        (row) => _DailyTotal(
          DateTime.tryParse(row.read<String>('day')) ?? DateTime.now(),
          (row.read<double?>('total') ?? 0).toDouble(),
        ),
      )
      .toList();
}

List<_DailyTotal> _fillSevenDays(List<_DailyTotal> rows, DateTime start) {
  final byDay = {
    for (final row in rows)
      DateTime(row.day.year, row.day.month, row.day.day): row.total,
  };
  return List.generate(7, (index) {
    final day = _dayStart(start.add(Duration(days: index)));
    return _DailyTotal(day, byDay[day] ?? 0);
  });
}

DateTime _dayStart(DateTime date) => DateTime(date.year, date.month, date.day);

(DateTime, DateTime) _todayRange() {
  final start = _dayStart(DateTime.now());
  return (
    start,
    start
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1)),
  );
}

bool _inRange(DateTime date, DateTime start, DateTime end) =>
    !date.isBefore(start) && !date.isAfter(end);

bool _isToday(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}

bool _isThisMonth(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year && date.month == now.month;
}

int _todayEggs(List<EggProduction> logs) {
  final range = _todayRange();
  return logs
      .where((e) => _inRange(e.logDate, range.$1, range.$2))
      .fold(0, (sum, e) => sum + e.eggsCollected);
}

int _todayEggsForBatch(List<EggProduction> logs, String batchId) {
  final range = _todayRange();
  return logs
      .where(
        (e) => e.batchId == batchId && _inRange(e.logDate, range.$1, range.$2),
      )
      .fold(0, (sum, e) => sum + e.eggsCollected);
}

(String, Color) _climateStatus(double? temperature, double? humidity) {
  final tempOk = temperature != null && temperature >= 18 && temperature <= 32;
  final humidityOk = humidity != null && humidity >= 40 && humidity <= 70;
  if (temperature == null && humidity == null) return ('UNKNOWN', Colors.grey);
  final outCount = [
    if (temperature != null && !tempOk) 1,
    if (humidity != null && !humidityOk) 1,
  ].length;
  if (outCount == 0) return ('OPTIMAL', const Color(0xFF22C55E));
  if (outCount == 1) return ('ATTENTION', const Color(0xFFF59E0B));
  return ('CRITICAL', const Color(0xFFEF4444));
}

Color _tempColor(double? value) {
  if (value == null) return Colors.grey;
  if (value < 18) return Colors.blue;
  if (value > 32) return Colors.red;
  return const Color(0xFF22C55E);
}

Color _humidityColor(double? value) {
  if (value == null) return Colors.grey;
  if (value < 40) return Colors.amber;
  if (value > 70) return Colors.orange;
  return const Color(0xFF22C55E);
}

Future<void> _openUpgrade() async {
  final baseUrl = dotenv.env['WEB_APP_URL']?.trim();
  if (baseUrl == null || baseUrl.isEmpty) return;
  await launchUrl(
    Uri.parse('$baseUrl/dashboard/license-upgrade'),
    mode: LaunchMode.externalApplication,
  );
}

class _DailyTotal {
  final DateTime day;
  final double total;

  const _DailyTotal(this.day, this.total);
}

class _ActivityItem {
  final String title;
  final DateTime date;
  final IconData icon;
  final Color color;

  const _ActivityItem({
    required this.title,
    required this.date,
    required this.icon,
    required this.color,
  });
}

class _DashboardAlert {
  final IconData icon;
  final Color color;
  final String message;
  final VoidCallback? onTap;

  const _DashboardAlert({
    required this.icon,
    required this.color,
    required this.message,
    this.onTap,
  });
}
