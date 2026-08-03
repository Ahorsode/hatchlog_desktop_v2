import 'package:flutter_test/flutter_test.dart';

// Flutter test binding blocks real HTTP (always 400). Use:
//   dart run tool/check_cloud_schema.dart
void main() {
  test('cloud schema check runs via tool/check_cloud_schema.dart', () {
    expect(true, isTrue);
  }, skip: 'Use: dart run tool/check_cloud_schema.dart for live Supabase');
}
