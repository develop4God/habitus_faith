/// Represents faith points earned from completing habits
class FaithPoint {
  final String id;
  final String userId;
  final int points;
  final String habitId;
  final String habitName;
  final DateTime earnedAt;
  final String? reason;

  const FaithPoint({
    required this.id,
    required this.userId,
    required this.points,
    required this.habitId,
    required this.habitName,
    required this.earnedAt,
    this.reason,
  });

  /// Calculate points based on habit difficulty and category
  static int calculatePoints({
    required int difficultyLevel,
    required bool isSpiritual,
    required int currentStreak,
  }) {
    // Base points from difficulty (1-5 → 10-50 points)
    int basePoints = difficultyLevel * 10;
    
    // Spiritual habits get 50% bonus
    if (isSpiritual) {
      basePoints = (basePoints * 1.5).round();
    }
    
    // Streak bonus: +5 points per streak day (capped at 50)
    int streakBonus = (currentStreak * 5).clamp(0, 50);
    
    return basePoints + streakBonus;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'points': points,
      'habitId': habitId,
      'habitName': habitName,
      'earnedAt': earnedAt.toIso8601String(),
      'reason': reason,
    };
  }

  factory FaithPoint.fromJson(Map<String, dynamic> json) {
    return FaithPoint(
      id: json['id'] as String,
      userId: json['userId'] as String,
      points: json['points'] as int,
      habitId: json['habitId'] as String,
      habitName: json['habitName'] as String,
      earnedAt: DateTime.parse(json['earnedAt'] as String),
      reason: json['reason'] as String?,
    );
  }
}
