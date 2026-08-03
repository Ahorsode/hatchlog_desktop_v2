import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/local_db.dart';
import '../services/batch_analytics_processor.dart';
import '../utils/farm_utils.dart';
import '../utils/navigation_permissions.dart';
import '../utils/worker_permissions_loader.dart';
import 'main_scaffold.dart';

enum _CompareMetricKey { netProfit, revenue, expenses, eggs, fcr, mortalityRate }

class _MetricDef {
  const _MetricDef({
    required this.label,
    required this.short,
    required this.accessor,
    required this.format,
    this.lowerIsBetter = false,
    this.finance = false,
    this.benchmark,
  });

  final String label;
  final String short;
  final double Function(BatchPerformanceSnapshot batch) accessor;
  final String Function(double value) format;
  final bool lowerIsBetter;
  final bool finance;
  final double? benchmark;
}

const _metricPalette = [
  Color(0xFF16A34A),
  Color(0xFF2563EB),
  Color(0xFFF59E0B),
  Color(0xFF9333EA),
  Color(0xFFEC4899),
  Color(0xFF0891B2),
];

Map<_CompareMetricKey, _MetricDef> _metricDefinitions(bool canViewFinance) {
  return {
    _CompareMetricKey.netProfit: _MetricDef(
      label: 'Net Profitability',
      short: 'Profit',
      accessor: (b) => b.netProfitability,
      format: (v) => NumberFormat.currency(symbol: 'GH₵ ', decimalDigits: 2).format(v),
      finance: true,
    ),
    _CompareMetricKey.revenue: _MetricDef(
      label: 'Total Revenue',
      short: 'Revenue',
      accessor: (b) => b.grossRevenue,
      format: (v) => NumberFormat.currency(symbol: 'GH₵ ', decimalDigits: 2).format(v),
      finance: true,
    ),
    _CompareMetricKey.expenses: _MetricDef(
      label: 'Total Costs',
      short: 'Costs',
      accessor: (b) => b.totalCosts,
      format: (v) => NumberFormat.currency(symbol: 'GH₵ ', decimalDigits: 2).format(v),
      lowerIsBetter: true,
      finance: true,
    ),
    _CompareMetricKey.eggs: _MetricDef(
      label: 'Eggs Collected',
      short: 'Eggs',
      accessor: (b) => b.totalEggs.toDouble(),
      format: (v) => '${v.round()} eggs',
    ),
    _CompareMetricKey.fcr: _MetricDef(
      label: 'Feed Conversion Ratio',
      short: 'FCR',
      accessor: (b) => b.currentFcr,
      format: (v) => v.toStringAsFixed(2),
      lowerIsBetter: true,
      benchmark: 1.6,
    ),
    _CompareMetricKey.mortalityRate: _MetricDef(
      label: 'Mortality Rate',
      short: 'Mortality',
      accessor: (b) => b.mortalityRate,
      format: (v) => '${v.toStringAsFixed(2)}%',
      lowerIsBetter: true,
      benchmark: 3.5,
    ),
  };
}

class ComparativeAnalyticsScreen extends StatefulWidget {
  const ComparativeAnalyticsScreen({super.key});

  @override
  State<ComparativeAnalyticsScreen> createState() =>
      _ComparativeAnalyticsScreenState();
}

