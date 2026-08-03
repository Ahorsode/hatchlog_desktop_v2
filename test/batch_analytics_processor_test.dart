import 'package:flutter_test/flutter_test.dart';
import 'package:poultry_pms_desktop/services/batch_analytics_processor.dart';

void main() {
  group('batch analytics processor calculations', () {
    test('layer FCR uses egg output denominator', () {
      expect(
        calculateBatchFeedConversionRatio(
          livestockType: 'POULTRY_LAYER',
          totalFeed: 160,
          eggOutput: 100,
          birdBiomassGain: 0,
        ),
        1.6,
      );
    });

    test('broiler FCR uses biomass gain denominator', () {
      expect(
        calculateBatchFeedConversionRatio(
          livestockType: 'POULTRY_BROILER',
          totalFeed: 180,
          eggOutput: 0,
          birdBiomassGain: 100,
        ),
        1.8,
      );
    });

    test('mortality rate is dead birds over initial population', () {
      expect(
        calculateBatchMortalityRatePercentage(
          totalDeadBirds: 35,
          initialPopulation: 1000,
        ),
        3.5,
      );
    });
  });
}
