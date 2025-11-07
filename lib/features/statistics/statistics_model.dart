
class StatisticsModel {
  final int totalHabits;
  final int completedHabits;
  final int currentStreak;
  final int longestStreak;
  final DateTime lastCompletion;

  StatisticsModel({
    required this.totalHabits,
    required this.completedHabits,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastCompletion,
  });

  Map<String, dynamic> toJson() => {
        'totalHabits': totalHabits,
        'completedHabits': completedHabits,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastCompletion': lastCompletion.toIso8601String(),
      };

  factory StatisticsModel.fromJson(Map<String, dynamic> json) => StatisticsModel(
        totalHabits: json['totalHabits'] ?? 0,
        completedHabits: json['completedHabits'] ?? 0,
        currentStreak: json['currentStreak'] ?? 0,
        longestStreak: json['longestStreak'] ?? 0,
        lastCompletion: DateTime.tryParse(json['lastCompletion'] ?? '') ?? DateTime.now(),
      );

  static StatisticsModel empty() => StatisticsModel(
        totalHabits: 0,
        completedHabits: 0,
        currentStreak: 0,
        longestStreak: 0,
        lastCompletion: DateTime.now(),
      );
}

