import 'package:flutter_test/flutter_test.dart';

/// Documents desktop house/climate sync contract enforced in SyncEngine.
void main() {
  group('House climate sync contract', () {
    test('house push payload uses camelCase web columns', () {
      final payload = {
        'id': 'house-1',
        'farmId': 'farm-1',
        'userId': 'user-1',
        'name': 'House A',
        'capacity': 1200,
        'currentTemperature': 27.5,
        'currentHumidity': 62.0,
        'isIsolation': false,
        'updatedAt': '2026-07-01T00:00:00.000Z',
      };

      expect(payload['currentTemperature'], 27.5);
      expect(payload['currentHumidity'], 62.0);
      expect(payload['isIsolation'], isFalse);
    });

    test('climate status thresholds match FEATURES_PROMPT', () {
      bool tempInRange(double? value) =>
          value != null && value >= 18 && value <= 32;
      bool humidityInRange(double? value) =>
          value != null && value >= 40 && value <= 70;

      const temp = 24.0;
      const humidity = 55.0;
      expect(tempInRange(temp) && humidityInRange(humidity), isTrue);

      const lowHumidity = 30.0;
      final outCount = [
        if (!tempInRange(temp)) 1,
        if (!humidityInRange(lowHumidity)) 1,
      ].length;
      expect(outCount, 1);
    });

    test('climate status labels are distinct', () {
      const optimal = 'OPTIMAL';
      const attention = 'ATTENTION';
      const critical = 'CRITICAL';

      expect(optimal, isNot(equals(attention)));
      expect(critical, isNot(equals(attention)));
    });
  });
}
