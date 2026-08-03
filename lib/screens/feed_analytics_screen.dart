import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

import '../data/local_db.dart';
import '../utils/farm_utils.dart';

class FeedAnalyticsScreen extends StatefulWidget {
  const FeedAnalyticsScreen({super.key});

  @override
  State<FeedAnalyticsScreen> createState() => _FeedAnalyticsScreenState();
}

class _FeedAnalyticsScreenState extends State<FeedAnalyticsScreen> {
  int _periodDays = 7;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Back',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 10),
                Text(
                  'Feed Analytics',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 7, label: Text('7 Days')),
                ButtonSegment(value: 30, label: Text('30 Days')),
                ButtonSegment(value: 90, label: Text('90 Days')),
              ],
              selected: {_periodDays},
              onSelectionChanged: (value) =>
                  setState(() => _periodDays = value.first),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<_FeedAnalytics>(
                future: _loadAnalytics(context.read<AppDatabase>()),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return _FeedAnalyticsView(data: snapshot.data!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<_FeedAnalytics> _loadAnalytics(AppDatabase db) async {
    final farmId = await FarmUtils.getBoundFarmId();
    if (farmId == null) return _FeedAnalytics.empty(_periodDays);
    final start = DateTime.now().subtract(Duration(days: _periodDays - 1));
    final startDay = DateTime(start.year, start.month, start.day);
    final logs = await (db.select(
      db.feedingLogs,
    )..where((f) => f.farmId.equals(farmId))).get();
    final periodLogs = logs
        .where((f) => !f.logDate.isBefore(startDay))
        .toList();
    final batches = await (db.select(
      db.batches,
    )..where((b) => b.farmId.equals(farmId))).get();
    final inventory = await (db.select(
      db.inventory,
    )..where((i) => i.farmId.equals(farmId))).get();
    final batchMap = {for (final b in batches) b.id: b.batchName};
    final inventoryMap = {for (final item in inventory) item.id: item};

    final daily = <DateTime, double>{};
    for (var i = 0; i < _periodDays; i++) {
      final day = startDay.add(Duration(days: i));
      daily[day] = 0;
    }
    final perBatch = <String, double>{};
    double totalCost = 0;
    var hasCost = false;

    for (final log in periodLogs) {
      final day = DateTime(
        log.logDate.year,
        log.logDate.month,
        log.logDate.day,
      );
      daily[day] = (daily[day] ?? 0) + log.amountConsumed;
      final batchId = log.batchId ?? 'global';
      perBatch[batchId] = (perBatch[batchId] ?? 0) + log.amountConsumed;
      final feed = log.feedTypeId == null ? null : inventoryMap[log.feedTypeId];
      if (feed?.costPerUnit != null) {
        hasCost = true;
        totalCost += log.amountConsumed * feed!.costPerUnit!;
      }
    }

    final totalFeed = periodLogs.fold(
      0.0,
      (sum, log) => sum + log.amountConsumed,
    );
    final rows =
        perBatch.entries
            .map(
              (entry) => _FeedBatchRow(
                name: entry.key == 'global'
                    ? 'Global'
                    : batchMap[entry.key] ?? 'Batch ${entry.key}',
                consumed: entry.value,
                share: totalFeed == 0 ? 0 : entry.value / totalFeed * 100,
              ),
            )
            .toList()
          ..sort((a, b) => b.consumed.compareTo(a.consumed));

    return _FeedAnalytics(
      totalFeed: totalFeed,
      dailyAverage: totalFeed / _periodDays,
      cost: hasCost ? totalCost : null,
      topConsumer: rows.isEmpty ? 'N/A' : rows.first.name,
      daily: daily,
      rows: rows,
    );
  }
}

class _FeedAnalyticsView extends StatelessWidget {
  final _FeedAnalytics data;

  const _FeedAnalyticsView({required this.data});

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(symbol: 'GHc ', decimalDigits: 2);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _MetricCard(
                'Total Feed Consumed',
                '${data.totalFeed.toStringAsFixed(1)} bags',
                Icons.restaurant_rounded,
              ),
              _MetricCard(
                'Daily Average',
                '${data.dailyAverage.toStringAsFixed(1)} bags/day',
                Icons.insights_rounded,
              ),
              _MetricCard(
                'Cost This Period',
                data.cost == null ? 'N/A' : money.format(data.cost),
                Icons.payments_rounded,
              ),
              _MetricCard(
                'Top Consumer',
                data.topConsumer,
                Icons.trending_up_rounded,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ChartCard(
            title: 'Daily Feed Trend',
            values: data.daily.values.toList(),
            labels: data.daily.keys
                .map((d) => DateFormat('MMM d').format(d))
                .toList(),
          ),
          const SizedBox(height: 18),
          _FeedBatchTable(rows: data.rows),
        ],
      ),
    );
  }
}

