import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final env = await _loadEnv(File('.env'));
  final url = (env['SUPABASE_URL'] ?? '').replaceAll(RegExp(r'/$'), '');
  final anonKey = env['SUPABASE_ANON_KEY'] ?? '';
  if (url.isEmpty || anonKey.isEmpty) { stderr.writeln('Missing env'); exit(1); }
  final candidates = [
    '_prisma_migrations','accounts','audit_logs','batches','customers',
    'daily_feeding_logs','delete_logs','device_registrations','egg_categories',
    'egg_production','expenses','farm_members','farm_settings','farms',
    'feed_formulation_ingredients','feed_formulations','feed_types','growth_standards',
    'health_records','houses','inventory','invitations','medication_schedules',
    'mortality','order_items','orders','sale_items','sales','sessions',
    'settlements','stock_logs','subscription_plans','subscriptions','suppliers',
    'user_permissions','users','vaccination_schedules','verification_tokens','weight_records',
  ];
  final client = HttpClient();
  final existing = <String>[];
  final denied = <String>[];
  for (final table in candidates) {
    final uri = Uri.parse('$url/rest/v1/$table?select=*&limit=0');
    final request = await client.getUrl(uri);
    request.headers.set('apikey', anonKey);
    request.headers.set('Authorization', 'Bearer $anonKey');
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode == 200 || response.statusCode == 206) {
      existing.add(table);
    } else if (response.statusCode == 401 || response.statusCode == 403 ||
        (response.statusCode == 400 && body.contains('permission denied'))) {
      denied.add(table);
    }
  }
  client.close(force: true);
  existing.sort(); denied.sort();
  print('EXISTING (${existing.length}):');
  for (final t in existing) {
    print('  $t');
  }
  print('RLS_OR_AUTH (${denied.length}):');
  for (final t in denied) {
    print('  $t');
  }
}

Future<Map<String, String>> _loadEnv(File file) async {
  final map = <String, String>{};
  if (!await file.exists()) return map;
  for (final line in await file.readAsLines()) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final eq = trimmed.indexOf('=');
    if (eq <= 0) continue;
    var value = trimmed.substring(eq + 1).trim();
    if (value.startsWith('"') && value.endsWith('"')) value = value.substring(1, value.length - 1);
    map[trimmed.substring(0, eq).trim()] = value;
  }
  return map;
}