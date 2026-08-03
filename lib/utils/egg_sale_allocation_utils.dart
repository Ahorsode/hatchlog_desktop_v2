/// Egg sale allocation: FIFO vs batch-scoped FIFO, sorted size selection.

import '../data/local_db.dart';

enum EggAllocationMode { fifo, batch }

class EggBatchStockOption {
  const EggBatchStockOption({
    required this.batchId,
    required this.batchName,
    required this.eggsRemaining,
  });

  final String batchId;
  final String batchName;
  final int eggsRemaining;
}

bool requiresEggSizeSelection(List<dynamic> eggInventory) {
  if (eggInventory.length <= 1) {
    return false;
  }
  final categories = eggInventory
      .map((row) {
        if (row is Map) {
          return row['eggCategoryId']?.toString().trim() ?? '';
        }
        try {
          return (row as dynamic).eggCategoryId?.toString().trim() ?? '';
        } catch (_) {
          return '';
        }
      })
      .where((id) => id.isNotEmpty)
      .toSet();
  return categories.length > 1 || eggInventory.length > 1;
}

String eggSizeLabelFromRow(dynamic row) {
  final name = row is Map
      ? row['itemName']?.toString() ?? row['item_name']?.toString() ?? 'Eggs'
      : (row as dynamic).itemName?.toString() ?? 'Eggs';
  final match = RegExp(r'\(([^)]+)\)').firstMatch(name);
  return match?.group(1) ?? name;
}

dynamic defaultEggInventoryRow(List<dynamic> rows) {
  if (rows.isEmpty) {
    return null;
  }
  if (rows.length == 1) {
    return rows.first;
  }
  for (final row in rows) {
    final name = row is Map
        ? row['itemName']?.toString().toLowerCase() ??
            row['item_name']?.toString().toLowerCase() ??
            ''
        : (row as dynamic).itemName?.toString().toLowerCase() ?? '';
    if (name.contains('unsorted') || name == 'eggs') {
      return row;
    }
  }
  return rows.first;
}

bool isUnsortedEggInventoryRow(Map<String, Object?> row) {
  final name = row['item_name']?.toString().toLowerCase() ??
      row['itemName']?.toString().toLowerCase() ??
      '';
  return name.contains('unsorted') || name == 'eggs';
}

bool isUnsortedEggInventoryItem(InventoryItem item) {
  return item.itemName.toLowerCase().contains('unsorted') ||
      item.itemName.toLowerCase() == 'eggs';
}
