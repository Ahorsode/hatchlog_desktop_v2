import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/settings_profile_contract.dart';

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
  TrashService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<Map<String, List<TrashRecordItem>>> loadTrashItems(String farmId) async {
    if (farmId.isEmpty) return {};

    final results = await Future.wait([
      _loadBatches(farmId),
      _loadEggProduction(farmId),
      _loadFeedingLogs(farmId),
      _loadMortality(farmId),
      _loadExpenses(farmId),
      _loadSales(farmId),
      _loadOrders(farmId),
      _loadInventory(farmId),
    ]);

    final grouped = <String, List<TrashRecordItem>>{};
    for (final batch in results) {
      grouped.addAll(batch);
    }
    return grouped;
  }

  Future<void> restoreRecord({
    required String tabKey,
    required String recordId,
  }) async {
    final tab = SettingsProfileContract.tabByKey(tabKey);
    if (tab == null || !tab.restoreAllowed) {
      throw StateError('Restore not allowed for $tabKey');
    }
    await _client.from(tab.remoteTable).update({
      'is_deleted': false,
      'deleted_at': null,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', recordId);
  }

  Future<Map<String, List<TrashRecordItem>>> _loadBatches(String farmId) async {
    final rows = await _client
        .from('batches')
        .select('id,batchName,breedType,initialCount,arrivalDate,status')
        .eq('farmId', farmId)
        .eq('is_deleted', true)
        .order('updatedAt', ascending: false);
    return {
      'batches': (rows as List).map((row) {
        final map = Map<String, dynamic>.from(row as Map);
        return TrashRecordItem(
          id: map['id'].toString(),
          tabKey: 'batches',
          title: map['batchName']?.toString() ?? 'Batch',
          subtitle:
              '${map['breedType'] ?? ''} • ${map['initialCount'] ?? 0} birds',
        );
      }).toList(),
    };
  }

  Future<Map<String, List<TrashRecordItem>>> _loadEggProduction(
    String farmId,
  ) async {
    final rows = await _client
        .from('egg_production')
        .select('id,eggsCollected,unusableCount,logDate,batch:batchId(batchName)')
        .eq('farmId', farmId)
        .eq('is_deleted', true)
        .order('logDate', ascending: false);
    return {
      'eggProduction': (rows as List).map((row) {
        final map = Map<String, dynamic>.from(row as Map);
        final batch = map['batch'] as Map<String, dynamic>?;
        return TrashRecordItem(
          id: map['id'].toString(),
          tabKey: 'eggProduction',
          title: batch?['batchName']?.toString() ?? 'Egg log',
          subtitle:
              '${map['eggsCollected'] ?? 0} collected • ${map['logDate'] ?? ''}',
        );
      }).toList(),
    };
  }

  Future<Map<String, List<TrashRecordItem>>> _loadFeedingLogs(
    String farmId,
  ) async {
    final rows = await _client
        .from('daily_feeding_logs')
        .select('id,amountConsumed,logDate,batch:batchId(batchName)')
        .eq('farmId', farmId)
        .eq('is_deleted', true)
        .order('logDate', ascending: false);
    return {
      'feedingLogs': (rows as List).map((row) {
        final map = Map<String, dynamic>.from(row as Map);
        final batch = map['batch'] as Map<String, dynamic>?;
        return TrashRecordItem(
          id: map['id'].toString(),
          tabKey: 'feedingLogs',
          title: batch?['batchName']?.toString() ?? 'Feed log',
          subtitle: '${map['amountConsumed'] ?? 0} kg • ${map['logDate'] ?? ''}',
        );
      }).toList(),
    };
  }

  Future<Map<String, List<TrashRecordItem>>> _loadMortality(String farmId) async {
    final rows = await _client
        .from('mortality')
        .select('id,count,type,reason,logDate,batch:batchId(batchName)')
        .eq('farmId', farmId)
        .eq('is_deleted', true)
        .order('logDate', ascending: false);
    return {
      'mortality': (rows as List).map((row) {
        final map = Map<String, dynamic>.from(row as Map);
        final batch = map['batch'] as Map<String, dynamic>?;
        return TrashRecordItem(
          id: map['id'].toString(),
          tabKey: 'mortality',
          title: batch?['batchName']?.toString() ?? 'Mortality record',
          subtitle:
              '${map['count'] ?? 0} ${map['type'] ?? ''} • ${map['reason'] ?? 'No reason'}',
        );
      }).toList(),
    };
  }

  Future<Map<String, List<TrashRecordItem>>> _loadExpenses(String farmId) async {
    final rows = await _client
        .from('expenses')
        .select('id,amount,category,description,expense_date')
        .eq('farmId', farmId)
        .eq('is_deleted', true)
        .order('expense_date', ascending: false);
    return {
      'expenses': (rows as List).map((row) {
        final map = Map<String, dynamic>.from(row as Map);
        return TrashRecordItem(
          id: map['id'].toString(),
          tabKey: 'expenses',
          title: map['description']?.toString() ?? map['category']?.toString() ?? 'Expense',
          subtitle: map['category']?.toString() ?? '',
          amount: (map['amount'] as num?)?.toDouble(),
        );
      }).toList(),
    };
  }

  Future<Map<String, List<TrashRecordItem>>> _loadSales(String farmId) async {
    final rows = await _client
        .from('sales')
        .select('id,customerName,totalAmount,saleDate,status')
        .eq('farmId', farmId)
        .eq('is_deleted', true)
        .order('saleDate', ascending: false);
    return {
      'sales': (rows as List).map((row) {
        final map = Map<String, dynamic>.from(row as Map);
        return TrashRecordItem(
          id: map['id'].toString(),
          tabKey: 'sales',
          title: map['customerName']?.toString() ?? 'Walk-in Customer',
          subtitle: '${map['status'] ?? ''} • ${map['saleDate'] ?? ''}',
          amount: (map['totalAmount'] as num?)?.toDouble(),
        );
      }).toList(),
    };
  }

  Future<Map<String, List<TrashRecordItem>>> _loadOrders(String farmId) async {
    final rows = await _client
        .from('orders')
        .select('id,totalAmount,status,orderDate,customer:customerId(name)')
        .eq('farmId', farmId)
        .eq('is_deleted', true)
        .order('orderDate', ascending: false);
    return {
      'orders': (rows as List).map((row) {
        final map = Map<String, dynamic>.from(row as Map);
        final customer = map['customer'] as Map<String, dynamic>?;
        return TrashRecordItem(
          id: map['id'].toString(),
          tabKey: 'orders',
          title: customer?['name']?.toString() ?? 'No Customer',
          subtitle: '${map['status'] ?? ''} • ${map['orderDate'] ?? ''}',
          amount: (map['totalAmount'] as num?)?.toDouble(),
        );
      }).toList(),
    };
  }

  Future<Map<String, List<TrashRecordItem>>> _loadInventory(String farmId) async {
    final rows = await _client
        .from('inventory')
        .select('id,itemName,stockLevel,unit,category')
        .eq('farmId', farmId)
        .eq('is_deleted', true)
        .order('updatedAt', ascending: false);
    return {
      'inventory': (rows as List).map((row) {
        final map = Map<String, dynamic>.from(row as Map);
        return TrashRecordItem(
          id: map['id'].toString(),
          tabKey: 'inventory',
          title: map['itemName']?.toString() ?? 'Inventory item',
          subtitle:
              '${map['stockLevel'] ?? 0} ${map['unit'] ?? ''} • ${map['category'] ?? 'General'}',
        );
      }).toList(),
    };
  }

  Future<void> deleteForever({
    required String tabKey,
    required String recordId,
  }) async {
    final tab = SettingsProfileContract.tabByKey(tabKey);
    if (tab == null) {
      throw StateError('Unknown trash tab: $tabKey');
    }
    await _client.from('delete_logs').insert({
      'table_name': tab.remoteTable,
      'record_id': recordId,
      'reason': 'PERMANENTLY_DELETED',
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
    await _client.from(tab.remoteTable).delete().eq('id', recordId);
  }
}
