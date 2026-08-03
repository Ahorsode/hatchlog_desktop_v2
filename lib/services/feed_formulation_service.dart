import 'package:drift/drift.dart';

import '../data/local_db.dart';
import '../utils/id_utils.dart';
import '../utils/inventory_constants.dart';

class FeedFormulationIngredientView {
  const FeedFormulationIngredientView({
    required this.inventoryId,
    required this.itemName,
    required this.quantity,
    required this.unit,
  });

  final String inventoryId;
  final String itemName;
  final double quantity;
  final String unit;
}

class FeedFormulationService {
  FeedFormulationService(this._db);

  final AppDatabase _db;

  Future<List<InventoryItem>> loadFeedInventory(String farmId) async {
    final rows = await (_db.select(_db.inventory)
          ..where((t) => t.farmId.equals(farmId)))
        .get();
    return rows
        .where(
          (item) =>
              matchesInventoryCategoryFilter(item.category, kFeedInventoryCategory),
        )
        .toList()
      ..sort((a, b) => a.itemName.compareTo(b.itemName));
  }

  Future<Map<String, List<FeedFormulationIngredientView>>>
  loadIngredientViewsByFormulationIds(
    Iterable<String> formulationIds,
  ) async {
    final ids = formulationIds.where((id) => id.isNotEmpty).toSet();
    if (ids.isEmpty) {
      return {};
    }

    final ingredientRows = await (_db.select(_db.feedFormulationIngredients)
          ..where((t) => t.formulationId.isIn(ids)))
        .get();
    if (ingredientRows.isEmpty) {
      return {};
    }

    final inventoryIds = ingredientRows.map((row) => row.inventoryId).toSet();
    final inventoryRows = await (_db.select(_db.inventory)
          ..where((t) => t.id.isIn(inventoryIds)))
        .get();
    final inventoryNames = {
      for (final item in inventoryRows) item.id: item.itemName,
    };

    final grouped = <String, List<FeedFormulationIngredientView>>{};
    for (final row in ingredientRows) {
      grouped.putIfAbsent(row.formulationId, () => []).add(
        FeedFormulationIngredientView(
          inventoryId: row.inventoryId,
          itemName: inventoryNames[row.inventoryId] ?? 'Ingredient',
          quantity: row.quantity,
          unit: row.unit,
        ),
      );
    }
    return grouped;
  }

  Future<String> createFormulation({
    required String farmId,
    required String name,
    required String type,
    String? targetLivestock,
    required List<({String inventoryId, double bags})> ingredients,
  }) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('Formulation name is required');
    }
    if (ingredients.isEmpty) {
      throw ArgumentError('Add at least one ingredient');
    }

    final formulationId = newLocalId();
    final now = DateTime.now();
    final totalBags = ingredients.fold<double>(0, (sum, row) => sum + row.bags);

    await _db.transaction(() async {
      for (final ingredient in ingredients) {
        if (ingredient.bags <= 0) {
          throw ArgumentError('Each ingredient must use at least one bag');
        }
        final items = await (_db.select(_db.inventory)
              ..where((t) => t.id.equals(ingredient.inventoryId)))
            .get();
        if (items.isEmpty) {
          throw StateError('Ingredient inventory item not found');
        }
        final item = items.first;
        if (item.stockLevel < ingredient.bags) {
          throw StateError(
            'Insufficient stock for ${item.itemName} (${item.stockLevel} available)',
          );
        }
      }

      await _db.into(_db.feedFormulations).insert(
        FeedFormulationsCompanion.insert(
          id: formulationId,
          farmId: farmId,
          name: name.trim(),
          type: Value(type),
          targetLivestock: Value(targetLivestock),
          stockLevel: Value(totalBags),
          createdAt: Value(now),
          updatedAt: Value(now),
          synced: const Value(false),
        ),
      );

      for (final ingredient in ingredients) {
        final item = (await (_db.select(_db.inventory)
              ..where((t) => t.id.equals(ingredient.inventoryId)))
            .get())
            .first;

        await _db.into(_db.feedFormulationIngredients).insert(
          FeedFormulationIngredientsCompanion.insert(
            id: newLocalId(),
            formulationId: formulationId,
            inventoryId: ingredient.inventoryId,
            quantity: ingredient.bags,
            unit: Value(
              item.unit.isNotEmpty ? item.unit : kDefaultFeedUnit,
            ),
            synced: const Value(false),
          ),
        );

        await (_db.update(_db.inventory)
              ..where((t) => t.id.equals(ingredient.inventoryId)))
            .write(
          InventoryCompanion(
            stockLevel: Value(
              (item.stockLevel - ingredient.bags).clamp(0.0, double.infinity),
            ),
            synced: const Value(false),
            updatedAt: Value(now),
          ),
        );
      }
    });

    return formulationId;
  }

  Future<void> deleteFormulation(String formulationId) async {
    await _db.transaction(() async {
      await (_db.delete(_db.feedFormulationIngredients)
            ..where((t) => t.formulationId.equals(formulationId)))
          .go();
      await (_db.delete(_db.feedFormulations)
            ..where((t) => t.id.equals(formulationId)))
          .go();
    });
  }
}
