import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/local_db.dart';
import '../data/sync_engine.dart';
import '../services/finance_ledger_service.dart';
import '../services/finance_transaction_service.dart';
import '../services/ledger_allocation_service.dart';
import '../utils/farm_utils.dart';

class FinanceLedgerHubPanel extends StatefulWidget {
  const FinanceLedgerHubPanel({super.key});

  @override
  State<FinanceLedgerHubPanel> createState() => _FinanceLedgerHubPanelState();
}

class _FinanceLedgerHubPanelState extends State<FinanceLedgerHubPanel> {
  final _searchController = TextEditingController();
  String _filterType = 'ALL';
  String _filterStatus = 'ALL';
  List<FinanceLedgerEntry> _entries = const [];
  FinanceLedgerSummary? _summary;
  bool _loading = true;
  String? _farmId;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    unawaited(_load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final farmId = await FarmUtils.getBoundFarmId();
    if (farmId == null || farmId.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final db = context.read<AppDatabase>();
    final service = FinanceLedgerService(db);
    final entries = await service.loadEntries(farmId);
    final summary = await service.loadSummary(farmId);
    if (!mounted) return;
    setState(() {
      _farmId = farmId;
      _entries = entries;
      _summary = summary;
      _loading = false;
    });
  }

  List<FinanceLedgerEntry> get _filteredEntries {
    final query = _searchController.text.trim().toLowerCase();
    return _entries.where((entry) {
      final matchesSearch = query.isEmpty ||
          entry.category.toLowerCase().contains(query) ||
          (entry.description ?? '').toLowerCase().contains(query) ||
          (entry.referenceNum ?? '').toLowerCase().contains(query);
      final matchesType =
          _filterType == 'ALL' || entry.type == _filterType;
      final matchesStatus = _filterStatus == 'ALL' ||
          entry.paymentStatus.toUpperCase() == _filterStatus;
      return matchesSearch && matchesType && matchesStatus;
    }).toList();
  }

  bool get _showZeroBalanceState {
    if (_filterStatus != 'ALL' || _entries.isEmpty) return false;
    return _entries.every(
      (entry) => entry.paymentStatus.toUpperCase() == 'PAID',
    );
  }

  Future<void> _showSettleDialog(FinanceLedgerEntry entry) async {
    if (entry.source != FinanceLedgerSource.ledger) return;
    if (entry.paymentStatus.toUpperCase() == 'PAID') return;

    final refController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settle Transaction'),
        content: TextField(
          controller: refController,
          decoration: const InputDecoration(
            labelText: 'Settlement Reference (optional)',
            hintText: 'MoMo ref #123',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Mark as Settled'),
          ),
        ],
      ),
    );
    final reference = refController.text;
    refController.dispose();
    if (confirmed != true || !mounted) return;

    try {
      final db = context.read<AppDatabase>();
      await FinanceTransactionService(db).settleTransaction(
        transactionId: entry.id,
        referenceNum: reference,
      );
      if (!mounted) return;
      unawaited(context.read<SyncEngine>().syncNow());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction marked as settled')),
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> _showDeleteDialog(FinanceLedgerEntry entry) async {
    if (entry.source != FinanceLedgerSource.ledger) return;

    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final canSubmit = reasonController.text.trim().length >= 5;
          return AlertDialog(
            title: const Text('Delete Transaction'),
            content: TextField(
              controller: reasonController,
              maxLines: 3,
              onChanged: (_) => setDialogState(() {}),
              decoration: const InputDecoration(
                labelText: 'Reason for deletion',
                helperText: 'Minimum 5 characters required',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: canSubmit ? () => Navigator.pop(context, true) : null,
                child: const Text('Delete'),
              ),
            ],
          );
        },
      ),
    );
    final reason = reasonController.text;
    reasonController.dispose();
    if (confirmed != true || !mounted || _farmId == null) return;

    try {
      final db = context.read<AppDatabase>();
      final userId = await FarmUtils.getRequiredUserId();
      await FinanceTransactionService(db).deleteTransaction(
        transactionId: entry.id,
        reason: reason,
        farmId: _farmId!,
        userId: userId,
      );
      if (!mounted) return;
      unawaited(context.read<SyncEngine>().syncNow());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction deleted')),
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'GH₵ ', decimalDigits: 2);
    final cs = Theme.of(context).colorScheme;
    final filtered = _filteredEntries;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF16A34A)),
              const SizedBox(width: 10),
              Text(
                'Finance Hub Ledger',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _loading ? null : _load,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh ledger',
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'GAAP-style ledger with settle and delete flows (web parity)',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
          ),
          if (_summary != null) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _SummaryChip(
                  label: 'Revenue',
                  value: currency.format(_summary!.totalRevenue),
                  color: const Color(0xFF16A34A),
                ),
                _SummaryChip(
                  label: 'Expenses',
                  value: currency.format(_summary!.totalExpense),
                  color: const Color(0xFFDC2626),
                ),
                _SummaryChip(
                  label: 'Net',
                  value: currency.format(_summary!.netPosition),
                  color: const Color(0xFF2563EB),
                ),
                _SummaryChip(
                  label: 'Outstanding',
                  value: '${_summary!.outstandingCount}',
                  color: Colors.orange,
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 240,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search ledger…',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              DropdownButton<String>(
                value: _filterType,
                items: const [
                  DropdownMenuItem(value: 'ALL', child: Text('All types')),
                  DropdownMenuItem(value: 'REVENUE', child: Text('Revenue')),
                  DropdownMenuItem(value: 'EXPENSE', child: Text('Expense')),
                ],
                onChanged: (value) =>
                    setState(() => _filterType = value ?? 'ALL'),
              ),
              DropdownButton<String>(
                value: _filterStatus,
                items: const [
                  DropdownMenuItem(value: 'ALL', child: Text('All statuses')),
                  DropdownMenuItem(value: 'PAID', child: Text('Paid')),
                  DropdownMenuItem(value: 'UNPAID', child: Text('Unpaid')),
                  DropdownMenuItem(
                    value: 'PARTIALLY_PAID',
                    child: Text('Partially paid'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _filterStatus = value ?? 'ALL'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Center(child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ))
          else if (_showZeroBalanceState)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'All ledger balances settled. Zero outstanding accounts.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            )
          else if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No ledger entries match the current filters.',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final entry = filtered[index];
                final displayDescription =
                    LedgerAllocationService.stripLedgerAllocation(
                      entry.description,
                    );
                final allocation = LedgerAllocationService.parseLedgerAllocation(
                  entry.description,
                );
                final isLedger = entry.source == FinanceLedgerSource.ledger;
                final isPaid = entry.paymentStatus.toUpperCase() == 'PAID';

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    entry.category,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.type} · ${DateFormat.yMMMd().add_jm().format(entry.transactionDate)}',
                      ),
                      if (displayDescription != null)
                        Text(displayDescription),
                      if (allocation != null && allocation.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'Allocated across ${allocation.length} batch(es)',
                            style: TextStyle(
                              color: cs.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currency.format(entry.amount),
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: entry.type == 'REVENUE'
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFDC2626),
                            ),
                          ),
                          Text(
                            entry.paymentStatus,
                            style: TextStyle(
                              fontSize: 11,
                              color: isPaid
                                  ? const Color(0xFF16A34A)
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      if (isLedger)
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'settle') {
                              _showSettleDialog(entry);
                            } else if (value == 'delete') {
                              _showDeleteDialog(entry);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'settle',
                              enabled: !isPaid,
                              child: const Text('Settle'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
