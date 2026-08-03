import 'dart:convert';

/// Pure Dart port of web `ledger-allocation.ts` for finance ledger batch splits.

class LedgerAllocationInput {
  const LedgerAllocationInput({
    required this.batchId,
    this.percentage,
    this.amount,
  });

  final String batchId;
  final double? percentage;
  final double? amount;
}

class AllocationBatch {
  const AllocationBatch({
    required this.id,
    required this.name,
    required this.currentCount,
    this.houseName,
  });

  final String id;
  final String name;
  final int currentCount;
  final String? houseName;
}

enum AllocationMode { percentage, amount }

class LedgerAllocationService {
  static const ledgerAllocPrefix = '[LEDGER_ALLOC:';

  static const _ledgerCategoryToExpense = <String, String>{
    'Feed Purchases': 'FEED',
    'Flock Vaccines & Medication': 'MEDICATION',
    'Day-Old Chicks Purchase': 'LIVESTOCK_PURCHASE',
    'Labor & Salaries': 'SALARY',
    'Utilities': 'UTILITIES',
    'Transport': 'TRANSPORT',
    'Equipment & Maintenance': 'EQUIPMENT',
    'Infrastructure & Setup': 'EQUIPMENT',
    'Other OpEx': 'OTHER',
    'Other CapEx': 'OTHER',
  };

  static String mapCategoryToExpenseType(String category) {
    return _ledgerCategoryToExpense[category] ?? 'OTHER';
  }

  static String encodeLedgerAllocation(
    List<({String batchId, double amount})> allocations,
  ) {
    final payload = allocations
        .map((row) => {'batchId': row.batchId, 'amount': row.amount})
        .toList();
    return '$ledgerAllocPrefix${jsonEncode({'allocations': payload})})';
  }

  static List<({String batchId, double amount})>? parseLedgerAllocation(
    String? description,
  ) {
    final text = description ?? '';
    final start = text.indexOf(ledgerAllocPrefix);
    if (start < 0) return null;
    final jsonStart = start + ledgerAllocPrefix.length;
    final jsonEnd = text.indexOf('})', jsonStart);
    if (jsonEnd < 0) return null;
    try {
      final parsed = jsonDecode(text.substring(jsonStart, jsonEnd + 1));
      if (parsed is! Map || parsed['allocations'] is! List) return null;
      return (parsed['allocations'] as List)
          .map((row) {
            if (row is! Map) return null;
            final batchId = row['batchId']?.toString();
            final amount = (row['amount'] as num?)?.toDouble();
            if (batchId == null || amount == null) return null;
            return (batchId: batchId, amount: amount);
          })
          .whereType<({String batchId, double amount})>()
          .toList();
    } catch (_) {
      return null;
    }
  }

  static String? stripLedgerAllocation(String? description) {
    final text = description ?? '';
    final start = text.indexOf(ledgerAllocPrefix);
    if (start < 0) {
      final trimmed = text.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    final stripped = text.substring(0, start).trim().replaceAll(RegExp(r'\s\|\s$'), '');
    return stripped.isEmpty ? null : stripped;
  }

  static double _roundMoney(double value) =>
      (value * 100).roundToDouble() / 100;

  static List<LedgerAllocationInput> buildEvenAllocations(
    List<AllocationBatch> batches,
    double totalAmount,
    AllocationMode mode,
  ) {
    if (batches.isEmpty) return const [];
    if (mode == AllocationMode.percentage) {
      final share = _roundMoney(100 / batches.length);
      var used = 0.0;
      return [
        for (var i = 0; i < batches.length; i++)
          () {
            final isLast = i == batches.length - 1;
            final percentage = isLast ? _roundMoney(100 - used) : share;
            used += percentage;
            return LedgerAllocationInput(
              batchId: batches[i].id,
              percentage: percentage,
            );
          }(),
      ];
    }

    var allocated = 0.0;
    final share = _roundMoney(totalAmount / batches.length);
    return [
      for (var i = 0; i < batches.length; i++)
        () {
          final isLast = i == batches.length - 1;
          final amount = isLast ? _roundMoney(totalAmount - allocated) : share;
          allocated += amount;
          return LedgerAllocationInput(
            batchId: batches[i].id,
            amount: amount,
          );
        }(),
    ];
  }

  static List<LedgerAllocationInput> buildHeadcountAllocations(
    List<AllocationBatch> batches,
    double totalAmount,
    AllocationMode mode,
  ) {
    final totalHeads = batches.fold<int>(
      0,
      (sum, batch) => sum + (batch.currentCount > 0 ? batch.currentCount : 0),
    );
    if (totalHeads <= 0) {
      return buildEvenAllocations(batches, totalAmount, mode);
    }

    if (mode == AllocationMode.percentage) {
      var used = 0.0;
      return [
        for (var i = 0; i < batches.length; i++)
          () {
            final isLast = i == batches.length - 1;
            final percentage = isLast
                ? _roundMoney(100 - used)
                : _roundMoney((batches[i].currentCount / totalHeads) * 100);
            used += percentage;
            return LedgerAllocationInput(
              batchId: batches[i].id,
              percentage: percentage,
            );
          }(),
      ];
    }

    var allocated = 0.0;
    return [
      for (var i = 0; i < batches.length; i++)
        () {
          final isLast = i == batches.length - 1;
          final amount = isLast
              ? _roundMoney(totalAmount - allocated)
              : _roundMoney(
                  (batches[i].currentCount / totalHeads) * totalAmount,
                );
          allocated += amount;
          return LedgerAllocationInput(
            batchId: batches[i].id,
            amount: amount,
          );
        }(),
    ];
  }

  static List<({String batchId, double amount})> resolveAllocationAmounts(
    double totalAmount,
    AllocationMode mode,
    List<LedgerAllocationInput> allocations,
  ) {
    if (mode == AllocationMode.amount) {
      return allocations
          .map(
            (row) => (
              batchId: row.batchId,
              amount: _roundMoney(row.amount ?? 0),
            ),
          )
          .toList();
    }

    var allocated = 0.0;
    return [
      for (var i = 0; i < allocations.length; i++)
        () {
          final isLast = i == allocations.length - 1;
          final amount = isLast
              ? _roundMoney(totalAmount - allocated)
              : _roundMoney(
                  (totalAmount * (allocations[i].percentage ?? 0)) / 100,
                );
          allocated += amount;
          return (batchId: allocations[i].batchId, amount: amount);
        }(),
    ];
  }

  static bool isBalanced({
    required AllocationMode mode,
    required double totalAmount,
    required List<LedgerAllocationInput> allocations,
  }) {
    const tolerance = 0.01;
    if (mode == AllocationMode.percentage) {
      final sum = allocations.fold<double>(
        0,
        (total, row) => total + (row.percentage ?? 0),
      );
      return (sum - 100).abs() <= tolerance;
    }
    final sum = allocations.fold<double>(
      0,
      (total, row) => total + (row.amount ?? 0),
    );
    return (sum - totalAmount).abs() <= tolerance;
  }
}
