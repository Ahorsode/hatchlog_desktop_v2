import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

import '../data/local_db.dart';
import '../utils/farm_utils.dart';

class EggAnalyticsScreen extends StatefulWidget {
  const EggAnalyticsScreen({super.key});

  @override
  State<EggAnalyticsScreen> createState() => _EggAnalyticsScreenState();
}

class _EggAnalyticsScreenState extends State<EggAnalyticsScreen> {
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
                  'Egg Analytics',
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
              child: FutureBuilder<_EggAnalytics>(
                future: _loadAnalytics(context.read<AppDatabase>()),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return _EggAnalyticsView(data: snapshot.data!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<_EggAnalytics> _loadAnalytics(AppDatabase db) async {
    final farmId = await FarmUtils.getBoundFarmId();
    if (farmId == null) return _EggAnalytics.empty(_periodDays);

    final start = DateTime.now().subtract(Duration(days: _periodDays - 1));
    final startDay = DateTime(start.year, start.month, start.day);
    final eggs = await (db.select(
      db.eggProductions,
    )..where((e) => e.farmId.equals(farmId))).get();
    final periodEggs = eggs
        .where((e) => !e.logDate.isBefore(startDay))
        .toList();
    final batches = await (db.select(
      db.batches,
    )..where((b) => b.farmId.equals(farmId))).get();
    final batchMap = {for (final b in batches) b.id: b};
    final totalBirds = batches.fold(0, (sum, b) => sum + b.currentCount);
    final totalEggs = periodEggs.fold(0, (sum, e) => sum + e.eggsCollected);
    final totalUnusable = periodEggs.fold(0, (sum, e) => sum + e.unusableCount);
    final collectionEvents = periodEggs.length;

    final daily = <DateTime, int>{};
    for (var i = 0; i < _periodDays; i++) {
      final day = startDay.add(Duration(days: i));
      daily[day] = 0;
    }
    for (final log in periodEggs) {
      final day = DateTime(
        log.logDate.year,
        log.logDate.month,
        log.logDate.day,
      );
      daily[day] = (daily[day] ?? 0) + log.eggsCollected;
    }

    final perBatch = <String, int>{};
    for (final log in periodEggs) {
      perBatch[log.batchId] = (perBatch[log.batchId] ?? 0) + log.eggsCollected;
    }
    final topBatches =
        perBatch.entries
            .map(
              (e) => _EggBatchRow(
                name: batchMap[e.key]?.batchName ?? 'Batch ${e.key}',
                eggs: e.value,
                average: e.value / _periodDays,
              ),
            )
            .toList()
          ..sort((a, b) => b.eggs.compareTo(a.eggs));

    final bestDay = daily.entries.fold<MapEntry<DateTime, int>?>(
      null,
      (best, entry) => best == null || entry.value > best.value ? entry : best,
    );

    return _EggAnalytics(
      totalEggs: totalEggs,
      dailyAverage: totalEggs / _periodDays,
      efficiency: totalBirds == 0 ? 0 : totalEggs / totalBirds,
      collectionEvents: collectionEvents,
      totalUnusable: totalUnusable,
      bestDay: bestDay,
      daily: daily,
      topBatches: topBatches.take(3).toList(),
    );
  }
}

class _EggAnalyticsView extends StatelessWidget {
  final _EggAnalytics data;

  const _EggAnalyticsView({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _MetricCard('Total Eggs', '${data.totalEggs}', Icons.egg_rounded),
              _MetricCard(
                'Daily Average',
                data.dailyAverage.toStringAsFixed(1),
                Icons.insights_rounded,
              ),
              _MetricCard(
                'Production Efficiency',
                '${data.efficiency.toStringAsFixed(2)} eggs/bird',
                Icons.speed_rounded,
              ),
              _MetricCard(
                'Collection Events',
                '${data.collectionEvents}',
                Icons.event_note_rounded,
              ),
              _MetricCard(
                'Best Day',
                data.bestDay == null
                    ? 'N/A'
                    : '${DateFormat('MMM d').format(data.bestDay!.key)} · ${data.bestDay!.value}',
                Icons.star_rounded,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ChartCard(
            title: 'Daily Egg Trend',
            values: data.daily.values.map((v) => v.toDouble()).toList(),
            labels: data.daily.keys
                .map((d) => DateFormat('MMM d').format(d))
                .toList(),
          ),
          const SizedBox(height: 18),
          _TopBatchTable(rows: data.topBatches),
        ],
      ),
    );
  }
}

class _TopBatchTable extends StatelessWidget {
  final List<_EggBatchRow> rows;

  const _TopBatchTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(context),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Batch')),
          DataColumn(label: Text('Eggs')),
          DataColumn(label: Text('Daily Average')),
        ],
        rows: rows
            .map(
              (row) => DataRow(
                cells: [
                  DataCell(Text(row.name)),
                  DataCell(Text('${row.eggs}')),
                  DataCell(Text(row.average.toStringAsFixed(1))),
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
      width: 230,
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
                    fontSize: 19,
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
      final ratio = maxValue == 0 ? 0.0 : values[i] / maxValue;
      final height = chartHeight * ratio;
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

class _EggAnalytics {
  final int totalEggs;
  final double dailyAverage;
  final double efficiency;
  final int collectionEvents;
  final int totalUnusable;
  final MapEntry<DateTime, int>? bestDay;
  final Map<DateTime, int> daily;
  final List<_EggBatchRow> topBatches;

  const _EggAnalytics({
    required this.totalEggs,
    required this.dailyAverage,
    required this.efficiency,
    required this.collectionEvents,
    required this.totalUnusable,
    required this.bestDay,
    required this.daily,
    required this.topBatches,
  });

  factory _EggAnalytics.empty(int periodDays) {
    final start = DateTime.now().subtract(Duration(days: periodDays - 1));
    final daily = <DateTime, int>{};
    for (var i = 0; i < periodDays; i++) {
      final day = start.add(Duration(days: i));
      daily[DateTime(day.year, day.month, day.day)] = 0;
    }
    return _EggAnalytics(
      totalEggs: 0,
      dailyAverage: 0,
      efficiency: 0,
      collectionEvents: 0,
      totalUnusable: 0,
      bestDay: null,
      daily: daily,
      topBatches: const [],
    );
  }
}

class _EggBatchRow {
  final String name;
  final int eggs;
  final double average;

  const _EggBatchRow({
    required this.name,
    required this.eggs,
    required this.average,
  });
}
