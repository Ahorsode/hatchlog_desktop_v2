import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Custom in-memory storage for test context
class MockLocalStorage extends LocalStorage {
  final Map<String, String> _storage = {};

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> accessToken() async => _storage['supabase_access_token'];

  @override
  Future<bool> hasAccessToken() async => _storage.containsKey('supabase_access_token');

  @override
  Future<void> persistSession(String persistSessionString) async {
    _storage['supabase_access_token'] = persistSessionString;
  }

  @override
  Future<void> removePersistedSession() async {
    _storage.remove('supabase_access_token');
  }
}

void main() {
  test('Query Supabase Logs', () async {
    // Mock shared preferences
    SharedPreferences.setMockInitialValues({});

    print("Loading .env file...");
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      print("Error loading .env: $e");
      return;
    }

    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

    print("Supabase URL: $url");
    print("Initializing Supabase...");
    
    await Supabase.initialize(
      url: url!,
      anonKey: anonKey!,
      authOptions: FlutterAuthClientOptions(
        localStorage: MockLocalStorage(),
      ),
    );

    final supabase = Supabase.instance.client;

    print("Fetching audit_logs...");
    try {
      final response = await supabase
          .from('audit_logs')
          .select('*')
          .limit(10);
      print("Fetched audit_logs successfully!");
      print("Count: ${response.length}");
      print("Data: $response");
    } catch (e) {
      print("Error fetching audit_logs: $e");
    }

    print("Fetching delete_logs...");
    try {
      final response = await supabase
          .from('delete_logs')
          .select('*')
          .limit(10);
      print("Fetched delete_logs successfully!");
      print("Count: ${response.length}");
      print("Data: $response");
    } catch (e) {
      print("Error fetching delete_logs: $e");
    }
  });
}
