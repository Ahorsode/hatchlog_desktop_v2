import 'dart:convert';

import '../models/batch_deep_dive_models.dart';
import 'batch_consumption_finance.dart';
import 'ledger_allocation_service.dart';

bool _isCancelled(String? status) =>
    (status ?? '').toUpperCase() == 'CANCELLED';

Map<String, List<BatchRevenueItem>> buildFarmRevenueByBatch({
  required List<({
    String id,
    String? description,
    int quantity,
    double unitPrice,
    double totalPrice,
    String? livestockId,
    String? eggAllocationMode,
    String? eggBatchId,
    DateTime orderDate,
    String? orderStatus,
  })> orderItems,
  required List<({
    String id,
    String orderItemId,
    String batchId,
    double revenueAmount,
    int? eggsUsed,
    String? description,
    DateTime orderDate,
    String? orderStatus,
  })> batchAllocations,
  required List<({
    String id,
    double amount,
    DateTime transactionDate,
    String? description,
  })> manualLedgerTransactions,
  required List<HeadcountBatch> activeBatches,
}) {
  final batchIds = activeBatches.map((batch) => batch.id).toSet();
  final byBatch = <String, List<BatchRevenueItem>>{
    for (final id in batchIds) id: <BatchRevenueItem>[],
  };

  final allocatedOrderItemIds = <String>{};
  for (final row in batchAllocations) {
    if (!batchIds.contains(row.batchId)) continue;
    if (_isCancelled(row.orderStatus)) continue;

    allocatedOrderItemIds.add(row.orderItemId);
    byBatch[row.batchId]!.add(
      BatchRevenueItem(
        id: row.id,
        description: row.description ?? 'Allocated sale',
        quantity: row.eggsUsed,
        totalPrice: roundBatchMoney(row.revenueAmount),
        orderDate: row.orderDate,
        orderStatus: row.orderStatus,
        kind: 'Allocated',
      ),
    );
  }

  final unlinkedItems = <({
    String id,
    String? description,
    int quantity,
    double unitPrice,
    double totalPrice,
    String? livestockId,
    String? eggAllocationMode,
    String? eggBatchId,
    DateTime orderDate,
    String? orderStatus,
  })>[];

  for (final item in orderItems) {
    if (_isCancelled(item.orderStatus)) continue;
    if (allocatedOrderItemIds.contains(item.id)) continue;

    final eggMode = item.eggAllocationMode ?? '';
    final eggBatchId = item.eggBatchId ?? '';

    if (eggMode == 'batch' &&
        eggBatchId.isNotEmpty &&
        batchIds.contains(eggBatchId)) {
      byBatch[eggBatchId]!.add(
        BatchRevenueItem(
          id: item.id,
          description: item.description ?? 'Egg batch sale',
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          totalPrice: roundBatchMoney(item.totalPrice),
          orderDate: item.orderDate,
          orderStatus: item.orderStatus,
          kind: 'EggBatch',
        ),
      );
      continue;
    }

    final livestockId = item.livestockId ?? '';
    if (livestockId.isNotEmpty && batchIds.contains(livestockId)) {
      byBatch[livestockId]!.add(
        BatchRevenueItem(
          id: item.id,
          description: item.description ?? 'Direct sale',
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          totalPrice: roundBatchMoney(item.totalPrice),
          orderDate: item.orderDate,
          orderStatus: item.orderStatus,
          kind: 'Direct',
        ),
      );
      continue;
    }

    unlinkedItems.add(item);
  }

  final unlinkedTotal = unlinkedItems.fold<double>(
    0,
    (sum, item) => sum + item.totalPrice,
  );

  if (unlinkedTotal > 0 && activeBatches.isNotEmpty) {
    final totalHeads = activeBatches.fold<int>(
      0,
      (sum, batch) => sum + batch.currentCount,
    );

    var allocated = 0.0;
    for (var index = 0; index < activeBatches.length; index += 1) {
      final batch = activeBatches[index];
      final isLast = index == activeBatches.length - 1;
      final sharePct = totalHeads > 0
          ? roundBatchMoney((batch.currentCount / totalHeads) * 100)
          : roundBatchMoney(100 / activeBatches.length);
      final amount = isLast
          ? roundBatchMoney(unlinkedTotal - allocated)
          : totalHeads > 0
          ? roundBatchMoney(
              unlinkedTotal * (batch.currentCount / totalHeads),
            )
          : roundBatchMoney(unlinkedTotal / activeBatches.length);

      allocated += amount;
      if (amount <= 0) continue;

      byBatch[batch.id]!.add(
        BatchRevenueItem(
          id: 'general-share-${batch.id}',
          description: 'Unlinked sales (headcount share)',
          totalPrice: amount,
          orderDate: DateTime.now(),
          orderStatus: 'COMPLETED',
          kind: 'GeneralShare',
          percentage: sharePct,
        ),
      );
    }
  }

  for (final txRow in manualLedgerTransactions) {
    final parsed = LedgerAllocationService.parseLedgerAllocation(
      txRow.description,
    );
    if (parsed == null) continue;

    for (final row in parsed) {
      if (!batchIds.contains(row.batchId)) continue;
      final amount = roundBatchMoney(row.amount);
      if (amount <= 0) continue;

      byBatch[row.batchId]!.add(
        BatchRevenueItem(
          id: '${txRow.id}-${row.batchId}',
          description:
              _stripLedgerTag(txRow.description) ?? 'Manual ledger revenue',
          totalPrice: amount,
          orderDate: txRow.transactionDate,
          orderStatus: 'COMPLETED',
          kind: 'Ledger',
        ),
      );
    }
  }

  for (final entry in byBatch.entries) {
    entry.value.sort((a, b) => b.orderDate.compareTo(a.orderDate));
  }

  return byBatch;
}

List<BatchRevenueItem> buildBatchRevenueItems(
  String batchId, {
  required List<({
    String id,
    String? description,
    int quantity,
    double unitPrice,
    double totalPrice,
    String? livestockId,
    String? eggAllocationMode,
    String? eggBatchId,
    DateTime orderDate,
    String? orderStatus,
  })> orderItems,
  required List<({
    String id,
    String orderItemId,
    String batchId,
    double revenueAmount,
    int? eggsUsed,
    String? description,
    DateTime orderDate,
    String? orderStatus,
  })> batchAllocations,
  required List<({
    String id,
    double amount,
    DateTime transactionDate,
    String? description,
  })> manualLedgerTransactions,
  required List<HeadcountBatch> activeBatches,
}) {
  final map = buildFarmRevenueByBatch(
    orderItems: orderItems,
    batchAllocations: batchAllocations,
    manualLedgerTransactions: manualLedgerTransactions,
    activeBatches: activeBatches,
  );
  return map[batchId] ?? const [];
}

String? _stripLedgerTag(String? description) {
  final text = description ?? '';
  final start = text.indexOf(LedgerAllocationService.ledgerAllocPrefix);
  if (start < 0) return text.trim().isEmpty ? null : text.trim();
  final stripped = text.substring(0, start).trim().replaceAll(RegExp(r'\s\|\s$'), '');
  return stripped.isEmpty ? null : stripped;
}

String encodeLedgerAllocationJson(List<({String batchId, double amount})> rows) {
  final payload = rows
      .map((row) => {'batchId': row.batchId, 'amount': row.amount})
      .toList();
  return jsonEncode({'allocations': payload});
}
