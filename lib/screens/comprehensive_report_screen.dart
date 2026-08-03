import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../data/local_db.dart';
import '../services/comprehensive_farm_report_service.dart';
import '../utils/farm_utils.dart';
import '../utils/staff_permission_defaults.dart';
import '../utils/worker_permissions_loader.dart';
import 'report_log_screen.dart';

class ComprehensiveReportScreen extends StatefulWidget {
  const ComprehensiveReportScreen({
    super.key,
    this.focusBatchId,
    this.focusBatchName,
  });

  final String? focusBatchId;
  final String? focusBatchName;

  @override
  State<ComprehensiveReportScreen> createState() =>
      _ComprehensiveReportScreenState();
}

class _ComprehensiveReportScreenState extends State<ComprehensiveReportScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  ComprehensiveFarmReport? _report;
  bool _loading = false;
  bool _canViewReports = true;
  Set<String> _permissions = const {};
  String? _role;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAccess());
  }

  Future<void> _loadAccess() async {
    try {
      final db = context.read<AppDatabase>();
      final permissions = await loadWorkerPermissions(db);
      final role = await FarmUtils.getUserRole();
      if (!mounted) return;
      setState(() {
        _permissions = permissions;
        _role = role;
        _canViewReports = canViewReports(role: role, permissions: permissions);
      });
      if (_canViewReports) {
        await _generateReport();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _canViewReports = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reports & Logs',
                        style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Generate farm reports and review operation logs.',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_report != null && _tabController.index == 0)
                  FilledButton.icon(
                    onPressed: _exportReportAsCsv,
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('Export CSV'),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Farm Report'),
                Tab(text: 'Operation Logs'),
              ],
              onTap: (_) => setState(() {}),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildReportTab(context), const ReportLogScreen()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTab(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (!_canViewReports) {
      return Center(
        child: Text(
          'Finance view permission is required to access farm intelligence reports.',
          style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _DatePickerButton(
              label: 'Start Date',
              date: _startDate,
              onPick: (date) => setState(() => _startDate = date),
            ),
            _DatePickerButton(
              label: 'End Date',
              date: _endDate,
              onPick: (date) => setState(() => _endDate = date),
            ),
            FilledButton.icon(
              onPressed: _loading ? null : _generateReport,
              icon: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.analytics_rounded, size: 18),
              label: const Text('Generate Report'),
            ),
            OutlinedButton.icon(
              onPressed: _loading ? null : () => _applyPreset(7),
              icon: const Icon(Icons.date_range_rounded, size: 18),
              label: const Text('Last 7 Days'),
            ),
            OutlinedButton.icon(
              onPressed: _loading ? null : () => _applyPreset(30),
              icon: const Icon(Icons.calendar_month_rounded, size: 18),
              label: const Text('Last 30 Days'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Expanded(
          child: _report == null
              ? Center(
                  child: Text(
                    'Choose a date range and generate a farm report.',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: _ReportView(
                    report: _report!,
                    focusBatchId: widget.focusBatchId,
                    focusBatchName: widget.focusBatchName,
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _applyPreset(int days) async {
    final end = DateTime.now();
    setState(() {
      _endDate = end;
      _startDate = DateTime(end.year, end.month, end.day).subtract(
        Duration(days: days - 1),
      );
    });
    await _generateReport();
  }

  Future<void> _generateReport() async {
    if (!_canViewReports) return;
    setState(() => _loading = true);
    try {
      final db = context.read<AppDatabase>();
      final farmId = await FarmUtils.getBoundFarmId();
      if (farmId == null) throw Exception('No bound farm found.');

      final report = await ComprehensiveFarmReportService(db).generate(
        farmId: farmId,
        startDate: _startDate,
        endDate: _endDate,
        role: _role,
        permissions: _permissions,
        assignableRoles: assignableStaffRoles,
      );

      setState(() => _report = report);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unable to generate: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _exportReportAsCsv() async {
    final report = _report;
    if (report == null) return;
    final buffer = StringBuffer()
      ..writeln('Metric,Value')
      ..writeln('Total Revenue,${report.kpis.totalRevenue.toStringAsFixed(2)}')
      ..writeln('Total Expenses,${report.kpis.totalExpense.toStringAsFixed(2)}')
      ..writeln('Net Income,${report.kpis.netIncome.toStringAsFixed(2)}')
      ..writeln('Total Eggs,${report.kpis.totalEggsCollected}')
      ..writeln('Feed Consumed Kg,${report.kpis.totalFeedConsumed.toStringAsFixed(2)}')
      ..writeln('Mortality,${report.kpis.totalMortality}')
      ..writeln('Mortality Rate,${report.kpis.mortalityRate.toStringAsFixed(2)}')
      ..writeln('Average FCR,${report.kpis.averageFcr.toStringAsFixed(2)}')
      ..writeln()
      ..writeln('Batch,Status,Initial,Current,Mortality,Feed Kg');
    for (final row in report.batches) {
      buffer.writeln(
        '"${row.batchName}",${row.status},${row.initialCount},${row.currentCount},${row.mortalityCount},${row.feedConsumed.toStringAsFixed(2)}',
      );
    }

    final downloads =
        await getDownloadsDirectory() ??
        await getApplicationDocumentsDirectory();
    final fileName =
        'pfm_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';
    final file = File(p.join(downloads.path, fileName));
    await file.writeAsString(buffer.toString());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report exported to ${file.path}')),
      );
    }
  }
}

class _ReportView extends StatelessWidget {
  final ComprehensiveFarmReport report;
  final String? focusBatchId;
  final String? focusBatchName;

  const _ReportView({
    required this.report,
    this.focusBatchId,
    this.focusBatchName,
  });

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(symbol: 'GHc ', decimalDigits: 2);
    final kpis = report.kpis;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _SummaryCard('Net Income', money.format(kpis.netIncome),
                accent: kpis.netIncome >= 0
                    ? const Color(0xFF22C55E)
                    : const Color(0xFFEF4444)),
            _SummaryCard('Feed Conversion Ratio', kpis.averageFcr.toStringAsFixed(2)),
            _SummaryCard('Total Eggs', '${kpis.totalEggsCollected}'),
            _SummaryCard(
              'Mortality Rate',
              '${kpis.mortalityRate.toStringAsFixed(2)}%',
              subtitle: '${kpis.totalMortality} deaths logged',
              accent: kpis.mortalityRate < 5
                  ? const Color(0xFF22C55E)
                  : const Color(0xFFEF4444),
            ),
            _SummaryCard('Total Revenue', money.format(kpis.totalRevenue)),
            _SummaryCard('Total Expenses', money.format(kpis.totalExpense)),
            _SummaryCard(
              'Feed Consumed',
              '${kpis.totalFeedConsumed.toStringAsFixed(1)} kg',
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
                  child: _BreakdownCard(
                    title: 'Revenue by Category',
                    values: report.revenueByCategory,
                    currency: money,
                  ),
                ),
                SizedBox(
                  width: narrow
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 18) / 2,
                  child: _BreakdownCard(
                    title: 'Expenses by Category',
                    values: report.expenseByCategory,
                    currency: money,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        _LedgerTrendCard(trends: report.dailyTrends),
        const SizedBox(height: 18),
        _BatchTable(
          rows: focusBatchId == null
              ? report.batches
              : report.batches
                  .where((row) => row.id == focusBatchId)
                  .toList(),
          highlightBatchId: focusBatchId,
        ),
        if (focusBatchName != null) ...[
          const SizedBox(height: 8),
          Text(
            'Focused on $focusBatchName',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const SizedBox(height: 18),
        _FinancialLedgerTable(rows: report.financials, currency: money),
      ],
    );
  }
}

class _DatePickerButton extends StatelessWidget {
  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onPick;

  const _DatePickerButton({
    required this.label,
    required this.date,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2000),
          lastDate: DateTime.now().add(const Duration(days: 1)),
        );
        if (picked != null) onPick(picked);
      },
      icon: const Icon(Icons.calendar_month_rounded, size: 18),
      label: Text('$label: ${DateFormat('MMM d, yyyy').format(date)}'),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final Color? accent;

  const _SummaryCard(this.label, this.value, {this.subtitle, this.accent});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = accent ?? cs.primary;
    return Container(
      width: 210,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outline.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  final String title;
  final Map<String, double> values;
  final NumberFormat currency;

  const _BreakdownCard({
    required this.title,
    required this.values,
    required this.currency,
  });

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
            title,
            style: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 14),
          if (values.isEmpty || total == 0)
            Text('No data', style: TextStyle(color: cs.onSurfaceVariant))
          else
            for (final entry in values.entries) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    currency.format(entry.value),
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: total == 0 ? 0 : entry.value / total,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _BatchTable extends StatelessWidget {
  final List<ReportBatchRow> rows;
  final String? highlightBatchId;

  const _BatchTable({required this.rows, this.highlightBatchId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(context),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Batch Name')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Initial')),
            DataColumn(label: Text('Current')),
            DataColumn(label: Text('Mortality')),
            DataColumn(label: Text('Feed (kg)')),
          ],
          rows: rows
              .map(
                (row) => DataRow(
                  cells: [
                    DataCell(Text(row.batchName)),
                    DataCell(Text(row.status)),
                    DataCell(Text('${row.initialCount}')),
                    DataCell(Text('${row.currentCount}')),
                    DataCell(Text('${row.mortalityCount}')),
                    DataCell(Text(row.feedConsumed.toStringAsFixed(1))),
                  ],
                ),
              )
              .toList(),
          headingTextStyle: TextStyle(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w900,
            fontSize: 11,
          ),
          dataTextStyle: TextStyle(color: cs.onSurface),
        ),
      ),
    );
  }
}

class _LedgerTrendCard extends StatelessWidget {
  final List<DailyReportTrend> trends;

  const _LedgerTrendCard({required this.trends});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 280,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ledger Inflow / Outflow Trends',
            style: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: trends.length < 2
                ? Center(
                    child: Text(
                      'Insufficient data points to plot trend line.',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  )
                : CustomPaint(
                    painter: _LedgerTrendPainter(trends: trends),
                    size: Size.infinite,
                  ),
          ),
        ],
      ),
    );
  }
}

class _FinancialLedgerTable extends StatelessWidget {
  final List<ReportFinancialRow> rows;
  final NumberFormat currency;

  const _FinancialLedgerTable({
    required this.rows,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Ledger',
            style: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            Text('No financial transactions in this period.',
                style: TextStyle(color: cs.onSurfaceVariant))
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Status')),
                ],
                rows: rows.take(30).map((row) {
                  return DataRow(cells: [
                    DataCell(Text(DateFormat('yyyy-MM-dd').format(row.transactionDate))),
                    DataCell(Text(row.type)),
                    DataCell(Text(row.category)),
                    DataCell(Text(currency.format(row.amount))),
                    DataCell(Text(row.paymentStatus)),
                  ]);
                }).toList(),
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

class _LedgerTrendPainter extends CustomPainter {
  final List<DailyReportTrend> trends;

  const _LedgerTrendPainter({required this.trends});

  @override
  void paint(Canvas canvas, Size size) {
    if (trends.length < 2) return;
    final maxVal = trends
        .map((t) => [t.revenue, t.expense, 100.0].reduce((a, b) => a > b ? a : b))
        .reduce((a, b) => a > b ? a : b);
    final padding = 12.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;

    void drawLine(Color color, double Function(DailyReportTrend) value) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;
      final path = Path();
      for (var i = 0; i < trends.length; i++) {
        final x = padding + (i / (trends.length - 1)) * chartWidth;
        final y = padding +
            chartHeight -
            (value(trends[i]) / maxVal) * chartHeight;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }

    drawLine(const Color(0xFF22C55E), (t) => t.revenue);
    drawLine(const Color(0xFFEF4444), (t) => t.expense);
  }

  @override
  bool shouldRepaint(covariant _LedgerTrendPainter oldDelegate) =>
      oldDelegate.trends != trends;
}
