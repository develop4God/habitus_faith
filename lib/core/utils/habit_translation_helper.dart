import 'package:flutter/material.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';

/// Helper to translate habit names from templates
///
/// Templates use language-agnostic keys (e.g., "morning_prayer")
/// This helper translates them to localized strings
class HabitTranslationHelper {
  /// Translate a habit name key to localized string
  ///
  /// Example:
  /// ```dart
  /// translateHabitName(context, 'morning_prayer') // "Morning Prayer" or "Oración Matutina"
  /// ```
  static String translateHabitName(BuildContext context, String nameKey) {
    final l10n = AppLocalizations.of(context)!;

    // Use the nameKey directly as it matches the translation keys in .arb files
    switch (nameKey) {
      // Spiritual
      case 'morning_prayer':
        return l10n.morning_prayer;
      case 'bible_reading':
        return l10n.bible_reading;
      case 'evening_prayer':
        return l10n.evening_prayer;
      case 'worship_music':
        return l10n.worship_music;
      case 'gratitude_journal':
        return l10n.gratitude_journal;
      case 'scripture_meditation':
        return l10n.scripture_meditation;
      case 'fasting':
        return l10n.fasting;
      case 'serve_others':
        return l10n.serve_others;
      case 'bible_study_group':
        return l10n.bible_study_group;
      case 'prayer_walk':
        return l10n.prayer_walk;
      case 'scripture_memorization':
        return l10n.scripture_memorization;
      case 'intercessory_prayer':
        return l10n.intercessory_prayer;
      case 'devotional_reading':
        return l10n.devotional_reading;
      case 'confession_repentance':
        return l10n.confession_repentance;
      case 'praise_thanksgiving':
        return l10n.praise_thanksgiving;
      case 'sabbath_rest':
        return l10n.sabbath_rest;
      case 'digital_detox_prayer':
        return l10n.digital_detox_prayer;
      case 'christian_podcast':
        return l10n.christian_podcast;
      case 'family_devotion':
        return l10n.family_devotion;
      case 'spiritual_reading':
        return l10n.spiritual_reading;

      // Physical
      case 'daily_walk':
        return l10n.daily_walk;
      case 'morning_exercise':
        return l10n.morning_exercise;
      case 'yoga_stretching':
        return l10n.yoga_stretching;
      case 'healthy_breakfast':
        return l10n.healthy_breakfast;
      case 'hydration_routine':
        return l10n.hydration_routine;
      case 'running_jogging':
        return l10n.running_jogging;
      case 'strength_training':
        return l10n.strength_training;
      case 'bike_cycling':
        return l10n.bike_cycling;
      case 'healthy_meal_prep':
        return l10n.healthy_meal_prep;
      case 'swimming':
        return l10n.swimming;
      case 'dance_movement':
        return l10n.dance_movement;
      case 'sports_recreation':
        return l10n.sports_recreation;
      case 'posture_breaks':
        return l10n.posture_breaks;
      case 'outdoor_nature':
        return l10n.outdoor_nature;
      case 'evening_walk':
        return l10n.evening_walk;

      // Mental
      case 'mindfulness_meditation':
        return l10n.mindfulness_meditation;
      case 'journaling':
        return l10n.journaling;
      case 'deep_work_focus':
        return l10n.deep_work_focus;
      case 'reading_learning':
        return l10n.reading_learning;
      case 'digital_detox':
        return l10n.digital_detox;
      case 'planning_review':
        return l10n.planning_review;
      case 'breathing_exercises':
        return l10n.breathing_exercises;
      case 'creative_hobby':
        return l10n.creative_hobby;

      // Relational
      case 'call_friend_family':
        return l10n.call_friend_family;
      case 'quality_time_loved_ones':
        return l10n.quality_time_loved_ones;

      default:
        return nameKey; // Fallback to key if not found
    }
  }

  /// Translate a notification key to localized string
  ///
  /// For now, notification keys match habit name keys
  static String translateNotification(BuildContext context, String notificationKey) {
    return translateHabitName(context, notificationKey);
  }
}

