import 'dart:math';

import 'package:drift/drift.dart';

import '../data/local_db.dart';
import '../utils/inventory_sale_utils.dart';
import '../utils/egg_sale_allocation_utils.dart';

class BatchEggAllocation {
  const BatchEggAllocation({
    required this.batchId,
    required this.eggsUsed,
  });

  final String batchId;
  final int eggsUsed;
}

class EggFifoService {
  EggFifoService(this._db);

  final AppDatabase _db;

  Future<int> getFifoEggAvailability({
    required String farmId,
    String? batchId,
    String? categoryId,
  }) async {
    final args = <Variable>[Variable.withString(farmId)];
    var batchFilter = '';
    var categoryFilter = '';
    if (batchId != null && batchId.isNotEmpty) {
      batchFilter = ' AND ep.batch_id = ?';
      args.add(Variable.withString(batchId));
    } else {
      batchFilter = '''
        AND EXISTS (
          SELECT 1 FROM batches b
          WHERE b.id = ep.batch_id
            AND COALESCE(b.is_deleted, 0) = 0
            AND upper(b.status) = 'ACTIVE'
        )
      ''';
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      categoryFilter = ' AND ep.category_id = ?';
      args.add(Variable.withString(categoryId));
    }
    final rows = await _db.customSelect(
      '''
      SELECT COALESCE(SUM(ep.eggs_remaining), 0) AS total
      FROM egg_production ep
      WHERE ep.farm_id = ?
        AND COALESCE(ep.is_deleted, 0) = 0
        AND COALESCE(ep.eggs_remaining, 0) > 0
        $batchFilter
        $categoryFilter
      ''',
      variables: args,
    ).get();
    return rows.first.read<int>('total');
  }

  Future<List<BatchEggAllocation>> deductFromProductionLogs({
    required String farmId,
    required int quantity,
    String? batchId,
    String? categoryId,
  }) async {
    if (quantity <= 0) {
      return const [];
    }
    var qtyToDeduct = quantity;
    final args = <Variable>[Variable.withString(farmId)];
    var batchFilter = '';
    var categoryFilter = '';
    if (batchId != null && batchId.isNotEmpty) {
      batchFilter = ' AND batch_id = ?';
      args.add(Variable.withString(batchId));
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      categoryFilter = ' AND category_id = ?';
      args.add(Variable.withString(categoryId));
    }
    final rows = await _db.customSelect(
      '''
      SELECT id, batch_id, eggs_remaining
      FROM egg_production
      WHERE farm_id = ?
        AND COALESCE(is_deleted, 0) = 0
        AND COALESCE(eggs_remaining, 0) > 0
        $batchFilter
        $categoryFilter
      ORDER BY log_date ASC
      ''',
      variables: args,
    ).get();

    final byBatch = <String, int>{};
    for (final row in rows) {
      if (qtyToDeduct <= 0) {
        break;
      }
      final remaining = row.read<int>('eggs_remaining');
      final take = min(remaining, qtyToDeduct);
      await (_db.update(_db.eggProductions)..where((t) => t.id.equals(row.read<String>('id'))))
          .write(
        EggProductionsCompanion(
          eggsRemaining: Value(remaining - take),
          synced: const Value(false),
        ),
      );
      final resolvedBatchId = row.read<String?>('batch_id') ?? '';
      if (resolvedBatchId.isNotEmpty) {
        byBatch[resolvedBatchId] = (byBatch[resolvedBatchId] ?? 0) + take;
      }
      qtyToDeduct -= take;
    }
    if (qtyToDeduct > 0) {
      throw StateError('Insufficient egg stock. Short by $qtyToDeduct egg(s).');
    }
    return byBatch.entries
        .map((entry) => BatchEggAllocation(batchId: entry.key, eggsUsed: entry.value))
        .toList();
  }

  Future<List<BatchEggAllocation>> deductForInventorySale({
    required String farmId,
    required String? inventoryId,
    required int quantity,
    String? batchId,
    String? categoryId,
  }) async {
    if (inventoryId == null || inventoryId.isEmpty || quantity <= 0) {
      return const [];
    }
    final inventory = await (_db.select(_db.inventory)
          ..where((t) => t.id.equals(inventoryId)))
        .getSingleOrNull();
    if (inventory == null) {
      return const [];
    }
    if (!isEggInventoryItem(inventory)) {
      await (_db.update(_db.inventory)..where((t) => t.id.equals(inventoryId))).write(
        InventoryCompanion(
          stockLevel: Value(max(0, inventory.stockLevel - quantity)),
          synced: const Value(false),
        ),
      );
      return const [];
    }
    final allocations = await deductFromProductionLogs(
      farmId: farmId,
      quantity: quantity,
      batchId: batchId,
      categoryId: isUnsortedEggInventoryItem(inventory)
          ? null
          : (categoryId ?? inventory.eggCategoryId),
    );
    await (_db.update(_db.inventory)..where((t) => t.id.equals(inventoryId))).write(
      InventoryCompanion(
        stockLevel: Value(max(0, inventory.stockLevel - quantity)),
        synced: const Value(false),
      ),
    );
    return allocations;
  }
}
