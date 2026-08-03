import 'package:drift/drift.dart';

import '../data/local_db.dart';

class SeatLimitCheck {
  const SeatLimitCheck({
    required this.canAdd,
    required this.limit,
    required this.current,
  });

  final bool canAdd;
  final int limit;
  final int current;

  bool get isUnlimited => limit >= 1000;
}

int workerLimitForTier(String? tier) {
  switch ((tier ?? 'BASIC').trim().toUpperCase()) {
    case 'PREMIUM':
      return 1000;
    case 'STANDARD':
      return 5;
    case 'BASIC':
    case 'FREE':
    default:
      return 2;
  }
}

Future<SeatLimitCheck> checkSeatLimit(AppDatabase db, String farmId) async {
  final farm = await (db.select(db.farms)..where((f) => f.id.equals(farmId)))
      .getSingleOrNull();
  final limit = workerLimitForTier(farm?.subscriptionTier);

  final members = await (db.select(db.farmMembers)
        ..where((m) => m.farmId.equals(farmId)))
      .get();
  final nonOwnerMembers =
      members.where((m) => m.role.toUpperCase() != 'OWNER').length;

  final pendingProfiles = await (db.select(db.profiles)
        ..where(
          (p) => p.farmId.equals(farmId) & p.status.equals('PENDING'),
        ))
      .get();

  final current = nonOwnerMembers + pendingProfiles.length;
  return SeatLimitCheck(
    canAdd: current < limit,
    limit: limit,
    current: current,
  );
}
