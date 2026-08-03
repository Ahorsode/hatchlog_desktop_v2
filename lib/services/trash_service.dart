import 'package:flutter/foundation.dart';

import '../utils/settings_profile_contract.dart';
import 'hatchlog_api_client.dart';

class TrashRecordItem {
  const TrashRecordItem({
    required this.id,
    required this.tabKey,
    required this.title,
    required this.subtitle,
    this.amount,
  });

  final String id;
  final String tabKey;
  final String title;
  final String subtitle;
  final double? amount;
}

class TrashService {
  TrashService({HatchlogApiClient? apiClient})
      : _api = apiClient ?? HatchlogApiClient();

  final HatchlogApiClient _api;

  Future<Map<String, List<TrashRecordItem>>> loadTrashItems(String farmId) async {
    if (farmId.isEmpty) return {};
    if (!_api.isConfigured) {
      throw StateError('HATCHLOG_API_URL is required for trash');
    }

    final raw = await _api.listTrash(farmId);
    return {
      'batches': _mapBatches(raw['batches']),
      'eggProduction': _mapEggProduction(raw['eggProduction']),
      'feedingLogs': _mapFeedingLogs(raw['feedingLogs']),
      'mortality': _mapMortality(raw['mortality']),
      'expenses': _mapExpenses(raw['expenses']),
      'sales': _mapSales(raw['sales']),
      'orders': _mapOrders(raw['orders']),
      'inventory': _mapInventory(raw['inventory']),
    };
  }

  Future<void> restoreRecord({
    required String farmId,
    required String tabKey,
    required String recordId,
  }) async {
    final tab = SettingsProfileContract.tabByKey(tabKey);
    if (tab == null || !tab.restoreAllowed) {
      throw StateError('Restore not allowed for $tabKey');
    }
    if (!_api.isConfigured) {
      throw StateError('HATCHLOG_API_URL is required for trash restore');
    }
    await _api.restoreTrashItem(
      table: tabKey,
      id: recordId,
      farmId: farmId,
    );
  }

  Future<void> deleteForever({
    required String tabKey,
    required String recordId,
  }) async {
    final tab = SettingsProfileContract.tabByKey(tabKey);
    if (tab == null) {
      throw StateError('Unknown trash tab: $tabKey');
    }
    // Nest trash API exposes list + restore only; hard purge is not available.
    throw StateError(
      'Permanent purge is not available via Nest API (record $recordId)',
    );
  }

  List<TrashRecordItem> _mapBatches(dynamic rows) {
    return _asMaps(rows).map((map) {
      return TrashRecordItem(
        id: map['id'].toString(),
        tabKey: 'batches',
        title: map['batchName']?.toString() ?? 'Batch',
        subtitle:
            '${map['breedType'] ?? ''} • ${map['initialCount'] ?? 0} birds',
      );
    }).toList();
  }

  List<TrashRecordItem> _mapEggProduction(dynamic rows) {
    return _asMaps(rows).map((map) {
      final batch = map['batch'] as Map<String, dynamic>?;
      return TrashRecordItem(
        id: map['id'].toString(),
        tabKey: 'eggProduction',
        title: batch?['batchName']?.toString() ?? 'Egg log',
        subtitle:
            '${map['eggsCollected'] ?? 0} collected • ${map['logDate'] ?? ''}',
      );
    }).toList();
  }

  List<TrashRecordItem> _mapFeedingLogs(dynamic rows) {
    return _asMaps(rows).map((map) {
      final batch = map['batch'] as Map<String, dynamic>?;
      return TrashRecordItem(
        id: map['id'].toString(),
        tabKey: 'feedingLogs',
        title: batch?['batchName']?.toString() ?? 'Feed log',
        subtitle: '${map['amountConsumed'] ?? 0} kg • ${map['logDate'] ?? ''}',
      );
    }).toList();
  }

  List<TrashRecordItem> _mapMortality(dynamic rows) {
    return _asMaps(rows).map((map) {
      final batch = map['batch'] as Map<String, dynamic>?;
      return TrashRecordItem(
        id: map['id'].toString(),
        tabKey: 'mortality',
        title: batch?['batchName']?.toString() ?? 'Mortality record',
        subtitle:
            '${map['count'] ?? 0} ${map['type'] ?? ''} • ${map['reason'] ?? 'No reason'}',
      );
    }).toList();
  }

  List<TrashRecordItem> _mapExpenses(dynamic rows) {
    return _asMaps(rows).map((map) {
      return TrashRecordItem(
        id: map['id'].toString(),
        tabKey: 'expenses',
        title: map['description']?.toString() ??
            map['category']?.toString() ??
            'Expense',
        subtitle: map['category']?.toString() ?? '',
        amount: (map['amount'] as num?)?.toDouble(),
      );
    }).toList();
  }

  List<TrashRecordItem> _mapSales(dynamic rows) {
    return _asMaps(rows).map((map) {
      return TrashRecordItem(
        id: map['id'].toString(),
        tabKey: 'sales',
        title: map['customerName']?.toString() ?? 'Walk-in Customer',
        subtitle: '${map['status'] ?? ''} • ${map['saleDate'] ?? ''}',
        amount: (map['totalAmount'] as num?)?.toDouble(),
      );
    }).toList();
  }

  List<TrashRecordItem> _mapOrders(dynamic rows) {
    return _asMaps(rows).map((map) {
      final customer = map['customer'] as Map<String, dynamic>?;
      return TrashRecordItem(
        id: map['id'].toString(),
        tabKey: 'orders',
        title: customer?['name']?.toString() ?? 'No Customer',
        subtitle: '${map['status'] ?? ''} • ${map['orderDate'] ?? ''}',
        amount: (map['totalAmount'] as num?)?.toDouble(),
      );
    }).toList();
  }

  List<TrashRecordItem> _mapInventory(dynamic rows) {
    return _asMaps(rows).map((map) {
      return TrashRecordItem(
        id: map['id'].toString(),
        tabKey: 'inventory',
        title: map['itemName']?.toString() ?? 'Inventory item',
        subtitle:
            '${map['stockLevel'] ?? 0} ${map['unit'] ?? ''} • ${map['category'] ?? 'General'}',
      );
    }).toList();
  }

  List<Map<String, dynamic>> _asMaps(dynamic rows) {
    if (rows is! List) return const [];
    return rows.map((row) {
      if (row is Map<String, dynamic>) return row;
      if (row is Map) return Map<String, dynamic>.from(row);
      debugPrint('TrashService: unexpected row type ${row.runtimeType}');
      return <String, dynamic>{};
    }).where((m) => m['id'] != null).toList();
  }
}
