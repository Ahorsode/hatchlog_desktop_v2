import 'package:flutter_test/flutter_test.dart';
import 'package:poultry_pms_desktop/utils/egg_log_utils.dart';

void main() {
  test('calculateEggsCollected uses crate math with remainder cap', () {
    expect(
      calculateEggsCollected(useCrates: true, crates: 1, remainder: 29),
      59,
    );
    expect(
      calculateEggsCollected(useCrates: true, crates: 1, remainder: 35),
      59,
    );
  });

  test('validateEggLog rejects over-allocation and unusable overflow', () {
    expect(
      validateEggLog(
        eggsCollected: 60,
        unusableCount: 2,
        isSorted: true,
        smallCount: 20,
        mediumCount: 20,
        largeCount: 25,
      ),
      isNotNull,
    );

    expect(
      validateEggLog(
        eggsCollected: 60,
        unusableCount: 60,
        isSorted: false,
        smallCount: 0,
        mediumCount: 0,
        largeCount: 0,
      ),
      isNull,
    );
  });

  test('normalizeQualityGrade maps labels to web enum values', () {
    expect(normalizeQualityGrade('Small'), 'SMALL');
    expect(normalizeQualityGrade('large'), 'LARGE');
    expect(normalizeQualityGrade(null), 'MEDIUM');
  });

  test('formatCrateDisplay renders crate and remainder', () {
    expect(formatCrateDisplay(65), '2 crates / 5');
    expect(formatCrateDisplay(30), '1 crate / 0');
  });
}
