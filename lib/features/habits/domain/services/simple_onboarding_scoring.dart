/// Simple onboarding scoring service for V2 flow
/// 
/// Formula: score = (goals.length * 2) + timeValue + levelValue
/// Range: 3-12 points
/// - Minimum: 1 goal (2) + 5-10min (1) + new (1) = 3
/// - Maximum: 3 goals (6) + 20+min (3) + consistent (3) = 12
library;

enum ScoreLevel {
  basic, // 3-5 points
  intermediate, // 6-8 points
  advanced, // 9+ points
}

enum GoalType {
  faith, // 🙏 Fe
  wellness, // 💪 Salud
  study, // 📖 Estudio
  peace, // 😌 Paz mental
}

enum TimeCommitment {
  short, // 5-10min: +1
  medium, // 10-20min: +2
  long, // 20+min: +3
}

enum ExperienceLevel {
  newbie, // 🌱 Nuevo: +1
  growing, // 🌿 Creciendo: +2
  consistent, // 🌳 Consistente: +3
}

/// Result of onboarding scoring
class OnboardingScore {
  final int totalScore;
  final ScoreLevel level;
  final String primaryIntent;
  final List<GoalType> goals;
  final TimeCommitment timeCommitment;
  final ExperienceLevel experienceLevel;

  const OnboardingScore({
    required this.totalScore,
    required this.level,
    required this.primaryIntent,
    required this.goals,
    required this.timeCommitment,
    required this.experienceLevel,
  });

  /// Get human-readable label for score level
  String getScoreLevelLabel() {
    switch (level) {
      case ScoreLevel.basic:
        return 'Empezando · Paso a paso';
      case ScoreLevel.intermediate:
        return 'Creciendo · Ritmo sostenible';
      case ScoreLevel.advanced:
        return 'Comprometido · Desafío constante';
    }
  }
}

/// Service for scoring simple onboarding answers
class SimpleOnboardingScoring {
  /// Calculate score from user answers
  /// 
  /// [goals] - Selected goals (1-3 required)
  /// [timeCommitment] - Daily time commitment
  /// [experienceLevel] - Current experience level
  /// 
  /// Returns [OnboardingScore] with total score (3-12) and level classification
  /// 
  /// Throws [ArgumentError] if goals is empty or has more than 3 items
  static OnboardingScore calculateScore({
    required List<GoalType> goals,
    required TimeCommitment timeCommitment,
    required ExperienceLevel experienceLevel,
  }) {
    // Validate goals
    if (goals.isEmpty) {
      throw ArgumentError('At least one goal must be selected');
    }
    if (goals.length > 3) {
      throw ArgumentError('Maximum 3 goals can be selected');
    }

    // Calculate score components
    final goalsScore = goals.length * 2;
    final timeScore = _getTimeScore(timeCommitment);
    final levelScore = _getLevelScore(experienceLevel);

    final totalScore = goalsScore + timeScore + levelScore;

    // Determine score level
    final scoreLevel = _getScoreLevel(totalScore);

    // Determine primary intent
    final primaryIntent = _determinePrimaryIntent(goals);

    return OnboardingScore(
      totalScore: totalScore,
      level: scoreLevel,
      primaryIntent: primaryIntent,
      goals: goals,
      timeCommitment: timeCommitment,
      experienceLevel: experienceLevel,
    );
  }

  /// Get score value for time commitment
  static int _getTimeScore(TimeCommitment timeCommitment) {
    switch (timeCommitment) {
      case TimeCommitment.short:
        return 1;
      case TimeCommitment.medium:
        return 2;
      case TimeCommitment.long:
        return 3;
    }
  }

  /// Get score value for experience level
  static int _getLevelScore(ExperienceLevel experienceLevel) {
    switch (experienceLevel) {
      case ExperienceLevel.newbie:
        return 1;
      case ExperienceLevel.growing:
        return 2;
      case ExperienceLevel.consistent:
        return 3;
    }
  }

  /// Classify total score into level
  static ScoreLevel _getScoreLevel(int totalScore) {
    if (totalScore >= 9) {
      return ScoreLevel.advanced;
    } else if (totalScore >= 6) {
      return ScoreLevel.intermediate;
    } else {
      return ScoreLevel.basic;
    }
  }

  /// Determine primary intent from selected goals
  /// 
  /// Priority:
  /// 1. 🙏 Fe (faithBased)
  /// 2. 💪 Salud (wellness)
  /// 3. Other (mixed)
  static String _determinePrimaryIntent(List<GoalType> goals) {
    // If only one goal, use that directly
    if (goals.length == 1) {
      return _goalTypeToIntent(goals.first);
    }

    // Multiple goals: apply priority
    if (goals.contains(GoalType.faith)) {
      return 'faithBased';
    }
    if (goals.contains(GoalType.wellness)) {
      return 'wellness';
    }
    // If study or peace (or both), return mixed
    return 'mixed';
  }

  /// Convert goal type to intent string
  static String _goalTypeToIntent(GoalType goal) {
    switch (goal) {
      case GoalType.faith:
        return 'faithBased';
      case GoalType.wellness:
        return 'wellness';
      case GoalType.study:
        return 'study';
      case GoalType.peace:
        return 'peace';
    }
  }
}
