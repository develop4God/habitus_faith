import 'package:flutter/material.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';
import '../../domain/habit.dart';

/// Color palette for habit categories and custom colors
class HabitColors {
  // Category-based default colors
  static const Map<HabitCategory, Color> categoryColors = {
    HabitCategory.spiritual: Color(0xFF9333EA), // Purple - Spiritual
    HabitCategory.physical: Color(0xFF10B981), // Green - Physical health
    HabitCategory.mental: Color(0xFF2563EB), // Blue - Mental growth
    HabitCategory.relational: Color(0xFFEF4444), // Red - Relationships/Love
    HabitCategory.other: Color(0xFFF59E0B), // Amber - Other
  };

  // Predefined color palette for user selection
  static const List<Color> availableColors = [
    Color(0xFF9333EA), // Purple
    Color(0xFF2563EB), // Blue
    Color(0xFFEF4444), // Red
    Color(0xFFF59E0B), // Amber
    Color(0xFF10B981), // Green
    Color(0xFF6366F1), // Indigo
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Violet
    Color(0xFF06B6D4), // Cyan
    Color(0xFF84CC16), // Lime
    Color(0xFFF97316), // Orange
    Color(0xFF14B8A6), // Teal
  ];

  /// Get color for a habit based on its category or custom color
  static Color getHabitColor(Habit habit) {
    if (habit.colorValue != null) {
      return Color(habit.colorValue!);
    }
    return categoryColors[habit.category] ??
        categoryColors[HabitCategory.spiritual]!;
  }

  /// Get category name for display (localized)
  static String getCategoryDisplayName(
      HabitCategory category, AppLocalizations l10n) {
    switch (category) {
      case HabitCategory.spiritual:
        return l10n.spiritual;
      case HabitCategory.physical:
        return l10n.physical;
      case HabitCategory.mental:
        return l10n.mental;
      case HabitCategory.relational:
        return l10n.relational;
      case HabitCategory.other:
        return 'Otros'; // Or use l10n.other if you add it to your localizations
    }
  }

  /// Get icon for category
  static IconData getCategoryIcon(HabitCategory category) {
    switch (category) {
      case HabitCategory.spiritual:
        return Icons.favorite;
      case HabitCategory.physical:
        return Icons.fitness_center;
      case HabitCategory.mental:
        return Icons.psychology;
      case HabitCategory.relational:
        return Icons.volunteer_activism;
      case HabitCategory.other:
        return Icons.star;
    }
  }
}

/// Difficulty level visual helpers
class HabitDifficultyHelper {
  static Color getDifficultyColor(HabitDifficulty difficulty) {
    switch (difficulty) {
      case HabitDifficulty.easy:
        return const Color(0xFF10B981); // Green
      case HabitDifficulty.medium:
        return const Color(0xFFF59E0B); // Amber
      case HabitDifficulty.hard:
        return const Color(0xFFEF4444); // Red
    }
  }

  static IconData getDifficultyIcon(HabitDifficulty difficulty) {
    switch (difficulty) {
      case HabitDifficulty.easy:
        return Icons.trending_down;
      case HabitDifficulty.medium:
        return Icons.trending_flat;
      case HabitDifficulty.hard:
        return Icons.trending_up;
    }
  }

  static int getDifficultyStars(HabitDifficulty difficulty) {
    switch (difficulty) {
      case HabitDifficulty.easy:
        return 1;
      case HabitDifficulty.medium:
        return 2;
      case HabitDifficulty.hard:
        return 3;
    }
  }
}
