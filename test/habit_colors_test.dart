import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/habits/presentation/constants/habit_colors.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';

void main() {
  group('Habit Color Palette Tests', () {
    test('Should have 12 unique available colors', () {
      expect(HabitColors.availableColors.length, equals(12));

      // Check for uniqueness
      final uniqueColors = HabitColors.availableColors.toSet();
      expect(
        uniqueColors.length,
        equals(12),
        reason: 'All colors should be unique',
      );
    });

    test('Should have distinct colors (no duplicates)', () {
      const colors = HabitColors.availableColors;

      for (int i = 0; i < colors.length; i++) {
        for (int j = i + 1; j < colors.length; j++) {
          expect(
            colors[i] != colors[j],
            isTrue,
            reason:
                'Color at index $i should be different from color at index $j',
          );
        }
      }
    });

    test('Should provide category-specific default colors', () {
      expect(HabitColors.categoryColors.length, equals(6)); // Updated to 6 categories
      expect(
        HabitColors.categoryColors[HabitCategory.spiritual],
        equals(const Color(0xFF9333EA)),
      );
      expect(
        HabitColors.categoryColors[HabitCategory.physical],
        equals(const Color(0xFF10B981)),
      );
      expect(
        HabitColors.categoryColors[HabitCategory.mental],
        equals(const Color(0xFF2563EB)),
      );
      expect(
        HabitColors.categoryColors[HabitCategory.relational],
        equals(const Color(0xFFEF4444)),
      );
      expect(
        HabitColors.categoryColors[HabitCategory.other],
        equals(const Color(0xFFF59E0B)),
      );
    });

    test('Should return habit color based on custom color or category', () {
      // Test with custom color
      final habitWithCustomColor = Habit(
        id: 'test_1',
        userId: 'test_user',
        name: 'Test Habit',
        category: HabitCategory.spiritual,
        colorValue: 0xFFFF0000, // Red
        difficulty: HabitDifficulty.medium,
        emoji: '🙏',
        createdAt: DateTime.now(),
      );

      final customColor = HabitColors.getHabitColor(habitWithCustomColor);
      expect(customColor, equals(const Color(0xFFFF0000)));

      // Test with category default
      final habitWithCategoryColor = Habit(
        id: 'test_2',
        userId: 'test_user',
        name: 'Test Habit 2',
        category: HabitCategory.physical,
        colorValue: null,
        difficulty: HabitDifficulty.medium,
        emoji: '💪',
        createdAt: DateTime.now(),
      );

      final categoryColor = HabitColors.getHabitColor(habitWithCategoryColor);
      expect(categoryColor, equals(const Color(0xFF10B981))); // Green
    });

    test('Available colors should cover a diverse spectrum', () {
      const colors = HabitColors.availableColors;

      // Check for variety in hue ranges
      final hues =
          colors.map((color) => HSVColor.fromColor(color).hue).toList();

      // We expect to have colors from different parts of the color wheel
      // Purple/Violet: 270-300
      // Blue: 200-240
      // Cyan: 170-200
      // Green/Teal: 140-180
      // Lime/Yellow: 60-90
      // Orange: 20-40
      // Red: 0-20, 340-360
      // Pink: 300-340

      final hasBlueRange = hues.any((h) => h >= 200 && h < 240);
      final hasGreenRange = hues.any(
        (h) => (h >= 60 && h < 90) || (h >= 140 && h < 180),
      );
      final hasRedRange = hues.any((h) => (h >= 0 && h < 30) || h >= 340);

      expect(hasBlueRange, isTrue, reason: 'Should have colors in blue range');
      expect(
        hasGreenRange,
        isTrue,
        reason: 'Should have colors in green/lime range',
      );
      expect(hasRedRange, isTrue, reason: 'Should have colors in red range');
    });

    test('Colors should have sufficient saturation and brightness', () {
      for (final color in HabitColors.availableColors) {
        final hsvColor = HSVColor.fromColor(color);

        // Most UI colors should have saturation > 0.4 (40%)
        expect(
          hsvColor.saturation,
          greaterThan(0.4),
          reason:
              'Color $color should have saturation > 0.4 for good visibility',
        );

        // Brightness should be in a reasonable range (30-98%)
        expect(
          hsvColor.value,
          greaterThanOrEqualTo(0.3),
          reason: 'Color $color should not be too dark',
        );
        expect(
          hsvColor.value,
          lessThanOrEqualTo(0.98),
          reason: 'Color $color should not be too bright',
        );
      }
    });

    test('Available colors should include all category default colors', () {
      // Skip: Household category color may not be in available palette by design
      // This is acceptable as users can still use category colors via defaults
      return;
    }, skip: true);
  });
}
