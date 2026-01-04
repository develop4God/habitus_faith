import 'simple_onboarding_scoring.dart';

/// Enum for habit template IDs to ensure type safety
enum HabitTemplateId {
  morningPrayer('morning_prayer'),
  bibleReading('bible_reading'),
  gratitude('gratitude'),
  exercise('exercise'),
  sleep('sleep'),
  healthyEating('healthy_eating'),
  meditation('meditation'),
  learning('learning'),
  creativity('creativity'),
  worship('worship');

  const HabitTemplateId(this.id);
  final String id;
}

/// O(1) template selector for simple onboarding V2
/// 
/// Maps (primaryIntent, ScoreLevel) combinations to predefined habit IDs
/// Total: 9 combinations (3 intents × 3 levels)
class SimpleTemplateSelector {
  /// Template lookup table: (intent, level) -> habit IDs
  /// 
  /// All IDs must exist in predefined_habits_data.dart
  static final Map<(String, ScoreLevel), List<String>> templates = {
    // Faith-based paths
    ('faithBased', ScoreLevel.basic): [HabitTemplateId.morningPrayer.id],
    ('faithBased', ScoreLevel.intermediate): [
      HabitTemplateId.morningPrayer.id,
      HabitTemplateId.bibleReading.id
    ],
    ('faithBased', ScoreLevel.advanced): [
      HabitTemplateId.morningPrayer.id,
      HabitTemplateId.bibleReading.id,
      HabitTemplateId.gratitude.id
    ],

    // Wellness paths
    ('wellness', ScoreLevel.basic): [HabitTemplateId.exercise.id],
    ('wellness', ScoreLevel.intermediate): [
      HabitTemplateId.exercise.id,
      HabitTemplateId.sleep.id
    ],
    ('wellness', ScoreLevel.advanced): [
      HabitTemplateId.exercise.id,
      HabitTemplateId.sleep.id,
      HabitTemplateId.healthyEating.id
    ],

    // Mixed/Study/Peace paths (consolidated)
    ('mixed', ScoreLevel.basic): [HabitTemplateId.meditation.id],
    ('mixed', ScoreLevel.intermediate): [
      HabitTemplateId.meditation.id,
      HabitTemplateId.learning.id
    ],
    ('mixed', ScoreLevel.advanced): [
      HabitTemplateId.meditation.id,
      HabitTemplateId.learning.id,
      HabitTemplateId.gratitude.id
    ],

    // Study specific
    ('study', ScoreLevel.basic): [HabitTemplateId.learning.id],
    ('study', ScoreLevel.intermediate): [
      HabitTemplateId.learning.id,
      HabitTemplateId.bibleReading.id
    ],
    ('study', ScoreLevel.advanced): [
      HabitTemplateId.learning.id,
      HabitTemplateId.bibleReading.id,
      HabitTemplateId.creativity.id
    ],

    // Peace specific
    ('peace', ScoreLevel.basic): [HabitTemplateId.meditation.id],
    ('peace', ScoreLevel.intermediate): [
      HabitTemplateId.meditation.id,
      HabitTemplateId.gratitude.id
    ],
    ('peace', ScoreLevel.advanced): [
      HabitTemplateId.meditation.id,
      HabitTemplateId.gratitude.id,
      HabitTemplateId.worship.id
    ],
  };

  /// Universal fallback when lookup fails
  static final List<String> fallbackTemplates = [HabitTemplateId.morningPrayer.id];

  /// Select habit templates based on onboarding score
  /// 
  /// Returns list of predefined habit IDs that match the user's
  /// primary intent and score level.
  /// 
  /// If no exact match found, returns [fallbackTemplates].
  /// 
  /// Time complexity: O(1) - constant-time map lookup
  static List<String> selectTemplates(OnboardingScore score) {
    final key = (score.primaryIntent, score.level);
    final result = templates[key];

    if (result == null || result.isEmpty) {
      // Fallback to universal default
      return fallbackTemplates;
    }

    return result;
  }

  /// Get all template combinations (for testing)
  static List<(String, ScoreLevel)> getAllCombinations() {
    return templates.keys.toList();
  }

  /// Validate that all template IDs exist in predefined habits
  /// 
  /// [availableHabitIds] - Set of valid habit IDs from predefined_habits_data.dart
  /// 
  /// Returns list of missing habit IDs, or empty list if all valid
  static List<String> validateTemplates(Set<String> availableHabitIds) {
    final missing = <String>[];

    for (final habitList in templates.values) {
      for (final habitId in habitList) {
        if (!availableHabitIds.contains(habitId)) {
          missing.add(habitId);
        }
      }
    }

    // Also check fallback
    for (final habitId in fallbackTemplates) {
      if (!availableHabitIds.contains(habitId)) {
        missing.add(habitId);
      }
    }

    return missing.toSet().toList(); // Remove duplicates
  }
}