class _FeedBatchTable extends StatelessWidget {
  final List<_FeedBatchRow> rows;

  const _FeedBatchTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(context),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Batch')),
          DataColumn(label: Text('Feed Consumed (bags)')),
          DataColumn(label: Text('% of Total')),
        ],
        rows: rows
            .map(
              (row) => DataRow(
                cells: [
                  DataCell(Text(row.name)),
                  DataCell(Text(row.consumed.toStringAsFixed(1))),
                  DataCell(Text('${row.share.toStringAsFixed(1)}%')),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricCard(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 240,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(context),
      child: Row(
        children: [
          Icon(icon, color: cs.primary, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 18,
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

class _ChartCard extends StatelessWidget {
  final String title;
  final List<double> values;
  final List<String> labels;

  const _ChartCard({
    required this.title,
    required this.values,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 310,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomPaint(
              painter: _BarChartPainter(
                values: values,
                labels: labels,
                color: cs.primary,
                labelColor: cs.onSurfaceVariant,
              ),
              child: const SizedBox.expand(),
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
    border: Border.all(color: cs.outline.withValues(alpha: 0.14)),
    boxShadow: [
      BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12),
    ],
  );
}

class _BarChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final Color color;
  final Color labelColor;

  const _BarChartPainter({
    required this.values,
    required this.labels,
    required this.color,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final chartHeight = size.height - 32;
    final gap = 4.0;
    final barWidth = (size.width - gap * (values.length - 1)) / values.length;
    final paint = Paint()..color = color;
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i < values.length; i++) {
      final height = maxValue == 0 ? 0.0 : chartHeight * (values[i] / maxValue);
      final x = i * (barWidth + gap);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, chartHeight - height, barWidth.clamp(3, 32), height),
          const Radius.circular(5),
        ),
        paint,
      );
      if (values.length <= 14 || i % (values.length / 7).ceil() == 0) {
        tp.text = TextSpan(
          text: labels[i],
          style: TextStyle(color: labelColor, fontSize: 10),
        );
        tp.layout(maxWidth: barWidth * 2);
        tp.paint(canvas, Offset(x, chartHeight + 8));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) =>
      oldDelegate.values != values;
}

class _FeedAnalytics {
  final double totalFeed;
  final double dailyAverage;
  final double? cost;
  final String topConsumer;
  final Map<DateTime, double> daily;
  final List<_FeedBatchRow> rows;

  const _FeedAnalytics({
    required this.totalFeed,
    required this.dailyAverage,
    required this.cost,
    required this.topConsumer,
    required this.daily,
    required this.rows,
  });

  factory _FeedAnalytics.empty(int periodDays) {
    final start = DateTime.now().subtract(Duration(days: periodDays - 1));
    final daily = <DateTime, double>{};
    for (var i = 0; i < periodDays; i++) {
      final day = start.add(Duration(days: i));
      daily[DateTime(day.year, day.month, day.day)] = 0;
    }
    return _FeedAnalytics(
      totalFeed: 0,
      dailyAverage: 0,
      cost: null,
      topConsumer: 'N/A',
      daily: daily,
      rows: const [],
    );
  }
}

class _FeedBatchRow {
  final String name;
  final double consumed;
  final double share;

  const _FeedBatchRow({
    required this.name,
    required this.consumed,
    required this.share,
  });
}
