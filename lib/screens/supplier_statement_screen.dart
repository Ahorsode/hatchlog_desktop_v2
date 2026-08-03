import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../data/local_db.dart';

class SupplierStatementScreen extends StatelessWidget {
  final Customer supplier;

  const SupplierStatementScreen({super.key, required this.supplier});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FutureBuilder<_SupplierStatement>(
        future: _loadStatement(db),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return _SupplierStatementView(
            supplier: supplier,
            data: snapshot.data!,
          );
        },
      ),
    );
  }

  Future<_SupplierStatement> _loadStatement(AppDatabase db) async {
    final expenses =
        await (db.select(db.expenses)
              ..where((e) => e.supplierId.equals(supplier.id))
              ..orderBy([(e) => OrderingTerm.asc(e.date)]))
            .get();
    final inventory = await (db.select(
      db.inventory,
    )..where((i) => i.supplierId.equals(supplier.id))).get();
    final settlements =
        await (db.select(db.settlements)
              ..where((s) => s.customerId.equals(supplier.id))
              ..where((s) => s.settlementType.equals('PAYMENT')))
            .get();

    final totalPaid = settlements.fold(0.0, (sum, item) => sum + item.amount);
    final rows = <_SupplierStatementRow>[];
    double totalPurchased = 0;
    var running = -totalPaid;

    if (expenses.isNotEmpty) {
      for (final expense in expenses) {
        totalPurchased += expense.amount;
        running += expense.amount;
        rows.add(
          _SupplierStatementRow(
            date: expense.date,
            itemName: expense.description ?? expense.category,
            quantity: null,
            unitCost: null,
            total: expense.amount,
            status: running <= 0 ? 'PAID' : 'UNPAID',
            balance: running < 0 ? 0 : running,
          ),
        );
      }
    } else {
      for (final item in inventory) {
        final total = item.stockLevel * (item.costPerUnit ?? 0);
        totalPurchased += total;
        running += total;
        rows.add(
          _SupplierStatementRow(
            date: item.updatedAt,
            itemName: item.itemName,
            quantity: item.stockLevel,
            unitCost: item.costPerUnit,
            total: total,
            status: total == 0 ? 'N/A' : 'UNPAID',
            balance: running < 0 ? 0 : running,
          ),
        );
      }
    }

    return _SupplierStatement(
      totalPurchased: totalPurchased,
      totalPaid: totalPaid,
      outstanding: (totalPurchased - totalPaid).clamp(0, double.infinity),
      rows: rows.reversed.toList(),
    );
  }
}

class _SupplierStatementView extends StatelessWidget {
  final Customer supplier;
  final _SupplierStatement data;

  const _SupplierStatementView({required this.supplier, required this.data});

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
                      supplier.name,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      [
                        if (supplier.phone?.isNotEmpty == true) supplier.phone!,
                        if (supplier.supplyItems?.isNotEmpty == true)
                          supplier.supplyItems!,
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
              _SummaryCard(
                'Total Purchased',
                money.format(data.totalPurchased),
              ),
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
                    DataColumn(label: Text('Item')),
                    DataColumn(label: Text('Quantity')),
                    DataColumn(label: Text('Unit Cost')),
                    DataColumn(label: Text('Total')),
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
                            DataCell(Text(row.itemName)),
                            DataCell(
                              Text(
                                row.quantity == null
                                    ? 'N/A'
                                    : row.quantity!.toStringAsFixed(1),
                              ),
                            ),
                            DataCell(
                              Text(
                                row.unitCost == null
                                    ? 'N/A'
                                    : money.format(row.unitCost),
                              ),
                            ),
                            DataCell(Text(money.format(row.total))),
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
      ..writeln('Date,Item,Quantity,Unit Cost,Total,Status,Balance');
    for (final row in data.rows) {
      buffer.writeln(
        '${DateFormat('yyyy-MM-dd').format(row.date)},"${row.itemName}",${row.quantity ?? ''},${row.unitCost ?? ''},${row.total.toStringAsFixed(2)},${row.status},${row.balance.toStringAsFixed(2)}',
      );
    }
    final dir =
        await getDownloadsDirectory() ??
        await getApplicationDocumentsDirectory();
    final file = File(
      p.join(
        dir.path,
        'supplier_statement_${supplier.id}_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv',
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
        : status == 'N/A'
        ? Colors.grey
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

class _SupplierStatement {
  final double totalPurchased;
  final double totalPaid;
  final double outstanding;
  final List<_SupplierStatementRow> rows;

  const _SupplierStatement({
    required this.totalPurchased,
    required this.totalPaid,
    required this.outstanding,
    required this.rows,
  });
}

class _SupplierStatementRow {
  final DateTime date;
  final String itemName;
  final double? quantity;
  final double? unitCost;
  final double total;
  final String status;
  final double balance;

  const _SupplierStatementRow({
    required this.date,
    required this.itemName,
    required this.quantity,
    required this.unitCost,
    required this.total,
    required this.status,
    required this.balance,
  });
}
