import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../utils/farm_utils.dart';
import '../utils/id_utils.dart';
import '../utils/user_role.dart';
import '../services/cloud_owner_bind_service.dart';
import '../services/hatchlog_api_client.dart';
import '../services/license_service.dart';
import 'local_db.dart';

const _localProfileOwnerIdKey = 'LOCAL_PROFILE_OWNER_ID';

class SyncEngine extends ChangeNotifier {
  final AppDatabase db;
  final HatchlogApiClient _hatchlogApi;
  final _supabase = Supabase.instance.client;
  final Connectivity _connectivity = Connectivity();

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  final _syncStatusController = StreamController<bool>.broadcast();
  Stream<bool> get syncStatus => _syncStatusController.stream;

  void _updateSyncStatus(bool syncing) {
    if (!_syncStatusController.isClosed) {
      _syncStatusController.add(syncing);
    }
  }

  int? _safeInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.toInt();
    }
    return null;
  }

  String? _safeStr(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }

  bool _isSharedAllocationDescription(String? description) {
    return description?.contains('[SHARED ALLOCATION:') ?? false;
  }

  String? _allocationGroupFromDescription(String? description) {
    if (description == null) return null;
    final match = RegExp(r'group=([^;\]]+)').firstMatch(description);
    return match?.group(1)?.trim();
  }

  double? _allocationPercentFromDescription(String? description) {
    if (description == null) return null;
    final match = RegExp(
      r'percent=([0-9]+(?:\.[0-9]+)?)%',
    ).firstMatch(description);
    return double.tryParse(match?.group(1) ?? '');
  }

  double? _safeDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  bool _safeBool(dynamic value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final string = value?.toString().toLowerCase();
    if (string == 'true' || string == '1' || string == 'yes') return true;
    if (string == 'false' || string == '0' || string == 'no') return false;
    return fallback;
  }

  DateTime? _safeDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  String _remoteFarmIdForPush(String localFarmId, String? webFarmId) {
    final local = safeIdString(localFarmId);
    if (local == FarmUtils.localGenesisFarmId &&
        webFarmId != null &&
        webFarmId.trim().isNotEmpty) {
      return safeIdString(webFarmId);
    }
    return webFarmId != null && webFarmId.trim().isNotEmpty
        ? safeIdString(webFarmId)
        : local;
  }

  Timer? _syncTimer;
  Timer? _reachabilityTimer;

  SyncEngine(this.db, {HatchlogApiClient? hatchlogApi})
    : _hatchlogApi = hatchlogApi ?? HatchlogApiClient() {
    _initConnectivity();
  }

  void startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (_isOnline) syncNow();
    });
  }

  Future<void> syncNow() => _syncWhenNestReachable();

  Future<bool> _canReachNest() async {
    if (!_hatchlogApi.isConfigured) {
      debugPrint('[Sync] HATCHLOG_API_URL missing — farm sync blocked');
      return false;
    }
    return _hatchlogApi.canReach();
  }

  void _requireNestApi() {
    if (!_hatchlogApi.isConfigured) {
      throw StateError(
        'HATCHLOG_API_URL is required for Nest-owned farm/commerce sync',
      );
    }
  }

  Future<void> _syncWhenNestReachable() async {
    if (!_isOnline) return;
    if (await _canReachNest()) {
      _reachabilityTimer?.cancel();
      _reachabilityTimer = null;
      unawaited(performSync());
      return;
    }

    _reachabilityTimer ??= Timer.periodic(const Duration(seconds: 20), (
      _,
    ) async {
      if (!_isOnline) return;
      if (!await _canReachNest()) return;
      _reachabilityTimer?.cancel();
      _reachabilityTimer = null;
      unawaited(performSync());
    });
  }

  Future<void> _initConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _updateOnlineStatus(results);

    _connectivity.onConnectivityChanged.listen((results) {
      _updateOnlineStatus(results);
    });
  }

  void _updateOnlineStatus(List<ConnectivityResult> results) {
    bool online = !results.contains(ConnectivityResult.none);
    if (online != _isOnline) {
      _isOnline = online;
      notifyListeners();
      if (_isOnline) {
        unawaited(_syncWhenNestReachable());
      } else {
        _reachabilityTimer?.cancel();
        _reachabilityTimer = null;
      }
    }
  }

  Future<void> performSync() async {
    if (_isSyncing || !_isOnline) return;
    if (!_hatchlogApi.isConfigured) {
      debugPrint('[Sync] Aborted: HATCHLOG_API_URL is required');
      return;
    }
    if (!await _canReachNest()) return;

    // Stamp last_used so anti-clock-tamper guard has a fresh timestamp.
    await LicenseService(db).touchLastUsed();

    final farmId = await FarmUtils.getBoundFarmId();
    if (farmId == null) return;

    _isSyncing = true;
    _updateSyncStatus(true);
    notifyListeners();

    try {
      final webFarmId = await _resolveWebFarmId();
      if (webFarmId != null) {
        try {
          await LicenseService(db).reconcileToCloudFarmId(webFarmId);
        } catch (e, st) {
          debugPrint('[Sync] Farm ID reconcile failed: $e\n$st');
        }
      }

      final farmIdFilter = (webFarmId != null && webFarmId.trim().isNotEmpty)
          ? safeIdString(webFarmId)
          : safeIdString(farmId);
      await _syncFarmMembersFromCloud(farmIdFilter);
      await CloudUserIdMapService(db).warmCacheForFarm(farmIdFilter);

      await _pushChanges(webFarmId: webFarmId);
      await _pushDeletions(webFarmId: webFarmId);
      await _pullChanges();
    } finally {
      _isSyncing = false;
      _updateSyncStatus(false);
      notifyListeners();
    }
  }

  /// Deprecated: Supabase farm bootstrap path. Use [performSync] / [_pullChanges]
  /// (Nest domain REST). Team permissions RPC remains in [_pullChanges].
  @Deprecated('Use performSync(); Nest owns farm domain data.')
  Future<void> initialFullSync(String farmId) async {
    throw UnsupportedError(
      'initialFullSync is deprecated and no longer boots farm tables from '
      'Supabase. Use performSync() for Nest pull + team permissions RPC.',
    );
  }

  Future<String?> _resolveWebFarmId() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final farmRow = await _supabase
            .from('farms')
            .select('id')
            .eq('user_id', user.id)
            .maybeSingle();
        final fromAuth = _safeStr(farmRow?['id']);
        if (fromAuth != null) return safeIdString(fromAuth);
      }
    } catch (e) {
      debugPrint('Could not fetch web_farm_id from auth: $e');
    }

    final bound = await FarmUtils.getBoundFarmId();
    if (bound != null &&
        bound.isNotEmpty &&
        bound != FarmUtils.localGenesisFarmId) {
      return safeIdString(bound);
    }

    final config = await (db.select(
      db.licenseConfigs,
    )..where((t) => t.id.equals('singleton'))).getSingleOrNull();
    final fromLicense = _safeStr(config?.farmId);
    if (fromLicense != null && fromLicense != FarmUtils.localGenesisFarmId) {
      return safeIdString(fromLicense);
    }

    return null;
  }

  Future<void> _pushChanges({String? webFarmId}) async {
    debugPrint('--- SYNC PUSH START (webFarmId=$webFarmId) ---');

    try {
      // 1. Push Houses (Nest required)
      final pendingHouses = await (db.select(
        db.houses,
      )..where((t) => t.synced.equals(false))).get();
      for (var h in pendingHouses) {
        try {
          final id = safeIdString(h.id);
          final remoteFarmId = _remoteFarmIdForPush(h.farmId, webFarmId);
          _requireNestApi();
          try {
            await _hatchlogApi.createHouse({
              'id': id,
              'farm_id': remoteFarmId,
              'name': h.name,
              'capacity': h.capacity,
              'isIsolation': h.isIsolation,
            });
          } catch (_) {
            await _hatchlogApi.updateHouse(id, {
              'farm_id': remoteFarmId,
              'name': h.name,
              'capacity': h.capacity,
              'isIsolation': h.isIsolation,
            });
          }
          await (db.update(db.houses)..where((t) => t.id.equals(h.id))).write(
            const HousesCompanion(synced: Value(true)),
          );
        } catch (e) {
          debugPrint("House push error: $e");
        }
      }

      // 2. Push Batches (Nest required)
      final pendingBatches = await (db.select(
        db.batches,
      )..where((t) => t.synced.equals(false))).get();
      for (var b in pendingBatches) {
        try {
          final id = safeIdString(b.id);
          final remoteFarmId = _remoteFarmIdForPush(b.farmId, webFarmId);
          _requireNestApi();
          try {
            await _hatchlogApi.createLivestock({
              'id': id,
              'farm_id': remoteFarmId,
              'houseId': optionalIdString(b.houseId) ?? '',
              'breedType': b.breedType ?? 'UNKNOWN',
              'type': b.type,
              'batchName': b.batchName,
              'initialCount': b.initialCount,
              'arrivalDate': b.arrivalDate.toIso8601String(),
            });
          } catch (_) {
            await _hatchlogApi.updateLivestock(id, {
              'houseId': optionalIdString(b.houseId),
              'breedType': b.breedType,
              'batchName': b.batchName,
              'initialCount': b.initialCount,
              'currentCount': b.currentCount,
              'arrivalDate': b.arrivalDate.toIso8601String(),
              'status': b.status,
            });
          }
          await (db.update(db.batches)..where((t) => t.id.equals(b.id))).write(
            const BatchesCompanion(synced: Value(true)),
          );
        } catch (e) {
          debugPrint("Batch push error: $e");
        }
      }

      // 3. Push Inventory (Nest required)
      final pendingInventory = await (db.select(
        db.inventory,
      )..where((t) => t.synced.equals(false))).get();
      for (var i in pendingInventory) {
        try {
          final id = safeIdString(i.id);
          final remoteFarmId = _remoteFarmIdForPush(i.farmId, webFarmId);
          _requireNestApi();
          try {
            await _hatchlogApi.createInventory({
              'farm_id': remoteFarmId,
              'itemName': i.itemName,
              'stockLevel': i.stockLevel,
              'unit': i.unit,
              'category': i.category,
              'costPerUnit': i.costPerUnit,
              'supplierId': optionalIdString(i.supplierId),
            });
          } catch (_) {
            await _hatchlogApi.updateInventory(id, {
              'farm_id': remoteFarmId,
              'itemName': i.itemName,
              'stockLevel': i.stockLevel,
              'unit': i.unit,
              'category': i.category,
              'costPerUnit': i.costPerUnit,
              'supplierId': optionalIdString(i.supplierId),
              'reorderLevel': i.reorderLevel,
            });
          }
          await (db.update(db.inventory)..where((t) => t.id.equals(i.id)))
              .write(const InventoryCompanion(synced: Value(true)));
        } catch (e) {
          debugPrint("Inventory push error: $e");
        }
      }

      // 4. Push Mortality (Nest pushMutation required)
      final pendingMortality = await (db.select(
        db.mortalities,
      )..where((t) => t.synced.equals(false))).get();
      for (var m in pendingMortality) {
        try {
          final id = safeIdString(m.id);
          final remoteFarmId = _remoteFarmIdForPush(m.farmId, webFarmId);
          _requireNestApi();
          final ok = await _hatchlogApi.pushMutation(
            farmId: remoteFarmId,
            clientId: id,
            entityType: 'mortality',
            payload: {
              'batch_id': safeIdString(m.batchId),
              'farm_id': remoteFarmId,
              'count': m.count,
              'health_type': m.healthType,
              'reason': m.reason,
              'category': m.category,
              'sub_category': m.subCategory,
              'isolation_room_id': optionalIdString(m.isolationRoomId),
              'log_date': m.logDate.toIso8601String(),
            },
          );
          if (!ok) throw StateError('Nest mortality push rejected');
          await (db.update(db.mortalities)..where((t) => t.id.equals(m.id)))
              .write(const MortalitiesCompanion(synced: Value(true)));
        } catch (e) {
          debugPrint("Mortality push error: $e");
        }
      }

      // 5. Push Feeding Logs (Nest pushMutation required)
      final pendingFeeding = await (db.select(
        db.feedingLogs,
      )..where((t) => t.synced.equals(false))).get();
      for (var fl in pendingFeeding) {
        try {
          final id = safeIdString(fl.id);
          final remoteFarmId = _remoteFarmIdForPush(fl.farmId, webFarmId);
          _requireNestApi();
          final ok = await _hatchlogApi.pushMutation(
            farmId: remoteFarmId,
            clientId: id,
            entityType: 'feed_usage',
            payload: {
              'batch_id': optionalIdString(fl.batchId),
              'feed_type_id': optionalIdString(fl.feedTypeId),
              'formulation_id': optionalIdString(fl.formulationId),
              'amount_consumed': fl.amountConsumed,
              'log_date': fl.logDate.toIso8601String(),
              'farm_id': remoteFarmId,
            },
          );
          if (!ok) throw StateError('Nest feed push rejected');
          await (db.update(db.feedingLogs)..where((t) => t.id.equals(fl.id)))
              .write(const FeedingLogsCompanion(synced: Value(true)));
        } catch (e) {
          debugPrint("Feeding push error: $e");
        }
      }

      // 6. Push Egg Production (Nest pushMutation required)
      final pendingEggs = await (db.select(
        db.eggProductions,
      )..where((t) => t.synced.equals(false))).get();
      for (var ep in pendingEggs) {
        try {
          final id = safeIdString(ep.id);
          final remoteFarmId = _remoteFarmIdForPush(ep.farmId, webFarmId);
          _requireNestApi();
          final ok = await _hatchlogApi.pushMutation(
            farmId: remoteFarmId,
            clientId: id,
            entityType: 'egg_collection',
            payload: {
              'batch_id': safeIdString(ep.batchId),
              'farm_id': remoteFarmId,
              'category_id': optionalIdString(ep.categoryId),
              'eggs_collected': ep.eggsCollected,
              'unusable_count': ep.unusableCount,
              'eggs_remaining': ep.eggsRemaining,
              'crates': ep.cratesCollected,
              'quality_grade': ep.qualityGrade,
              'is_sorted': ep.isSorted,
              'small_count': ep.smallCount,
              'medium_count': ep.mediumCount,
              'large_count': ep.largeCount,
              'log_date': ep.logDate.toIso8601String(),
            },
          );
          if (!ok) throw StateError('Nest egg push rejected');
          await (db.update(db.eggProductions)..where((t) => t.id.equals(ep.id)))
              .write(const EggProductionsCompanion(synced: Value(true)));
        } catch (e) {
          debugPrint("Egg push error: $e");
        }
      }

      // 7. Push Sales (Nest required)
      final pendingSales = await (db.select(
        db.sales,
      )..where((t) => t.synced.equals(false))).get();
      for (var s in pendingSales) {
        try {
          final remoteFarmId = _remoteFarmIdForPush(s.farmId, webFarmId);
          _requireNestApi();
          final saleItemRows = await db.customSelect(
            'SELECT * FROM sale_items WHERE sale_id = ?',
            variables: [Variable.withString(s.id)],
            readsFrom: {},
          ).get();
          final items = saleItemRows.isEmpty
              ? [
                  {
                    'description': 'Sale',
                    'quantity': 1,
                    'unitPrice': s.totalAmount,
                    'totalPrice': s.totalAmount,
                  },
                ]
              : saleItemRows.map((row) {
                  final qty = row.read<int>('quantity');
                  return {
                    'description':
                        row.read<String>('description').isEmpty
                            ? 'Sale item'
                            : row.read<String>('description'),
                    'quantity': qty < 1 ? 1 : qty,
                    'unitPrice': row.read<double>('unit_price'),
                    'totalPrice': row.read<double>('total_price'),
                  };
                }).toList();
          await _hatchlogApi.createSale({
            'farm_id': remoteFarmId,
            'customerName': 'Customer',
            'totalAmount': s.totalAmount,
            'items': items,
          });
          await db.customStatement(
            'UPDATE sale_items SET synced = 1 WHERE sale_id = ?',
            [s.id],
          );
          await (db.update(db.sales)..where((t) => t.id.equals(s.id))).write(
            const SalesCompanion(synced: Value(true)),
          );
        } catch (e) {
          debugPrint("Sale push error: $e");
        }
      }

      await _pushFinancialTransactions(webFarmId);

      // 8. Push Customers / Suppliers (web uses separate tables)
      final pendingCustomers = await (db.select(
        db.customers,
      )..where((t) => t.synced.equals(false))).get();
      for (var c in pendingCustomers) {
        try {
          if (c.customerType == 'SUPPLIER') {
            await _pushSupplierContactToCloud(c, webFarmId);
          } else {
            await _pushCustomerContactToCloud(c, webFarmId);
          }
          await (db.update(db.customers)..where((t) => t.id.equals(c.id)))
              .write(const CustomersCompanion(synced: Value(true)));
        } catch (e) {
          debugPrint("Customer push error: $e");
        }
      }

      // 9. Push Feed Formulations (Nest required)
      final pendingFormulations = await (db.select(
        db.feedFormulations,
      )..where((t) => t.synced.equals(false))).get();
      for (var ff in pendingFormulations) {
        try {
          final id = safeIdString(ff.id);
          final remoteFarmId = _remoteFarmIdForPush(ff.farmId, webFarmId);
          _requireNestApi();
          final ings = await (db.select(
            db.feedFormulationIngredients,
          )..where((t) => t.formulationId.equals(ff.id))).get();
          final ingredients = ings
              .map(
                (ing) => {
                  'inventoryId': safeIdString(ing.inventoryId),
                  'quantity': ing.quantity,
                },
              )
              .toList();
          if (ingredients.isEmpty) {
            throw StateError('Formulation $id has no ingredients for Nest');
          }
          await _hatchlogApi.createFeedFormulation({
            'farm_id': remoteFarmId,
            'name': ff.name,
            'type': ff.type.isEmpty ? 'CUSTOM' : ff.type,
            if (ff.targetLivestock != null &&
                ff.targetLivestock!.trim().isNotEmpty)
              'targetLivestock': ff.targetLivestock,
            'ingredients': ingredients,
          });
          await (db.update(db.feedFormulationIngredients)
                ..where((t) => t.formulationId.equals(ff.id)))
              .write(
            const FeedFormulationIngredientsCompanion(synced: Value(true)),
          );
          await (db.update(db.feedFormulations)
                ..where((t) => t.id.equals(ff.id)))
              .write(const FeedFormulationsCompanion(synced: Value(true)));
        } catch (e) {
          debugPrint("FeedFormulation push error: $e");
        }
      }

      // 11. Push Expenses (Nest required)
      final pendingExpenses = await (db.select(
        db.expenses,
      )..where((t) => t.synced.equals(false))).get();
      for (var e in pendingExpenses) {
        try {
          final remoteFarmId = _remoteFarmIdForPush(e.farmId, webFarmId);
          _requireNestApi();
          await _hatchlogApi.createExpense({
            'farm_id': remoteFarmId,
            'amount': e.amount,
            'category': _normalizeExpenseCategory(e.category),
            'description': e.description,
            'expenseDate': e.date.toIso8601String(),
            if (optionalIdString(e.batchId) != null)
              'batch_id': optionalIdString(e.batchId),
          });
          await (db.update(db.expenses)..where((t) => t.id.equals(e.id))).write(
            const ExpensesCompanion(synced: Value(true)),
          );
        } catch (e) {
          debugPrint("Expense push error: $e");
        }
      }

      // 12. Push settlements → cloud `expenses` + `customers.balanceOwed`
      final pendingSettlements = await (db.select(
        db.settlements,
      )..where((t) => t.synced.equals(false))).get();
      for (var s in pendingSettlements) {
        try {
          await _pushSettlementToCloud(s, webFarmId);
          await (db.update(db.settlements)..where((t) => t.id.equals(s.id)))
              .write(const SettlementsCompanion(synced: Value(true)));
        } catch (e) {
          debugPrint("Settlement push error: $e");
        }
      }

      // 13. Stock logs are local-only; mark synced once linked inventory is on cloud
      final pendingStockLogs = await (db.select(
        db.stockLogs,
      )..where((t) => t.synced.equals(false))).get();
      for (var sl in pendingStockLogs) {
        final item = await (db.select(
          db.inventory,
        )..where((t) => t.id.equals(sl.itemId))).getSingleOrNull();
        if (item != null && item.synced) {
          await (db.update(db.stockLogs)..where((t) => t.id.equals(sl.id)))
              .write(const StockLogsCompanion(synced: Value(true)));
        }
      }

      await _pushHealthSchedules(webFarmId);
      await _pushFarmSettings(webFarmId);
    } catch (e) {
      debugPrint("Push Changes overall error: $e");
    }
    debugPrint('--- SYNC PUSH END ---');
  }

  Future<void> _pushDeletions({String? webFarmId}) async {
    final pending = await db.select(db.pendingDeletions).get();
    for (var d in pending) {
      try {
        _requireNestApi();
        final id = safeIdString(d.recordId);
        final farmId = _remoteFarmIdForPush(d.farmId, webFarmId);
        final table = d.targetTableName.trim().toLowerCase();

        switch (table) {
          case 'mortalities':
          case 'mortality':
            await _hatchlogApi.deleteMortality(id);
            break;
          case 'feeding_logs':
          case 'daily_feeding_logs':
            await _hatchlogApi.deleteFeeding(id);
            break;
          case 'egg_productions':
          case 'egg_production':
            await _hatchlogApi.deleteEgg(id);
            break;
          case 'inventory':
            await _hatchlogApi.deleteInventory(
              id,
              farmId,
              reason: 'Deleted from desktop sync',
            );
            break;
          case 'sales':
            await _hatchlogApi.deleteSale(
              id,
              farmId,
              reason: 'Deleted from desktop sync',
            );
            break;
          case 'expenses':
            await _hatchlogApi.deleteExpense(id, farmId);
            break;
          case 'batches':
          case 'livestock':
            await _hatchlogApi.deleteLivestock(
              id,
              'Deleted from desktop sync',
            );
            break;
          case 'customers':
            await _hatchlogApi.deleteCustomer(id, farmId);
            break;
          case 'feed_formulations':
            await _hatchlogApi.deleteFeedFormulation(id, farmId);
            break;
          case 'houses':
            await _hatchlogApi.deleteHouse(id);
            break;
          default:
            debugPrint(
              'WARN: Skipping unknown pending deletion table '
              '"${d.targetTableName}" ID $id (no Nest helper)',
            );
            continue;
        }

        await (db.delete(
          db.pendingDeletions,
        )..where((t) => t.id.equals(d.id))).go();
        debugPrint('Deleted remote record via Nest: $table ID $id');
      } catch (e) {
        debugPrint(
          'Deletion sync error for ${d.targetTableName} ID ${d.recordId}: $e',
        );
      }
    }
  }

  Future<void> _pushFinancialTransactions(String? webFarmId) async {
    final pendingRows = await db.customSelect(
      'SELECT * FROM financial_transactions WHERE synced = 0 AND is_deleted = 0',
      readsFrom: {},
    ).get();

    for (final row in pendingRows) {
      try {
        final id = safeIdString(row.read<String>('id'));
        final farmId = safeIdString(row.read<String>('farm_id'));
        final remoteFarmId = _remoteFarmIdForPush(farmId, webFarmId);
        _requireNestApi();
        final paymentMethod =
            _safeStr(row.read<String?>('payment_method')) ?? 'Cash';
        final payload = {
          'farm_id': remoteFarmId,
          'type': row.read<String>('type'),
          'category': row.read<String>('category'),
          'amount': row.read<double>('amount'),
          'paymentStatus': row.read<String>('payment_status'),
          'paymentMethod': paymentMethod,
          'referenceNum': row.read<String?>('reference_num'),
          'transactionDate': row.read<String>('transaction_date'),
          'description': row.read<String?>('description'),
        };
        assertSyncPayloadUsesStringIds(payload);
        await _hatchlogApi.createLedgerTransaction(payload);
        await db.customStatement(
          'UPDATE financial_transactions SET synced = 1 WHERE id = ?',
          [id],
        );
      } catch (e) {
        debugPrint('Financial transaction push error: $e');
      }
    }
  }

  Future<void> _pullChanges() async {
    final farmId = await FarmUtils.getBoundFarmId();
    if (farmId == null) return;
    final farmIdFilter = safeIdString(farmId);

    try {
      _requireNestApi();

      // Team-plane bootstrap (permissions only). Nest-owned tables do not use this.
      Map<String, dynamic>? syncData;
      try {
        final raw = await _supabase.rpc(
          'get_farm_sync_data',
          params: {'p_farm_id': farmIdFilter},
        );
        if (raw is Map<String, dynamic>) {
          syncData = raw;
        } else if (raw is Map) {
          syncData = Map<String, dynamic>.from(raw);
        }
      } catch (e) {
        debugPrint('WARN: get_farm_sync_data unavailable (team plane only): $e');
      }

      // 1. Pull Houses (Nest required)
      final nestHouses = await _hatchlogApi.listHouses(farmIdFilter);
      for (var h in nestHouses) {
        final house = h as Map<String, dynamic>;
        await db
            .into(db.houses)
            .insertOnConflictUpdate(
              HousesCompanion.insert(
                id: safeIdString(house['id']),
                farmId: farmIdFilter,
                userId: Value(
                  house['user_id'] as String? ?? house['userId'] as String?,
                ),
                name: (house['name'] ?? '') as String,
                capacity: _safeInt(house['capacity']) ?? 0,
                currentTemperature: Value(
                  _safeDouble(
                    house['current_temperature'] ?? house['currentTemperature'],
                  ),
                ),
                currentHumidity: Value(
                  _safeDouble(
                    house['current_humidity'] ?? house['currentHumidity'],
                  ),
                ),
                isIsolation: Value(
                  _safeBool(
                    house['is_isolation'] ?? house['isIsolation'],
                    fallback: false,
                  ),
                ),
                synced: const Value(true),
              ),
            );
      }
      debugPrint('Pull: synced ${nestHouses.length} houses from Nest');

      // 2. Pull Batches / Livestock (Nest required)
      final nestLivestock = await _hatchlogApi.listLivestock(farmIdFilter);
      for (var b in nestLivestock) {
        final batch = b as Map<String, dynamic>;
        await db
            .into(db.batches)
            .insertOnConflictUpdate(
              BatchesCompanion.insert(
                id: safeIdString(batch['id']),
                farmId: farmIdFilter,
                houseId: Value(_safeStr(batch['house_id'] ?? batch['houseId'])),
                userId: Value(
                  batch['user_id'] as String? ?? batch['userId'] as String?,
                ),
                batchName: Value(
                  batch['batch_name'] as String? ??
                      batch['batchName'] as String? ??
                      batch['name'] as String? ??
                      '',
                ),
                type: Value(batch['type'] as String? ?? ''),
                breedType: Value(
                  batch['breed_type'] as String? ??
                      batch['breedType'] as String?,
                ),
                status: Value(batch['status'] as String? ?? ''),
                arrivalDate:
                    _safeDateTime(
                      batch['arrival_date'] ?? batch['arrivalDate'],
                    ) ??
                    DateTime.now().toUtc(),
                currentCount:
                    _safeInt(batch['current_count'] ?? batch['currentCount']) ??
                    0,
                initialCount:
                    _safeInt(batch['initial_count'] ?? batch['initialCount']) ??
                    0,
                isolationCount: Value(
                  _safeInt(
                        batch['isolation_count'] ?? batch['isolationCount'],
                      ) ??
                      0,
                ),
                initialActualCost: Value(
                  _safeDouble(batch['initial_actual_cost']),
                ),
                growthTarget: Value(batch['growth_target']?.toString()),
                synced: const Value(true),
              ),
            );
      }
      debugPrint('Pull: synced ${nestLivestock.length} livestock from Nest');

      // 3. Pull Inventory (Nest required)
      final nestInventory = await _hatchlogApi.listInventory(farmIdFilter);
      for (var i in nestInventory) {
        final row = Map<String, dynamic>.from(i as Map);
        await db
            .into(db.inventory)
            .insertOnConflictUpdate(
              InventoryCompanion.insert(
                id: safeIdString(row['id']),
                farmId: farmIdFilter,
                userId: Value(
                  (row['userId'] ?? row['user_id']) as String?,
                ),
                itemName: (row['itemName'] ?? row['item_name'] ?? '') as String,
                stockLevel:
                    _safeDouble(row['stockLevel'] ?? row['stock_level']) ?? 0.0,
                reorderLevel: Value(
                  _safeDouble(row['reorderLevel'] ?? row['reorder_level']),
                ),
                unit: (row['unit'] ?? 'bags') as String,
                category: Value(
                  (row['category'] as String?) ?? 'other',
                ),
                costPerUnit: Value(
                  _safeDouble(row['costPerUnit'] ?? row['cost_per_unit']),
                ),
                eggCategoryId: Value(
                  _safeStr(row['eggCategoryId'] ?? row['egg_category_id']),
                ),
                synced: const Value(true),
              ),
            );
      }
      debugPrint(
        'Pull: synced ${nestInventory.length} inventory items from Nest',
      );

      // 4. Pull Customers (Nest required)
      final nestCustomers = await _hatchlogApi.listCustomers(farmIdFilter);
      for (var c in nestCustomers) {
        final row = Map<String, dynamic>.from(c as Map);
        await db
            .into(db.customers)
            .insertOnConflictUpdate(
              CustomersCompanion.insert(
                id: safeIdString(row['id']),
                farmId: farmIdFilter,
                name: (row['name'] ?? '') as String,
                phone: Value(_safeStr(row['phone'])),
                email: Value(_safeStr(row['email'])),
                address: Value(_safeStr(row['address'])),
                customerType: Value(
                  (row['customerType'] ?? row['customer_type'] ?? 'CUSTOMER')
                      as String,
                ),
                balanceOwed: Value(
                  _safeDouble(
                        row['balanceOwed'] ?? row['balance_owed'],
                      ) ??
                      0.0,
                ),
                supplyItems: Value(
                  _safeStr(row['supplyItems'] ?? row['supply_items']),
                ),
                contactPerson: Value(
                  _safeStr(row['contactPerson'] ?? row['contact_person']),
                ),
                synced: const Value(true),
              ),
            );
      }
      debugPrint('Pull: synced ${nestCustomers.length} customers from Nest');

      await _syncSuppliersFromCloud(farmIdFilter);
      await _syncFeedFormulationsFromCloud(farmIdFilter);
      await _syncSalesFromCloud(farmIdFilter);

      // 4.1 Pull User Permissions (Supabase team plane)
      final remotePermissions =
          (syncData?['user_permissions'] as List<dynamic>?) ?? [];
      for (var p in remotePermissions) {
        final perm = p as Map<String, dynamic>;
        await db
            .into(db.userPermissions)
            .insertOnConflictUpdate(
              UserPermissionsCompanion.insert(
                id: safeIdString(perm['id']),
                farmId: farmIdFilter,
                userId: safeIdString(
                  perm['userId'] ?? perm['user_id'] ?? perm['user'],
                ),
                permissionKey:
                    perm['permissionKey'] as String? ??
                    perm['key'] as String? ??
                    'UNKNOWN',
                allowed: Value((perm['allowed'] as bool?) ?? true),
                synced: const Value(true),
              ),
            );
      }
      debugPrint('Pull: synced ${remotePermissions.length} user permissions');

      // 5. Pull Mortality (Nest required)
      final remoteMortality = await _hatchlogApi.listMortality(farmIdFilter);
      for (var m in remoteMortality) {
        final row = Map<String, dynamic>.from(m as Map);
        await db
            .into(db.mortalities)
            .insertOnConflictUpdate(
              MortalitiesCompanion.insert(
                id: safeIdString(row['id']),
                farmId: farmIdFilter,
                batchId: safeIdString(row['batch_id'] ?? row['batchId']),
                count: row['count'] as int,
                reason: Value(row['reason'] as String?),
                category: Value(row['category'] as String?),
                subCategory: Value(
                  (row['sub_category'] ?? row['subCategory']) as String?,
                ),
                healthType: Value(
                  (row['type'] as String?)?.toUpperCase() == 'SICK'
                      ? 'SICK'
                      : 'DEAD',
                ),
                isolationRoomId: Value(
                  _safeStr(row['isolation_room_id'] ?? row['isolationRoomId']),
                ),
                logDate:
                    _safeDateTime(row['logDate'] ?? row['log_date']) ??
                    DateTime.now().toUtc(),
                userId: Value(
                  (row['user_id'] ?? row['userId']) as String?,
                ),
                synced: const Value(true),
              ),
            );
      }
      debugPrint('Pull: synced ${remoteMortality.length} mortality records');

      // 6. Pull Egg Production (Nest required)
      final remoteEggs = await _hatchlogApi.listEggs(farmIdFilter);
      for (var e in remoteEggs) {
        final row = Map<String, dynamic>.from(e as Map);
        await db
            .into(db.eggProductions)
            .insertOnConflictUpdate(
              EggProductionsCompanion.insert(
                id: safeIdString(row['id']),
                farmId: farmIdFilter,
                batchId: safeIdString(row['batchId'] ?? row['batch_id']),
                categoryId: Value(
                  _safeStr(row['categoryId'] ?? row['category_id']),
                ),
                eggsCollected: (row['eggsCollected'] ?? row['eggs_collected']) as int,
                unusableCount: Value(
                  (row['unusableCount'] ?? row['unusable_count']) as int? ?? 0,
                ),
                eggsRemaining: Value(
                  (row['eggsRemaining'] ?? row['eggs_remaining']) as int? ?? 0,
                ),
                cratesCollected: Value(
                  _safeDouble(row['cratesCollected'] ?? row['crates_collected']),
                ),
                qualityGrade: Value(
                  (row['qualityGrade'] ?? row['quality_grade']) as String?,
                ),
                isSorted: Value(
                  (row['isSorted'] ?? row['is_sorted']) as bool? ?? false,
                ),
                smallCount: Value(
                  (row['smallCount'] ?? row['small_count']) as int? ?? 0,
                ),
                mediumCount: Value(
                  (row['mediumCount'] ?? row['medium_count']) as int? ?? 0,
                ),
                largeCount: Value(
                  (row['largeCount'] ?? row['large_count']) as int? ?? 0,
                ),
                logDate:
                    _safeDateTime(row['logDate'] ?? row['log_date']) ??
                    DateTime.now().toUtc(),
                userId: Value((row['userId'] ?? row['user_id']) as String?),
                synced: const Value(true),
              ),
            );
      }
      debugPrint('Pull: synced ${remoteEggs.length} egg production records');

      final remoteEggCategories =
          await _hatchlogApi.listEggCategories(farmIdFilter);
      for (final raw in remoteEggCategories) {
        final category = Map<String, dynamic>.from(raw as Map);
        final id = safeIdString(category['id']);
        await db.customInsert(
          'INSERT OR REPLACE INTO egg_categories (id, farm_id, name, selling_price, unit_size) VALUES (?, ?, ?, ?, ?)',
          variables: [
            Variable.withString(id),
            Variable.withString(farmIdFilter),
            Variable.withString(category['name'] as String? ?? 'Eggs'),
            Variable(
              _safeDouble(
                    category['sellingPrice'] ?? category['selling_price'],
                  ) ??
                  0,
            ),
            Variable.withInt(
              _safeInt(category['unitSize'] ?? category['unit_size']) ?? 30,
            ),
          ],
        );
      }
      debugPrint(
        'Pull: synced ${remoteEggCategories.length} egg categories',
      );

      // 7. Pull Feeding Logs (Nest required)
      final remoteFeeds = await _hatchlogApi.listFeeding(farmIdFilter);
      for (var f in remoteFeeds) {
        final row = Map<String, dynamic>.from(f as Map);
        await db
            .into(db.feedingLogs)
            .insertOnConflictUpdate(
              FeedingLogsCompanion.insert(
                id: safeIdString(row['id']),
                farmId: farmIdFilter,
                batchId: Value(_safeStr(row['batch_id'] ?? row['batchId'])),
                feedTypeId: Value(
                  _safeStr(row['feed_type_id'] ?? row['feedTypeId']),
                ),
                formulationId: Value(
                  _safeStr(row['formulation_id'] ?? row['formulationId']),
                ),
                amountConsumed:
                    _safeDouble(
                      row['amount_consumed'] ?? row['amountConsumed'],
                    ) ??
                    0.0,
                logDate:
                    _safeDateTime(row['log_date'] ?? row['logDate']) ??
                    DateTime.now().toUtc(),
                userId: Value((row['user_id'] ?? row['userId']) as String?),
                synced: const Value(true),
              ),
            );
      }
      debugPrint('Pull: synced ${remoteFeeds.length} feeding logs');

      // 8. Pull Users and Farm Members
      await _syncFarmMembersFromCloud(farmIdFilter);

      // 9. Pull Expenses (Nest required)
      final remoteExpenses = await _hatchlogApi.listExpenses(farmIdFilter);
      for (var e in remoteExpenses) {
        final row = Map<String, dynamic>.from(e as Map);
        final description = _safeStr(row['description']);
        await db
            .into(db.expenses)
            .insertOnConflictUpdate(
              ExpensesCompanion.insert(
                id: safeIdString(row['id']),
                farmId: farmIdFilter,
                batchId: Value(_safeStr(row['batch_id'] ?? row['batchId'])),
                supplierId: Value(
                  _safeStr(row['supplierId'] ?? row['supplier_id']),
                ),
                category: (row['category'] as String?) ?? 'OTHER',
                amount: _safeDouble(row['amount']) ?? 0.0,
                date: Value(
                  _safeDateTime(
                        row['expense_date'] ??
                            row['expenseDate'] ??
                            row['date'],
                      ) ??
                      DateTime.now().toUtc(),
                ),
                description: Value(description),
                allocationGroupId: Value(
                  _allocationGroupFromDescription(description),
                ),
                allocationPercent: Value(
                  _allocationPercentFromDescription(description),
                ),
                isSharedAllocation: Value(
                  _isSharedAllocationDescription(description),
                ),
                userId: Value(_safeStr(row['user_id'] ?? row['userId'])),
                synced: const Value(true),
              ),
            );
      }
      debugPrint("Pull: synced ${remoteExpenses.length} expenses");

      // 9. Pull Profiles (worker provisioning records)
      final remoteProfiles = await _supabase
          .from('profiles')
          .select()
          .eq('farmId', farmIdFilter);
      for (var prof in remoteProfiles) {
        await db
            .into(db.profiles)
            .insertOnConflictUpdate(
              ProfilesCompanion.insert(
                id: safeIdString(prof['id']),
                farmId: farmIdFilter,
                phoneNumber:
                    prof['phoneNumber'] as String? ??
                    prof['phone_number'] as String? ??
                    '',
                role: Value(prof['role'] as String? ?? 'WORKER'),
                firstName: Value(
                  prof['firstName'] as String? ?? prof['first_name'] as String?,
                ),
                lastName: Value(
                  prof['lastName'] as String? ?? prof['last_name'] as String?,
                ),
                status: Value(prof['status'] as String? ?? 'PENDING'),
                customPermissionsJson: Value(
                  _safeJsonText(
                    prof['customPermissionsJson'] ??
                        prof['custom_permissions_json'],
                  ),
                ),
                synced: const Value(true),
              ),
            );
      }
      debugPrint('Pull: synced ${remoteProfiles.length} profiles');

      await _pullHealthSchedules(farmIdFilter);

      notifyListeners();
    } catch (e) {
      debugPrint('Pull changes error: $e');
    }
  }

  Map<String, dynamic>? _safeMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  String? _safeJsonText(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is List || value is Map) return jsonEncode(value);
    return value.toString();
  }

  String _syncedRole(dynamic role) {
    final cleaned = (_safeStr(role) ?? '').toUpperCase();
    switch (cleaned) {
      case 'OWNER':
      case 'MANAGER':
      case 'WORKER':
      case 'ACCOUNTANT':
        return cleaned;
      case 'ACCOUNTEN':
      case 'FINANCIAL':
        return 'ACCOUNTANT';
      case 'OPERATIONAL':
      case 'VETERINARIAN':
      default:
        return 'WORKER';
    }
  }

  String? _syncedCredentialHash(Map<String, dynamic> user) {
    return _safeStr(
      user['password'] ??
          user['password_hash'] ??
          user['credential_hash'] ??
          user['encrypted_password'],
    );
  }

  Future<String?> _protectedOwnerId() async {
    final prefs = await SharedPreferences.getInstance();
    final ownerId = prefs.getString(_localProfileOwnerIdKey);
    return ownerId == null || ownerId.trim().isEmpty ? null : ownerId.trim();
  }

  Future<bool> _isProtectedOwnerRecord(String userId, {String? ownerId}) async {
    if (ownerId == null || ownerId != userId) return false;
    final localOwner = await (db.select(
      db.users,
    )..where((u) => u.id.equals(userId))).getSingleOrNull();
    return localOwner == null ||
        UserRoleUtils.normalize(localOwner.role) == UserRoleUtils.owner;
  }

  Future<void> _upsertSyncedUser(
    Map<String, dynamic> user, {
    required String role,
    required String? ownerId,
  }) async {
    final userId = _safeStr(user['id']);
    if (userId == null) return;
    if (await _isProtectedOwnerRecord(userId, ownerId: ownerId)) return;

    final displayName =
        _safeStr(user['username']) ??
        _safeStr(user['name']) ??
        _safeStr(user['email']);

    await db
        .into(db.users)
        .insertOnConflictUpdate(
          UsersCompanion.insert(
            id: userId,
            firstname: Value(_safeStr(user['firstname'])),
            surname: Value(_safeStr(user['surname'])),
            middleName: Value(
              _safeStr(user['middle_name'] ?? user['middleName']),
            ),
            name: Value(displayName),
            email: Value(_safeStr(user['email'] ?? user['username'])),
            image: Value(_safeStr(user['image'])),
            password: Value(_syncedCredentialHash(user)),
            phoneNumber: Value(
              _safeStr(user['phone_number'] ?? user['phoneNumber']),
            ),
            mustChangePassword: Value(
              _safeBool(
                user['must_change_password'] ?? user['mustChangePassword'],
              ),
            ),
            role: Value(role),
            createdAt: Value(
              _safeDateTime(user['created_at'] ?? user['createdAt']) ??
                  DateTime.now().toUtc(),
            ),
            updatedAt: Value(
              _safeDateTime(user['updated_at'] ?? user['updatedAt']) ??
                  DateTime.now().toUtc(),
            ),
            synced: const Value(true),
          ),
        );
  }

  Future<void> _syncFarmMembersFromCloud(
    String farmIdFilter, {
    List<dynamic> rpcUsers = const [],
  }) async {
    final ownerId = await _protectedOwnerId();
    final rpcUsersById = <String, Map<String, dynamic>>{};
    for (final item in rpcUsers) {
      final user = _safeMap(item);
      final id = _safeStr(user?['id']);
      if (user != null && id != null) {
        rpcUsersById[id] = user;
      }
    }

    final remoteUserIds = <String>{};
    final remoteMemberIds = <String>{};
    var authoritativeMemberships = false;
    var syncedCount = 0;

    try {
      final members = await _supabase
          .from('farm_members')
          .select('*, users(*)')
          .eq('farmId', farmIdFilter);
      authoritativeMemberships = true;

      for (final item in members) {
        final member = _safeMap(item);
        if (member == null) continue;

        final userId = _safeStr(member['userId'] ?? member['user_id']);
        if (userId == null) continue;
        final memberId = safeIdString(
          member['id'] ?? '${farmIdFilter}_$userId',
        );
        remoteUserIds.add(userId);
        remoteMemberIds.add(memberId);

        Map<String, dynamic>? user = _safeMap(member['users']);
        user ??= rpcUsersById[userId];
        if (user == null) {
          final fetched = await _supabase
              .from('users')
              .select()
              .eq('id', userId)
              .maybeSingle();
          user = _safeMap(fetched);
        }

        final memberRole = _syncedRole(member['role'] ?? user?['role']);
        if (user != null) {
          await _upsertSyncedUser(user, role: memberRole, ownerId: ownerId);
        }

        if (!await _isProtectedOwnerRecord(userId, ownerId: ownerId)) {
          await db
              .into(db.farmMembers)
              .insertOnConflictUpdate(
                FarmMembersCompanion.insert(
                  id: memberId,
                  farmId: farmIdFilter,
                  userId: userId,
                  role: Value(memberRole),
                  joinedAt: Value(
                    _safeDateTime(
                          member['joinedAt'] ??
                              member['joined_at'] ??
                              member['createdAt'] ??
                              member['created_at'],
                        ) ??
                        DateTime.now().toUtc(),
                  ),
                  synced: const Value(true),
                ),
              );
        }
        syncedCount++;
      }
    } catch (e) {
      debugPrint(
        'Farm member table pull failed, falling back to RPC users: $e',
      );
      for (final entry in rpcUsersById.entries) {
        final user = entry.value;
        final userId = entry.key;
        final role = _syncedRole(user['role']);
        remoteUserIds.add(userId);
        await _upsertSyncedUser(user, role: role, ownerId: ownerId);
        syncedCount++;
      }
    }

    if (authoritativeMemberships) {
      final localMembers = await (db.select(
        db.farmMembers,
      )..where((m) => m.farmId.equals(farmIdFilter))).get();

      for (final localMember in localMembers) {
        if (await _isProtectedOwnerRecord(
          localMember.userId,
          ownerId: ownerId,
        )) {
          continue;
        }
        final stillPresent =
            remoteMemberIds.contains(localMember.id) ||
            remoteUserIds.contains(localMember.userId);
        if (stillPresent) continue;

        await (db.delete(
          db.farmMembers,
        )..where((m) => m.id.equals(localMember.id))).go();

        final remainingMemberships = await (db.select(
          db.farmMembers,
        )..where((m) => m.userId.equals(localMember.userId))).get();
        if (remainingMemberships.isEmpty) {
          await (db.delete(
            db.users,
          )..where((u) => u.id.equals(localMember.userId))).go();
        }
      }
    }

    debugPrint('Pull: synced $syncedCount team members');
    await CloudUserIdMapService(db).rebuildForFarm(farmIdFilter);
  }

  Future<void> _syncSuppliersFromCloud(String farmIdFilter) async {
    _requireNestApi();
    final remoteSuppliers = await _hatchlogApi.listSuppliers(farmIdFilter);
    for (var s in remoteSuppliers) {
      final row = Map<String, dynamic>.from(s as Map);
      await db
          .into(db.customers)
          .insertOnConflictUpdate(
            CustomersCompanion.insert(
              id: safeIdString(row['id']),
              farmId: farmIdFilter,
              name: (row['name'] ?? '') as String,
              phone: Value(_safeStr(row['phone'])),
              email: Value(_safeStr(row['email'])),
              address: Value(_safeStr(row['address'])),
              balanceOwed: Value(
                _safeDouble(row['balanceOwed'] ?? row['balance_owed']) ?? 0.0,
              ),
              customerType: const Value('SUPPLIER'),
              supplyItems: Value(
                _safeStr(row['supplyItems'] ?? row['supply_items']),
              ),
              contactPerson: Value(
                _safeStr(row['contactPerson'] ?? row['contact_person']),
              ),
              synced: const Value(true),
            ),
          );
    }
    debugPrint('Pull: synced ${remoteSuppliers.length} suppliers');
  }

  Future<void> _syncSalesFromCloud(String farmIdFilter) async {
    _requireNestApi();
    final remoteSales = await _hatchlogApi.listSales(farmIdFilter);
    for (final raw in remoteSales) {
      final row = Map<String, dynamic>.from(raw as Map);
      final total =
          _safeDouble(row['totalAmount'] ?? row['total_amount']) ?? 0.0;
      await db.into(db.sales).insertOnConflictUpdate(
        SalesCompanion.insert(
          id: safeIdString(row['id']),
          farmId: farmIdFilter,
          customerId: Value(
            _safeStr(row['customerId'] ?? row['customer_id']),
          ),
          userId: Value(_safeStr(row['userId'] ?? row['user_id'])),
          quantity: 1,
          unitPrice: total,
          totalAmount: total,
          saleDate: Value(
            _safeDateTime(row['saleDate'] ?? row['sale_date']) ??
                DateTime.now().toUtc(),
          ),
          synced: const Value(true),
        ),
      );
    }
    debugPrint('Pull: synced ${remoteSales.length} sales from Nest');
  }

  Future<void> _syncFeedFormulationsFromCloud(String farmIdFilter) async {
    _requireNestApi();
    final nestFormulations =
        await _hatchlogApi.listFeedFormulations(farmIdFilter);
    var ingredientCount = 0;
    for (final raw in nestFormulations) {
      final row = Map<String, dynamic>.from(raw as Map);
      final id = safeIdString(row['id']);
      await db.into(db.feedFormulations).insertOnConflictUpdate(
        FeedFormulationsCompanion.insert(
          id: id,
          farmId: farmIdFilter,
          name: (row['name'] ?? '') as String,
          notes: Value(_safeStr(row['notes'])),
          type: Value(_safeStr(row['type']) ?? 'CUSTOM'),
          targetLivestock: Value(
            _safeStr(row['targetLivestock'] ?? row['target_livestock']),
          ),
          stockLevel: Value(
            _safeDouble(row['stockLevel'] ?? row['stock_level']) ?? 0,
          ),
          createdAt: Value(
            DateTime.tryParse(
                  _safeStr(row['createdAt'] ?? row['created_at']) ?? '',
                ) ??
                DateTime.now(),
          ),
          updatedAt: Value(
            DateTime.tryParse(
                  _safeStr(row['updatedAt'] ?? row['updated_at']) ?? '',
                ) ??
                DateTime.now(),
          ),
          synced: const Value(true),
        ),
      );
      final ingredients = (row['ingredients'] as List?) ?? const [];
      for (final ingRaw in ingredients) {
        final ing = Map<String, dynamic>.from(ingRaw as Map);
        final inventoryId = _safeStr(
          ing['inventoryId'] ?? ing['inventory_id'],
        );
        if (inventoryId == null || inventoryId.isEmpty) continue;
        await db.into(db.feedFormulationIngredients).insertOnConflictUpdate(
          FeedFormulationIngredientsCompanion.insert(
            id: safeIdString(ing['id'] ?? '${id}_$inventoryId'),
            formulationId: id,
            inventoryId: inventoryId,
            quantity: _safeDouble(ing['quantity']) ?? 0,
            unit: Value(_safeStr(ing['unit']) ?? 'bag'),
            synced: const Value(true),
          ),
        );
        ingredientCount++;
      }
    }
    debugPrint(
      'Pull: synced ${nestFormulations.length} feed formulations from Nest',
    );
    debugPrint(
      'Pull: synced $ingredientCount feed formulation ingredients from Nest',
    );
  }

  Future<void> _pushCustomerContactToCloud(
    Customer c,
    String? webFarmId,
  ) async {
    _requireNestApi();
    final id = safeIdString(c.id);
    final remoteFarmId = _remoteFarmIdForPush(c.farmId, webFarmId);
    final body = {
      'farm_id': remoteFarmId,
      'name': c.name,
      if (c.phone != null && c.phone!.trim().isNotEmpty) 'phone': c.phone,
      if (c.email != null && c.email!.trim().isNotEmpty) 'email': c.email,
      if (c.address != null && c.address!.trim().isNotEmpty) 'address': c.address,
    };
    try {
      await _hatchlogApi.createCustomer(body);
    } catch (_) {
      await _hatchlogApi.updateCustomer(id, body);
    }
  }

  Future<void> _pushSupplierContactToCloud(
    Customer c,
    String? webFarmId,
  ) async {
    _requireNestApi();
    final id = safeIdString(c.id);
    final remoteFarmId = _remoteFarmIdForPush(c.farmId, webFarmId);
    final body = {
      'farm_id': remoteFarmId,
      'name': c.name,
      if (c.phone != null && c.phone!.trim().isNotEmpty) 'phone': c.phone,
      if (c.email != null && c.email!.trim().isNotEmpty) 'email': c.email,
      if (c.address != null && c.address!.trim().isNotEmpty) 'address': c.address,
    };
    try {
      await _hatchlogApi.createSupplier(body);
    } catch (_) {
      await _hatchlogApi.updateSupplier(id, body);
    }
  }

  Future<void> _pushSettlementToCloud(
    Settlement s,
    String? webFarmId,
  ) async {
    final customer = await (db.select(
      db.customers,
    )..where((t) => t.id.equals(s.customerId))).getSingleOrNull();
    if (customer != null) {
      if (customer.customerType == 'SUPPLIER') {
        await _pushSupplierContactToCloud(customer, webFarmId);
      } else {
        await _pushCustomerContactToCloud(customer, webFarmId);
      }
      await (db.update(db.customers)..where((t) => t.id.equals(customer.id)))
          .write(const CustomersCompanion(synced: Value(true)));
    }

    final remoteFarmId = _remoteFarmIdForPush(s.farmId, webFarmId);
    final description =
        'Settlement ${s.settlementType} (${customer?.customerType == 'SUPPLIER' ? 'supplier' : 'customer'} ${s.customerId})';
    _requireNestApi();
    await _hatchlogApi.createExpense({
      'farm_id': remoteFarmId,
      'amount': s.amount,
      'category': _settlementExpenseCategory(s.settlementType),
      'description': description,
      'expenseDate': s.settlementDate.toIso8601String(),
    });
  }

  String _settlementExpenseCategory(String settlementType) {
    switch (settlementType) {
      case 'COLLECTION':
      case 'PAYMENT':
      case 'DEBT_INCURRED':
        return 'OTHER';
      default:
        return 'OTHER';
    }
  }

  String _normalizeExpenseCategory(String? raw) {
    final key = (raw ?? '').trim().toUpperCase();
    const allowed = {
      'FEED',
      'MEDICATION',
      'EQUIPMENT',
      'UTILITIES',
      'SALARY',
      'MAINTENANCE',
      'OTHER',
      'LIVESTOCK_PURCHASE',
      'TRANSPORT',
    };
    if (allowed.contains(key)) return key;
    if (key == 'FEEDING' || key == 'FEEDS') return 'FEED';
    return 'OTHER';
  }

  Future<void> _pushHealthSchedules(String? webFarmId) async {
    _requireNestApi();
    final entries = <Map<String, dynamic>>[];
    final pendingVax = await (db.select(
      db.vaccinationSchedules,
    )..where((t) => t.synced.equals(false))).get();
    for (final v in pendingVax) {
      entries.add({
        'type': 'VACCINATION',
        'batchId': safeIdString(v.batchId),
        'name': v.vaccineName,
        'scheduledDate': v.scheduledDate.toIso8601String(),
        'status': v.status,
        'notes': v.notes,
        'quantity': v.quantity,
        'usageType': v.usageType,
        'unit': v.unit,
      });
    }

    final pendingMed = await (db.select(
      db.medicationSchedules,
    )..where((t) => t.synced.equals(false))).get();
    for (final m in pendingMed) {
      entries.add({
        'type': 'MEDICATION',
        'batchId': safeIdString(m.batchId),
        'name': m.medicationName,
        'scheduledDate': m.scheduledDate.toIso8601String(),
        'status': m.status,
        'notes': m.notes,
        'quantity': m.quantity,
        'usageType': m.usageType,
        'unit': m.unit,
      });
    }

    if (entries.isNotEmpty) {
      try {
        final remoteFarmId = _remoteFarmIdForPush(
          pendingVax.isNotEmpty
              ? pendingVax.first.farmId
              : pendingMed.first.farmId,
          webFarmId,
        );
        final payload = {
          'farm_id': remoteFarmId,
          'entries': entries,
        };
        assertSyncPayloadUsesStringIds(payload);
        await _hatchlogApi.createHealthSchedules(payload);
        for (final v in pendingVax) {
          await (db.update(db.vaccinationSchedules)
                ..where((t) => t.id.equals(v.id)))
              .write(const VaccinationSchedulesCompanion(synced: Value(true)));
        }
        for (final m in pendingMed) {
          await (db.update(db.medicationSchedules)
                ..where((t) => t.id.equals(m.id)))
              .write(const MedicationSchedulesCompanion(synced: Value(true)));
        }
      } catch (e) {
        debugPrint('Health schedules push error: $e');
      }
    }

    final pendingWeight = await (db.select(
      db.weightRecords,
    )..where((t) => t.synced.equals(false))).get();
    for (final w in pendingWeight) {
      try {
        final remoteFarmId = _remoteFarmIdForPush(w.farmId, webFarmId);
        final batchId = safeIdString(w.batchId);
        final payload = {
          'farm_id': remoteFarmId,
          'averageWeight': w.averageWeight,
          'logDate': w.logDate.toIso8601String(),
        };
        assertSyncPayloadUsesStringIds(payload);
        await _hatchlogApi.createWeightRecord(batchId, payload);
        await (db.update(db.weightRecords)..where((t) => t.id.equals(w.id)))
            .write(const WeightRecordsCompanion(synced: Value(true)));
      } catch (e) {
        debugPrint('Weight record push error: $e');
      }
    }
  }

  Future<void> _pushFarmSettings(String? webFarmId) async {
    final pending = await (db.select(
      db.farmSettings,
    )..where((t) => t.synced.equals(false))).get();
    for (final settings in pending) {
      try {
        _requireNestApi();
        final farmId = _remoteFarmIdForPush(settings.farmId, webFarmId);
        final farm = await (db.select(
          db.farms,
        )..where((t) => t.id.equals(settings.farmId))).getSingleOrNull();
        if (farm != null) {
          await _hatchlogApi.updateFarm(farmId, {
            'name': farm.name,
            'location': farm.location,
            'capacity': farm.capacity,
          });
        }
        await _hatchlogApi.updateFarmSettings(farmId, {
          'currency': settings.currency,
          'eggsPerCrate': settings.eggsPerCrate,
          'eggRecordReminderTime': settings.eggRecordReminderTime,
          'feedRecordReminderTime': settings.feedRecordReminderTime,
          if (settings.growthTargetStandard != null)
            'growthTargetStandard': settings.growthTargetStandard,
        });
        await (db.update(db.farmSettings)
              ..where((t) => t.id.equals(settings.id)))
            .write(const FarmSettingsCompanion(synced: Value(true)));
      } catch (e) {
        debugPrint('Farm settings push error: $e');
      }
    }
  }

  Future<void> _pullHealthSchedules(String farmIdFilter) async {
    _requireNestApi();
    final schedules = await _hatchlogApi.listHealthSchedules(farmIdFilter);
    final remoteVax = (schedules['vaccinations'] as List?) ?? const [];
    for (final raw in remoteVax) {
      final v = Map<String, dynamic>.from(raw as Map);
      await db
          .into(db.vaccinationSchedules)
          .insertOnConflictUpdate(
            VaccinationSchedulesCompanion.insert(
              id: safeIdString(v['id']),
              farmId: farmIdFilter,
              batchId: safeIdString(v['batchId'] ?? v['batch_id']),
              vaccineName:
                  (v['vaccineName'] ?? v['vaccine_name'] ?? '') as String,
              scheduledDate:
                  _safeDateTime(v['scheduledDate'] ?? v['scheduled_date']) ??
                  DateTime.now().toUtc(),
              status: Value(v['status'] as String? ?? 'PENDING'),
              notes: Value(v['notes'] as String?),
              quantity: Value(_safeDouble(v['quantity']) ?? 1),
              usageType: Value(
                (v['usageType'] ?? v['usage_type']) as String?,
              ),
              unit: Value(v['unit'] as String?),
              synced: const Value(true),
            ),
          );
    }

    final remoteMed = (schedules['medications'] as List?) ?? const [];
    for (final raw in remoteMed) {
      final m = Map<String, dynamic>.from(raw as Map);
      await db
          .into(db.medicationSchedules)
          .insertOnConflictUpdate(
            MedicationSchedulesCompanion.insert(
              id: safeIdString(m['id']),
              farmId: farmIdFilter,
              batchId: safeIdString(m['batchId'] ?? m['batch_id']),
              medicationName:
                  (m['medicationName'] ?? m['medication_name'] ?? '')
                      as String,
              scheduledDate:
                  _safeDateTime(m['scheduledDate'] ?? m['scheduled_date']) ??
                  DateTime.now().toUtc(),
              status: Value(m['status'] as String? ?? 'PENDING'),
              notes: Value(m['notes'] as String?),
              quantity: Value(_safeDouble(m['quantity']) ?? 1),
              usageType: Value(
                (m['usageType'] ?? m['usage_type']) as String?,
              ),
              unit: Value(m['unit'] as String?),
              synced: const Value(true),
            ),
          );
    }

    // Weight records live under livestock details on Nest.
    final remoteBatches = await _hatchlogApi.listLivestock(farmIdFilter);
    var weightCount = 0;
    for (final raw in remoteBatches) {
      final batch = Map<String, dynamic>.from(raw as Map);
      final batchId = safeIdString(batch['id']);
      try {
        final details =
            await _hatchlogApi.getLivestockDetails(batchId, farmIdFilter);
        final weights = (details['weightRecords'] as List?) ??
            (details['weight_records'] as List?) ??
            const [];
        for (final wRaw in weights) {
          final w = Map<String, dynamic>.from(wRaw as Map);
          await db
              .into(db.weightRecords)
              .insertOnConflictUpdate(
                WeightRecordsCompanion.insert(
                  id: safeIdString(w['id']),
                  farmId: farmIdFilter,
                  batchId: batchId,
                  averageWeight:
                      _safeDouble(
                        w['averageWeight'] ?? w['average_weight'],
                      ) ??
                      0.0,
                  logDate:
                      _safeDateTime(w['logDate'] ?? w['log_date']) ??
                      DateTime.now().toUtc(),
                  userId: Value(
                    (w['userId'] ?? w['user_id']) as String?,
                  ),
                  synced: const Value(true),
                ),
              );
          weightCount++;
        }
      } catch (e) {
        debugPrint('Weight pull for batch $batchId failed: $e');
      }
    }
    debugPrint(
      'Pull: synced ${remoteVax.length} vaccinations, '
      '${remoteMed.length} medications, $weightCount weight records',
    );
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _reachabilityTimer?.cancel();
    _syncStatusController.close();
    super.dispose();
  }
}
