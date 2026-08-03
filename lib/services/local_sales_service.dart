import 'dart:math';

import 'package:drift/drift.dart';

import '../data/local_db.dart';
import '../features/sales/sale_line_draft.dart';
import '../utils/id_utils.dart';
import 'egg_fifo_service.dart';

class LocalSalesService {
  LocalSalesService(this._db);

  final AppDatabase _db;

  static double roundMoney(double value) => (value * 100).roundToDouble() / 100;

  Future<String> recordMultiLineSale({
    required String farmId,
    required String userId,
    required List<SaleLineDraft> items,
    required DateTime orderDate,
    required double totalCashReceived,
    String? customerId,
    String? customerName,
    double discountAmount = 0,
    String paymentMethod = 'CASH',
    String? paymentReference,
    String? paymentAccountName,
    bool requireExactCashTotal = true,
    bool? completeNow,
  }) async {
    if (items.isEmpty) {
      throw ArgumentError('At least one sale line item is required.');
    }

    final subtotal = roundMoney(
      items.fold<double>(0, (sum, item) => sum + item.lineTotal),
    );
    final discount = roundMoney(discountAmount.clamp(0, subtotal));
    final computedTotal = roundMoney(
      (subtotal - discount).clamp(0, double.infinity),
    );
    final cashReceived = roundMoney(totalCashReceived);

    if (requireExactCashTotal && (cashReceived - computedTotal).abs() > 0.01) {
      throw ArgumentError(
        'Cash received must equal the locked sale total.',
      );
    }
    if (!requireExactCashTotal && cashReceived < 0) {
      throw ArgumentError('Cash received cannot be negative.');
    }
    if (!requireExactCashTotal &&
        paymentMethod != 'CREDIT' &&
        cashReceived <= 0 &&
        computedTotal > 0) {
      throw ArgumentError('Cash received must be greater than zero.');
    }

    final outstanding = roundMoney(
      (computedTotal - cashReceived).clamp(0, double.infinity),
    );
    final isPaid = outstanding <= 0.01;
    final paymentStatus = isPaid
        ? 'PAID'
        : (cashReceived > 0 ? 'PARTIALLY_PAID' : 'UNPAID');
    final isCreditSale = paymentMethod == 'CREDIT';
    final needsCompletionPrompt = isCreditSale || outstanding > 0.01;
    final shouldCompleteNow = completeNow == true || !needsCompletionPrompt;
    final orderStatus = shouldCompleteNow
        ? 'COMPLETED'
        : (isPaid ? 'PAID' : 'PENDING');
    final resolvedCustomerName =
        (customerName == null || customerName.trim().isEmpty)
        ? 'Walk-in Customer'
        : customerName.trim();

    final saleId = newLocalId();
    final now = orderDate.toUtc();
    final firstLivestock = items
        .where((item) => item.livestockId != null && item.livestockId!.isNotEmpty)
        .map((item) => item.livestockId!)
        .firstOrNull;
    final lineQuantity = items.fold<int>(0, (sum, item) => sum + item.quantity);

    await _db.into(_db.sales).insert(
      SalesCompanion.insert(
        id: saleId,
        farmId: farmId,
        batchId: Value(firstLivestock),
        customerId: Value(customerId),
        quantity: lineQuantity <= 0 ? 1 : lineQuantity,
        unitPrice: lineQuantity <= 0
            ? computedTotal
            : roundMoney(computedTotal / lineQuantity),
        totalAmount: computedTotal,
        saleDate: Value(now),
        userId: Value(userId),
        synced: const Value(false),
      ),
    );

    await _db.customStatement(
      '''
      INSERT INTO orders (
        id, farm_id, customer_id, subtotal_amount, tax_amount, total_amount,
        cash_received, currency, status, discount_amount, order_date, paid_at,
        payment_method, payment_reference, payment_account_name, user_id,
        is_deleted, created_at, updated_at
      ) VALUES (?, ?, ?, ?, 0, ?, ?, 'GHS', ?, ?, ?, ?, ?, ?, ?, ?, 0, ?, ?)
      ''',
      [
        saleId,
        farmId,
        customerId,
        subtotal,
        computedTotal,
        cashReceived,
        orderStatus,
        discount,
        now.toIso8601String(),
        isPaid ? now.toIso8601String() : null,
        paymentMethod,
        paymentReference?.trim().isNotEmpty == true ? paymentReference!.trim() : null,
        paymentAccountName?.trim().isNotEmpty == true
            ? paymentAccountName!.trim()
            : null,
        userId,
        now.toIso8601String(),
        now.toIso8601String(),
      ],
    );

    final fifoService = EggFifoService(_db);
    for (var index = 0; index < items.length; index += 1) {
      final item = items[index];
      final orderItemId = '${saleId}_item_$index';
      await _db.customStatement(
        '''
        INSERT INTO order_items (
          id, order_id, description, quantity, unit_price, total_price,
          inventory_id, livestock_id, egg_allocation_mode, egg_batch_id,
          line_discount_amount, line_discount_type, egg_quantity_unit
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        [
          orderItemId,
          saleId,
          item.description,
          item.resolvedQuantityEggs,
          item.productType == SaleProductType.inventory
              ? item.resolvedUnitPricePerEgg
              : item.unitPrice,
          item.lineTotal,
          item.inventoryId,
          item.livestockId,
          item.eggAllocationMode,
          item.eggBatchId,
          item.lineDiscountValue,
          item.lineDiscountType,
          item.productType == SaleProductType.inventory
              ? item.eggQuantityUnit.name
              : null,
        ],
      );
      await _db.customStatement(
        '''
        INSERT INTO sale_items (
          id, sale_id, description, quantity, unit_price, total_price,
          farm_id, inventory_id, livestock_id, egg_allocation_mode, egg_batch_id,
          line_discount_amount, line_discount_type, egg_quantity_unit, synced
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)
        ''',
        [
          orderItemId,
          saleId,
          item.description,
          item.resolvedQuantityEggs,
          item.productType == SaleProductType.inventory
              ? item.resolvedUnitPricePerEgg
              : item.unitPrice,
          item.lineTotal,
          farmId,
          item.inventoryId,
          item.livestockId,
          item.eggAllocationMode,
          item.eggBatchId,
          item.lineDiscountValue,
          item.lineDiscountType,
          item.productType == SaleProductType.inventory
              ? item.eggQuantityUnit.name
              : null,
        ],
      );

      if (shouldCompleteNow) {
        if (item.productType == SaleProductType.inventory) {
          final allocations = await fifoService.deductForInventorySale(
            farmId: farmId,
            inventoryId: item.inventoryId,
            quantity: item.resolvedQuantityEggs,
            batchId: item.eggAllocationMode == 'batch' ? item.eggBatchId : null,
          );
          final resolvedAllocations = item.eggAllocationMode == 'batch' &&
                  item.eggBatchId != null &&
                  item.eggBatchId!.isNotEmpty
              ? [
                  BatchEggAllocation(
                    batchId: item.eggBatchId!,
                    eggsUsed: item.resolvedQuantityEggs,
                  ),
                ]
              : allocations;
          var allocatedRevenue = 0.0;
          for (var allocIndex = 0;
              allocIndex < resolvedAllocations.length;
              allocIndex += 1) {
            final allocation = resolvedAllocations[allocIndex];
            final isLast = allocIndex == resolvedAllocations.length - 1;
            final revenueAmount = isLast
                ? roundMoney(item.lineTotal - allocatedRevenue)
                : roundMoney(
                    item.lineTotal *
                        (allocation.eggsUsed / item.resolvedQuantityEggs),
                  );
            allocatedRevenue += revenueAmount;
            await _db.customStatement(
              '''
              INSERT INTO order_item_batch_allocations (
                id, order_item_id, batch_id, farm_id, eggs_used, revenue_amount,
                created_at, updated_at
              ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
              ''',
              [
                '${orderItemId}_alloc_$allocIndex',
                orderItemId,
                allocation.batchId,
                farmId,
                allocation.eggsUsed,
                revenueAmount,
                now.toIso8601String(),
                now.toIso8601String(),
              ],
            );
          }
        } else if (item.productType == SaleProductType.livestock &&
            item.livestockId != null &&
            item.livestockId!.isNotEmpty) {
          final batch = await (_db.select(_db.batches)
                ..where((t) => t.id.equals(item.livestockId!)))
              .getSingleOrNull();
          if (batch != null) {
            await (_db.update(_db.batches)..where((t) => t.id.equals(batch.id)))
                .write(
              BatchesCompanion(
                currentCount: Value(max(0, batch.currentCount - item.quantity)),
                synced: const Value(false),
              ),
            );
          }
        }
      }
    }

    final itemSummary = items
        .map((item) => '${item.quantity} x ${item.description}')
        .join(', ');
    final resolvedReference = paymentReference?.trim().isNotEmpty == true
        ? paymentReference!.trim()
        : saleId;
    await _db.customStatement(
      '''
      INSERT INTO financial_transactions (
        id, order_id, farm_id, user_id, type, category, amount, payment_status,
        payment_method, reference_num, transaction_date, description,
        customer_id, deposit_amount, outstanding_credit, expense_outlay,
        is_deleted, settled_at, created_at, updated_at, synced
      ) VALUES (?, ?, ?, ?, 'REVENUE', 'SALES', ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 0, ?, ?, ?, 0)
      ''',
      [
        '${saleId}_transaction',
        saleId,
        farmId,
        userId,
        computedTotal,
        paymentStatus,
        paymentMethod,
        resolvedReference,
        now.toIso8601String(),
        paymentAccountName != null && paymentAccountName.trim().isNotEmpty
            ? '$itemSummary to $resolvedCustomerName (${paymentAccountName.trim()})'
            : '$itemSummary to $resolvedCustomerName',
        customerId,
        cashReceived,
        outstanding,
        isPaid ? now.toIso8601String() : null,
        now.toIso8601String(),
        now.toIso8601String(),
      ],
    );

    if (customerId != null && customerId.isNotEmpty && outstanding > 0) {
      final customer = await (_db.select(_db.customers)
            ..where((t) => t.id.equals(customerId)))
          .getSingleOrNull();
      if (customer != null) {
        await (_db.update(_db.customers)..where((t) => t.id.equals(customerId)))
            .write(
          CustomersCompanion(
            balanceOwed: Value(roundMoney(customer.balanceOwed + outstanding)),
            synced: const Value(false),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
      }
    }

    return saleId;
  }
}
