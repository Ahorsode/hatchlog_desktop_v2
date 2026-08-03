import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/batch_deep_dive_models.dart';

class BatchFinanceBreakdownPanel extends StatelessWidget {
  const BatchFinanceBreakdownPanel({
    super.key,
    required this.finance,
  });

  final BatchFinanceResult finance;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RevenueBreakdownCard(
          title: 'Revenue Breakdown',
          icon: Icons.trending_up,
          color: const Color(0xFF0EA5E9),
          items: finance.revenueBreakdown,
        ),
        const SizedBox(height: 16),
        _ExpenseBreakdownCard(
          title: 'Expense Breakdown',
          icon: Icons.receipt_long_outlined,
          color: const Color(0xFFEF4444),
          items: finance.expenseBreakdown,
        ),
      ],
    );
  }
}

class _RevenueBreakdownCard extends StatelessWidget {
  const _RevenueBreakdownCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<RevenueBreakdownItem> items;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currency = NumberFormat.currency(symbol: 'GH₵ ', decimalDigits: 2);
    final total = items.fold<double>(0, (sum, item) => sum + item.amount);

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
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Text(
              'No entries yet',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.description,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Text(
                                DateFormat.yMMMd().format(item.date),
                                style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                              ),
                              _kindBadge(item.kind, cs),
                              if (item.quantity != null)
                                Text(
                                  '${item.quantity} units',
                                  style: TextStyle(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                                ),
                              if (item.percentage != null)
                                Text(
                                  '${item.percentage!.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      currency.format(item.amount),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const Divider(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${items.length} entr${items.length == 1 ? 'y' : 'ies'}',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
              ),
              Text(
                currency.format(total),
                style: TextStyle(color: color, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpenseBreakdownCard extends StatelessWidget {
  const _ExpenseBreakdownCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<ExpenseBreakdownItem> items;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currency = NumberFormat.currency(symbol: 'GH₵ ', decimalDigits: 2);
    final total = items.fold<double>(0, (sum, item) => sum + item.amount);

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
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Text(
              'No entries yet',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.description,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Text(
                                item.category,
                                style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                DateFormat.yMMMd().format(item.date),
                                style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                              ),
                              _kindBadge(item.kind, cs),
                              if (item.percentage != null)
                                Text(
                                  '${item.percentage!.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      currency.format(item.amount),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const Divider(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${items.length} entr${items.length == 1 ? 'y' : 'ies'}',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
              ),
              Text(
                currency.format(total),
                style: TextStyle(color: color, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _kindBadge(String kind, ColorScheme cs) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: cs.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      kind,
      style: TextStyle(
        color: cs.primary,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class BatchMetadataPanel extends StatelessWidget {
  const BatchMetadataPanel({
    super.key,
    required this.batch,
    required this.finance,
  });

  final BatchDeepDiveBatch batch;
  final BatchFinanceResult? finance;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currency = NumberFormat.currency(symbol: 'GH₵ ', decimalDigits: 2);

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
            'BATCH METADATA',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.1),
          ),
          const SizedBox(height: 12),
          _metaRow('Unit Name', batch.batchName),
          _metaRow('House', batch.house?.name ?? 'Unassigned'),
          _metaRow('Breed', batch.breedType ?? '—'),
          _metaRow('Growth Target', batch.growthTarget ?? '—'),
          if (finance != null)
            _metaRow(
              'Initial Investment',
              currency.format(finance!.initialInvestment),
            ),
        ],
      ),
    );
  }

  Widget _metaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
