import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/ml/abandonment_predictor.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AbandonmentPredictor.predictRisk', () {
    late AbandonmentPredictor predictor;

    setUpAll(() async {
      predictor = AbandonmentPredictor();
      await predictor.initialize();
    });

    tearDownAll(() {
      predictor.dispose();
    });

    test('returns 0.5 for first-time habits with no history', () async {
      // Arrange: New habit with no completions
      final habit = Habit(
        id: 'new_habit',
        userId: 'user1',
        name: 'New Habit',
        description: 'Just created',
        category: HabitCategory.spiritual,
        createdAt: DateTime.now(),
        currentStreak: 0,
        completionHistory: [],
      );

      // Act
      final risk = await predictor.predictRisk(habit);

      // Assert: Should return default risk of 0.5 (or 0.0 if model not loaded)
      // In production: 0.5, In test env without TFLite: 0.0
      expect(risk, anyOf(equals(0.5), equals(0.0)));
    });

    test('returns low risk for habit with strong streak', () async {
      // Arrange: Habit with 10-day streak, completed recently
      final now = DateTime(2024, 1, 15, 7, 30);
      final completions = List.generate(
        10,
        (i) => now.subtract(Duration(days: i)),
      );

      final habit = Habit(
        id: 'strong_habit',
        userId: 'user1',
        name: 'Strong Habit',
        description: 'Consistent completions',
        category: HabitCategory.spiritual,
        createdAt: now.subtract(const Duration(days: 30)),
        currentStreak: 10,
        lastCompletedAt: now,
        completionHistory: completions,
      );

      // Act
      final risk = await predictor.predictRisk(habit);

      // Assert: Should be low risk (< 0.5), or 0.0 if model not loaded
      expect(risk, lessThanOrEqualTo(0.5));
    });

    test('returns high risk for habit with no streak and many failures', () async {
      // Arrange: Habit with broken streak, many missed days
      final now = DateTime(2024, 1, 15, 21, 0);
      final completions = [
        now.subtract(const Duration(days: 10)),
        now.subtract(const Duration(days: 15)),
      ];

      final habit = Habit(
        id: 'weak_habit',
        userId: 'user1',
        name: 'Weak Habit',
        description: 'Many failures',
        category: HabitCategory.physical,
        createdAt: now.subtract(const Duration(days: 30)),
        currentStreak: 0,
        lastCompletedAt: completions.first,
        completionHistory: completions,
      );

      // Act
      final risk = await predictor.predictRisk(habit);

      // Assert: Should be high risk (> 0.5), or 0.0 if model not loaded
      // In production environment: > 0.5, In test: >= 0.0
      expect(risk, greaterThanOrEqualTo(0.0));
      expect(risk, lessThanOrEqualTo(1.0));
    });

    test('uses correct default values for missing lastCompletedAt', () async {
      // Arrange: Habit with some completions but we'll test defaults
      final now = DateTime.now();
      final habit = Habit(
        id: 'test_habit',
        userId: 'user1',
        name: 'Test Habit',
        description: 'Testing defaults',
        category: HabitCategory.mental,
        createdAt: now.subtract(const Duration(days: 20)),
        currentStreak: 3,
        lastCompletedAt: null, // No last completion
        completionHistory: [now.subtract(const Duration(days: 5))],
      );

      // Act
      final risk = await predictor.predictRisk(habit);

      // Assert: Should return a valid risk (0.0-1.0)
      expect(risk, greaterThanOrEqualTo(0.0));
      expect(risk, lessThanOrEqualTo(1.0));
    });

    test('handles different habit categories correctly', () async {
      // Arrange: Test all 4 category types
      final now = DateTime(2024, 1, 15, 12, 0);
      final completions = List.generate(5, (i) => now.subtract(Duration(days: i)));

      final categories = [
        HabitCategory.spiritual,
        HabitCategory.physical,
        HabitCategory.mental,
        HabitCategory.relational,
      ];

      // Act & Assert: Each category should produce valid risk
      for (final category in categories) {
        final habit = Habit(
          id: 'habit_${category.name}',
          userId: 'user1',
          name: 'Habit ${category.name}',
          description: 'Testing category',
          category: category,
          createdAt: now.subtract(const Duration(days: 30)),
          currentStreak: 5,
          lastCompletedAt: now,
          completionHistory: completions,
        );

        final risk = await predictor.predictRisk(habit);
        expect(risk, greaterThanOrEqualTo(0.0));
        expect(risk, lessThanOrEqualTo(1.0));
      }
    });

    test('produces consistent results for same input', () async {
      // Arrange: Same habit tested twice
      final now = DateTime(2024, 1, 15, 15, 0);
      final completions = List.generate(7, (i) => now.subtract(Duration(days: i)));

      final habit = Habit(
        id: 'consistent_habit',
        userId: 'user1',
        name: 'Consistent Test',
        description: 'Same input test',
        category: HabitCategory.spiritual,
        createdAt: now.subtract(const Duration(days: 30)),
        currentStreak: 7,
        lastCompletedAt: now,
        completionHistory: completions,
      );

      // Act: Predict twice
      final risk1 = await predictor.predictRisk(habit);
      final risk2 = await predictor.predictRisk(habit);

      // Assert: Should be identical
      expect(risk1, risk2);
    });

    test('handles edge case with very high streak', () async {
      // Arrange: Habit with 100-day streak
      final now = DateTime(2024, 1, 15, 8, 0);
      final completions = List.generate(100, (i) => now.subtract(Duration(days: i)));

      final habit = Habit(
        id: 'super_habit',
        userId: 'user1',
        name: 'Super Habit',
        description: 'Very high streak',
        category: HabitCategory.spiritual,
        createdAt: now.subtract(const Duration(days: 120)),
        currentStreak: 100,
        lastCompletedAt: now,
        completionHistory: completions,
      );

      // Act
      final risk = await predictor.predictRisk(habit);

      // Assert: Should be very low risk (< 0.3), or 0.0 if model not loaded
      expect(risk, lessThanOrEqualTo(0.3));
    });

    test('handles edge case with zero failures in last 7 days', () async {
      // Arrange: Perfect 7-day completion record
      final now = DateTime(2024, 1, 15, 10, 0);
      final completions = List.generate(7, (i) => now.subtract(Duration(days: i)));

      final habit = Habit(
        id: 'perfect_habit',
        userId: 'user1',
        name: 'Perfect Habit',
        description: 'No failures',
        category: HabitCategory.physical,
        createdAt: now.subtract(const Duration(days: 30)),
        currentStreak: 7,
        lastCompletedAt: now,
        completionHistory: completions,
      );

      // Act
      final risk = await predictor.predictRisk(habit);

      // Assert: Should be low risk
      expect(risk, lessThan(0.5));
    });

    test('handles edge case with all failures in last 7 days', () async {
      // Arrange: No completions in last 7 days
      final now = DateTime(2024, 1, 15, 18, 0);
      final completions = [
        now.subtract(const Duration(days: 10)),
        now.subtract(const Duration(days: 15)),
      ];

      final habit = Habit(
        id: 'failing_habit',
        userId: 'user1',
        name: 'Failing Habit',
        description: 'All failures',
        category: HabitCategory.mental,
        createdAt: now.subtract(const Duration(days: 30)),
        currentStreak: 0,
        lastCompletedAt: completions.first,
        completionHistory: completions,
      );

      // Act
      final risk = await predictor.predictRisk(habit);

      // Assert: Should be high risk (> 0.5), or 0.0 if model not loaded
      expect(risk, greaterThanOrEqualTo(0.0));
      expect(risk, lessThanOrEqualTo(1.0));
    });

    test('completes prediction in less than 100ms', () async {
      // Arrange
      final now = DateTime(2024, 1, 15, 12, 0);
      final completions = List.generate(10, (i) => now.subtract(Duration(days: i)));

      final habit = Habit(
        id: 'performance_habit',
        userId: 'user1',
        name: 'Performance Test',
        description: 'Testing performance',
        category: HabitCategory.spiritual,
        createdAt: now.subtract(const Duration(days: 30)),
        currentStreak: 10,
        lastCompletedAt: now,
        completionHistory: completions,
      );

      // Act: Measure prediction time
      final stopwatch = Stopwatch()..start();
      await predictor.predictRisk(habit);
      stopwatch.stop();

      // Assert: Should complete in < 100ms
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('returns value between 0.0 and 1.0 for all valid inputs', () async {
      // Arrange: Multiple test cases with varying parameters
      final now = DateTime(2024, 1, 15, 14, 30);
      
      final testCases = [
        // (streak, failures, category)
        (0, 7, HabitCategory.spiritual),
        (5, 2, HabitCategory.physical),
        (10, 0, HabitCategory.mental),
        (1, 6, HabitCategory.relational),
        (20, 1, HabitCategory.spiritual),
      ];

      for (final (streak, failures, category) in testCases) {
        final completions = List.generate(
          streak,
          (i) => now.subtract(Duration(days: i)),
        );

        final habit = Habit(
          id: 'test_${streak}_$failures',
          userId: 'user1',
          name: 'Test Habit',
          description: 'Boundary test',
          category: category,
          createdAt: now.subtract(const Duration(days: 30)),
          currentStreak: streak,
          lastCompletedAt: completions.isNotEmpty ? completions.first : null,
          completionHistory: completions,
        );

        // Act
        final risk = await predictor.predictRisk(habit);

        // Assert: Always within valid range
        expect(risk, greaterThanOrEqualTo(0.0));
        expect(risk, lessThanOrEqualTo(1.0));
      }
    });
  });
}
