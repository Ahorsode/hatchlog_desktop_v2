/// Growth performance helpers — mirrors web `growth-utils.ts`.
class GrowthPerformance {
  const GrowthPerformance({
    required this.days,
    required this.currentWeight,
    required this.targetWeight,
    required this.weightGap,
    required this.weightPerformance,
    required this.status,
  });

  final int days;
  final double currentWeight;
  final double targetWeight;
  final double weightGap;
  final double weightPerformance;
  final GrowthStatus status;
}

enum GrowthStatus { optimal, deviated, critical }

class GrowthStandard {
  const GrowthStandard({required this.ageInDays, required this.targetWeight});

  final int ageInDays;
  final double targetWeight;
}

/// Broiler benchmark curve (kg) aligned with common Ross 308 targets.
const List<GrowthStandard> defaultBroilerStandards = [
  GrowthStandard(ageInDays: 0, targetWeight: 0.045),
  GrowthStandard(ageInDays: 7, targetWeight: 0.18),
  GrowthStandard(ageInDays: 14, targetWeight: 0.45),
  GrowthStandard(ageInDays: 21, targetWeight: 0.85),
  GrowthStandard(ageInDays: 28, targetWeight: 1.35),
  GrowthStandard(ageInDays: 35, targetWeight: 1.95),
  GrowthStandard(ageInDays: 42, targetWeight: 2.55),
];

GrowthPerformance? calculateGrowthPerformance({
  required DateTime hatchDate,
  required double currentWeight,
  List<GrowthStandard> standards = defaultBroilerStandards,
}) {
  final days = DateTime.now().difference(hatchDate).inDays;
  if (days < 0 || currentWeight <= 0 || standards.isEmpty) return null;

  final closest = standards.reduce(
    (a, b) =>
        (a.ageInDays - days).abs() <= (b.ageInDays - days).abs() ? a : b,
  );

  final targetWeight = closest.targetWeight;
  if (targetWeight <= 0) return null;

  final weightGap = currentWeight - targetWeight;
  final weightPerformance = (currentWeight / targetWeight) * 100;

  GrowthStatus status = GrowthStatus.optimal;
  if (weightPerformance < 90) status = GrowthStatus.deviated;
  if (weightPerformance < 80) status = GrowthStatus.critical;

  return GrowthPerformance(
    days: days,
    currentWeight: currentWeight,
    targetWeight: targetWeight,
    weightGap: weightGap,
    weightPerformance: weightPerformance,
    status: status,
  );
}

String formatLivestockType(String? type) {
  if (type == null || type.trim().isEmpty) return 'Unknown';
  return type
      .replaceAll('_', ' ')
      .toLowerCase()
      .split(' ')
      .map(
        (word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');
}
