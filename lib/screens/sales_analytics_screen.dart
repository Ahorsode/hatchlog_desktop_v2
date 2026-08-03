import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

import '../data/local_db.dart';
import '../utils/farm_utils.dart';

class SalesAnalyticsScreen extends StatefulWidget {
  const SalesAnalyticsScreen({super.key});

  @override
  State<SalesAnalyticsScreen> createState() => _SalesAnalyticsScreenState();
}

class _SalesAnalyticsScreenState extends State<SalesAnalyticsScreen> {
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
                  'Sales Analytics',
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
              child: FutureBuilder<_SalesAnalytics>(
                future: _loadAnalytics(context.read<AppDatabase>()),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return _SalesAnalyticsView(data: snapshot.data!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<_SalesAnalytics> _loadAnalytics(AppDatabase db) async {
    final farmId = await FarmUtils.getBoundFarmId();
    if (farmId == null) return _SalesAnalytics.empty(_periodDays);
    final start = DateTime.now().subtract(Duration(days: _periodDays - 1));
    final startDay = DateTime(start.year, start.month, start.day);
    final sales = await (db.select(
      db.sales,
    )..where((s) => s.farmId.equals(farmId))).get();
    final periodSales = sales
        .where((s) => !s.saleDate.isBefore(startDay))
        .toList();
    final customers = await (db.select(
      db.customers,
    )..where((c) => c.farmId.equals(farmId))).get();
    final customerMap = {for (final c in customers) c.id: c};

    final daily = <DateTime, double>{};
    for (var i = 0; i < _periodDays; i++) {
      final day = startDay.add(Duration(days: i));
      daily[day] = 0;
    }
    final perCustomer = <String, _CustomerSalesAccumulator>{};
    for (final sale in periodSales) {
      final day = DateTime(
        sale.saleDate.year,
        sale.saleDate.month,
        sale.saleDate.day,
      );
      daily[day] = (daily[day] ?? 0) + sale.totalAmount;
      final customerId = sale.customerId ?? 'walk-in';
      final current = perCustomer[customerId] ?? _CustomerSalesAccumulator();
      current.total += sale.totalAmount;
      current.count += 1;
      perCustomer[customerId] = current;
    }

    final totalRevenue = periodSales.fold(
      0.0,
      (sum, sale) => sum + sale.totalAmount,
    );
    final outstanding = customers
        .where((c) => c.customerType == 'CUSTOMER')
        .fold(0.0, (sum, c) => sum + c.balanceOwed);
    final topCustomers =
        perCustomer.entries
            .map(
              (entry) => _TopCustomerRow(
                name: entry.key == 'walk-in'
                    ? 'Walk-in'
                    : customerMap[entry.key]?.name ?? 'Customer ${entry.key}',
                total: entry.value.total,
                count: entry.value.count,
              ),
            )
            .toList()
          ..sort((a, b) => b.total.compareTo(a.total));

    return _SalesAnalytics(
      totalRevenue: totalRevenue,
      salesCount: periodSales.length,
      averageSale: periodSales.isEmpty ? 0 : totalRevenue / periodSales.length,
      outstanding: outstanding,
      categoryRevenue: {'Product Sales': totalRevenue},
      paidTotal: totalRevenue,
      paidCount: periodSales.length,
      daily: daily,
      topCustomers: topCustomers.take(5).toList(),
    );
  }
}

class _SalesAnalyticsView extends StatelessWidget {
  final _SalesAnalytics data;

  const _SalesAnalyticsView({required this.data});

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
                'Total Revenue',
                money.format(data.totalRevenue),
                Icons.payments_rounded,
              ),
              _MetricCard(
                'Total Sales Count',
                '${data.salesCount}',
                Icons.receipt_long_rounded,
              ),
              _MetricCard(
                'Average Sale Value',
                money.format(data.averageSale),
                Icons.trending_up_rounded,
              ),
              _MetricCard(
                'Outstanding',
                money.format(data.outstanding),
                Icons.warning_amber_rounded,
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 900;
              return Wrap(
                spacing: 18,
                runSpacing: 18,
                children: [
                  SizedBox(
                    width: narrow
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 18) / 2,
                    child: _RevenueCategoryCard(
                      values: data.categoryRevenue,
                      money: money,
                    ),
                  ),
                  SizedBox(
                    width: narrow
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 18) / 2,
                    child: _PaymentMatrixCard(data: data, money: money),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          _TopCustomerTable(rows: data.topCustomers, money: money),
          const SizedBox(height: 18),
          _ChartCard(
            title: 'Daily Revenue Trend',
            values: data.daily.values.toList(),
            labels: data.daily.keys
                .map((d) => DateFormat('MMM d').format(d))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _RevenueCategoryCard extends StatelessWidget {
  final Map<String, double> values;
  final NumberFormat money;

  const _RevenueCategoryCard({required this.values, required this.money});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final total = values.values.fold(0.0, (sum, v) => sum + v);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revenue by Category',
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          for (final entry in values.entries) ...[
            Row(
              children: [
                Expanded(child: Text(entry.key)),
                Text(money.format(entry.value)),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: total == 0 ? 0 : entry.value / total,
              minHeight: 10,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ],
      ),
    );
  }
}

class _PaymentMatrixCard extends StatelessWidget {
  final _SalesAnalytics data;
  final NumberFormat money;

  const _PaymentMatrixCard({required this.data, required this.money});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Status Matrix',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          _statusRow(
            'PAID',
            data.paidCount,
            money.format(data.paidTotal),
            Colors.green,
          ),
          _statusRow('PARTIAL', 0, money.format(0), Colors.amber),
          _statusRow('UNPAID', 0, money.format(0), Colors.red),
        ],
      ),
    );
  }

  Widget _statusRow(String label, int count, String amount, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          Text(
            '$count · $amount',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _TopCustomerTable extends StatelessWidget {
  final List<_TopCustomerRow> rows;
  final NumberFormat money;

  const _TopCustomerTable({required this.rows, required this.money});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(context),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Customer')),
          DataColumn(label: Text('Total Spent')),
          DataColumn(label: Text('Sales Count')),
        ],
        rows: rows
            .map(
              (row) => DataRow(
                cells: [
                  DataCell(Text(row.name)),
                  DataCell(Text(money.format(row.total))),
                  DataCell(Text('${row.count}')),
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

class _SalesAnalytics {
  final double totalRevenue;
  final int salesCount;
  final double averageSale;
  final double outstanding;
  final Map<String, double> categoryRevenue;
  final int paidCount;
  final double paidTotal;
  final Map<DateTime, double> daily;
  final List<_TopCustomerRow> topCustomers;

  const _SalesAnalytics({
    required this.totalRevenue,
    required this.salesCount,
    required this.averageSale,
    required this.outstanding,
    required this.categoryRevenue,
    required this.paidCount,
    required this.paidTotal,
    required this.daily,
    required this.topCustomers,
  });

  factory _SalesAnalytics.empty(int periodDays) {
    final start = DateTime.now().subtract(Duration(days: periodDays - 1));
    final daily = <DateTime, double>{};
    for (var i = 0; i < periodDays; i++) {
      final day = start.add(Duration(days: i));
      daily[DateTime(day.year, day.month, day.day)] = 0;
    }
    return _SalesAnalytics(
      totalRevenue: 0,
      salesCount: 0,
      averageSale: 0,
      outstanding: 0,
      categoryRevenue: const {'Product Sales': 0},
      paidCount: 0,
      paidTotal: 0,
      daily: daily,
      topCustomers: const [],
    );
  }
}

class _CustomerSalesAccumulator {
  double total = 0;
  int count = 0;
}

class _TopCustomerRow {
  final String name;
  final double total;
  final int count;

  const _TopCustomerRow({
    required this.name,
    required this.total,
    required this.count,
  });
}