class _ComparativeAnalyticsScreenState
    extends State<ComparativeAnalyticsScreen> {
  late AppDatabase db;
  Future<List<BatchPerformanceSnapshot>>? _analyticsFuture;
  final Set<String> _selectedBatchIds = {};
  final Set<String> _hiddenBatchIds = {};
  _CompareMetricKey _selectedMetric = _CompareMetricKey.fcr;
  bool _showBenchmark = true;
  bool _canViewBatches = true;
  bool _canViewFinance = true;

  final _currency = NumberFormat.currency(symbol: 'GH₵ ', decimalDigits: 2);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    db = Provider.of<AppDatabase>(context);
    _analyticsFuture ??= BatchAnalyticsProcessor.load(db);
    _loadAccess();
  }

  Future<void> _loadAccess() async {
    try {
      final permissions = await loadWorkerPermissions(db);
      final role = await FarmUtils.getUserRole();
      if (!mounted) return;
      final normalizedRole = role?.toUpperCase() ?? 'WORKER';
      setState(() {
        _canViewBatches = canShowNavigationItem(
          name: 'Analytics',
          role: role,
          roles: const ['WORKER', 'CASHIER', 'MANAGER', 'ACCOUNTANT', 'FINANCE_OFFICER'],
          permissions: permissions,
        );
        _canViewFinance = permissions.contains('can_view_finance') ||
            permissions.contains('can_edit_finance') ||
            normalizedRole == 'OWNER' ||
            normalizedRole == 'MANAGER';
      });
    } catch (_) {
      if (mounted) {
        setState(() => _canViewBatches = false);
      }
    }
  }

  void _refreshAnalytics() {
    setState(() {
      _analyticsFuture = BatchAnalyticsProcessor.load(db);
    });
  }

  void _ensureSelection(List<BatchPerformanceSnapshot> snapshots) {
    if (_selectedBatchIds.isNotEmpty || snapshots.isEmpty) return;
    for (final snapshot in snapshots.take(4)) {
      _selectedBatchIds.add(snapshot.batchId);
    }
  }

  BatchPerformanceSnapshot? _primarySnapshot(
    List<BatchPerformanceSnapshot> snapshots,
  ) {
    if (snapshots.isEmpty) return null;
    final active = snapshots.where((s) => s.status == 'active').toList();
    final candidates = active.isEmpty ? snapshots : active;
    for (final id in _selectedBatchIds) {
      final match = candidates.where((s) => s.batchId == id).firstOrNull;
      if (match != null) return match;
    }
    return candidates.first;
  }

  List<BatchPerformanceSnapshot> _activeSnapshots(
    List<BatchPerformanceSnapshot> snapshots,
  ) {
    return snapshots
        .where(
          (snapshot) =>
              _selectedBatchIds.contains(snapshot.batchId) &&
              !_hiddenBatchIds.contains(snapshot.batchId),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (!_canViewBatches) {
      return Scaffold(
        body: Center(
          child: Text(
            'Batch view permission is required to access comparative analytics.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0B1220) : const Color(0xFFF6F8FB);

    return Scaffold(
      backgroundColor: bg,
      body: FutureBuilder<List<BatchPerformanceSnapshot>>(
        future: _analyticsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final snapshots = snapshot.data ?? const <BatchPerformanceSnapshot>[];
          _ensureSelection(snapshots);
          final selected = _primarySnapshot(snapshots);
          final activeSnapshots = _activeSnapshots(snapshots);

          return Row(
            children: [
              _BatchAnalyticsRail(
                snapshots: snapshots,
                selectedBatchIds: _selectedBatchIds,
                hiddenBatchIds: _hiddenBatchIds,
                onToggleBatch: (id) {
                  setState(() {
                    if (_selectedBatchIds.contains(id)) {
                      _selectedBatchIds.remove(id);
                      _hiddenBatchIds.remove(id);
                    } else {
                      _selectedBatchIds.add(id);
                    }
                  });
                },
                onToggleHidden: (id) {
                  setState(() {
                    if (_hiddenBatchIds.contains(id)) {
                      _hiddenBatchIds.remove(id);
                    } else {
                      _hiddenBatchIds.add(id);
                    }
                  });
                },
              ),
              Expanded(
                child: selected == null
                    ? _EmptyAnalyticsState(onRefresh: _refreshAnalytics)
                    : _AnalyticsWorkspace(
                        selected: selected,
                        activeSnapshots: activeSnapshots,
                        snapshots: snapshots,
                        currency: _currency,
                        canViewFinance: _canViewFinance,
                        selectedMetric: _selectedMetric,
                        showBenchmark: _showBenchmark,
                        onRefresh: _refreshAnalytics,
                        onMetricChanged: (metric) =>
                            setState(() => _selectedMetric = metric),
                        onBenchmarkChanged: (value) =>
                            setState(() => _showBenchmark = value),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BatchAnalyticsRail extends StatelessWidget {
  final List<BatchPerformanceSnapshot> snapshots;
  final Set<String> selectedBatchIds;
  final Set<String> hiddenBatchIds;
  final ValueChanged<String> onToggleBatch;
  final ValueChanged<String> onToggleHidden;

  const _BatchAnalyticsRail({
    required this.snapshots,
    required this.selectedBatchIds,
    required this.hiddenBatchIds,
    required this.onToggleBatch,
    required this.onToggleHidden,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final railBg = isDark ? const Color(0xFF101827) : Colors.white;
    final border = isDark ? const Color(0xFF253044) : const Color(0xFFE2E8F0);
    final active = snapshots.where((s) => s.status == 'active').toList();
    final display = active.isEmpty ? snapshots : active;
    final selectedCount =
        display.where((batch) => selectedBatchIds.contains(batch.batchId)).length;

    return Container(
      width: 326,
      decoration: BoxDecoration(
        color: railBg,
        border: Border(right: BorderSide(color: border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 18),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Back to Livestock',
                  onPressed: () {
                    final navigator = Navigator.of(context);
                    if (navigator.canPop()) {
                      navigator.pop();
                      return;
                    }
                    MainScaffold.of(context)?.setSelectedIndex(1);
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Batch Reports',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '$selectedCount selected · ${display.length} batches',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: border),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
            child: Text(
              'COMPARE BATCHES',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.7,
              ),
            ),
          ),
          Expanded(
            child: display.isEmpty
                ? Center(
                    child: Text(
                      'No batches found',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
                    itemCount: display.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final batch = display[index];
                      final selected = selectedBatchIds.contains(batch.batchId);
                      final hidden = hiddenBatchIds.contains(batch.batchId);
                      final danger = batch.mortalityRate > 5.0;
                      return InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => onToggleBatch(batch.batchId),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(
                                    0xFF16A34A,
                                  ).withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selected
                                  ? const Color(
                                      0xFF16A34A,
                                    ).withValues(alpha: 0.35)
                                  : border,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    selected
                                        ? Icons.check_box_rounded
                                        : Icons.check_box_outline_blank_rounded,
                                    size: 18,
                                    color: selected
                                        ? const Color(0xFF16A34A)
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      batch.batchName,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  if (selected)
                                    IconButton(
                                      tooltip: hidden
                                          ? 'Show in charts'
                                          : 'Hide from charts',
                                      onPressed: () => onToggleHidden(batch.batchId),
                                      icon: Icon(
                                        hidden
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        size: 16,
                                      ),
                                    ),
                                  Icon(
                                    danger
                                        ? Icons.warning_amber_rounded
                                        : Icons.check_circle_rounded,
                                    size: 16,
                                    color: danger
                                        ? const Color(0xFFE8833A)
                                        : const Color(0xFF16A34A),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _RailMetric(
                                    label: 'FCR',
                                    value: batch.currentFcr > 0
                                        ? batch.currentFcr.toStringAsFixed(2)
                                        : 'N/A',
                                  ),
                                  _RailMetric(
                                    label: 'Loss',
                                    value:
                                        '${batch.mortalityRate.toStringAsFixed(1)}%',
                                  ),
                                  _RailMetric(
                                    label: 'Birds',
                                    value: '${batch.currentCount}',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _RailMetric extends StatelessWidget {
  final String label;
  final String value;

  const _RailMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsWorkspace extends StatelessWidget {
  final BatchPerformanceSnapshot selected;
  final List<BatchPerformanceSnapshot> activeSnapshots;
  final List<BatchPerformanceSnapshot> snapshots;
  final NumberFormat currency;
  final bool canViewFinance;
  final _CompareMetricKey selectedMetric;
  final bool showBenchmark;
  final VoidCallback onRefresh;
  final ValueChanged<_CompareMetricKey> onMetricChanged;
  final ValueChanged<bool> onBenchmarkChanged;

  const _AnalyticsWorkspace({
    required this.selected,
    required this.activeSnapshots,
    required this.snapshots,
    required this.currency,
    required this.canViewFinance,
    required this.selectedMetric,
    required this.showBenchmark,
    required this.onRefresh,
    required this.onMetricChanged,
    required this.onBenchmarkChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final border = isDark ? const Color(0xFF253044) : const Color(0xFFE2E8F0);
    final metrics = _metricDefinitions(canViewFinance);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WorkspaceHeader(selected: selected, onRefresh: onRefresh),
          const SizedBox(height: 16),
          _CompareMetricPanel(
            activeSnapshots: activeSnapshots,
            availableMetrics: metrics.entries
                .where((entry) => canViewFinance || !entry.value.finance)
                .map((entry) => entry.key)
                .toList(),
            metrics: metrics,
            selectedMetric: selectedMetric,
            showBenchmark: showBenchmark,
            onMetricChanged: onMetricChanged,
            onBenchmarkChanged: onBenchmarkChanged,
          ),
          const SizedBox(height: 16),
          _KpiStrip(
            selected: selected,
            currency: currency,
            canViewFinance: canViewFinance,
          ),
          const SizedBox(height: 16),
          Expanded(
            flex: 7,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final useColumns = constraints.maxWidth >= 980;
                if (!useColumns) {
                  return ListView(
                    children: [
                      SizedBox(
                        height: 300,
                        child: _FcrTrendPanel(snapshot: selected),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 300,
                        child: _MortalityGaugePanel(snapshot: selected),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 300,
                        child: _FinancialBarsPanel(
                          snapshot: selected,
                          currency: currency,
                          canViewFinance: canViewFinance,
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: _FcrTrendPanel(snapshot: selected)),
                    const SizedBox(width: 14),
                    Expanded(child: _MortalityGaugePanel(snapshot: selected)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _FinancialBarsPanel(
                        snapshot: selected,
                        currency: currency,
                        canViewFinance: canViewFinance,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            flex: 3,
            child: _BatchComparisonTable(
              snapshots: snapshots,
              selectedBatchIds: activeSnapshots.map((s) => s.batchId).toSet(),
              currency: currency,
              canViewFinance: canViewFinance,
              border: border,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceHeader extends StatelessWidget {
  final BatchPerformanceSnapshot selected;
  final VoidCallback onRefresh;

  const _WorkspaceHeader({required this.selected, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selected.batchName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${selected.type.replaceAll('POULTRY_', '')} • ${selected.currentCount} current birds • ${selected.totalFeedKg.toStringAsFixed(1)} kg feed logged',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('REFRESH'),
        ),
      ],
    );
  }
}

class _CompareMetricPanel extends StatelessWidget {
  final List<BatchPerformanceSnapshot> activeSnapshots;
  final List<_CompareMetricKey> availableMetrics;
  final Map<_CompareMetricKey, _MetricDef> metrics;
  final _CompareMetricKey selectedMetric;
  final bool showBenchmark;
  final ValueChanged<_CompareMetricKey> onMetricChanged;
  final ValueChanged<bool> onBenchmarkChanged;

  const _CompareMetricPanel({
    required this.activeSnapshots,
    required this.availableMetrics,
    required this.metrics,
    required this.selectedMetric,
    required this.showBenchmark,
    required this.onMetricChanged,
    required this.onBenchmarkChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final border = isDark ? const Color(0xFF253044) : const Color(0xFFE2E8F0);
    final metric = metrics[selectedMetric]!;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.compare_arrows_rounded, size: 18, color: Color(0xFF16A34A)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Batch Comparison · ${metric.label}',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${activeSnapshots.length} active streams',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final key in availableMetrics)
                ChoiceChip(
                  label: Text(metrics[key]!.short),
                  selected: selectedMetric == key,
                  onSelected: (_) => onMetricChanged(key),
                ),
            ],
          ),
          if (metric.benchmark != null) ...[
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Industry benchmark'),
              value: showBenchmark,
              onChanged: onBenchmarkChanged,
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: activeSnapshots.isEmpty
                ? const _PanelEmptyState('Select or unhide batches from the rail.')
                : _MultiBatchMetricChart(
                    snapshots: activeSnapshots,
                    metric: metric,
                    showBenchmark: showBenchmark && metric.benchmark != null,
                  ),
          ),
        ],
      ),
    );
  }
}

class _MultiBatchMetricChart extends StatelessWidget {
  final List<BatchPerformanceSnapshot> snapshots;
  final _MetricDef metric;
  final bool showBenchmark;

  const _MultiBatchMetricChart({
    required this.snapshots,
    required this.metric,
    required this.showBenchmark,
  });

  @override
  Widget build(BuildContext context) {
    final values = snapshots.map(metric.accessor).toList();
    final maxValue = values.fold<double>(0, (a, b) => a > b ? a : b);
    final benchmark = metric.benchmark ?? 0;
    final chartMax = (maxValue > benchmark || !showBenchmark ? maxValue : benchmark) * 1.2;
    final safeMax = chartMax <= 0 ? 1.0 : chartMax;

    return BarChart(
      BarChartData(
        maxY: safeMax,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.35),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                child: Text(
                  metric.finance ? value.toStringAsFixed(0) : value.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= snapshots.length) {
                  return const SizedBox.shrink();
                }
                final name = snapshots[index].batchName;
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    name.length > 10 ? '${name.substring(0, 9)}…' : name,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                );
              },
            ),
          ),
        ),
        extraLinesData: showBenchmark && metric.benchmark != null
            ? ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: metric.benchmark!,
                    color: const Color(0xFF2563EB),
                    strokeWidth: 2,
                    dashArray: [6, 4],
                  ),
                ],
              )
            : null,
        barGroups: [
          for (var i = 0; i < snapshots.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: values[i],
                  width: 24,
                  color: _metricPalette[i % _metricPalette.length],
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _KpiStrip extends StatelessWidget {
  final BatchPerformanceSnapshot selected;
  final NumberFormat currency;
  final bool canViewFinance;

  const _KpiStrip({
    required this.selected,
    required this.currency,
    required this.canViewFinance,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: Row(
        children: [
          Expanded(
            child: _KpiTile(
              label: 'Current FCR',
              value: selected.currentFcr > 0
                  ? selected.currentFcr.toStringAsFixed(2)
                  : 'N/A',
              icon: Icons.restaurant_rounded,
              color: const Color(0xFF16A34A),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _KpiTile(
              label: 'Mortality',
              value: '${selected.mortalityRate.toStringAsFixed(2)}%',
              icon: Icons.monitor_heart_outlined,
              color: selected.mortalityRate <= 5
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFE8833A),
            ),
          ),
          if (canViewFinance) ...[
            const SizedBox(width: 12),
            Expanded(
              child: _KpiTile(
                label: 'Net Profit',
                value: currency.format(selected.netProfitability),
                icon: Icons.account_balance_wallet_rounded,
                color: selected.netProfitability >= 0
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFDC2626),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiTile(
                label: 'Gross Revenue',
                value: currency.format(selected.grossRevenue),
                icon: Icons.point_of_sale_rounded,
                color: const Color(0xFF2563EB),
              ),
            ),
          ] else ...[
            const SizedBox(width: 12),
            Expanded(
              child: _KpiTile(
                label: 'Eggs Collected',
                value: '${selected.totalEggs}',
                icon: Icons.egg_alt_outlined,
                color: const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiTile(
                label: 'Current Birds',
                value: '${selected.currentCount}',
                icon: Icons.pets_rounded,
                color: const Color(0xFF2563EB),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _KpiTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final border = isDark ? const Color(0xFF253044) : const Color(0xFFE2E8F0);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FcrTrendPanel extends StatelessWidget {
  final BatchPerformanceSnapshot snapshot;

  const _FcrTrendPanel({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final points = snapshot.weeklyFcr;
    final maxY = points.isEmpty
        ? 3.0
        : points.map((p) => p.fcr).reduce((a, b) => a > b ? a : b) * 1.2;

    return _AnalyticsPanel(
      title: 'FCR Trend Analysis',
      icon: Icons.show_chart_rounded,
      child: points.isEmpty
          ? const _PanelEmptyState('Log feed plus egg or weight records')
          : LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY <= 0 ? 3.0 : maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.35),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) {
                      return spots.map((spot) {
                        final index = spot.x.toInt() - 1;
                        final safeIndex = index
                            .clamp(0, points.length - 1)
                            .toInt();
                        final point = points[safeIndex];
                        return LineTooltipItem(
                          'Week ${point.week}\nFCR ${point.fcr.toStringAsFixed(3)}\nFeed ${point.feedKg.toStringAsFixed(1)} kg',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            'W${value.toInt()}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            value.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: points
                        .map(
                          (point) => FlSpot(point.week.toDouble(), point.fcr),
                        )
                        .toList(),
                    isCurved: true,
                    color: const Color(0xFF16A34A),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF16A34A).withValues(alpha: 0.08),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _MortalityGaugePanel extends StatelessWidget {
  final BatchPerformanceSnapshot snapshot;

  const _MortalityGaugePanel({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final rate = snapshot.mortalityRate.clamp(0, 100).toDouble();
    final healthy = rate <= 5.0;
    final color = healthy ? const Color(0xFF16A34A) : const Color(0xFFE8833A);

    return _AnalyticsPanel(
      title: 'Mortality Monitoring',
      icon: Icons.monitor_heart_outlined,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    startDegreeOffset: 270,
                    centerSpaceRadius: 58,
                    sectionsSpace: 2,
                    sections: [
                      PieChartSectionData(
                        value: rate <= 0 ? 0.01 : rate,
                        color: color,
                        showTitle: false,
                        radius: 28,
                      ),
                      PieChartSectionData(
                        value: (100 - rate).clamp(0.01, 100).toDouble(),
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.22),
                        showTitle: false,
                        radius: 28,
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${snapshot.mortalityRate.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: color,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      healthy ? 'WITHIN LIMIT' : 'REVIEW NOW',
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _MetricLine(
            label: 'Dead birds logged',
            value: '${snapshot.totalDeadBirds} of ${snapshot.initialCount}',
          ),
          _MetricLine(
            label: 'Threshold',
            value: healthy ? '<= 5% success band' : '> 5% warning band',
          ),
        ],
      ),
    );
  }
}

class _FinancialBarsPanel extends StatelessWidget {
  final BatchPerformanceSnapshot snapshot;
  final NumberFormat currency;
  final bool canViewFinance;

  const _FinancialBarsPanel({
    required this.snapshot,
    required this.currency,
    required this.canViewFinance,
  });

  @override
  Widget build(BuildContext context) {
    if (!canViewFinance) {
      return _AnalyticsPanel(
        title: 'Egg Production',
        icon: Icons.egg_alt_outlined,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${snapshot.totalEggs} eggs collected',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Finance metrics require finance view permission.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    final maxY =
        [
          snapshot.totalCosts,
          snapshot.grossRevenue,
        ].reduce((a, b) => a > b ? a : b) *
        1.25;

    return _AnalyticsPanel(
      title: 'Financial Comparison',
      icon: Icons.bar_chart_rounded,
      child: Column(
        children: [
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxY <= 0 ? 100 : maxY,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.35),
                    strokeWidth: 1,
                  ),
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final label = group.x == 0 ? 'Total Costs' : 'Revenue';
                      return BarTooltipItem(
                        '$label\n${currency.format(rod.toY)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            value.toInt() == 0 ? 'Costs' : 'Revenue',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: snapshot.totalCosts,
                        color: const Color(0xFFDC2626),
                        width: 38,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: snapshot.grossRevenue,
                        color: const Color(0xFF2563EB),
                        width: 38,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _MetricLine(
            label: 'Direct expenses',
            value: currency.format(snapshot.directExpenses),
          ),
          _MetricLine(
            label: 'Allocated shared expenses',
            value: currency.format(snapshot.allocatedSharedExpenses),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsPanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _AnalyticsPanel({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final border = isDark ? const Color(0xFF253044) : const Color(0xFFE2E8F0);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF16A34A)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _MetricLine extends StatelessWidget {
  final String label;
  final String value;

  const _MetricLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _BatchComparisonTable extends StatelessWidget {
  final List<BatchPerformanceSnapshot> snapshots;
  final Set<String> selectedBatchIds;
  final NumberFormat currency;
  final bool canViewFinance;
  final Color border;

  const _BatchComparisonTable({
    required this.snapshots,
    required this.selectedBatchIds,
    required this.currency,
    required this.canViewFinance,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = snapshots.where((s) => s.status == 'active').toList();
    final rows = (active.isEmpty ? snapshots : active)
        .where((row) => selectedBatchIds.contains(row.batchId))
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A5F),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              border: Border(bottom: BorderSide(color: border)),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: _TableHeader('Batch')),
                Expanded(child: _TableHeader('FCR')),
                Expanded(child: _TableHeader('Mortality')),
                if (canViewFinance) ...[
                  Expanded(flex: 2, child: _TableHeader('Revenue')),
                  Expanded(flex: 2, child: _TableHeader('Costs')),
                  Expanded(flex: 2, child: _TableHeader('Net')),
                ] else ...[
                  Expanded(flex: 2, child: _TableHeader('Eggs')),
                  Expanded(flex: 2, child: _TableHeader('Birds')),
                ],
              ],
            ),
          ),
          Expanded(
            child: rows.isEmpty
                ? const _PanelEmptyState('No batch data available')
                : ListView.builder(
                    itemCount: rows.length,
                    itemBuilder: (context, index) {
                      final row = rows[index];
                      final selected = selectedBatchIds.contains(row.batchId);
                      final color = selected
                          ? const Color(0xFF16A34A).withValues(alpha: 0.08)
                          : Colors.transparent;
                      return Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        color: color,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                row.batchName,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontSize: 12,
                                  fontWeight: selected
                                      ? FontWeight.w900
                                      : FontWeight.w700,
                                ),
                              ),
                            ),
                            Expanded(
                              child: _TableCell(
                                row.currentFcr > 0
                                    ? row.currentFcr.toStringAsFixed(2)
                                    : 'N/A',
                              ),
                            ),
                            Expanded(
                              child: _TableCell(
                                '${row.mortalityRate.toStringAsFixed(1)}%',
                              ),
                            ),
                            if (canViewFinance) ...[
                              Expanded(
                                flex: 2,
                                child: _TableCell(
                                  currency.format(row.grossRevenue),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: _TableCell(
                                  currency.format(row.totalCosts),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: _TableCell(
                                  currency.format(row.netProfitability),
                                  color: row.netProfitability >= 0
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFDC2626),
                                ),
                              ),
                            ] else ...[
                              Expanded(
                                flex: 2,
                                child: _TableCell('${row.totalEggs}'),
                              ),
                              Expanded(
                                flex: 2,
                                child: _TableCell('${row.currentCount}'),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String label;

  const _TableHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String value;
  final Color? color;

  const _TableCell(this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: color ?? Theme.of(context).colorScheme.onSurface,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _PanelEmptyState extends StatelessWidget {
  final String text;

  const _PanelEmptyState(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyAnalyticsState extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyAnalyticsState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 42,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'No local batch analytics available',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('REFRESH'),
          ),
        ],
      ),
    );
  }
}
