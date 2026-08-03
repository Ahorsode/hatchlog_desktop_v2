import 'package:flutter_test/flutter_test.dart';
import 'package:poultry_pms_desktop/utils/growth_utils.dart';
import 'package:poultry_pms_desktop/utils/livestock_breed_options.dart';

void main() {
  test('normalizeBreedKey aligns with web livestock-breed-options', () {
    expect(
      LivestockBreedCatalog.normalizeBreedKey('Ross 308'),
      'ross_308',
    );
    expect(
      LivestockBreedCatalog.normalizeBreedKey('ndama_brown_cross'),
      'ndama_brown_crosses',
    );
  });

  test('calculateGrowthPerformance returns status from benchmark', () {
    final result = calculateGrowthPerformance(
      hatchDate: DateTime.now().subtract(const Duration(days: 21)),
      currentWeight: 0.60,
    );

    expect(result, isNotNull);
    expect(result!.status, GrowthStatus.critical);
  });
}
