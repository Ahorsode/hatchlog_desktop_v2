import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/batch_log_entries_service.dart';

class BatchLogsHistoryDialog extends StatefulWidget {
  const BatchLogsHistoryDialog({
    super.key,
    required this.entries,
    required this.canViewFinance,
  });

  final List<BatchLogEntry> entries;
  final bool canViewFinance;

  @override
  State<BatchLogsHistoryDialog> createState() => _BatchLogsHistoryDialogState();
}

class _BatchLogsHistoryDialogState extends State<BatchLogsHistoryDialog> {
  BatchLogEntryType? _filter;

  @override
  Widget build(BuildContext context) {
    final visibleTypes = BatchLogEntryType.values.where((type) {
      if (type == BatchLogEntryType.sales ||
          type == BatchLogEntryType.expense) {
        return widget.canViewFinance;
      }
      return true;
    }).toList();

    final filtered = _filter == null
        ? widget.entries
        : widget.entries.where((entry) => entry.type == _filter).toList();

    return Dialog(
      child: SizedBox(
        width: 720,
        height: 640,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.history),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Logs History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _filter == null,
                    onSelected: (_) => setState(() => _filter = null),
                  ),
                  const SizedBox(width: 8),
                  for (final type in visibleTypes) ...[
                    FilterChip(
                      label: Text(_labelFor(type)),
                      selected: _filter == type,
                      onSelected: (_) => setState(() => _filter = type),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('No logs found'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final entry = filtered[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(entry.title),
                          subtitle: Text(
                            '${DateFormat.yMMMd().add_jm().format(entry.date)} · ${entry.detail}',
                          ),
                          trailing: entry.amount == null
                              ? null
                              : Text(
                                  NumberFormat.currency(
                                    symbol: 'GH₵ ',
                                    decimalDigits: 2,
                                  ).format(entry.amount),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _labelFor(BatchLogEntryType type) {
    return switch (type) {
      BatchLogEntryType.feed => 'Feed',
      BatchLogEntryType.mortality => 'Mortality',
      BatchLogEntryType.eggs => 'Eggs',
      BatchLogEntryType.weight => 'Weight',
      BatchLogEntryType.health => 'Health',
      BatchLogEntryType.sales => 'Sales',
      BatchLogEntryType.expense => 'Expenses',
    };
  }
}
