/// Represents a level in the faith journey progression
enum JourneyStage {
  wilderness,
  desert,
  jordan,
  canaan,
  jerusalem,
  promisedLand;

  String get displayName {
    switch (this) {
      case JourneyStage.wilderness:
        return 'Wilderness';
      case JourneyStage.desert:
        return 'Desert';
      case JourneyStage.jordan:
        return 'Jordan';
      case JourneyStage.canaan:
        return 'Canaan';
      case JourneyStage.jerusalem:
        return 'Jerusalem';
      case JourneyStage.promisedLand:
        return 'Promised Land';
    }
  }

  String get description {
    switch (this) {
      case JourneyStage.wilderness:
        return 'Beginning your journey of faith';
      case JourneyStage.desert:
        return 'Testing and refining your commitment';
      case JourneyStage.jordan:
        return 'Preparing to cross into new territory';
      case JourneyStage.canaan:
        return 'Entering the land of promise';
      case JourneyStage.jerusalem:
        return 'Establishing your spiritual foundation';
      case JourneyStage.promisedLand:
        return 'Living in the fullness of God\'s promises';
    }
  }

  /// Points required to reach this stage
  int get requiredPoints {
    switch (this) {
      case JourneyStage.wilderness:
        return 0;
      case JourneyStage.desert:
        return 100;
      case JourneyStage.jordan:
        return 300;
      case JourneyStage.canaan:
        return 600;
      case JourneyStage.jerusalem:
        return 1000;
      case JourneyStage.promisedLand:
        return 1500;
    }
  }
}

class JourneyLevel {
  final String userId;
  final JourneyStage currentStage;
  final int totalPoints;
  final DateTime lastUpdatedAt;

  const JourneyLevel({
    required this.userId,
    required this.currentStage,
    required this.totalPoints,
    required this.lastUpdatedAt,
  });

  /// Calculate progress to next level (0.0 - 1.0)
  double get progressToNext {
    final currentStageIndex = JourneyStage.values.indexOf(currentStage);
    if (currentStageIndex == JourneyStage.values.length - 1) {
      return 1.0; // At max level
    }

    final nextStage = JourneyStage.values[currentStageIndex + 1];
    final currentRequired = currentStage.requiredPoints;
    final nextRequired = nextStage.requiredPoints;
    final pointsInCurrentLevel = totalPoints - currentRequired;
    final pointsNeededForNext = nextRequired - currentRequired;

    return (pointsInCurrentLevel / pointsNeededForNext).clamp(0.0, 1.0);
  }

  /// Get the next stage in the journey
  JourneyStage? get nextStage {
    final currentIndex = JourneyStage.values.indexOf(currentStage);
    if (currentIndex == JourneyStage.values.length - 1) {
      return null; // Already at max level
    }
    return JourneyStage.values[currentIndex + 1];
  }

  /// Check if user has enough points to level up
  bool canLevelUp() {
    final next = nextStage;
    if (next == null) return false;
    return totalPoints >= next.requiredPoints;
  }

  /// Create new level with additional points
  JourneyLevel addPoints(int points, DateTime timestamp) {
    final newTotal = totalPoints + points;
    final newStage = _calculateStage(newTotal);

    return JourneyLevel(
      userId: userId,
      currentStage: newStage,
      totalPoints: newTotal,
      lastUpdatedAt: timestamp,
    );
  }

  /// Calculate stage based on total points
  static JourneyStage _calculateStage(int points) {
    for (var i = JourneyStage.values.length - 1; i >= 0; i--) {
      if (points >= JourneyStage.values[i].requiredPoints) {
        return JourneyStage.values[i];
      }
    }
    return JourneyStage.wilderness;
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'currentStage': currentStage.name,
      'totalPoints': totalPoints,
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
    };
  }

  factory JourneyLevel.fromJson(Map<String, dynamic> json) {
    return JourneyLevel(
      userId: json['userId'] as String,
      currentStage: JourneyStage.values.firstWhere(
        (s) => s.name == json['currentStage'],
        orElse: () => JourneyStage.wilderness,
      ),
      totalPoints: json['totalPoints'] as int,
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt'] as String),
    );
  }

  factory JourneyLevel.initial(String userId) {
    return JourneyLevel(
      userId: userId,
      currentStage: JourneyStage.wilderness,
      totalPoints: 0,
      lastUpdatedAt: DateTime.now(),
    );
  }
}
