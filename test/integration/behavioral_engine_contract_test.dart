import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/ai/behavioral_engine.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';

void main() {
  group('BehavioralEngine Contract Tests', () {
    late BehavioralEngine engine;
    late Habit testHabit;

    setUp(() {
      engine = BehavioralEngine();

      // Create a standard test habit with sufficient data
      testHabit = Habit(
        id: 'test1',
        userId: 'user1',
        name: 'Test Habit',
        category: HabitCategory.spiritual,
        createdAt: DateTime(2024, 1, 1),
        currentStreak: 5,
        lastCompletedAt: DateTime(2024, 1, 15, 10, 0),
        completionHistory: List.generate(
          10,
          (i) => DateTime(2024, 1, 15 - i, 10, 0),
        ),
        difficultyLevel: 3,
      );
    });

    test('BehavioralEngine interface methods exist and are callable', () {
      // Verify all public methods exist and can be called without errors
      expect(() => engine.findOptimalTime(testHabit), returnsNormally);
      expect(() => engine.detectFailurePattern(testHabit), returnsNormally);
      expect(() => engine.calculateNextDifficulty(testHabit), returnsNormally);
      expect(() => engine.findOptimalDays(testHabit), returnsNormally);
    });

    test('findOptimalTime returns correct type', () {
      final result = engine.findOptimalTime(testHabit);

      // Should return TimeOfDay or null
      expect(result, anyOf(isA<TimeOfDay>(), isNull));
    });

    test('detectFailurePattern returns correct type', () {
      final result = engine.detectFailurePattern(testHabit);

      // Should return FailurePattern or null
      expect(result, anyOf(isA<FailurePattern>(), isNull));
    });

    test('calculateNextDifficulty returns valid integer', () {
      final result = engine.calculateNextDifficulty(testHabit);

      // Should return int within valid range
      expect(result, isA<int>());
      expect(result, greaterThanOrEqualTo(BehavioralEngine.minDifficultyLevel));
      expect(result, lessThanOrEqualTo(BehavioralEngine.maxDifficultyLevel));
    });

    test('findOptimalDays returns correct type', () {
      final result = engine.findOptimalDays(testHabit);

      // Should return List<int> (may be empty)
      expect(result, isA<List<int>>());

      // All values should be valid weekdays (1-7)
      for (final day in result) {
        expect(day, greaterThanOrEqualTo(1));
        expect(day, lessThanOrEqualTo(7));
      }
    });

    test('methods handle habits with minimal data gracefully', () {
      final minimalHabit = Habit(
        id: 'minimal',
        userId: 'user1',
        name: 'Minimal Habit',
        category: HabitCategory.spiritual,
        createdAt: DateTime(2024, 1, 15),
        currentStreak: 0,
        completionHistory: [],
      );

      // Should not throw with minimal data
      expect(() => engine.findOptimalTime(minimalHabit), returnsNormally);
      expect(() => engine.detectFailurePattern(minimalHabit), returnsNormally);
      expect(
          () => engine.calculateNextDifficulty(minimalHabit), returnsNormally);
      expect(() => engine.findOptimalDays(minimalHabit), returnsNormally);

      // With no data, should return safe defaults
      expect(engine.findOptimalTime(minimalHabit), isNull);
      expect(engine.detectFailurePattern(minimalHabit), isNull);
      expect(engine.findOptimalDays(minimalHabit), isEmpty);
    });

    test('calculateNextDifficulty respects boundaries', () {
      // Test upper boundary
      final maxDifficultyHabit = Habit(
        id: 'max',
        userId: 'user1',
        name: 'Max Difficulty',
        category: HabitCategory.spiritual,
        createdAt: DateTime(2024, 1, 1),
        currentStreak: 10,
        difficultyLevel: BehavioralEngine.maxDifficultyLevel,
        completionHistory: List.generate(
          10,
          (i) => DateTime(2024, 1, 15 - i),
        ),
      );

      final nextDifficulty = engine.calculateNextDifficulty(maxDifficultyHabit);
      expect(nextDifficulty,
          lessThanOrEqualTo(BehavioralEngine.maxDifficultyLevel));

      // Test lower boundary
      final minDifficultyHabit = Habit(
        id: 'min',
        userId: 'user1',
        name: 'Min Difficulty',
        category: HabitCategory.spiritual,
        createdAt: DateTime(2024, 1, 1),
        currentStreak: 0,
        difficultyLevel: BehavioralEngine.minDifficultyLevel,
        completionHistory: [],
      );

      final nextMinDifficulty =
          engine.calculateNextDifficulty(minDifficultyHabit);
      expect(nextMinDifficulty,
          greaterThanOrEqualTo(BehavioralEngine.minDifficultyLevel));
    });

    test('findOptimalTime with consistent completion times', () {
      // Habit completed consistently at 10am
      final consistentHabit = Habit(
        id: 'consistent',
        userId: 'user1',
        name: 'Consistent Habit',
        category: HabitCategory.spiritual,
        createdAt: DateTime(2024, 1, 1),
        currentStreak: 5,
        lastCompletedAt: DateTime(2024, 1, 15, 10, 0),
        completionHistory: List.generate(
          5,
          (i) => DateTime(2024, 1, 15 - i, 10, 0), // All at 10am
        ),
      );

      final optimalTime = engine.findOptimalTime(consistentHabit);

      expect(optimalTime, isNotNull);
      expect(optimalTime!.hour, equals(10));
    });

    test('detectFailurePattern recognizes patterns or returns null', () {
      // Habit with recent consecutive failures
      final strugglingHabit = Habit(
        id: 'struggling',
        userId: 'user1',
        name: 'Struggling Habit',
        category: HabitCategory.spiritual,
        createdAt: DateTime(2024, 1, 1),
        currentStreak: 0,
        consecutiveFailures: 5,
        lastCompletedAt: DateTime(2024, 1, 10),
        completionHistory: [
          DateTime(2024, 1, 10),
          DateTime(2024, 1, 9),
          DateTime(2024, 1, 8),
        ],
      );

      final pattern = engine.detectFailurePattern(strugglingHabit);

      // Should return a specific pattern or null
      expect(
          pattern,
          anyOf(
            isA<FailurePattern>(),
            isNull,
          ));
    });

    test('interface stability - methods maintain same signatures', () {
      // This test ensures the public API doesn't change unexpectedly

      // Verify method signatures by checking parameter types
      final TimeOfDay? optimalTime = engine.findOptimalTime(testHabit);
      final FailurePattern? pattern = engine.detectFailurePattern(testHabit);
      final int difficulty = engine.calculateNextDifficulty(testHabit);
      final List<int> optimalDays = engine.findOptimalDays(testHabit);

      // Type checks ensure signatures haven't changed
      expect(optimalTime, anyOf(isA<TimeOfDay>(), isNull));
      expect(pattern, anyOf(isA<FailurePattern>(), isNull));
      expect(difficulty, isA<int>());
      expect(optimalDays, isA<List<int>>());
    });

    test('BehavioralEngine constants are accessible', () {
      // Verify public constants exist and have expected values
      expect(BehavioralEngine.tccIncreaseThreshold, equals(0.85));
      expect(BehavioralEngine.tccDecreaseThreshold, equals(0.50));
      expect(BehavioralEngine.maxDifficultyLevel, equals(5));
      expect(BehavioralEngine.minDifficultyLevel, equals(1));
      expect(BehavioralEngine.minCompletionsForOptimalTime, equals(3));
      expect(BehavioralEngine.minCompletionsForOptimalDays, equals(5));
      expect(BehavioralEngine.minConsecutiveFailuresForPattern, equals(3));
      expect(BehavioralEngine.topOptimalDaysCount, equals(3));
    });
  });
}
