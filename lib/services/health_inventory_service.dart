import 'package:drift/drift.dart';

import '../data/local_db.dart';
import '../utils/health_constants.dart';

class HealthInventoryService {
  HealthInventoryService(this._db);

  final AppDatabase _db;

  Future<void> applyScheduleStatusChange({
    required String farmId,
    required String itemName,
    required String previousStatus,
    required String newStatus,
    required double quantity,
  }) async {
    final item = await _resolveItem(farmId, itemName);
    if (item == null) {
      return;
    }

    final wasCompleted = isHealthScheduleCompleted(previousStatus);
    final isCompleted = isHealthScheduleCompleted(newStatus);
    if (wasCompleted == isCompleted) {
      return;
    }

    if (isCompleted) {
      await _depleteOnCompletion(item, quantity);
      return;
    }
    await _restoreOnRevert(item, quantity);
  }

  Future<void> _depleteOnCompletion(InventoryItem item, double quantity) async {
    final usageType = normalizeHealthUsageType(item.usageType);
    final nextStock = usageType == HealthUsageType.oneTime
        ? 0.0
        : (item.stockLevel - quantity).clamp(0.0, double.infinity);

    await (_db.update(_db.inventory)..where((t) => t.id.equals(item.id))).write(
      InventoryCompanion(
        stockLevel: Value(nextStock),
        synced: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> _restoreOnRevert(InventoryItem item, double quantity) async {
    final usageType = normalizeHealthUsageType(item.usageType);
    final nextStock = usageType == HealthUsageType.oneTime
        ? 1.0
        : item.stockLevel + quantity;

    await (_db.update(_db.inventory)..where((t) => t.id.equals(item.id))).write(
      InventoryCompanion(
        stockLevel: Value(nextStock),
        synced: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<InventoryItem?> _resolveItem(String farmId, String itemName) async {
    final rows = await (_db.select(_db.inventory)
          ..where((t) => t.farmId.equals(farmId)))
        .get();
    for (final row in rows) {
      if (_namesMatch(row.itemName, itemName)) {
        return row;
      }
    }
    return null;
  }

  bool _namesMatch(String left, String right) {
    return left.trim().toLowerCase() == right.trim().toLowerCase();
  }
}
