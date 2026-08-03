// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final env = await _loadEnv(File('.env'));
  final url = (env['SUPABASE_URL'] ?? '').replaceAll(RegExp(r'/$'), '');
  final anonKey = env['SUPABASE_ANON_KEY'] ?? '';
  if (url.isEmpty || anonKey.isEmpty) {
    stderr.writeln('Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env');
    exit(1);
  }

  const tables = [
    ('farms', 'id'),
    ('houses', 'id,farmId'),
    ('batches', 'id,farmId,houseId'),
    ('inventory', 'id,farmId,supplierId'),
    ('mortality', 'id,farmId,batchId'),
    ('daily_feeding_logs', 'id,farmId,batch_id'),
    ('egg_production', 'id,farmId,batchId'),
    ('customers', 'id,farmId'),
    ('expenses', 'id,farmId'),
    ('feed_formulations', 'id,farmId'),
    ('vaccination_schedules', 'id,farmId,batchId'),
    ('medication_schedules', 'id,farmId,batchId'),
    ('weight_records', 'id,farmId,batchId'),
    ('device_registrations', 'id,farm_id,licenseKey'),
  ];

  final client = HttpClient();
  final mismatches = <String>[];
  var checked = 0;

  for (final entry in tables) {
    final table = entry.$1;
    final select = entry.$2;
    final uri = Uri.parse('$url/rest/v1/$table?select=$select&limit=1');
    final request = await client.getUrl(uri);
    request.headers.set('apikey', anonKey);
    request.headers.set('Authorization', 'Bearer $anonKey');
    request.headers.set('Accept', 'application/json');

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode >= 400) {
      mismatches.add('$table: HTTP ${response.statusCode} $body');
      continue;
    }

    final rows = jsonDecode(body) as List<dynamic>;
    if (rows.isEmpty) {
      print('OK (empty) $table');
      continue;
    }

    checked++;
    final row = rows.first as Map<String, dynamic>;
    for (final col in select.split(',')) {
      final value = row[col];
      if (value == null) continue;
      if (value is! String) {
        mismatches.add('$table.$col is ${value.runtimeType} ($value)');
      }
    }
    if (!mismatches.any((m) => m.startsWith(table))) {
      print('OK $table');
    }
  }

  client.close(force: true);
  print('Checked $checked tables with data.');
  if (mismatches.isNotEmpty) {
    stderr.writeln('SCHEMA MISMATCH:');
    for (final m in mismatches) {
      stderr.writeln('  - $m');
    }
    exit(2);
  }
  print('All cloud id columns are string-compatible with local SQLite v15.');
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
    if (value.startsWith('"') && value.endsWith('"')) {
      value = value.substring(1, value.length - 1);
    }
    map[trimmed.substring(0, eq).trim()] = value;
  }
  return map;
}
