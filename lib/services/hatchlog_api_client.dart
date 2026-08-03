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
    if (method == 'GET') {
      response = await _http.get(uri, headers: headers);
    } else if (method == 'POST') {
      response = await _http.post(
        uri,
        headers: headers,
        body: body == null ? null : jsonEncode(body),
      );
    } else {
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
