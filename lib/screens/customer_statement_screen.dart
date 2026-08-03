import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../data/local_db.dart';

class CustomerStatementScreen extends StatelessWidget {
  final Customer customer;

  const CustomerStatementScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FutureBuilder<_CustomerStatement>(
        future: _loadStatement(db),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return _CustomerStatementView(
            customer: customer,
            data: snapshot.data!,
          );
        },
      ),
    );
  }

  Future<_CustomerStatement> _loadStatement(AppDatabase db) async {
    final sales =
        await (db.select(db.sales)
              ..where((s) => s.customerId.equals(customer.id))
              ..orderBy([(s) => OrderingTerm.asc(s.saleDate)]))
            .get();
    final settlements =
        await (db.select(db.settlements)
              ..where((s) => s.customerId.equals(customer.id))
              ..where((s) => s.settlementType.equals('COLLECTION')))
            .get();

    final totalBilled = sales.fold(0.0, (sum, sale) => sum + sale.totalAmount);
    final totalPaid = settlements.fold(0.0, (sum, item) => sum + item.amount);
    final rows = <_CustomerStatementRow>[];
    var running = -totalPaid;
    for (final sale in sales) {
      running += sale.totalAmount;
      rows.add(
        _CustomerStatementRow(
          date: sale.saleDate,
          description:
              'Sale #${sale.id.length > 8 ? sale.id.substring(0, 8) : sale.id}',
          amount: sale.totalAmount,
          status: running <= 0 ? 'PAID' : 'UNPAID',
          balance: running < 0 ? 0 : running,
        ),
      );
    }
    return _CustomerStatement(
      totalBilled: totalBilled,
      totalPaid: totalPaid,
      outstanding: (totalBilled - totalPaid).clamp(0, double.infinity),
      rows: rows.reversed.toList(),
    );
  }
}

class _CustomerStatementView extends StatelessWidget {
  final Customer customer;
  final _CustomerStatement data;

  const _CustomerStatementView({required this.customer, required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final money = NumberFormat.currency(symbol: 'GHc ', decimalDigits: 2);
    return Padding(
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      [
                        if (customer.phone?.isNotEmpty == true) customer.phone!,
                        if (customer.address?.isNotEmpty == true)
                          customer.address!,
                      ].join(' · '),
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _export(context),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Export CSV'),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _SummaryCard('Total Billed', money.format(data.totalBilled)),
              _SummaryCard('Total Paid', money.format(data.totalPaid)),
              _SummaryCard(
                'Outstanding',
                money.format(data.outstanding),
                accent: data.outstanding > 0
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF22C55E),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: _cardDecoration(context),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Description')),
                    DataColumn(label: Text('Amount')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Balance')),
                  ],
                  rows: data.rows
                      .map(
                        (row) => DataRow(
                          cells: [
                            DataCell(
                              Text(DateFormat('MMM d, yyyy').format(row.date)),
                            ),
                            DataCell(Text(row.description)),
                            DataCell(Text(money.format(row.amount))),
                            DataCell(_StatusBadge(status: row.status)),
                            DataCell(Text(money.format(row.balance))),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context) async {
    final buffer = StringBuffer()
      ..writeln('Date,Description,Amount,Status,Balance');
    for (final row in data.rows) {
      buffer.writeln(
        '${DateFormat('yyyy-MM-dd').format(row.date)},"${row.description}",${row.amount.toStringAsFixed(2)},${row.status},${row.balance.toStringAsFixed(2)}',
      );
    }
    final dir =
        await getDownloadsDirectory() ??
        await getApplicationDocumentsDirectory();
    final file = File(
      p.join(
        dir.path,
        'customer_statement_${customer.id}_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv',
      ),
    );
    await file.writeAsString(buffer.toString());
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Statement exported to ${file.path}')),
      );
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? accent;

  const _SummaryCard(this.label, this.value, {this.accent});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 230,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            value,
            style: TextStyle(
              color: accent ?? cs.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == 'PAID'
        ? const Color(0xFF22C55E)
        : status == 'PARTIAL'
        ? const Color(0xFFF59E0B)
        : const Color(0xFFEF4444);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
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

class _CustomerStatement {
  final double totalBilled;
  final double totalPaid;
  final double outstanding;
  final List<_CustomerStatementRow> rows;

  const _CustomerStatement({
    required this.totalBilled,
    required this.totalPaid,
    required this.outstanding,
    required this.rows,
  });
}

class _CustomerStatementRow {
  final DateTime date;
  final String description;
  final double amount;
  final String status;
  final double balance;

  const _CustomerStatementRow({
    required this.date,
    required this.description,
    required this.amount,
    required this.status,
    required this.balance,
  });
}
