import '../l10n/app_localizations.dart';

/// Utility class for translating predefined habit names and descriptions
class PredefinedHabitTranslations {
  /// Translates a predefined habit name key to the localized string
  static String getTranslatedName(AppLocalizations l10n, String key) {
    switch (key) {
      case 'predefinedHabit_morningPrayer_name':
        return l10n.predefinedHabit_morningPrayer_name;
      case 'predefinedHabit_bibleReading_name':
        return l10n.predefinedHabit_bibleReading_name;
      case 'predefinedHabit_worship_name':
        return l10n.predefinedHabit_worship_name;
      case 'predefinedHabit_gratitude_name':
        return l10n.predefinedHabit_gratitude_name;
      case 'predefinedHabit_exercise_name':
        return l10n.predefinedHabit_exercise_name;
      case 'predefinedHabit_healthyEating_name':
        return l10n.predefinedHabit_healthyEating_name;
      case 'predefinedHabit_sleep_name':
        return l10n.predefinedHabit_sleep_name;
      case 'predefinedHabit_meditation_name':
        return l10n.predefinedHabit_meditation_name;
      case 'predefinedHabit_learning_name':
        return l10n.predefinedHabit_learning_name;
      case 'predefinedHabit_creativity_name':
        return l10n.predefinedHabit_creativity_name;
      case 'predefinedHabit_familyTime_name':
        return l10n.predefinedHabit_familyTime_name;
      case 'predefinedHabit_service_name':
        return l10n.predefinedHabit_service_name;
      default:
        return key;
    }
  }

  /// Translates a predefined habit description key to the localized string
  static String getTranslatedDescription(AppLocalizations l10n, String key) {
    switch (key) {
      case 'predefinedHabit_morningPrayer_description':
        return l10n.predefinedHabit_morningPrayer_description;
      case 'predefinedHabit_bibleReading_description':
        return l10n.predefinedHabit_bibleReading_description;
      case 'predefinedHabit_worship_description':
        return l10n.predefinedHabit_worship_description;
      case 'predefinedHabit_gratitude_description':
        return l10n.predefinedHabit_gratitude_description;
      case 'predefinedHabit_exercise_description':
        return l10n.predefinedHabit_exercise_description;
      case 'predefinedHabit_healthyEating_description':
        return l10n.predefinedHabit_healthyEating_description;
      case 'predefinedHabit_sleep_description':
        return l10n.predefinedHabit_sleep_description;
      case 'predefinedHabit_meditation_description':
        return l10n.predefinedHabit_meditation_description;
      case 'predefinedHabit_learning_description':
        return l10n.predefinedHabit_learning_description;
      case 'predefinedHabit_creativity_description':
        return l10n.predefinedHabit_creativity_description;
      case 'predefinedHabit_familyTime_description':
        return l10n.predefinedHabit_familyTime_description;
      case 'predefinedHabit_service_description':
        return l10n.predefinedHabit_service_description;
      default:
        return key;
    }
  }
}
