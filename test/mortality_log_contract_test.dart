import 'package:flutter_test/flutter_test.dart';
import 'package:poultry_pms_desktop/utils/mortality_log_utils.dart';

void main() {
  test('resolveSubCategory handles Unknown category', () {
    expect(
      resolveSubCategory(category: 'Unknown', subCategory: 'Anything'),
      'Unknown cause yet',
    );
    expect(
      resolveSubCategory(category: 'Disease', subCategory: 'Coccidiosis'),
      'Coccidiosis',
    );
  });

  test('buildHealthLogPayload includes type and isolation room for sick logs', () {
    final payload = buildHealthLogPayload(
      batchId: 'batch-9',
      count: 5,
      healthType: 'SICK',
      category: 'Disease',
      subCategory: 'Coccidiosis',
      reason: 'Lethargy and droopy wings',
      isolationRoomId: 'room-a',
      logDate: DateTime.utc(2026, 7, 1),
    );

    expect(payload['health_type'], 'SICK');
    expect(payload['type'], 'SICK');
    expect(payload['category'], 'Disease');
    expect(payload['sub_category'], 'Coccidiosis');
    expect(payload['reason'], 'Lethargy and droopy wings');
    expect(payload['isolation_room_id'], 'room-a');
  });

  test('legacy isolation rows classify as sick not dead', () {
    expect(
      isSickMortalityRecord(
        healthType: 'DEAD',
        category: legacyIsolationCategory,
      ),
      isTrue,
    );
    expect(
      isDeadMortalityRecord(
        healthType: 'DEAD',
        category: legacyIsolationCategory,
      ),
      isFalse,
    );
  });
}
