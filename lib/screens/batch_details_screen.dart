import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/local_db.dart';
import '../models/batch_deep_dive_models.dart';
import '../services/batch_deep_dive_service.dart';
import '../services/batch_log_entries_service.dart';
import '../utils/farm_utils.dart';
import '../widgets/batch_finance_breakdown_panel.dart';
import '../widgets/batch_health_schedule_panel.dart';
import '../widgets/batch_logs_history_dialog.dart';
import '../widgets/batch_quick_log_panel.dart';
import '../widgets/batch_trend_charts.dart';
import 'comprehensive_report_screen.dart';

class BatchDetailsScreen extends StatefulWidget {
  final Batch batch;
  const BatchDetailsScreen({super.key, required this.batch});

  @override
  State<BatchDetailsScreen> createState() => _BatchDetailsScreenState();
}

class _BatchDetailsScreenState extends State<BatchDetailsScreen> {
  BatchDeepDivePayload? _payload;
  List<BatchLogEntry> _entries = const [];
  bool _loading = true;
  String? _farmId;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final farmId = await FarmUtils.getBoundFarmId();
    if (farmId == null || !mounted) return;

    final db = context.read<AppDatabase>();
    final payload = await BatchDeepDiveService(db).load(widget.batch.id, farmId);
    if (!mounted) return;

    final entries = payload == null
        ? const <BatchLogEntry>[]
        : BatchLogEntriesService.buildBatchLogEntries(
            logs: payload.logs,
            expenseBreakdown: payload.finance.result?.expenseBreakdown ?? const [],
            canViewFinance: payload.finance.canViewFinance,
          );

