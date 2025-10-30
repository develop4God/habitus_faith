import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';

void main() {
  group('Habit Model - Extended TCC/Nudge Fields', () {
    test('Constructor initializes with default TCC/Nudge values', () {
      // Arrange & Act
      final habit = Habit.create(
        id: 'test-1',
        userId: 'user-1',
        name: 'Prayer',
        description: 'Daily prayer',
      );

      // Assert
      expect(habit.difficultyLevel, 3);
      expect(habit.targetMinutes, 15);
      expect(habit.successRate7d, 0.0);
      expect(habit.optimalDays, isEmpty);
      expect(habit.optimalTime, isNull);
      expect(habit.consecutiveFailures, 0);
      expect(habit.failurePattern, isNull);
      expect(habit.abandonmentRisk, 0.0);
      expect(habit.lastAdjustedAt, isNull);
    });

    test('Constructor accepts custom TCC/Nudge values', () {
      // Arrange & Act
      final now = DateTime.now();
      final habit = Habit(
        id: 'test-2',
        userId: 'user-1',
        name: 'Bible Reading',
        description: 'Read 1 chapter',
        category: HabitCategory.spiritual,
        createdAt: now,
        difficultyLevel: 4,
        targetMinutes: 30,
        successRate7d: 0.85,
        optimalDays: [1, 3, 5],
        optimalTime: const TimeOfDay(hour: 7, minute: 0),
        consecutiveFailures: 2,
        failurePattern: FailurePattern.weekendGap,
        abandonmentRisk: 0.3,
        lastAdjustedAt: now,
      );

      // Assert
      expect(habit.difficultyLevel, 4);
      expect(habit.targetMinutes, 30);
      expect(habit.successRate7d, 0.85);
      expect(habit.optimalDays, [1, 3, 5]);
      expect(habit.optimalTime, const TimeOfDay(hour: 7, minute: 0));
      expect(habit.consecutiveFailures, 2);
      expect(habit.failurePattern, FailurePattern.weekendGap);
      expect(habit.abandonmentRisk, 0.3);
      expect(habit.lastAdjustedAt, now);
    });

    test('copyWith updates TCC/Nudge fields correctly', () {
      // Arrange
      final habit = Habit.create(
        id: 'test-3',
        userId: 'user-1',
        name: 'Gratitude',
        description: 'Write in journal',
      );

      // Act
      final updated = habit.copyWith(
        difficultyLevel: 5,
        targetMinutes: 20,
        successRate7d: 0.71,
        optimalDays: [2, 4, 6],
        optimalTime: const TimeOfDay(hour: 21, minute: 0),
        consecutiveFailures: 1,
        failurePattern: FailurePattern.eveningSlump,
        abandonmentRisk: 0.15,
      );

      // Assert
      expect(updated.difficultyLevel, 5);
      expect(updated.targetMinutes, 20);
      expect(updated.successRate7d, 0.71);
      expect(updated.optimalDays, [2, 4, 6]);
      expect(updated.optimalTime, const TimeOfDay(hour: 21, minute: 0));
      expect(updated.consecutiveFailures, 1);
      expect(updated.failurePattern, FailurePattern.eveningSlump);
      expect(updated.abandonmentRisk, 0.15);
    });

    test('completeToday() calculates successRate7d with 5/7 completions', () {
      // Arrange
      final now = DateTime.now();
      final completions = [
        now.subtract(const Duration(days: 6)),
        now.subtract(const Duration(days: 5)),
        now.subtract(const Duration(days: 3)),
        now.subtract(const Duration(days: 2)),
        now.subtract(const Duration(days: 1)),
      ];
      
      final habit = Habit.create(
        id: 'test-4',
        userId: 'user-1',
        name: 'Exercise',
        description: 'Daily workout',
      ).copyWith(
        completionHistory: completions,
        currentStreak: 1,
        lastCompletedAt: completions.last,
      );

      // Act
      final completed = habit.completeToday();

      // Assert - 6 completions (5 old + 1 today) over 7 days = 6/7 ≈ 0.857
      expect(completed.successRate7d, closeTo(6/7, 0.01));
    });

    test('completeToday() calculates successRate7d with 7/7 completions', () {
      // Arrange
      final now = DateTime.now();
      final completions = [
        now.subtract(const Duration(days: 6)),
        now.subtract(const Duration(days: 5)),
        now.subtract(const Duration(days: 4)),
        now.subtract(const Duration(days: 3)),
        now.subtract(const Duration(days: 2)),
        now.subtract(const Duration(days: 1)),
      ];
      
      final habit = Habit.create(
        id: 'test-5',
        userId: 'user-1',
        name: 'Perfect Streak',
        description: 'All 7 days',
      ).copyWith(
        completionHistory: completions,
        currentStreak: 6,
        lastCompletedAt: completions.last,
      );

      // Act
      final completed = habit.completeToday();

      // Assert - 7 completions over 7 days = 7/7 = 1.0
      expect(completed.successRate7d, 1.0);
    });

    test('completeToday() calculates successRate7d with 1/7 completion (first completion)', () {
      // Arrange
      final habit = Habit.create(
        id: 'test-6',
        userId: 'user-1',
        name: 'New Habit',
        description: 'Just starting',
      );

      // Act
      final completed = habit.completeToday();

      // Assert - 1 completion over 7 days = 1/7 ≈ 0.143
      expect(completed.successRate7d, closeTo(1/7, 0.01));
    });

    test('completeToday() resets consecutiveFailures to 0', () {
      // Arrange
      final habit = Habit.create(
        id: 'test-7',
        userId: 'user-1',
        name: 'Recovery',
        description: 'Recovering from failures',
      ).copyWith(
        consecutiveFailures: 5,
      );

      // Act
      final completed = habit.completeToday();

      // Assert
      expect(completed.consecutiveFailures, 0);
    });
  });
}
