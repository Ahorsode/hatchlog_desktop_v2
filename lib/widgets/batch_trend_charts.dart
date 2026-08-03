import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/batch_deep_dive_models.dart';

class BatchTrendCharts extends StatelessWidget {
  const BatchTrendCharts({
    super.key,
    required this.payload,
  });

  final BatchDeepDivePayload payload;

  @override
  Widget build(BuildContext context) {
    final finance = payload.finance.result;
    final showEggs =
        payload.metrics.isLayer || payload.series.eggDaily.isNotEmpty;
    final showSales = payload.finance.canViewFinance &&
        (payload.series.salesDaily.isNotEmpty ||
            (finance?.totalRevenue ?? 0) > 0);

    return Column(
      children: [
        if (payload.finance.canViewFinance && finance != null)
          _FinanceTrendCard(finance: finance),
        if (showEggs) ...[
          const SizedBox(height: 16),
          _SimpleBarCard(
            title: 'Egg Production',
            icon: Icons.egg_outlined,
            color: const Color(0xFFFB923C),
            points: payload.series.eggDaily
                .map((p) => (p.label, p.eggs.toDouble()))
                .toList(),
          ),
        ],
        const SizedBox(height: 16),
        _MortalityCard(points: payload.series.mortalityDaily),
        if (showSales) ...[
          const SizedBox(height: 16),
          _SimpleBarCard(
            title: 'Sales Trend',
            icon: Icons.shopping_cart_outlined,
            color: const Color(0xFF0EA5E9),
            points: payload.series.salesDaily
                .map((p) => (p.label, p.revenue))
                .toList(),
            valueFormatter: (v) => NumberFormat.compactCurrency(symbol: 'GH₵ ')
                .format(v),
          ),
        ],
      ],
    );
  }
}

class _FinanceTrendCard extends StatelessWidget {
  const _FinanceTrendCard({required this.finance});

  final BatchFinanceResult finance;

  @override
  Widget build(BuildContext context) {
    final monthly = finance.financeMonthly;
    if (monthly.isEmpty) {
      return _ChartShell(
        title: 'Finance Trends',
        icon: Icons.account_balance_wallet_outlined,
        child: const Center(child: Text('No finance data yet')),
      );
    }

    return _ChartShell(
      title: 'Finance Trends',
      icon: Icons.account_balance_wallet_outlined,
      child: SizedBox(
        height: 260,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= monthly.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        monthly[index].label,
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: [
              for (var i = 0; i < monthly.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: monthly[i].revenue,
                      color: const Color(0xFF0EA5E9),
                      width: 10,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    BarChartRodData(
                      toY: monthly[i].expenses,
                      color: const Color(0xFFEF4444),
                      width: 10,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MortalityCard extends StatelessWidget {
  const _MortalityCard({required this.points});

  final List<DailyMortalityPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return _ChartShell(
        title: 'Mortality Trend',
        icon: Icons.coronavirus_outlined,
        child: const Center(child: Text('No mortality records yet')),
      );
    }

    return _ChartShell(
      title: 'Mortality Trend',
      icon: Icons.coronavirus_outlined,
      child: SizedBox(
        height: 220,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  for (var i = 0; i < points.length; i++)
                    FlSpot(i.toDouble(), points[i].deaths.toDouble()),
                ],
                isCurved: true,
                color: const Color(0xFFEF4444),
                barWidth: 3,
                dotData: const FlDotData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SimpleBarCard extends StatelessWidget {
  const _SimpleBarCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.points,
    this.valueFormatter,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<(String, double)> points;
  final String Function(double value)? valueFormatter;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return _ChartShell(
        title: title,
        icon: icon,
        child: Center(child: Text('No $title data yet')),
      );
    }

    return _ChartShell(
      title: title,
      icon: icon,
      child: SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            barGroups: [
              for (var i = 0; i < points.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: points[i].$2,
                      color: color,
                      width: 12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartShell extends StatelessWidget {
  const _ChartShell({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF10B981)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