    setState(() {
      _farmId = farmId;
      _payload = payload;
      _entries = entries;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final payload = _payload;
    final currency = NumberFormat.currency(symbol: 'GH₵ ', decimalDigits: 2);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(widget.batch.batchName),
        actions: [
          IconButton(
            tooltip: 'Generate report',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ComprehensiveReportScreen(
                    focusBatchId: widget.batch.id,
                    focusBatchName: widget.batch.batchName,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.description_outlined),
          ),
          if (payload != null)
            TextButton.icon(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => BatchLogsHistoryDialog(
                  entries: _entries,
                  canViewFinance: payload.finance.canViewFinance,
                ),
              ),
              icon: const Icon(Icons.history),
              label: const Text('Logs'),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : payload == null || _farmId == null
          ? const Center(child: Text('Unable to load batch details'))
          : RefreshIndicator(
              onRefresh: _reload,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 980;
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(isNarrow ? 16 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BatchQuickLogPanel(
                          batch: widget.batch,
                          payload: payload,
                          farmId: _farmId!,
                          onChanged: _reload,
                        ),
                        const SizedBox(height: 20),
                        _buildOperationalMetrics(payload),
                        if (payload.finance.canViewFinance &&
                            payload.finance.result != null) ...[
                          const SizedBox(height: 16),
                          _buildFinanceMetrics(payload.finance.result!, currency),
                        ],
                        const SizedBox(height: 20),
                        if (isNarrow) ...[
                          BatchTrendCharts(payload: payload),
                          const SizedBox(height: 16),
                          _buildActivityTimeline(),
                          const SizedBox(height: 16),
                          _buildSidebar(payload),
                        ] else
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    BatchTrendCharts(payload: payload),
                                    const SizedBox(height: 16),
                                    _buildActivityTimeline(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 2,
                                child: _buildSidebar(payload),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildOperationalMetrics(BatchDeepDivePayload payload) {
    final metrics = payload.metrics;
    final batch = payload.batch;
    final stockSubtext = batch.isolationCount > 0
        ? '${batch.isolationCount} in isolation'
        : 'from ${NumberFormat('#,###').format(batch.initialCount)}';

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _metricCard(
          'Current Age',
          '${metrics.ageInDays} Days',
          'Arrived ${DateFormat.yMMMd().format(batch.arrivalDate)}',
          Icons.calendar_today_outlined,
          const Color(0xFF10B981),
        ),
        _metricCard(
          'Feed Conversion (FCR)',
          metrics.fcr > 0 ? metrics.fcr.toStringAsFixed(2) : '---',
          '${metrics.totalFeed.toStringAsFixed(0)} bags fed',
          Icons.show_chart,
          const Color(0xFFF59E0B),
        ),
        _metricCard(
          'Mortality Rate',
          '${metrics.mortalityRate.toStringAsFixed(1)}%',
          '${metrics.totalMortality} total deaths',
          Icons.coronavirus_outlined,
          const Color(0xFFEF4444),
        ),
        _metricCard(
          'Current Stock',
          NumberFormat('#,###').format(batch.currentCount),
          stockSubtext,
          Icons.inventory_2_outlined,
          const Color(0xFF3B82F6),
        ),
      ],
    );
  }

  Widget _buildFinanceMetrics(BatchFinanceResult finance, NumberFormat currency) {
    final expenseSubtext = [
      if (finance.initialInvestment > 0)
        '${currency.format(finance.initialInvestment)} initial',
      if (finance.consumptionAllocatedTotal > 0)
        '${currency.format(finance.consumptionAllocatedTotal)} feed & med',
      if (finance.generalAllocatedTotal > 0)
        '${finance.headcountSharePct.toStringAsFixed(0)}% general',
    ].join(' · ');

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _metricCard(
          'Total Revenue',
          currency.format(finance.totalRevenue),
          'From sales',
          Icons.account_balance_wallet_outlined,
          const Color(0xFF0EA5E9),
        ),
        _metricCard(
          'Total Expenses',
          currency.format(finance.totalExpenses),
          expenseSubtext.isEmpty ? 'Operating costs' : expenseSubtext,
          Icons.payments_outlined,
          const Color(0xFFFB923C),
        ),
        _metricCard(
          'Net Profit',
          currency.format(finance.netProfit),
          finance.netProfit >= 0 ? 'In profit' : 'In loss',
          finance.netProfit >= 0 ? Icons.trending_up : Icons.trending_down,
          finance.netProfit >= 0
              ? const Color(0xFF10B981)
              : const Color(0xFFEF4444),
        ),
      ],
    );
  }

  Widget _metricCard(
    String title,
    String value,
    String subtext,
    IconData icon,
    Color color,
  ) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: 220,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    subtext,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(BatchDeepDivePayload payload) {
    return Column(
      children: [
        BatchHealthSchedulePanel(
          batchId: widget.batch.id,
          farmId: _farmId!,
          vaccinations: payload.logs.vaccinations,
          medications: payload.logs.medications,
          canEdit: payload.forms.canEditHealth,
          onChanged: _reload,
        ),
        const SizedBox(height: 16),
        if (payload.finance.canViewFinance && payload.finance.result != null)
          BatchFinanceBreakdownPanel(finance: payload.finance.result!),
        if (payload.finance.canViewFinance && payload.finance.result != null)
          const SizedBox(height: 16),
        BatchMetadataPanel(
          batch: payload.batch,
          finance: payload.finance.result,
        ),
        const SizedBox(height: 16),
        _buildRecentOperations(),
      ],
    );
  }

  Widget _buildActivityTimeline() {
    final cs = Theme.of(context).colorScheme;
    final recent = _entries.take(12).toList();

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
          const Text(
            'Activity Timeline',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 12),
          if (recent.isEmpty)
            Text(
              'No activity yet',
              style: TextStyle(color: cs.onSurfaceVariant),
            )
          else
            ...recent.map(
              (entry) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: _colorFor(entry.type).withValues(alpha: 0.12),
                  child: Icon(
                    _iconFor(entry.type),
                    size: 16,
                    color: _colorFor(entry.type),
                  ),
                ),
                title: Text(entry.title),
                subtitle: Text(
                  '${DateFormat.yMMMd().add_jm().format(entry.date)} · ${entry.detail}',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentOperations() {
    final cs = Theme.of(context).colorScheme;
    final recent = _entries.take(6).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Operations',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          if (recent.isEmpty)
            Text(
              'No recent logs found.',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            )
          else
            ...recent.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      DateFormat.MMMd().format(entry.date),
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _colorFor(BatchLogEntryType type) {
    return switch (type) {
      BatchLogEntryType.feed => const Color(0xFFF59E0B),
      BatchLogEntryType.mortality => const Color(0xFFEF4444),
      BatchLogEntryType.eggs => const Color(0xFFFB923C),
      BatchLogEntryType.weight => const Color(0xFF10B981),
      BatchLogEntryType.health => const Color(0xFF8B5CF6),
      BatchLogEntryType.sales => const Color(0xFF0EA5E9),
      BatchLogEntryType.expense => const Color(0xFF3B82F6),
    };
  }

  IconData _iconFor(BatchLogEntryType type) {
    return switch (type) {
      BatchLogEntryType.feed => Icons.grain,
      BatchLogEntryType.mortality => Icons.coronavirus_outlined,
      BatchLogEntryType.eggs => Icons.egg_outlined,
      BatchLogEntryType.weight => Icons.monitor_weight_outlined,
      BatchLogEntryType.health => Icons.medical_services_outlined,
      BatchLogEntryType.sales => Icons.shopping_cart_outlined,
      BatchLogEntryType.expense => Icons.payments_outlined,
    };
  }
}
