import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/ai/behavioral_engine.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';

void main() {
  late BehavioralEngine engine;

  setUp(() {
    engine = BehavioralEngine();
  });

  group('BehavioralEngine - calculateNextDifficulty', () {
    test('Increases difficulty when successRate >= 0.85 and level < 5', () {
      // Arrange
      final habit = Habit.create(
        id: 'test-1',
        userId: 'user-1',
        name: 'High Success',
        description: 'Doing great',
      ).copyWith(difficultyLevel: 3, successRate7d: 0.87);

      // Act
      final nextDifficulty = engine.calculateNextDifficulty(habit);

      // Assert
      expect(nextDifficulty, 4);
    });

    test('Does not increase difficulty when at max level 5', () {
      // Arrange
      final habit = Habit.create(
        id: 'test-2',
        userId: 'user-1',
        name: 'Max Level',
        description: 'Already at peak',
      ).copyWith(difficultyLevel: 5, successRate7d: 0.87);

      // Act
      final nextDifficulty = engine.calculateNextDifficulty(habit);

      // Assert
      expect(nextDifficulty, 5);
    });

    test('Decreases difficulty when successRate < 0.50 and level > 1', () {
      // Arrange
      final habit = Habit.create(
        id: 'test-3',
        userId: 'user-1',
        name: 'Struggling',
        description: 'Need easier challenge',
      ).copyWith(difficultyLevel: 3, successRate7d: 0.45);

      // Act
      final nextDifficulty = engine.calculateNextDifficulty(habit);

      // Assert
      expect(nextDifficulty, 2);
    });

    test('Does not decrease difficulty when at min level 1', () {
      // Arrange
      final habit = Habit.create(
        id: 'test-4',
        userId: 'user-1',
        name: 'Min Level',
        description: 'Already at easiest',
      ).copyWith(difficultyLevel: 1, successRate7d: 0.45);

      // Act
      final nextDifficulty = engine.calculateNextDifficulty(habit);

      // Assert
      expect(nextDifficulty, 1);
    });

    test('Maintains difficulty when successRate is moderate (0.50-0.84)', () {
      // Arrange
      final habit = Habit.create(
        id: 'test-5',
        userId: 'user-1',
        name: 'Moderate',
        description: 'Just right',
      ).copyWith(difficultyLevel: 3, successRate7d: 0.71);

      // Act
      final nextDifficulty = engine.calculateNextDifficulty(habit);

      // Assert
      expect(nextDifficulty, 3);
    });
  });

  group('BehavioralEngine - findOptimalTime', () {
    test('Returns null for empty completion history', () {
      // Arrange
      final habit = Habit.create(
        id: 'test-6',
        userId: 'user-1',
        name: 'No Completions',
        description: 'Never completed',
      );

      // Act
      final optimalTime = engine.findOptimalTime(habit);

      // Assert
      expect(optimalTime, isNull);
    });

    test('Returns null for insufficient data (< 3 completions)', () {
      // Arrange
      final now = DateTime.now();
      final habit =
          Habit.create(
            id: 'test-7',
            userId: 'user-1',
            name: 'Few Completions',
            description: 'Only 2 completions',
          ).copyWith(
            completionHistory: [
              now.subtract(const Duration(days: 2)),
              now.subtract(const Duration(days: 1)),
            ],
          );

      // Act
      final optimalTime = engine.findOptimalTime(habit);

      // Assert
      expect(optimalTime, isNull);
    });

    test(
      'Returns hour of single completion when exactly 3 completions at same hour',
      () {
        // Arrange
        final now = DateTime.now();
        final sevenAM = DateTime(now.year, now.month, now.day, 7, 0);
        final habit =
            Habit.create(
              id: 'test-8',
              userId: 'user-1',
              name: 'Morning Routine',
              description: 'Always at 7am',
            ).copyWith(
              completionHistory: [
                sevenAM.subtract(const Duration(days: 2)),
                sevenAM.subtract(const Duration(days: 1)),
                sevenAM,
              ],
            );

        // Act
        final optimalTime = engine.findOptimalTime(habit);

        // Assert
        expect(optimalTime, isNotNull);
        expect(optimalTime!.hour, 7);
        expect(optimalTime.minute, 0);
      },
    );

    test(
      'Returns most frequent hour with mixed times (7am wins: 5 vs 9am: 4 vs 8am: 1)',
      () {
        // Arrange
        final now = DateTime.now();
        final baseDate = DateTime(now.year, now.month, now.day);
        final habit =
            Habit.create(
              id: 'test-9',
              userId: 'user-1',
              name: 'Mixed Times',
              description: 'Various completion times',
            ).copyWith(
              completionHistory: [
                baseDate
                    .subtract(const Duration(days: 9))
                    .add(const Duration(hours: 7)),
                baseDate
                    .subtract(const Duration(days: 8))
                    .add(const Duration(hours: 9)),
                baseDate
                    .subtract(const Duration(days: 7))
                    .add(const Duration(hours: 7)),
                baseDate
                    .subtract(const Duration(days: 6))
                    .add(const Duration(hours: 9)),
                baseDate
                    .subtract(const Duration(days: 5))
                    .add(const Duration(hours: 7)),
                baseDate
                    .subtract(const Duration(days: 4))
                    .add(const Duration(hours: 9)),
                baseDate
                    .subtract(const Duration(days: 3))
                    .add(const Duration(hours: 7)),
                baseDate
                    .subtract(const Duration(days: 2))
                    .add(const Duration(hours: 9)),
                baseDate
                    .subtract(const Duration(days: 1))
                    .add(const Duration(hours: 7)),
                baseDate.add(const Duration(hours: 8)),
              ],
            );

        // Act
        final optimalTime = engine.findOptimalTime(habit);

        // Assert
        expect(optimalTime, isNotNull);
        expect(
          optimalTime!.hour,
          7,
          reason: '7am appears 5 times, most frequent',
        );
        expect(optimalTime.minute, 0);
      },
    );

    test(
      'Returns most frequent hour for tie-breaking (first encountered in frequency map)',
      () {
        // Arrange
        final now = DateTime.now();
        final baseDate = DateTime(now.year, now.month, now.day);
        final habit =
            Habit.create(
              id: 'test-10',
              userId: 'user-1',
              name: 'Tie Scenario',
              description: 'Equal frequency',
            ).copyWith(
              completionHistory: [
                baseDate
                    .subtract(const Duration(days: 5))
                    .add(const Duration(hours: 7)),
                baseDate
                    .subtract(const Duration(days: 4))
                    .add(const Duration(hours: 9)),
                baseDate
                    .subtract(const Duration(days: 3))
                    .add(const Duration(hours: 7)),
                baseDate
                    .subtract(const Duration(days: 2))
                    .add(const Duration(hours: 9)),
                baseDate
                    .subtract(const Duration(days: 1))
                    .add(const Duration(hours: 7)),
                baseDate.add(const Duration(hours: 9)),
              ],
            );

        // Act
        final optimalTime = engine.findOptimalTime(habit);

        // Assert - Both 7am and 9am appear 3 times, but we just need A result
        expect(optimalTime, isNotNull);
        expect([7, 9].contains(optimalTime!.hour), isTrue);
      },
    );
  });

  group('BehavioralEngine - findOptimalDays', () {
    test('Returns empty list for insufficient data (< 5 completions)', () {
      // Arrange
      final now = DateTime.now();
      final habit =
          Habit.create(
            id: 'test-11',
            userId: 'user-1',
            name: 'Few Completions',
            description: 'Only 4 completions',
          ).copyWith(
            completionHistory: [
              now.subtract(const Duration(days: 4)),
              now.subtract(const Duration(days: 3)),
              now.subtract(const Duration(days: 2)),
              now.subtract(const Duration(days: 1)),
            ],
          );

      // Act
      final optimalDays = engine.findOptimalDays(habit);

      // Assert
      expect(optimalDays, isEmpty);
    });

    test('Returns top 3 most frequent days for Mon/Wed/Fri pattern', () {
      // Arrange
      final now = DateTime.now();
      // Find a Monday to start from
      final monday = now.subtract(Duration(days: now.weekday - 1));

      final habit =
          Habit.create(
            id: 'test-12',
            userId: 'user-1',
            name: 'MWF Pattern',
            description: 'Mon/Wed/Fri completion pattern',
          ).copyWith(
            completionHistory: [
              monday.subtract(const Duration(days: 14)), // Mon, 2 weeks ago
              monday.subtract(const Duration(days: 12)), // Wed
              monday.subtract(const Duration(days: 10)), // Fri
              monday.subtract(const Duration(days: 7)), // Mon, last week
              monday.subtract(const Duration(days: 5)), // Wed
              monday.subtract(const Duration(days: 3)), // Fri
              monday, // Mon, this week
            ],
          );

      // Act
      final optimalDays = engine.findOptimalDays(habit);

      // Assert - Should return [1, 3, 5] representing Monday, Wednesday, Friday
      expect(optimalDays.length, 3);
      expect(optimalDays.contains(1), isTrue, reason: 'Should include Monday');
      expect(
        optimalDays.contains(3),
        isTrue,
        reason: 'Should include Wednesday',
      );
      expect(optimalDays.contains(5), isTrue, reason: 'Should include Friday');
    });

    test('Returns days sorted by frequency (descending)', () {
      // Arrange
      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));

      final habit =
          Habit.create(
            id: 'test-13',
            userId: 'user-1',
            name: 'Varied Frequency',
            description: 'Different day frequencies',
          ).copyWith(
            completionHistory: [
              // Monday appears 4 times
              monday.subtract(const Duration(days: 21)),
              monday.subtract(const Duration(days: 14)),
              monday.subtract(const Duration(days: 7)),
              monday,
              // Tuesday appears 2 times
              monday.subtract(const Duration(days: 20)),
              monday.subtract(const Duration(days: 13)),
              // Wednesday appears 3 times
              monday.subtract(const Duration(days: 19)),
              monday.subtract(const Duration(days: 12)),
              monday.subtract(const Duration(days: 5)),
            ],
          );

      // Act
      final optimalDays = engine.findOptimalDays(habit);

      // Assert - Should return top 3: [1 (Mon-4), 3 (Wed-3), 2 (Tue-2)]
      expect(optimalDays.length, 3);
      expect(
        optimalDays[0],
        1,
        reason: 'Monday should be first (4 occurrences)',
      );
      expect(
        optimalDays[1],
        3,
        reason: 'Wednesday should be second (3 occurrences)',
      );
      expect(
        optimalDays[2],
        2,
        reason: 'Tuesday should be third (2 occurrences)',
      );
    });

    test('Returns fewer than 3 days if only 1-2 unique days completed', () {
      // Arrange
      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));

      final habit =
          Habit.create(
            id: 'test-14',
            userId: 'user-1',
            name: 'Only Mondays',
            description: 'Completed only on Mondays',
          ).copyWith(
            completionHistory: [
              monday.subtract(const Duration(days: 21)),
              monday.subtract(const Duration(days: 14)),
              monday.subtract(const Duration(days: 7)),
              monday,
              monday.add(const Duration(hours: 1)), // Still Monday
            ],
          );

      // Act
      final optimalDays = engine.findOptimalDays(habit);

      // Assert - Only 1 unique day (Monday)
      expect(optimalDays.length, 1);
      expect(optimalDays[0], 1);
    });
  });

  group('BehavioralEngine - detectFailurePattern', () {
    test('Returns null when consecutiveFailures < 3', () {
      // Arrange
      final habit = Habit.create(
        id: 'test-15',
        userId: 'user-1',
        name: 'Few Failures',
        description: 'Not enough failures',
      ).copyWith(consecutiveFailures: 2);

      // Act
      final pattern = engine.detectFailurePattern(habit);

      // Assert
      expect(pattern, isNull);
    });

    test('Detects weekendGap when weekdays succeed but weekends fail', () {
      // Arrange
      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));

      final habit =
          Habit.create(
            id: 'test-16',
            userId: 'user-1',
            name: 'Weekday Only',
            description: 'No weekend completions',
          ).copyWith(
            consecutiveFailures: 3,
            completionHistory: [
              // Only weekdays: Mon, Tue, Wed, Thu, Fri from last 7 days
              monday.subtract(const Duration(days: 7)), // Mon
              monday.subtract(const Duration(days: 6)), // Tue
              monday.subtract(const Duration(days: 5)), // Wed
              monday.subtract(const Duration(days: 4)), // Thu
              monday.subtract(const Duration(days: 3)), // Fri
              // No Saturday or Sunday completions
            ],
          );

      // Act
      final pattern = engine.detectFailurePattern(habit);

      // Assert
      expect(pattern, FailurePattern.weekendGap);
    });

    test('Detects eveningSlump when only morning completions', () {
      // Arrange
      final now = DateTime.now();
      final baseDate = DateTime(now.year, now.month, now.day);

      final habit =
          Habit.create(
            id: 'test-17',
            userId: 'user-1',
            name: 'Morning Only',
            description: 'No evening completions',
          ).copyWith(
            consecutiveFailures: 3,
            completionHistory: [
              baseDate
                  .subtract(const Duration(days: 6))
                  .add(const Duration(hours: 8)),
              baseDate
                  .subtract(const Duration(days: 5))
                  .add(const Duration(hours: 9)),
              baseDate
                  .subtract(const Duration(days: 4))
                  .add(const Duration(hours: 7)),
              // All before 6pm (18:00), none after
            ],
          );

      // Act
      final pattern = engine.detectFailurePattern(habit);

      // Assert
      expect(pattern, FailurePattern.eveningSlump);
    });

    test('Detects inconsistent when no clear pattern', () {
      // Arrange
      final now = DateTime.now();
      final baseDate = DateTime(now.year, now.month, now.day);

      final habit =
          Habit.create(
            id: 'test-18',
            userId: 'user-1',
            name: 'Random Pattern',
            description: 'No specific pattern',
          ).copyWith(
            consecutiveFailures: 3,
            completionHistory: [
              // Mixed days and times
              baseDate
                  .subtract(const Duration(days: 6))
                  .add(const Duration(hours: 8)), // Mon morning
              baseDate
                  .subtract(const Duration(days: 5))
                  .add(const Duration(hours: 20)), // Tue evening
              baseDate
                  .subtract(const Duration(days: 3))
                  .add(const Duration(hours: 14)), // Thu afternoon
              baseDate
                  .subtract(const Duration(days: 1))
                  .add(const Duration(hours: 19)), // Sat evening
            ],
          );

      // Act
      final pattern = engine.detectFailurePattern(habit);

      // Assert
      expect(pattern, FailurePattern.inconsistent);
    });

    test(
      'Returns null for empty completion history with consecutive failures',
      () {
        // Arrange
        final habit = Habit.create(
          id: 'test-19',
          userId: 'user-1',
          name: 'Never Completed',
          description: 'No completions at all',
        ).copyWith(consecutiveFailures: 5, completionHistory: []);

        // Act
        final pattern = engine.detectFailurePattern(habit);

        // Assert - Can't detect pattern without data
        expect(pattern, isNull);
      },
    );
  });
}
