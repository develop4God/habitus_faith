import 'package:flutter/material.dart';
import '../../domain/habit.dart';

/// Color palette for habit categories and custom colors
class HabitColors {
  // Category-based default colors
  static const Map<HabitCategory, Color> categoryColors = {
    HabitCategory.prayer: Color(0xFF9333EA), // Purple - Spiritual
    HabitCategory.bibleReading: Color(0xFF2563EB), // Blue - Knowledge
    HabitCategory.service: Color(0xFFEF4444), // Red - Love/Service
    HabitCategory.gratitude: Color(0xFFF59E0B), // Amber - Gratitude/Joy
    HabitCategory.other: Color(0xFF6366F1), // Indigo - Default
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
    return categoryColors[habit.category] ?? categoryColors[HabitCategory.other]!;
  }

  /// Get category name for display (localized)
  static String getCategoryDisplayName(HabitCategory category) {
    switch (category) {
      case HabitCategory.prayer:
        return 'Espiritual';
      case HabitCategory.bibleReading:
        return 'Lectura';
      case HabitCategory.service:
        return 'Servicio';
      case HabitCategory.gratitude:
        return 'Gratitud';
      case HabitCategory.other:
        return 'Otros';
    }
  }

  /// Get icon for category
  static IconData getCategoryIcon(HabitCategory category) {
    switch (category) {
      case HabitCategory.prayer:
        return Icons.favorite;
      case HabitCategory.bibleReading:
        return Icons.menu_book;
      case HabitCategory.service:
        return Icons.volunteer_activism;
      case HabitCategory.gratitude:
        return Icons.wb_sunny;
      case HabitCategory.other:
        return Icons.auto_awesome;
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
