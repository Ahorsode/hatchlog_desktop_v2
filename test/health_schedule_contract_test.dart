import 'package:flutter_test/flutter_test.dart';
import 'package:poultry_pms_desktop/utils/health_constants.dart';

void main() {
  group('health schedule contract', () {
    test('normalizeHealthUsageType defaults to one-time', () {
      expect(normalizeHealthUsageType(null), HealthUsageType.oneTime);
      expect(normalizeHealthUsageType('QUANTITY'), HealthUsageType.quantity);
    });

    test('healthScheduleStatuses match web lifecycle', () {
      expect(healthScheduleStatuses, ['PENDING', 'COMPLETED', 'CANCELLED']);
    });
  });
}
