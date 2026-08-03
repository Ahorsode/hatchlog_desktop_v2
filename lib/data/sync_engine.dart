import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io' show Platform;
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

  Future<void> syncNow() => _syncWhenSupabaseReachable();

  Future<bool> _canReachSupabase() async {
    final url = dotenv.env['SUPABASE_URL'];
    final uri = Uri.tryParse(url ?? '');
    if (uri == null ||
        uri.host.isEmpty ||
        uri.host == 'PLACEHOLDER.supabase.co') {
      return true;
    }

    try {
      final response = await http.head(uri).timeout(const Duration(seconds: 3));
      return response.statusCode < 500;
    } catch (e) {
      debugPrint('[Sync] Supabase reachability check failed: $e');
      return false;
    }
  }

  Future<void> _syncWhenSupabaseReachable() async {
    if (!_isOnline) return;
    if (await _canReachSupabase()) {
      _reachabilityTimer?.cancel();
      _reachabilityTimer = null;
      unawaited(performSync());
      return;
    }

    _reachabilityTimer ??= Timer.periodic(const Duration(seconds: 20), (
      _,
    ) async {
      if (!_isOnline) return;
      if (!await _canReachSupabase()) return;
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
        unawaited(_syncWhenSupabaseReachable());
      } else {
        _reachabilityTimer?.cancel();
        _reachabilityTimer = null;
      }
    }
  }

  Future<void> performSync() async {
    if (_isSyncing || !_isOnline) return;
    if (!await _canReachSupabase()) return;

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
      final userIdMap = CloudUserIdMapService(db);
      await userIdMap.warmCacheForFarm(farmIdFilter);

      await _pushChanges(webFarmId: webFarmId, userIdMap: userIdMap);
      await _pushDeletions();
      await _pullChanges();
    } finally {
      _isSyncing = false;
      _updateSyncStatus(false);
      notifyListeners();
    }
  }

  Future<void> initialFullSync(String farmId) async {
    if (!_isOnline) throw Exception("No internet connection for initial sync");

    _isSyncing = true;
    _updateSyncStatus(true);
    notifyListeners();

    try {
      final farmIdFilter = safeIdString(farmId);
      final data = await _supabase.rpc(
        'get_farm_sync_data',
        params: {'p_farm_id': farmIdFilter},
      );

      if (data == null) {
        throw Exception(
          "Farm not found or Permission Denied. Binding refused.",
        );
      }

      // 0. Hardware Binding
      try {
        final deviceInfo = DeviceInfoPlugin();
        String deviceId = "unknown_device";
        String deviceName = "Unknown Desktop";

        if (Platform.isWindows) {
          final windowsInfo = await deviceInfo.windowsInfo;
          deviceId = windowsInfo.deviceId;
          deviceName = windowsInfo.computerName;
        }

        await _supabase.rpc(
          'register_hardware_device',
          params: {
            'p_farm_id': farmIdFilter,
            'p_device_id': deviceId,
            'p_device_name': deviceName,
          },
        );
      } catch (e) {
        debugPrint("Hardware registration warning: $e");
      }

      // 1. Farm
      final remoteFarm = data['farm'] as Map<String, dynamic>;
      await db
          .into(db.farms)
          .insertOnConflictUpdate(
            FarmsCompanion.insert(
              id: safeIdString(remoteFarm['id']),
              name: remoteFarm['name'] as String,
              capacity: remoteFarm['capacity'] as int,
              userId: remoteFarm['userId'] as String? ?? '',
              location: Value(remoteFarm['location'] as String?),
              subscriptionTier: Value(
                remoteFarm['subscriptionTier'] as String? ?? 'FREE',
              ),
            ),
          );

      // 2. Farm Settings
      final remoteSettings = data['farm_settings'] as Map<String, dynamic>?;
      if (remoteSettings != null) {
        await db
            .into(db.farmSettings)
            .insertOnConflictUpdate(
              FarmSettingsCompanion.insert(
                id: safeIdString(remoteSettings['id']),
                farmId: safeIdString(remoteSettings['farmId']),
                currency: Value(remoteSettings['currency'] as String? ?? 'GHS'),
                eggRecordReminderTime: Value(
                  remoteSettings['eggRecordReminderTime'] as String?,
                ),
                feedRecordReminderTime: Value(
                  remoteSettings['feedRecordReminderTime'] as String?,
                ),
                growthTargetStandard: Value(
                  remoteSettings['growth_target_standard'] as int?,
                ),
                eggsPerCrate: Value(
                  remoteSettings['eggsPerCrate'] as int? ?? 30,
                ),
              ),
            );
      }

      // 3. Users and farm memberships are downstream-only on desktop.
      final remoteUsers = (data['users'] as List<dynamic>?) ?? [];
      await _syncFarmMembersFromCloud(farmIdFilter, rpcUsers: remoteUsers);

      // 4. Houses
      final remoteHouses = (data['houses'] as List<dynamic>?) ?? [];
      for (var h in remoteHouses) {
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
                name: house['name'] as String,
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

      // 5. Inventory
      final remoteInventory = (data['inventory'] as List<dynamic>?) ?? [];
      for (var i in remoteInventory) {
        final item = i as Map<String, dynamic>;
        await db
            .into(db.inventory)
            .insertOnConflictUpdate(
              InventoryCompanion.insert(
                id: safeIdString(item['id']),
                farmId: farmIdFilter,
                userId: Value(
                  item['user_id'] as String? ?? item['userId'] as String?,
                ),
                itemName: (item['item_name'] ?? item['itemName']) as String,
                stockLevel:
                    _safeDouble(item['stock_level'] ?? item['stockLevel']) ??
                    0.0,
                reorderLevel: Value(
                  _safeDouble(item['reorder_level'] ?? item['reorderLevel']),
                ),
                unit: item['unit'] as String,
                category: Value(item['category'] as String?),
                costPerUnit: Value(
                  _safeDouble(item['cost_per_unit'] ?? item['costPerUnit']),
                ),
                eggCategoryId: Value(
                  _safeStr(item['egg_category_id'] ?? item['eggCategoryId']),
                ),
                supplierId: Value(
                  _safeStr(item['supplier_id'] ?? item['supplierId']),
                ),
                synced: const Value(true),
              ),
            );
      }

      // 6. Batches
      final remoteBatches = (data['batches'] as List<dynamic>?) ?? [];
      for (var b in remoteBatches) {
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
                growthTarget: Value(batch['growth_target'] as String?),
                synced: const Value(true),
              ),
            );
      }

      // 7. Customers
      final remoteCustomers = (data['customers'] as List<dynamic>?) ?? [];
      for (var c in remoteCustomers) {
        final customer = c as Map<String, dynamic>;
        await db
            .into(db.customers)
            .insertOnConflictUpdate(
              CustomersCompanion.insert(
                id: safeIdString(customer['id']),
                farmId: farmIdFilter,
                name: customer['name'] as String,
                phone: Value(customer['phone'] as String?),
                email: Value(customer['email'] as String?),
                address: Value(customer['address'] as String?),
                balanceOwed: Value(_safeDouble(customer['balanceOwed']) ?? 0.0),
                customerType: const Value('CUSTOMER'),
                supplyItems: Value(customer['supplyItems'] as String?),
                contactPerson: Value(customer['contactPerson'] as String?),
                synced: const Value(true),
              ),
            );
      }

      await _syncSuppliersFromCloud(farmIdFilter);

      // 8. Expenses
      final remoteExpenses = await _supabase
          .from('expenses')
          .select()
          .eq('farmId', farmIdFilter);
      for (var e in remoteExpenses) {
        final description = _safeStr(e['description']);
        await db
            .into(db.expenses)
            .insertOnConflictUpdate(
              ExpensesCompanion.insert(
                id: safeIdString(e['id']),
                farmId: farmIdFilter,
                batchId: Value(_safeStr(e['batch_id'] ?? e['batchId'])),
                supplierId: Value(
                  _safeStr(e['supplierId'] ?? e['supplier_id']),
                ),
                category: e['category'] as String,
                amount: _safeDouble(e['amount']) ?? 0.0,
                date: Value(
                  _safeDateTime(e['expense_date'] ?? e['date']) ??
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
                userId: Value(_safeStr(e['user_id'] ?? e['userId'])),
                synced: const Value(true),
              ),
            );
      }

      await _pullHealthSchedules(farmIdFilter);
    } catch (e) {
      debugPrint("Initial Sync Error: $e");
      rethrow;
    } finally {
      _isSyncing = false;
      _updateSyncStatus(false);
      notifyListeners();
    }
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

  Future<void> _pushChanges({
    String? webFarmId,
    CloudUserIdMapService? userIdMap,
  }) async {
    debugPrint('--- SYNC PUSH START (webFarmId=$webFarmId) ---');

    try {
      final pushUserId = await FarmUtils.getUserId();
      final map = userIdMap ?? CloudUserIdMapService(db);
      final farmIdForMap = _remoteFarmIdForPush(
        await FarmUtils.getBoundFarmId() ?? '',
        webFarmId,
      );
      if (userIdMap == null) {
        await map.warmCacheForFarm(farmIdForMap);
      }
      String? pushUserIdForPayload(String? localUserId) {
        return map.resolveForPush(localUserId, sessionUserId: pushUserId);
      }

      // 1. Push Houses (camelCase columns)
      final pendingHouses = await (db.select(
        db.houses,
      )..where((t) => t.synced.equals(false))).get();
      for (var h in pendingHouses) {
        try {
          final id = safeIdString(h.id);
          final existing = await _supabase
              .from('houses')
              .select('id')
              .eq('id', id)
              .maybeSingle();
          final now = DateTime.now().toUtc().toIso8601String();
          final payload = {
            'id': id,
            'farmId': _remoteFarmIdForPush(h.farmId, webFarmId),
            'userId': pushUserIdForPayload(h.userId ?? pushUserId),
            'name': h.name,
            'capacity': h.capacity,
            'currentTemperature': h.currentTemperature,
            'currentHumidity': h.currentHumidity,
            'isIsolation': h.isIsolation,
            'updatedAt': now,
          };

          assertSyncPayloadUsesStringIds(payload);
          if (existing != null) {
            await _supabase.from('houses').update(payload).eq('id', id);
          } else {
            payload['createdAt'] = now;
            await _supabase.from('houses').insert(payload);
          }
          await (db.update(db.houses)..where((t) => t.id.equals(h.id))).write(
            const HousesCompanion(synced: Value(true)),
          );
        } catch (e) {
          debugPrint("House push error: $e");
        }
      }

      // 2. Push Batches (Mixed camel/snake columns)
      final pendingBatches = await (db.select(
        db.batches,
      )..where((t) => t.synced.equals(false))).get();
      for (var b in pendingBatches) {
        try {
          final id = safeIdString(b.id);
          final existing = await _supabase
              .from('batches')
              .select('id')
              .eq('id', id)
              .maybeSingle();
          final now = DateTime.now().toUtc().toIso8601String();
          final payload = {
            'id': id,
            'farmId': _remoteFarmIdForPush(b.farmId, webFarmId),
            'houseId': optionalIdString(b.houseId),
            'userId': pushUserIdForPayload(b.userId ?? pushUserId),
            'batchName': b.batchName,
            'type': b.type,
            'breedType': b.breedType,
            'status': b.status,
            'arrivalDate': b.arrivalDate.toIso8601String(),
            'currentCount': b.currentCount,
            'initialCount': b.initialCount,
            'isolationCount': b.isolationCount,
            'initial_actual_cost': b.initialActualCost,
            'growth_target': b.growthTarget,
            'updatedAt': now,
          };
          assertSyncPayloadUsesStringIds(payload);

          if (existing != null) {
            await _supabase.from('batches').update(payload).eq('id', id);
          } else {
            payload['createdAt'] = now;
            await _supabase.from('batches').insert(payload);
          }
          await (db.update(db.batches)..where((t) => t.id.equals(b.id))).write(
            const BatchesCompanion(synced: Value(true)),
          );
        } catch (e) {
          debugPrint("Batch push error: $e");
        }
      }

      // 3. Push Inventory (camelCase columns)
      final pendingInventory = await (db.select(
        db.inventory,
      )..where((t) => t.synced.equals(false))).get();
      for (var i in pendingInventory) {
        try {
          final id = safeIdString(i.id);
          final existing = await _supabase
              .from('inventory')
              .select('id')
              .eq('id', id)
              .maybeSingle();
          final now = DateTime.now().toUtc().toIso8601String();
          final payload = {
            'id': id,
            'farmId': _remoteFarmIdForPush(i.farmId, webFarmId),
            'userId': pushUserIdForPayload(i.userId),
            'itemName': i.itemName,
            'stockLevel': i.stockLevel,
            'reorderLevel': i.reorderLevel,
            'unit': i.unit,
            'category': i.category,
            'costPerUnit': i.costPerUnit,
            'supplierId': optionalIdString(i.supplierId),
            'updatedAt': now,
          };
          assertSyncPayloadUsesStringIds(payload);

          if (existing != null) {
            await _supabase.from('inventory').update(payload).eq('id', id);
          } else {
            payload['createdAt'] = now;
            await _supabase.from('inventory').insert(payload);
          }
          await (db.update(db.inventory)..where((t) => t.id.equals(i.id)))
              .write(const InventoryCompanion(synced: Value(true)));
        } catch (e) {
          debugPrint("Inventory push error: $e");
        }
      }

      // 4. Push Mortality (Nest when configured, else Supabase)
      final pendingMortality = await (db.select(
        db.mortalities,
      )..where((t) => t.synced.equals(false))).get();
      for (var m in pendingMortality) {
        try {
          final id = safeIdString(m.id);
          final remoteFarmId = _remoteFarmIdForPush(m.farmId, webFarmId);
          if (_hatchlogApi.isConfigured) {
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
          } else {
            final existing = await _supabase
                .from('mortality')
                .select('id')
                .eq('id', id)
                .maybeSingle();
            final now = DateTime.now().toUtc().toIso8601String();
            final payload = {
              'id': id,
              'farmId': remoteFarmId,
              'batchId': safeIdString(m.batchId),
              'count': m.count,
              'type': m.healthType,
              'reason': m.reason,
              'logDate': m.logDate.toIso8601String(),
              'user_id': pushUserIdForPayload(m.userId),
              'category': m.category,
              'sub_category': m.subCategory,
              'isolation_room_id': optionalIdString(m.isolationRoomId),
              'updatedAt': now,
            };
            assertSyncPayloadUsesStringIds(payload);

            if (existing != null) {
              await _supabase.from('mortality').update(payload).eq('id', id);
            } else {
              payload['createdAt'] = now;
              await _supabase.from('mortality').insert(payload);
            }
          }
          await (db.update(db.mortalities)..where((t) => t.id.equals(m.id)))
              .write(const MortalitiesCompanion(synced: Value(true)));
        } catch (e) {
          debugPrint("Mortality push error: $e");
        }
      }

      // 5. Push Feeding Logs (Nest when configured, else Supabase)
      final pendingFeeding = await (db.select(
        db.feedingLogs,
      )..where((t) => t.synced.equals(false))).get();
      for (var fl in pendingFeeding) {
        try {
          final id = safeIdString(fl.id);
          final remoteFarmId = _remoteFarmIdForPush(fl.farmId, webFarmId);
          if (_hatchlogApi.isConfigured) {
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
          } else {
            final existing = await _supabase
                .from('daily_feeding_logs')
                .select('id')
                .eq('id', id)
                .maybeSingle();
            final payload = {
              'id': id,
              'farmId': remoteFarmId,
              'batch_id': optionalIdString(fl.batchId),
              'feed_type_id': optionalIdString(fl.feedTypeId),
              'formulation_id': optionalIdString(fl.formulationId),
              'amount_consumed': fl.amountConsumed,
              'log_date': fl.logDate.toIso8601String(),
              'user_id': pushUserIdForPayload(fl.userId),
            };
            assertSyncPayloadUsesStringIds(payload);

            if (existing != null) {
              await _supabase
                  .from('daily_feeding_logs')
                  .update(payload)
                  .eq('id', id);
            } else {
              await _supabase.from('daily_feeding_logs').insert(payload);
            }
          }
          await (db.update(db.feedingLogs)..where((t) => t.id.equals(fl.id)))
              .write(const FeedingLogsCompanion(synced: Value(true)));
        } catch (e) {
          debugPrint("Feeding push error: $e");
        }
      }

      // 6. Push Egg Production (Nest when configured, else Supabase)
      final pendingEggs = await (db.select(
        db.eggProductions,
      )..where((t) => t.synced.equals(false))).get();
      for (var ep in pendingEggs) {
        try {
          final id = safeIdString(ep.id);
          final remoteFarmId = _remoteFarmIdForPush(ep.farmId, webFarmId);
          if (_hatchlogApi.isConfigured) {
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
          } else {
            final existing = await _supabase
                .from('egg_production')
                .select('id')
                .eq('id', id)
                .maybeSingle();
            final now = DateTime.now().toUtc().toIso8601String();
            final payload = {
              'id': id,
              'farmId': remoteFarmId,
              'batchId': safeIdString(ep.batchId),
              'categoryId': optionalIdString(ep.categoryId),
              'eggsCollected': ep.eggsCollected,
              'unusableCount': ep.unusableCount,
              'eggsRemaining': ep.eggsRemaining,
              'cratesCollected': ep.cratesCollected,
              'qualityGrade': ep.qualityGrade,
              'isSorted': ep.isSorted,
              'smallCount': ep.smallCount,
              'mediumCount': ep.mediumCount,
              'largeCount': ep.largeCount,
              'logDate': ep.logDate.toIso8601String(),
              'userId': pushUserIdForPayload(ep.userId),
            };
            assertSyncPayloadUsesStringIds(payload);

            if (existing != null) {
              await _supabase
                  .from('egg_production')
                  .update(payload)
                  .eq('id', id);
            } else {
              payload['createdAt'] = now;
              await _supabase.from('egg_production').insert(payload);
            }
          }
          await (db.update(db.eggProductions)..where((t) => t.id.equals(ep.id)))
              .write(const EggProductionsCompanion(synced: Value(true)));
        } catch (e) {
          debugPrint("Egg push error: $e");
        }
      }

      // 7. Push Sales (camelCase columns)
      final pendingSales = await (db.select(
        db.sales,
      )..where((t) => t.synced.equals(false))).get();
      for (var s in pendingSales) {
        try {
          final id = safeIdString(s.id);
          final existing = await _supabase
              .from('sales')
              .select('id')
              .eq('id', id)
              .maybeSingle();
          final now = DateTime.now().toUtc().toIso8601String();
          final payload = {
            'id': id,
            'farmId': _remoteFarmIdForPush(s.farmId, webFarmId),
            'customerId': optionalIdString(s.customerId),
            'userId': pushUserIdForPayload(s.userId),
            'totalAmount': s.totalAmount,
            'saleDate': s.saleDate.toIso8601String(),
            'updatedAt': now,
          };
          assertSyncPayloadUsesStringIds(payload);

          if (existing != null) {
            await _supabase.from('sales').update(payload).eq('id', id);
          } else {
            payload['createdAt'] = now;
            await _supabase.from('sales').insert(payload);
          }
          await (db.update(db.sales)..where((t) => t.id.equals(s.id))).write(
            const SalesCompanion(synced: Value(true)),
          );
        } catch (e) {
          debugPrint("Sale push error: $e");
        }
      }

      await _pushSaleItems(webFarmId);
      await _pushFinancialTransactions(
        webFarmId,
        pushUserIdForPayload: pushUserIdForPayload,
      );

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

      // 9. Push Feed Formulations
      final pendingFormulations = await (db.select(
        db.feedFormulations,
      )..where((t) => t.synced.equals(false))).get();
      for (var ff in pendingFormulations) {
        try {
          final id = safeIdString(ff.id);
          final now = DateTime.now().toUtc().toIso8601String();
          final payload = {
            'id': id,
            'farmId': _remoteFarmIdForPush(ff.farmId, webFarmId),
            'name': ff.name,
            'notes': ff.notes,
            'type': ff.type,
            'targetLivestock': ff.targetLivestock,
            'stockLevel': ff.stockLevel,
            'createdAt': ff.createdAt.toUtc().toIso8601String(),
            'updatedAt': now,
          };
          assertSyncPayloadUsesStringIds(payload);
          final existing = await _supabase
              .from('feed_formulations')
              .select('id')
              .eq('id', id)
              .maybeSingle();
          if (existing != null) {
            await _supabase
                .from('feed_formulations')
                .update(payload)
                .eq('id', id);
          } else {
            await _supabase.from('feed_formulations').insert(payload);
          }
          await (db.update(db.feedFormulations)
                ..where((t) => t.id.equals(ff.id)))
              .write(const FeedFormulationsCompanion(synced: Value(true)));
        } catch (e) {
          debugPrint("FeedFormulation push error: $e");
        }
      }

      // 9.1 Push Feed Formulation Ingredients
      final pendingIngredients = await (db.select(
        db.feedFormulationIngredients,
      )..where((t) => t.synced.equals(false))).get();
      for (var ing in pendingIngredients) {
        try {
          final id = safeIdString(ing.id);
          final payload = {
            'id': id,
            'formulationId': safeIdString(ing.formulationId),
            'inventoryId': safeIdString(ing.inventoryId),
            'quantity': ing.quantity,
            'unit': ing.unit,
          };
          assertSyncPayloadUsesStringIds(payload);
          final existing = await _supabase
              .from('feed_formulation_ingredients')
              .select('id')
              .eq('id', id)
              .maybeSingle();
          if (existing != null) {
            await _supabase
                .from('feed_formulation_ingredients')
                .update(payload)
                .eq('id', id);
          } else {
            await _supabase.from('feed_formulation_ingredients').insert(payload);
          }
          await (db.update(db.feedFormulationIngredients)
                ..where((t) => t.id.equals(ing.id)))
              .write(
            const FeedFormulationIngredientsCompanion(synced: Value(true)),
          );
        } catch (e) {
          debugPrint("FeedFormulationIngredient push error: $e");
        }
      }

      // 11. Push Expenses
      final pendingExpenses = await (db.select(
        db.expenses,
      )..where((t) => t.synced.equals(false))).get();
      for (var e in pendingExpenses) {
        try {
          final id = safeIdString(e.id);
          final existing = await _supabase
              .from('expenses')
              .select('id')
              .eq('id', id)
              .maybeSingle();
          final now = DateTime.now().toUtc().toIso8601String();
          final payload = {
            'id': id,
            'farmId': _remoteFarmIdForPush(e.farmId, webFarmId),
            'batch_id': optionalIdString(e.batchId),
            'supplierId': optionalIdString(e.supplierId),
            'user_id': pushUserIdForPayload(e.userId),
            'category': _normalizeExpenseCategory(e.category),
            'amount': e.amount,
            'expense_date': e.date.toIso8601String(),
            'description': e.description,
            'updated_at': now,
          };
          assertSyncPayloadUsesStringIds(payload);

          if (existing != null) {
            await _supabase.from('expenses').update(payload).eq('id', id);
          } else {
            payload['created_at'] = now;
            await _supabase.from('expenses').insert(payload);
          }
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
          await _pushSettlementToCloud(
            s,
            webFarmId,
            pushUserIdForPayload: pushUserIdForPayload,
          );
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

      await _pushHealthSchedules(
        webFarmId,
        pushUserIdForPayload: pushUserIdForPayload,
      );
      await _pushFarmSettings(webFarmId);
    } catch (e) {
      debugPrint("Push Changes overall error: $e");
    }
    debugPrint('--- SYNC PUSH END ---');
  }

  Future<void> _pushDeletions() async {
    final pending = await db.select(db.pendingDeletions).get();
    for (var d in pending) {
      try {
        // Table names in Supabase are sometimes different (e.g. mortality vs mortalities)
        String remoteTable = d.targetTableName;
        if (remoteTable == 'mortalities') remoteTable = 'mortality';
        if (remoteTable == 'feeding_logs') remoteTable = 'daily_feeding_logs';
        if (remoteTable == 'egg_productions') remoteTable = 'egg_production';

        await _supabase
            .from(remoteTable)
            .delete()
            .eq('id', safeIdString(d.recordId));
        await (db.delete(
          db.pendingDeletions,
        )..where((t) => t.id.equals(d.id))).go();
        debugPrint("Deleted remote record: $remoteTable ID ${d.recordId}");
      } catch (e) {
        debugPrint(
          "Deletion sync error for ${d.targetTableName} ID ${d.recordId}: $e",
        );
      }
    }
  }

  Future<void> _pushSaleItems(String? webFarmId) async {
    final pendingItems = await db.customSelect(
      'SELECT * FROM sale_items WHERE synced = 0',
      readsFrom: {},
    ).get();

    for (final row in pendingItems) {
      try {
        final id = safeIdString(row.read<String>('id'));
        final saleId = safeIdString(row.read<String>('sale_id'));
        final farmId = safeIdString(row.read<String>('farm_id'));
        final existing = await _supabase
            .from('sale_items')
            .select('id')
            .eq('id', id)
            .maybeSingle();
        final payload = {
          'id': id,
          'saleId': saleId,
          'farmId': _remoteFarmIdForPush(farmId, webFarmId),
          'description': row.read<String>('description'),
          'quantity': row.read<int>('quantity'),
          'unitPrice': row.read<double>('unit_price'),
          'totalPrice': row.read<double>('total_price'),
          'inventoryId': _safeStr(row.read<String?>('inventory_id')),
          'livestockId': _safeStr(row.read<String?>('livestock_id')),
        };
        assertSyncPayloadUsesStringIds(payload);

        if (existing != null) {
          await _supabase.from('sale_items').update(payload).eq('id', id);
        } else {
          await _supabase.from('sale_items').insert(payload);
        }
        await db.customStatement(
          'UPDATE sale_items SET synced = 1 WHERE id = ?',
          [id],
        );
      } catch (e) {
        debugPrint('Sale item push error: $e');
      }
    }
  }

  Future<void> _pushFinancialTransactions(
    String? webFarmId, {
    required String? Function(String? localUserId) pushUserIdForPayload,
  }) async {
    final pendingRows = await db.customSelect(
      'SELECT * FROM financial_transactions WHERE synced = 0 AND is_deleted = 0',
      readsFrom: {},
    ).get();

    for (final row in pendingRows) {
      try {
        final id = safeIdString(row.read<String>('id'));
        final farmId = safeIdString(row.read<String>('farm_id'));
        final existing = await _supabase
            .from('financial_transactions')
            .select('id')
            .eq('id', id)
            .maybeSingle();
        final now = DateTime.now().toUtc().toIso8601String();
        final payload = {
          'id': id,
          'farm_id': _remoteFarmIdForPush(farmId, webFarmId),
          'user_id': pushUserIdForPayload(_safeStr(row.read<String?>('user_id'))),
          'type': row.read<String>('type'),
          'category': row.read<String>('category'),
          'amount': row.read<double>('amount'),
          'payment_status': row.read<String>('payment_status'),
          'payment_method': row.read<String?>('payment_method'),
          'reference_num': row.read<String?>('reference_num'),
          'transaction_date': row.read<String>('transaction_date'),
          'description': row.read<String?>('description'),
          'updated_at': now,
        };
        assertSyncPayloadUsesStringIds(payload);

        if (existing != null) {
          await _supabase
              .from('financial_transactions')
              .update(payload)
              .eq('id', id);
        } else {
          payload['created_at'] = now;
          await _supabase.from('financial_transactions').insert(payload);
        }
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
      final syncData = await _supabase.rpc(
        'get_farm_sync_data',
        params: {'p_farm_id': farmIdFilter},
      );
      if (syncData == null) return;

      // 1. Pull Houses
      final remoteHouses = (syncData['houses'] as List<dynamic>?) ?? [];
      for (var h in remoteHouses) {
        await db
            .into(db.houses)
            .insertOnConflictUpdate(
              HousesCompanion.insert(
                id: safeIdString(h['id']),
                farmId: farmIdFilter,
                userId: Value(h['userId'] as String?),
                name: h['name'] as String,
                capacity: _safeInt(h['capacity']) ?? 0,
                currentTemperature: Value(_safeDouble(h['currentTemperature'])),
                currentHumidity: Value(_safeDouble(h['currentHumidity'])),
                isIsolation: Value(h['isIsolation'] as bool? ?? false),
                synced: const Value(true),
              ),
            );
      }
      debugPrint('Pull: synced ${remoteHouses.length} houses');

      // 2. Pull Batches
      final remoteBatches = (syncData['batches'] as List<dynamic>?) ?? [];
      for (var rb in remoteBatches) {
        await db
            .into(db.batches)
            .insertOnConflictUpdate(
              BatchesCompanion.insert(
                id: safeIdString(rb['id']),
                farmId: farmIdFilter,
                houseId: Value(_safeStr(rb['houseId'] ?? rb['house_id'])),
                userId: Value(rb['userId'] as String?),
                batchName: Value(rb['batchName'] as String? ?? ''),
                type: Value(rb['type'] as String? ?? ''),
                breedType: Value(rb['breedType'] as String?),
                status: Value(rb['status'] as String? ?? ''),
                arrivalDate:
                    _safeDateTime(rb['arrivalDate']) ?? DateTime.now().toUtc(),
                currentCount: _safeInt(rb['currentCount']) ?? 0,
                initialCount: _safeInt(rb['initialCount']) ?? 0,
                isolationCount: Value(_safeInt(rb['isolationCount']) ?? 0),
                initialActualCost: Value(
                  _safeDouble(rb['initial_actual_cost']),
                ),
                growthTarget: Value(rb['growth_target']?.toString()),
                synced: const Value(true),
              ),
            );
      }
      debugPrint('Pull: synced ${remoteBatches.length} batches');

      // 3. Pull Inventory
      final remoteInventory = (syncData['inventory'] as List<dynamic>?) ?? [];
      for (var i in remoteInventory) {
        await db
            .into(db.inventory)
            .insertOnConflictUpdate(
              InventoryCompanion.insert(
                id: safeIdString(i['id']),
                farmId: farmIdFilter,
                userId: Value(i['userId'] as String?),
                itemName: i['itemName'] as String,
                stockLevel: _safeDouble(i['stockLevel']) ?? 0.0,
                reorderLevel: Value(_safeDouble(i['reorderLevel'])),
                unit: i['unit'] as String,
                category: Value(i['category'] as String?),
                costPerUnit: Value(_safeDouble(i['costPerUnit'])),
                eggCategoryId: Value(_safeStr(i['eggCategoryId'])),
                synced: const Value(true),
              ),
            );
      }
      debugPrint('Pull: synced ${remoteInventory.length} inventory items');

      // 4. Pull Customers
      final remoteCustomers = (syncData['customers'] as List<dynamic>?) ?? [];
      for (var c in remoteCustomers) {
        await db
            .into(db.customers)
            .insertOnConflictUpdate(
              CustomersCompanion.insert(
                id: safeIdString(c['id']),
                farmId: farmIdFilter,
                name: c['name'] as String,
                phone: Value(c['phone'] as String?),
                email: Value(c['email'] as String?),
                address: Value(c['address'] as String?),
                customerType: Value(c['customerType'] as String? ?? 'CUSTOMER'),
                balanceOwed: Value(_safeDouble(c['balanceOwed']) ?? 0.0),
                supplyItems: Value(c['supplyItems'] as String?),
                contactPerson: Value(c['contactPerson'] as String?),
                synced: const Value(true),
              ),
            );
      }
      debugPrint('Pull: synced ${remoteCustomers.length} customers');

      await _syncSuppliersFromCloud(farmIdFilter);
      await _syncFeedFormulationsFromCloud(farmIdFilter);

      // 4.1 Pull User Permissions (if provided by RPC)
      final remotePermissions =
          (syncData['user_permissions'] as List<dynamic>?) ?? [];
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

      // 5. Pull Mortality (direct table query)
      final remoteMortality = await _supabase
          .from('mortality')
          .select()
          .eq('farmId', farmIdFilter);
      for (var m in remoteMortality) {
        await db
            .into(db.mortalities)
            .insertOnConflictUpdate(
              MortalitiesCompanion.insert(
                id: safeIdString(m['id']),
                farmId: farmIdFilter,
                batchId: safeIdString(m['batch_id'] ?? m['batchId']),
                count: m['count'] as int,
                reason: Value(m['reason'] as String?),
                category: Value(m['category'] as String?),
                subCategory: Value(m['sub_category'] as String?),
                healthType: Value(
                  (m['type'] as String?)?.toUpperCase() == 'SICK'
                      ? 'SICK'
                      : 'DEAD',
                ),
                isolationRoomId: Value(
                  _safeStr(m['isolation_room_id'] ?? m['isolationRoomId']),
                ),
                logDate: _safeDateTime(m['logDate']) ?? DateTime.now().toUtc(),
                userId: Value(m['user_id'] as String?),
                synced: const Value(true),
              ),
            );
      }
      debugPrint('Pull: synced ${remoteMortality.length} mortality records');

      // 6. Pull Egg Production (direct table query)
      final remoteEggs = await _supabase
          .from('egg_production')
          .select()
          .eq('farmId', farmIdFilter);
      for (var e in remoteEggs) {
        await db
            .into(db.eggProductions)
            .insertOnConflictUpdate(
              EggProductionsCompanion.insert(
                id: safeIdString(e['id']),
                farmId: farmIdFilter,
                batchId: safeIdString(e['batchId'] ?? e['batch_id']),
                categoryId: Value(
                  _safeStr(e['categoryId'] ?? e['category_id']),
                ),
                eggsCollected: e['eggsCollected'] as int,
                unusableCount: Value(e['unusableCount'] as int? ?? 0),
                eggsRemaining: Value(e['eggsRemaining'] as int? ?? 0),
                cratesCollected: Value(_safeDouble(e['cratesCollected'])),
                qualityGrade: Value(e['qualityGrade'] as String?),
                isSorted: Value(e['isSorted'] as bool? ?? false),
                smallCount: Value(e['smallCount'] as int? ?? 0),
                mediumCount: Value(e['mediumCount'] as int? ?? 0),
                largeCount: Value(e['largeCount'] as int? ?? 0),
                logDate: _safeDateTime(e['logDate']) ?? DateTime.now().toUtc(),
                userId: Value(e['userId'] as String?),
                synced: const Value(true),
              ),
            );
      }
      debugPrint('Pull: synced ${remoteEggs.length} egg production records');

      final remoteEggCategories = await _supabase
          .from('egg_categories')
          .select()
          .eq('farmId', farmIdFilter);
      for (final category in remoteEggCategories) {
        final id = safeIdString(category['id']);
        await db.customInsert(
          'INSERT OR REPLACE INTO egg_categories (id, farm_id, name, selling_price, unit_size) VALUES (?, ?, ?, ?, ?)',
          variables: [
            Variable.withString(id),
            Variable.withString(farmIdFilter),
            Variable.withString(category['name'] as String? ?? 'Eggs'),
            Variable(_safeDouble(category['sellingPrice']) ?? 0),
            Variable.withInt(category['unitSize'] as int? ?? 30),
          ],
        );
      }
      debugPrint(
        'Pull: synced ${remoteEggCategories.length} egg categories',
      );

      // 7. Pull Feeding Logs (direct table query)
      final remoteFeeds = await _supabase
          .from('daily_feeding_logs')
          .select()
          .eq('farmId', farmIdFilter);
      for (var f in remoteFeeds) {
        await db
            .into(db.feedingLogs)
            .insertOnConflictUpdate(
              FeedingLogsCompanion.insert(
                id: safeIdString(f['id']),
                farmId: farmIdFilter,
                batchId: Value(_safeStr(f['batch_id'] ?? f['batchId'])),
                feedTypeId: Value(
                  _safeStr(f['feed_type_id'] ?? f['feedTypeId']),
                ),
                formulationId: Value(
                  _safeStr(f['formulation_id'] ?? f['formulationId']),
                ),
                amountConsumed: _safeDouble(f['amount_consumed']) ?? 0.0,
                logDate: _safeDateTime(f['log_date']) ?? DateTime.now().toUtc(),
                userId: Value(f['user_id'] as String?),
                synced: const Value(true),
              ),
            );
      }
      debugPrint('Pull: synced ${remoteFeeds.length} feeding logs');

      // 8. Pull Users and Farm Members
      await _syncFarmMembersFromCloud(farmIdFilter);

      // 9. Pull Expenses
      final remoteExpenses = await _supabase
          .from('expenses')
          .select()
          .eq('farmId', farmIdFilter);
      for (var e in remoteExpenses) {
        final description = _safeStr(e['description']);
        await db
            .into(db.expenses)
            .insertOnConflictUpdate(
              ExpensesCompanion.insert(
                id: safeIdString(e['id']),
                farmId: farmIdFilter,
                batchId: Value(_safeStr(e['batch_id'] ?? e['batchId'])),
                supplierId: Value(
                  _safeStr(e['supplierId'] ?? e['supplier_id']),
                ),
                category: e['category'] as String,
                amount: _safeDouble(e['amount']) ?? 0.0,
                date: Value(
                  _safeDateTime(e['expense_date'] ?? e['date']) ??
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
                userId: Value(_safeStr(e['user_id'] ?? e['userId'])),
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
    final remoteSuppliers = await _supabase
        .from('suppliers')
        .select()
        .eq('farmId', farmIdFilter);
    for (var s in remoteSuppliers) {
      await db
          .into(db.customers)
          .insertOnConflictUpdate(
            CustomersCompanion.insert(
              id: safeIdString(s['id']),
              farmId: farmIdFilter,
              name: s['name'] as String,
              phone: Value(_safeStr(s['phone'])),
              email: Value(_safeStr(s['email'])),
              address: Value(_safeStr(s['address'])),
              balanceOwed: Value(_safeDouble(s['balanceOwed']) ?? 0.0),
              customerType: const Value('SUPPLIER'),
              supplyItems: Value(_safeStr(s['supplyItems'])),
              contactPerson: Value(_safeStr(s['contactPerson'])),
              synced: const Value(true),
            ),
          );
    }
    debugPrint('Pull: synced ${remoteSuppliers.length} suppliers');
  }

  Future<void> _syncFeedFormulationsFromCloud(String farmIdFilter) async {
    final remoteFormulations = await _supabase
        .from('feed_formulations')
        .select()
        .eq('farmId', farmIdFilter);
    final formulationIds = <String>[];
    for (final row in remoteFormulations) {
      final id = safeIdString(row['id']);
      formulationIds.add(id);
      await db.into(db.feedFormulations).insertOnConflictUpdate(
        FeedFormulationsCompanion.insert(
          id: id,
          farmId: farmIdFilter,
          name: row['name'] as String,
          notes: Value(_safeStr(row['notes'])),
          type: Value(_safeStr(row['type']) ?? 'CUSTOM'),
          targetLivestock: Value(_safeStr(row['targetLivestock'])),
          stockLevel: Value(_safeDouble(row['stockLevel']) ?? 0),
          createdAt: Value(
            DateTime.tryParse(_safeStr(row['createdAt']) ?? '') ?? DateTime.now(),
          ),
          updatedAt: Value(
            DateTime.tryParse(_safeStr(row['updatedAt']) ?? '') ?? DateTime.now(),
          ),
          synced: const Value(true),
        ),
      );
    }
    debugPrint('Pull: synced ${remoteFormulations.length} feed formulations');

    if (formulationIds.isEmpty) {
      return;
    }

    final remoteIngredients = await _supabase
        .from('feed_formulation_ingredients')
        .select()
        .inFilter('formulationId', formulationIds);
    for (final row in remoteIngredients) {
      await db.into(db.feedFormulationIngredients).insertOnConflictUpdate(
        FeedFormulationIngredientsCompanion.insert(
          id: safeIdString(row['id']),
          formulationId: safeIdString(row['formulationId']),
          inventoryId: safeIdString(row['inventoryId']),
          quantity: _safeDouble(row['quantity']) ?? 0,
          unit: Value(_safeStr(row['unit']) ?? 'bag'),
          synced: const Value(true),
        ),
      );
    }
    debugPrint(
      'Pull: synced ${remoteIngredients.length} feed formulation ingredients',
    );
  }

  Future<void> _pushCustomerContactToCloud(
    Customer c,
    String? webFarmId,
  ) async {
    final id = safeIdString(c.id);
    final existing = await _supabase
        .from('customers')
        .select('id')
        .eq('id', id)
        .maybeSingle();
    final now = DateTime.now().toUtc().toIso8601String();
    final payload = {
      'id': id,
      'farmId': _remoteFarmIdForPush(c.farmId, webFarmId),
      'name': c.name,
      'phone': c.phone,
      'email': c.email,
      'address': c.address,
      'balanceOwed': c.balanceOwed,
      'updatedAt': now,
    };
    assertSyncPayloadUsesStringIds(payload);
    if (existing != null) {
      await _supabase.from('customers').update(payload).eq('id', id);
    } else {
      payload['createdAt'] = now;
      await _supabase.from('customers').insert(payload);
    }
  }

  Future<void> _pushSupplierContactToCloud(
    Customer c,
    String? webFarmId,
  ) async {
    final id = safeIdString(c.id);
    final existing = await _supabase
        .from('suppliers')
        .select('id')
        .eq('id', id)
        .maybeSingle();
    final now = DateTime.now().toUtc().toIso8601String();
    final payload = {
      'id': id,
      'farmId': _remoteFarmIdForPush(c.farmId, webFarmId),
      'name': c.name,
      'phone': c.phone,
      'email': c.email,
      'address': c.address,
      'balanceOwed': c.balanceOwed,
      'updatedAt': now,
    };
    assertSyncPayloadUsesStringIds(payload);
    if (existing != null) {
      await _supabase.from('suppliers').update(payload).eq('id', id);
    } else {
      payload['createdAt'] = now;
      await _supabase.from('suppliers').insert(payload);
    }
  }

  Future<void> _pushSettlementToCloud(
    Settlement s,
    String? webFarmId, {
    required String? Function(String? localUserId) pushUserIdForPayload,
  }) async {
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

    final expenseId = 'stl_${safeIdString(s.id)}';
    final now = DateTime.now().toUtc().toIso8601String();
    final expensePayload = {
      'id': expenseId,
      'farmId': _remoteFarmIdForPush(s.farmId, webFarmId),
      'user_id': pushUserIdForPayload(s.userId),
      'supplierId': customer?.customerType == 'SUPPLIER'
          ? optionalIdString(s.customerId)
          : null,
      'category': _settlementExpenseCategory(s.settlementType),
      'amount': s.amount,
      'expense_date': s.settlementDate.toIso8601String(),
      'description':
          'Settlement ${s.settlementType} (${customer?.customerType == 'SUPPLIER' ? 'supplier' : 'customer'} ${s.customerId})',
      'created_at': now,
      'updated_at': now,
    };
    assertSyncPayloadUsesStringIds(expensePayload);
    final existing = await _supabase
        .from('expenses')
        .select('id')
        .eq('id', expenseId)
        .maybeSingle();
    if (existing != null) {
      await _supabase
          .from('expenses')
          .update(expensePayload)
          .eq('id', expenseId);
    } else {
      await _supabase.from('expenses').insert(expensePayload);
    }
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

  Future<void> _pushHealthSchedules(
    String? webFarmId, {
    required String? Function(String? localUserId) pushUserIdForPayload,
  }) async {
    final pendingVax = await (db.select(
      db.vaccinationSchedules,
    )..where((t) => t.synced.equals(false))).get();
    for (var v in pendingVax) {
      try {
        final id = safeIdString(v.id);
        final existing = await _supabase
            .from('vaccination_schedules')
            .select('id')
            .eq('id', id)
            .maybeSingle();
        final payload = {
          'id': id,
          'farmId': _remoteFarmIdForPush(v.farmId, webFarmId),
          'batchId': safeIdString(v.batchId),
          'vaccineName': v.vaccineName,
          'scheduledDate': v.scheduledDate.toIso8601String(),
          'status': v.status,
          'notes': v.notes,
          'quantity': v.quantity,
          'usageType': v.usageType,
          'unit': v.unit,
        };
        assertSyncPayloadUsesStringIds(payload);
        if (existing != null) {
          await _supabase
              .from('vaccination_schedules')
              .update(payload)
              .eq('id', id);
        } else {
          await _supabase.from('vaccination_schedules').insert(payload);
        }
        await (db.update(db.vaccinationSchedules)
              ..where((t) => t.id.equals(v.id)))
            .write(const VaccinationSchedulesCompanion(synced: Value(true)));
      } catch (e) {
        debugPrint('Vaccination push error: $e');
      }
    }

    final pendingMed = await (db.select(
      db.medicationSchedules,
    )..where((t) => t.synced.equals(false))).get();
    for (var m in pendingMed) {
      try {
        final id = safeIdString(m.id);
        final existing = await _supabase
            .from('medication_schedules')
            .select('id')
            .eq('id', id)
            .maybeSingle();
        final payload = {
          'id': id,
          'farmId': _remoteFarmIdForPush(m.farmId, webFarmId),
          'batchId': safeIdString(m.batchId),
          'medicationName': m.medicationName,
          'scheduledDate': m.scheduledDate.toIso8601String(),
          'status': m.status,
          'notes': m.notes,
          'quantity': m.quantity,
          'usageType': m.usageType,
          'unit': m.unit,
        };
        assertSyncPayloadUsesStringIds(payload);
        if (existing != null) {
          await _supabase
              .from('medication_schedules')
              .update(payload)
              .eq('id', id);
        } else {
          await _supabase.from('medication_schedules').insert(payload);
        }
        await (db.update(db.medicationSchedules)
              ..where((t) => t.id.equals(m.id)))
            .write(const MedicationSchedulesCompanion(synced: Value(true)));
      } catch (e) {
        debugPrint('Medication push error: $e');
      }
    }

    final pendingWeight = await (db.select(
      db.weightRecords,
    )..where((t) => t.synced.equals(false))).get();
    for (var w in pendingWeight) {
      try {
        final id = safeIdString(w.id);
        final existing = await _supabase
            .from('weight_records')
            .select('id')
            .eq('id', id)
            .maybeSingle();
        final payload = {
          'id': id,
          'farmId': _remoteFarmIdForPush(w.farmId, webFarmId),
          'batchId': safeIdString(w.batchId),
          'averageWeight': w.averageWeight,
          'logDate': w.logDate.toIso8601String(),
          'userId': pushUserIdForPayload(w.userId),
        };
        assertSyncPayloadUsesStringIds(payload);
        if (existing != null) {
          await _supabase.from('weight_records').update(payload).eq('id', id);
        } else {
          await _supabase.from('weight_records').insert(payload);
        }
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
        final farmId = _remoteFarmIdForPush(settings.farmId, webFarmId);
        final farm = await (db.select(
          db.farms,
        )..where((t) => t.id.equals(settings.farmId))).getSingleOrNull();
        if (farm != null) {
          await _supabase.from('farms').update({
            'name': farm.name,
            'location': farm.location,
            'capacity': farm.capacity,
            'updatedAt': DateTime.now().toUtc().toIso8601String(),
          }).eq('id', farmId);
        }
        final payload = {
          'id': safeIdString(settings.id),
          'farmId': farmId,
          'currency': settings.currency,
          'eggsPerCrate': settings.eggsPerCrate,
          'eggRecordReminderTime': settings.eggRecordReminderTime,
          'feedRecordReminderTime': settings.feedRecordReminderTime,
          if (settings.growthTargetStandard != null)
            'growth_target_standard': settings.growthTargetStandard,
          'updatedAt': DateTime.now().toUtc().toIso8601String(),
        };
        await _supabase.from('farm_settings').upsert(payload);
        await (db.update(db.farmSettings)
              ..where((t) => t.id.equals(settings.id)))
            .write(const FarmSettingsCompanion(synced: Value(true)));
      } catch (e) {
        debugPrint('Farm settings push error: $e');
      }
    }
  }

  Future<void> _pullHealthSchedules(String farmIdFilter) async {
    final remoteVax = await _supabase
        .from('vaccination_schedules')
        .select()
        .eq('farmId', farmIdFilter);
    for (var v in remoteVax) {
      await db
          .into(db.vaccinationSchedules)
          .insertOnConflictUpdate(
            VaccinationSchedulesCompanion.insert(
              id: safeIdString(v['id']),
              farmId: farmIdFilter,
              batchId: safeIdString(v['batchId']),
              vaccineName: v['vaccineName'] as String,
              scheduledDate:
                  _safeDateTime(v['scheduledDate']) ?? DateTime.now().toUtc(),
              status: Value(v['status'] as String? ?? 'PENDING'),
              notes: Value(v['notes'] as String?),
              quantity: Value(_safeDouble(v['quantity']) ?? 1),
              usageType: Value(v['usageType'] as String?),
              unit: Value(v['unit'] as String?),
              synced: const Value(true),
            ),
          );
    }

    final remoteMed = await _supabase
        .from('medication_schedules')
        .select()
        .eq('farmId', farmIdFilter);
    for (var m in remoteMed) {
      await db
          .into(db.medicationSchedules)
          .insertOnConflictUpdate(
            MedicationSchedulesCompanion.insert(
              id: safeIdString(m['id']),
              farmId: farmIdFilter,
              batchId: safeIdString(m['batchId']),
              medicationName: m['medicationName'] as String,
              scheduledDate:
                  _safeDateTime(m['scheduledDate']) ?? DateTime.now().toUtc(),
              status: Value(m['status'] as String? ?? 'PENDING'),
              notes: Value(m['notes'] as String?),
              quantity: Value(_safeDouble(m['quantity']) ?? 1),
              usageType: Value(m['usageType'] as String?),
              unit: Value(m['unit'] as String?),
              synced: const Value(true),
            ),
          );
    }

    final remoteWeight = await _supabase
        .from('weight_records')
        .select()
        .eq('farmId', farmIdFilter);
    for (var w in remoteWeight) {
      await db
          .into(db.weightRecords)
          .insertOnConflictUpdate(
            WeightRecordsCompanion.insert(
              id: safeIdString(w['id']),
              farmId: farmIdFilter,
              batchId: safeIdString(w['batchId']),
              averageWeight: _safeDouble(w['averageWeight']) ?? 0.0,
              logDate: _safeDateTime(w['logDate']) ?? DateTime.now().toUtc(),
              userId: Value(w['userId'] as String?),
              synced: const Value(true),
            ),
          );
    }
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _reachabilityTimer?.cancel();
    _syncStatusController.close();
    super.dispose();
  }
}
