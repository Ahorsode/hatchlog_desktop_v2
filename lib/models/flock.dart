class Flock {
  final String id;
  final String breed;
  final int initialCount;
  final int currentCount;
  final DateTime hatchDate;
  final String status;

  final int targetDays;
  final double fcr;

  Flock({
    required this.id,
    required this.breed,
    required this.initialCount,
    required this.currentCount,
    required this.hatchDate,
    required this.status,
    this.targetDays = 42,
    this.fcr = 1.6,
  });

  int get mortality => initialCount - currentCount;
  
  double get mortalityRate {
    if (initialCount <= 0) return 0.0;
    return (mortality / initialCount) * 100.0;
  }
  
  int get currentAgeDays {
    return DateTime.now().difference(hatchDate).inDays;
  }
}
