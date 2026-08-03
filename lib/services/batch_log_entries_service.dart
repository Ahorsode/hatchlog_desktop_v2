import 'package:intl/intl.dart';

import '../models/batch_deep_dive_models.dart';

enum BatchLogEntryType {
  feed,
  mortality,
  eggs,
  weight,
  health,
  sales,
  expense,
}

class BatchLogEntry {
  const BatchLogEntry({
    required this.id,
    required this.type,
    required this.date,
    required this.title,
    required this.detail,
    this.amount,
    this.userId,
  });

  final String id;
  final BatchLogEntryType type;
  final DateTime date;
  final String title;
  final String detail;
  final double? amount;
  final String? userId;
}

class BatchLogEntriesService {
  static List<BatchLogEntry> buildBatchLogEntries({
    required BatchDeepDiveLogs logs,
    required List<ExpenseBreakdownItem> expenseBreakdown,
    required bool canViewFinance,
  }) {
    final entries = <BatchLogEntry>[];

    for (final log in logs.feedingLogs) {
      final inventory = log['inventory'] as Map<String, dynamic>?;
      final itemName = inventory?['itemName']?.toString() ?? 'Feed consumption';
      final unit = inventory?['unit']?.toString() ?? 'bags';
      final amount = (log['amountConsumed'] as num?)?.toDouble() ?? 0;
      entries.add(
        BatchLogEntry(
          id: 'feed-${log['id']}',
          type: BatchLogEntryType.feed,
          date: DateTime.parse(log['logDate'] as String),
          title: itemName,
          detail:
              '${NumberFormat('#,###').format(amount)} $unit consumed',
          userId: log['userId']?.toString(),
        ),
      );
    }

    for (final record in logs.mortalityRecords) {
      final type = (record['type']?.toString() ?? '').toUpperCase();
      final count = (record['count'] as num?)?.toInt() ?? 0;
      entries.add(
        BatchLogEntry(
          id: 'mortality-${record['id']}',
          type: BatchLogEntryType.mortality,
          date: DateTime.parse(record['logDate'] as String),
          title: type == 'SICK' ? 'Sick birds recorded' : 'Mortality recorded',
          detail:
              '$count bird${count == 1 ? '' : 's'} · ${type == 'SICK' ? 'Sick' : 'Dead'}',
          userId: record['userId']?.toString(),
        ),
      );
    }

    for (final record in logs.eggProduction) {
      final eggs = (record['eggsCollected'] as num?)?.toInt() ?? 0;
      entries.add(
        BatchLogEntry(
          id: 'eggs-${record['id']}',
          type: BatchLogEntryType.eggs,
          date: DateTime.parse(record['logDate'] as String),
          title: 'Egg collection',
          detail: '${NumberFormat('#,###').format(eggs)} eggs collected',
          userId: record['userId']?.toString(),
        ),
      );
    }

    for (final record in logs.weightRecords) {
      final weight = (record['averageWeight'] as num?)?.toDouble() ?? 0;
      entries.add(
        BatchLogEntry(
          id: 'weight-${record['id']}',
          type: BatchLogEntryType.weight,
          date: DateTime.parse(record['logDate'] as String),
          title: 'Weight check',
          detail: 'Average weight ${weight.toStringAsFixed(2)} kg',
          userId: record['userId']?.toString(),
        ),
      );
    }

    for (final schedule in logs.vaccinations) {
      entries.add(
        BatchLogEntry(
          id: 'vaccine-${schedule['id']}',
          type: BatchLogEntryType.health,
          date: DateTime.parse(schedule['scheduledDate'] as String),
          title: 'Vaccination · ${schedule['vaccineName']}',
          detail: [
            schedule['status'],
            if (schedule['quantity'] != null)
              '${schedule['quantity']} ${schedule['unit'] ?? 'doses'}',
            schedule['notes'],
          ].where((part) => part != null && '$part'.isNotEmpty).join(' · '),
        ),
      );
    }

    for (final schedule in logs.medications) {
      entries.add(
        BatchLogEntry(
          id: 'med-${schedule['id']}',
          type: BatchLogEntryType.health,
          date: DateTime.parse(schedule['scheduledDate'] as String),
          title: 'Medication · ${schedule['medicationName']}',
          detail: [
            schedule['status'],
            if (schedule['quantity'] != null)
              '${schedule['quantity']} ${schedule['unit'] ?? 'doses'}',
            schedule['notes'],
          ].where((part) => part != null && '$part'.isNotEmpty).join(' · '),
        ),
      );
    }

    if (canViewFinance) {
      for (final sale in logs.salesRecords) {
        final quantity = (sale['quantity'] as num?)?.toInt() ?? 0;
        final unitPrice = (sale['unitPrice'] as num?)?.toDouble() ?? 0;
        final totalPrice = (sale['totalPrice'] as num?)?.toDouble() ?? 0;
        entries.add(
          BatchLogEntry(
            id: 'sale-${sale['id']}',
            type: BatchLogEntryType.sales,
            date: DateTime.parse(sale['logDate'] as String),
            title: sale['description']?.toString() ?? 'Sale',
            detail:
                '${NumberFormat('#,###').format(quantity)} units @ ${_formatCurrency(unitPrice)}',
            amount: totalPrice,
          ),
        );
      }

      for (final expense in expenseBreakdown) {
        entries.add(
          BatchLogEntry(
            id: 'expense-${expense.id}',
            type: BatchLogEntryType.expense,
            date: expense.date,
            title: expense.description,
            detail: [
              expense.category,
              expense.kind,
              if (expense.percentage != null) '${expense.percentage}%',
            ].join(' · '),
            amount: expense.amount,
          ),
        );
      }
    }

    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  static String _formatCurrency(double value) {
    return NumberFormat.currency(symbol: 'GH₵ ', decimalDigits: 2).format(value);
  }
}
