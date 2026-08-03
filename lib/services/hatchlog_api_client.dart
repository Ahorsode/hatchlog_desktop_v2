import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class HatchlogApiClient {
  HatchlogApiClient({String? baseUrl, http.Client? httpClient})
    : _baseUrl = _normalize(
        baseUrl ?? dotenv.env['HATCHLOG_API_URL'] ?? '',
      ),
      _http = httpClient ?? http.Client();

  final String _baseUrl;
  final http.Client _http;

  static const nestSupportedEntityTypes = {
    'egg_collection',
    'feed_usage',
    'mortality',
  };

  bool get isConfigured => _baseUrl.isNotEmpty;

  bool supportsEntityType(String entityType) =>
      nestSupportedEntityTypes.contains(entityType);

  Future<bool> canReach() async {
    if (!isConfigured) return false;
    try {
      final response = await _http
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode < 500;
    } catch (e) {
      debugPrint('[HatchlogApi] health check failed: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> push({
    required String farmId,
    required List<Map<String, dynamic>> mutations,
  }) async {
    return _requestJson(
      method: 'POST',
      path: '/api/v1/sync/push',
      body: {
        'sync_protocol_version': 1,
        'farm_id': farmId,
        'mutations': mutations,
      },
    );
  }

  Future<Map<String, dynamic>> pull({
    required String farmId,
    String? since,
    int limit = 200,
  }) async {
    return _requestJson(
      method: 'GET',
      path: '/api/v1/sync/pull',
      query: {
        'farm_id': farmId,
        'limit': '$limit',
        if (since != null && since.isNotEmpty) 'since': since,
      },
    );
  }

  Future<Map<String, dynamic>> status({required String farmId}) async {
    return _requestJson(
      method: 'GET',
      path: '/api/v1/sync/status',
      query: {'farm_id': farmId},
    );
  }

  // Domain REST — Nest /api/v1/* with farm_id query
  Future<Map<String, dynamic>> getMe() =>
      _requestJsonUnwrap(method: 'GET', path: '/api/v1/me');

  Future<List<dynamic>> listFarms() =>
      _requestList(method: 'GET', path: '/api/v1/farms');

  Future<List<dynamic>> listLivestock(String farmId) => _requestList(
        method: 'GET',
        path: '/api/v1/livestock',
        query: {'farm_id': farmId},
      );

  Future<Map<String, dynamic>> createLivestock(Map<String, dynamic> body) =>
      _requestJsonUnwrap(method: 'POST', path: '/api/v1/livestock', body: body);

  Future<Map<String, dynamic>> updateLivestock(
    String id,
    Map<String, dynamic> body,
  ) =>
      _requestJsonUnwrap(
        method: 'PATCH',
        path: '/api/v1/livestock/$id',
        body: body,
      );

  Future<Map<String, dynamic>> deleteLivestock(String id, String reason) =>
      _requestJsonUnwrap(
        method: 'DELETE',
        path: '/api/v1/livestock/$id',
        body: {'reason': reason},
      );

  Future<Map<String, dynamic>> getLivestockDetails(
    String id,
    String farmId,
  ) =>
      _requestJsonUnwrap(
        method: 'GET',
        path: '/api/v1/livestock/$id/details',
        query: {'farm_id': farmId},
      );

  Future<List<dynamic>> listHouses(String farmId) => _requestList(
        method: 'GET',
        path: '/api/v1/houses',
        query: {'farm_id': farmId},
      );

  Future<Map<String, dynamic>> createHouse(Map<String, dynamic> body) =>
      _requestJsonUnwrap(method: 'POST', path: '/api/v1/houses', body: body);

  Future<Map<String, dynamic>> updateHouse(
    String id,
    Map<String, dynamic> body,
  ) =>
      _requestJsonUnwrap(
        method: 'PATCH',
        path: '/api/v1/houses/$id',
        body: body,
      );

  Future<Map<String, dynamic>> deleteHouse(String id) =>
      _requestJsonUnwrap(method: 'DELETE', path: '/api/v1/houses/$id');

  Future<List<dynamic>> listEggs(String farmId) => _requestList(
        method: 'GET',
        path: '/api/v1/eggs',
        query: {'farm_id': farmId},
      );

  Future<Map<String, dynamic>> createEgg(Map<String, dynamic> body) =>
      _requestJsonUnwrap(method: 'POST', path: '/api/v1/eggs', body: body);

  Future<Map<String, dynamic>> updateEgg(
    String id,
    Map<String, dynamic> body,
  ) =>
      _requestJsonUnwrap(
        method: 'PATCH',
        path: '/api/v1/eggs/$id',
        body: body,
      );

  Future<Map<String, dynamic>> deleteEgg(String id) =>
      _requestJsonUnwrap(method: 'DELETE', path: '/api/v1/eggs/$id');

  Future<List<dynamic>> listFeeding(String farmId) => _requestList(
        method: 'GET',
        path: '/api/v1/feeding',
        query: {'farm_id': farmId},
      );

  Future<Map<String, dynamic>> createFeeding(Map<String, dynamic> body) =>
      _requestJsonUnwrap(
        method: 'POST',
        path: '/api/v1/feeding',
        body: body,
      );

  Future<Map<String, dynamic>> updateFeeding(
    String id,
    Map<String, dynamic> body,
  ) =>
      _requestJsonUnwrap(
        method: 'PATCH',
        path: '/api/v1/feeding/$id',
        body: body,
      );

  Future<Map<String, dynamic>> deleteFeeding(String id) =>
      _requestJsonUnwrap(method: 'DELETE', path: '/api/v1/feeding/$id');

  Future<List<dynamic>> listMortality(String farmId) => _requestList(
        method: 'GET',
        path: '/api/v1/mortality',
        query: {'farm_id': farmId},
      );

  Future<Map<String, dynamic>> createMortality(Map<String, dynamic> body) =>
      _requestJsonUnwrap(
        method: 'POST',
        path: '/api/v1/mortality',
        body: body,
      );

  Future<Map<String, dynamic>> updateMortality(
    String id,
    Map<String, dynamic> body,
  ) =>
      _requestJsonUnwrap(
        method: 'PATCH',
        path: '/api/v1/mortality/$id',
        body: body,
      );

  Future<Map<String, dynamic>> deleteMortality(String id) =>
      _requestJsonUnwrap(method: 'DELETE', path: '/api/v1/mortality/$id');

  // --- Commerce / finance / health (Nest domain REST) ---

  Future<List<dynamic>> listInventory(String farmId) => _requestList(
        method: 'GET',
        path: '/api/v1/inventory',
        query: {'farm_id': farmId},
      );

  Future<Map<String, dynamic>> createInventory(Map<String, dynamic> body) =>
      _requestJsonUnwrap(
        method: 'POST',
        path: '/api/v1/inventory',
        body: body,
      );

  Future<Map<String, dynamic>> updateInventory(
    String id,
    Map<String, dynamic> body,
  ) =>
      _requestJsonUnwrap(
        method: 'PATCH',
        path: '/api/v1/inventory/$id',
        body: body,
      );

  Future<Map<String, dynamic>> deleteInventory(
    String id,
    String farmId, {
    String? reason,
  }) =>
      _requestJsonUnwrap(
        method: 'DELETE',
        path: '/api/v1/inventory/$id',
        query: {'farm_id': farmId},
        body: {if (reason != null && reason.isNotEmpty) 'reason': reason},
      );

  Future<List<dynamic>> listCustomers(String farmId) => _requestList(
        method: 'GET',
        path: '/api/v1/customers',
        query: {'farm_id': farmId},
      );

  Future<Map<String, dynamic>> createCustomer(Map<String, dynamic> body) =>
      _requestJsonUnwrap(
        method: 'POST',
        path: '/api/v1/customers',
        body: body,
      );

  Future<Map<String, dynamic>> updateCustomer(
    String id,
    Map<String, dynamic> body,
  ) =>
      _requestJsonUnwrap(
        method: 'PATCH',
        path: '/api/v1/customers/$id',
        body: body,
      );

  Future<Map<String, dynamic>> deleteCustomer(String id, String farmId) =>
      _requestJsonUnwrap(
        method: 'DELETE',
        path: '/api/v1/customers/$id',
        query: {'farm_id': farmId},
      );

  Future<List<dynamic>> listSuppliers(String farmId) => _requestList(
        method: 'GET',
        path: '/api/v1/suppliers',
        query: {'farm_id': farmId},
      );

  Future<Map<String, dynamic>> createSupplier(Map<String, dynamic> body) =>
      _requestJsonUnwrap(
        method: 'POST',
        path: '/api/v1/suppliers',
        body: body,
      );

  Future<Map<String, dynamic>> updateSupplier(
    String id,
    Map<String, dynamic> body,
  ) =>
      _requestJsonUnwrap(
        method: 'PATCH',
        path: '/api/v1/suppliers/$id',
        body: body,
      );

  Future<List<dynamic>> listSales(String farmId) => _requestList(
        method: 'GET',
        path: '/api/v1/sales',
        query: {'farm_id': farmId},
      );

  Future<Map<String, dynamic>> createSale(Map<String, dynamic> body) =>
      _requestJsonUnwrap(method: 'POST', path: '/api/v1/sales', body: body);

  Future<Map<String, dynamic>> deleteSale(
    String id,
    String farmId, {
    String? reason,
  }) =>
      _requestJsonUnwrap(
        method: 'DELETE',
        path: '/api/v1/sales/$id',
        query: {'farm_id': farmId},
        body: {if (reason != null && reason.isNotEmpty) 'reason': reason},
      );

  Future<List<dynamic>> listExpenses(String farmId) => _requestList(
        method: 'GET',
        path: '/api/v1/expenses',
        query: {'farm_id': farmId},
      );

  Future<Map<String, dynamic>> createExpense(Map<String, dynamic> body) =>
      _requestJsonUnwrap(
        method: 'POST',
        path: '/api/v1/expenses',
        body: body,
      );

  Future<Map<String, dynamic>> deleteExpense(
    String id,
    String farmId, {
    String reason = 'Deleted from desktop sync',
  }) =>
      _requestJsonUnwrap(
        method: 'DELETE',
        path: '/api/v1/expenses/$id',
        body: {'farm_id': farmId, 'reason': reason},
      );

  Future<List<dynamic>> listIsolationRooms(String farmId) => _requestList(
        method: 'GET',
        path: '/api/v1/isolation-rooms',
        query: {'farm_id': farmId},
      );

  Future<Map<String, dynamic>> createIsolationRoom(
    Map<String, dynamic> body,
  ) =>
      _requestJsonUnwrap(
        method: 'POST',
        path: '/api/v1/isolation-rooms',
        body: body,
      );

  Future<Map<String, dynamic>> listHealthSchedules(String farmId) =>
      _requestJsonUnwrap(
        method: 'GET',
        path: '/api/v1/health-schedules',
        query: {'farm_id': farmId},
      );

  Future<Map<String, dynamic>> createHealthSchedules(
    Map<String, dynamic> body,
  ) =>
      _requestJsonUnwrap(
        method: 'POST',
        path: '/api/v1/health-schedules',
        body: body,
      );

  Future<List<dynamic>> listHealthInventory(String farmId) => _requestList(
        method: 'GET',
        path: '/api/v1/health-inventory',
        query: {'farm_id': farmId},
      );

  Future<Map<String, dynamic>> createWeightRecord(
    String batchId,
    Map<String, dynamic> body,
  ) =>
      _requestJsonUnwrap(
        method: 'POST',
        path: '/api/v1/livestock/$batchId/weight',
        body: body,
      );

  Future<Map<String, dynamic>> getFarmSettings(String farmId) =>
      _requestJsonUnwrap(
        method: 'GET',
        path: '/api/v1/farms/$farmId/settings',
      );

  Future<Map<String, dynamic>> updateFarm(
    String farmId,
    Map<String, dynamic> body,
  ) =>
      _requestJsonUnwrap(
        method: 'PATCH',
        path: '/api/v1/farms/$farmId',
        body: body,
      );

  Future<Map<String, dynamic>> updateFarmSettings(
    String farmId,
    Map<String, dynamic> body,
  ) =>
      _requestJsonUnwrap(
        method: 'PATCH',
        path: '/api/v1/farms/$farmId/settings',
        body: body,
      );

  Future<List<dynamic>> listLedger(String farmId) => _requestList(
        method: 'GET',
        path: '/api/v1/ledger',
        query: {'farm_id': farmId},
      );

  Future<Map<String, dynamic>> createLedgerTransaction(
    Map<String, dynamic> body,
  ) =>
      _requestJsonUnwrap(method: 'POST', path: '/api/v1/ledger', body: body);

  Future<List<dynamic>> listEggCategories(String farmId) => _requestList(
        method: 'GET',
        path: '/api/v1/egg-categories',
        query: {'farm_id': farmId},
      );

  Future<Map<String, dynamic>> createEggCategory(Map<String, dynamic> body) =>
      _requestJsonUnwrap(
        method: 'POST',
        path: '/api/v1/egg-categories',
        body: body,
      );

  Future<Map<String, dynamic>> listTrash(String farmId) => _requestJsonUnwrap(
        method: 'GET',
        path: '/api/v1/trash',
        query: {'farm_id': farmId},
      );

  Future<Map<String, dynamic>> restoreTrashItem({
    required String table,
    required String id,
    required String farmId,
  }) =>
      _requestJsonUnwrap(
        method: 'POST',
        path: '/api/v1/trash/$table/$id/restore',
        query: {'farm_id': farmId},
      );

  Future<List<dynamic>> listAuditInsertLogs(String farmId) => _requestList(
        method: 'GET',
        path: '/api/v1/audit/insert-logs',
        query: {'farm_id': farmId},
      );

  Future<List<dynamic>> listAuditDeleteLogs(String farmId) => _requestList(
        method: 'GET',
        path: '/api/v1/audit/delete-logs',
        query: {'farm_id': farmId},
      );

  Future<List<dynamic>> listAuditEditLogs(String farmId) => _requestList(
        method: 'GET',
        path: '/api/v1/audit/edit-logs',
        query: {'farm_id': farmId},
      );

  Future<List<dynamic>> listFeedFormulations(String farmId) => _requestList(
        method: 'GET',
        path: '/api/v1/feeding/feed-formulations',
        query: {'farm_id': farmId},
      );

  Future<Map<String, dynamic>> createFeedFormulation(
    Map<String, dynamic> body,
  ) =>
      _requestJsonUnwrap(
        method: 'POST',
        path: '/api/v1/feeding/feed-formulations',
        body: body,
      );

  Future<Map<String, dynamic>> deleteFeedFormulation(
    String id,
    String farmId,
  ) =>
      _requestJsonUnwrap(
        method: 'DELETE',
        path: '/api/v1/feeding/feed-formulations/$id',
        query: {'farm_id': farmId},
      );

  Future<bool> pushMutation({
    required String farmId,
    required String clientId,
    required String entityType,
    required Map<String, dynamic> payload,
    String op = 'upsert',
  }) async {
    final result = await push(
      farmId: farmId,
      mutations: [
        {
          'client_id': clientId,
          'entity_type': entityType,
          'op': op,
          'payload': payload,
          'client_updated_at': DateTime.now().toUtc().toIso8601String(),
        },
      ],
    );
    final results = (result['results'] as List?) ?? const [];
    if (results.isEmpty) return false;
    final first = Map<String, dynamic>.from(results.first as Map);
    return first['status']?.toString() == 'accepted';
  }

  Future<List<dynamic>> _requestList({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    final raw = await _requestJson(
      method: method,
      path: path,
      body: body,
      query: query,
    );
    if (raw['success'] == false) {
      throw StateError(
        (raw['error'] is Map ? raw['error']['message'] : null)?.toString() ??
            'HatchLog API request failed',
      );
    }
    final data = raw.containsKey('data') ? raw['data'] : raw;
    if (data is List) return data;
    if (data is Map && data['items'] is List) return data['items'] as List;
    return const [];
  }

  Future<Map<String, dynamic>> _requestJsonUnwrap({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    final raw = await _requestJson(
      method: method,
      path: path,
      body: body,
      query: query,
    );
    return _unwrapEnvelope(raw);
  }

  static Map<String, dynamic> _unwrapEnvelope(Map<String, dynamic> raw) {
    if (raw['success'] == false) {
      throw StateError(
        (raw['error'] is Map ? raw['error']['message'] : null)?.toString() ??
            'HatchLog API request failed',
      );
    }
    if (raw.containsKey('success') && raw.containsKey('data')) {
      final data = raw['data'];
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return raw;
    }
    return raw;
  }

  Future<Map<String, dynamic>> _requestJson({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    if (!isConfigured) {
      throw StateError('HATCHLOG_API_URL is not configured');
    }
    final token = await _requireAccessToken();
    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: query);
    final headers = <String, String>{
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
    };

    late http.Response response;
    switch (method) {
      case 'GET':
        response = await _http.get(uri, headers: headers);
      case 'POST':
        response = await _http.post(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        );
      case 'PATCH':
        response = await _http.patch(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        );
      case 'DELETE':
        response = await _http.delete(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        );
      default:
        throw UnsupportedError(method);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint(
        '[HatchlogApi] $method $path failed '
        '(${response.statusCode}): ${response.body}',
      );
      throw StateError(
        'HatchLog API $method $path failed with ${response.statusCode}',
      );
    }
    if (response.body.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(response.body);
    return Map<String, dynamic>.from(decoded as Map);
  }

  Future<String> _requireAccessToken() async {
    var session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      final refreshed = await Supabase.instance.client.auth.refreshSession();
      session = refreshed.session;
    }
    final token = session?.accessToken;
    if (token == null || token.isEmpty) {
      throw StateError('No Supabase access token available for HatchLog API');
    }
    return token;
  }

  static String _normalize(String value) {
    final trimmed = value.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }
}
