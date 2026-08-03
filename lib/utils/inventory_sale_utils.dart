import '../data/local_db.dart';

/// Helpers aligned with web `SalesForm` egg inventory selection.
bool isEggInventoryItem(InventoryItem item) {
  final category = item.category?.trim().toUpperCase() ?? '';
  final name = item.itemName.trim().toLowerCase();
  return category == 'EGGS' || name.contains('egg');
}

bool isInStockForSale(InventoryItem item) {
  return item.stockLevel > 0;
}

String formatSaleInventoryLabel(InventoryItem item) {
  final stock = item.stockLevel.floor();
  final unit = item.unit.trim().isNotEmpty ? item.unit.trim() : 'units';
  return '${item.itemName} ($stock $unit)';
}

List<InventoryItem> inventoryItemsForSale(List<InventoryItem> items) {
  final inStock = items.where(isInStockForSale).toList(growable: false);
  final eggRows = inStock.where(isEggInventoryItem).toList(growable: false);
  if (eggRows.isNotEmpty) {
    return eggRows;
  }
  return inStock;
}

/// Egg-only sellable rows for sales (no feed/medicine fallback).
List<InventoryItem> sellableEggInventory(List<InventoryItem> items) {
  return items
      .where(isInStockForSale)
      .where(isEggInventoryItem)
      .toList(growable: false);
}

double inventoryItemSalePrice(
  InventoryItem item, {
  Map<String, double> eggCategoryPrices = const {},
}) {
  final categoryId = item.eggCategoryId?.trim() ?? '';
  if (categoryId.isNotEmpty) {
    final categoryPrice = eggCategoryPrices[categoryId] ?? 0;
    if (categoryPrice > 0) {
      return categoryPrice;
    }
  }
  return item.costPerUnit ?? 0;
}

bool inventoryCatalogIsEggFocused(List<InventoryItem> saleRows) {
  return saleRows.isNotEmpty && saleRows.every(isEggInventoryItem);
}

int eggUsableCount({required int collected, required int unusable}) {
  final usable = collected - unusable;
  return usable < 0 ? 0 : usable;
}

int eggSoldCount({
  required int collected,
  required int unusable,
  required int remaining,
}) {
  final sold = eggUsableCount(collected: collected, unusable: unusable) - remaining;
  return sold < 0 ? 0 : sold;
}

bool isEggLogSoldOut({
  required int remaining,
  required int collected,
  required int unusable,
}) {
  if (collected <= 0) {
    return true;
  }
  return remaining <= 0;
}

bool isEggLogActive({
  required int remaining,
  required int collected,
}) {
  return collected > 0 && remaining > 0;
}

int eggActivePercent({
  required int collected,
  required int unusable,
  required int remaining,
}) {
  final usable = eggUsableCount(collected: collected, unusable: unusable);
  if (usable <= 0) {
    return 0;
  }
  return ((remaining / usable) * 100).round();
}

int eggSoldPercent({
  required int collected,
  required int unusable,
  required int remaining,
}) {
  final usable = eggUsableCount(collected: collected, unusable: unusable);
  if (usable <= 0) {
    return 0;
  }
  final sold = eggSoldCount(
    collected: collected,
    unusable: unusable,
    remaining: remaining,
  );
  return ((sold / usable) * 100).round();
}

bool matchesEggProductionStockFilter(EggProduction log, String filter) {
  return switch (filter) {
    'active' => isEggLogActive(
      remaining: log.eggsRemaining,
      collected: log.eggsCollected,
    ),
    'sold_out' =>
      log.eggsCollected > 0 &&
          isEggLogSoldOut(
            remaining: log.eggsRemaining,
            collected: log.eggsCollected,
            unusable: log.unusableCount,
          ),
    _ => true,
  };
}
