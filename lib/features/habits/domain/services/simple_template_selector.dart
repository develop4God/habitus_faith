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
  static const Map<(String, ScoreLevel), List<String>> templates = {
    // Faith-based paths
    ('faithBased', ScoreLevel.basic): ['morning_prayer'],
    ('faithBased', ScoreLevel.intermediate): [
      'morning_prayer',
      'bible_reading'
    ],
    ('faithBased', ScoreLevel.advanced): [
      'morning_prayer',
      'bible_reading',
      'gratitude'
    ],

    // Wellness paths
    ('wellness', ScoreLevel.basic): ['exercise'],
    ('wellness', ScoreLevel.intermediate): [
      'exercise',
      'sleep'
    ],
    ('wellness', ScoreLevel.advanced): [
      'exercise',
      'sleep',
      'healthy_eating'
    ],

    // Mixed/Study/Peace paths (consolidated)
    ('mixed', ScoreLevel.basic): ['meditation'],
    ('mixed', ScoreLevel.intermediate): [
      'meditation',
      'learning'
    ],
    ('mixed', ScoreLevel.advanced): [
      'meditation',
      'learning',
      'gratitude'
    ],

    // Study specific
    ('study', ScoreLevel.basic): ['learning'],
    ('study', ScoreLevel.intermediate): [
      'learning',
      'bible_reading'
    ],
    ('study', ScoreLevel.advanced): [
      'learning',
      'bible_reading',
      'creativity'
    ],

    // Peace specific
    ('peace', ScoreLevel.basic): ['meditation'],
    ('peace', ScoreLevel.intermediate): [
      'meditation',
      'gratitude'
    ],
    ('peace', ScoreLevel.advanced): [
      'meditation',
      'gratitude',
      'worship'
    ],
  };

  /// Universal fallback when lookup fails
  static const List<String> fallbackTemplates = ['morning_prayer'];

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

  /// Validate that all template IDs match enum values
  /// 
  /// Returns list of template IDs that don't have corresponding enum values
  static List<String> validateTemplateEnumMapping() {
    final enumIds = HabitTemplateId.values.map((e) => e.id).toSet();
    final invalid = <String>[];

    for (final habitList in templates.values) {
      for (final habitId in habitList) {
        if (!enumIds.contains(habitId)) {
          invalid.add(habitId);
        }
      }
    }

    // Also check fallback
    for (final habitId in fallbackTemplates) {
      if (!enumIds.contains(habitId)) {
        invalid.add(habitId);
      }
    }

    return invalid.toSet().toList();
  }
}
