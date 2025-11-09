import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';

void main() {
  group('Habit - Pure Domain Logic (Streak calculation)', () {
    test('First completion sets streak to 1', () {
      // Arrange
      final habit = Habit.create(
        id: 'test-1',
        userId: 'user-1',
        name: 'Oración',
        description: 'Orar diariamente',
      );

      // Act
      final completed = habit.completeToday();

      // Assert
      expect(completed.currentStreak, 1);
      expect(completed.longestStreak, 1);
      expect(completed.completedToday, true);
      expect(completed.completionHistory.length, 1);
    });

    test('Consecutive days increment streak', () {
      // Arrange
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final yesterdayDate = DateTime(
        yesterday.year,
        yesterday.month,
        yesterday.day,
      );

      final habit =
          Habit.create(
            id: 'test-2',
            userId: 'user-1',
            name: 'Lectura',
            description: 'Leer la Biblia',
          ).copyWith(
            currentStreak: 5,
            longestStreak: 5,
            lastCompletedAt: yesterdayDate,
            completionHistory: [yesterdayDate],
          );

      // Act
      final completed = habit.completeToday();

      // Assert
      expect(completed.currentStreak, 6);
      expect(completed.longestStreak, 6);
      expect(completed.completionHistory.length, 2);
    });

    test('Gap resets current streak, preserves longest', () {
      // Arrange
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      final threeDaysAgoDate = DateTime(
        threeDaysAgo.year,
        threeDaysAgo.month,
        threeDaysAgo.day,
      );

      final habit =
          Habit.create(
            id: 'test-3',
            userId: 'user-1',
            name: 'Servicio',
            description: 'Servir a otros',
          ).copyWith(
            currentStreak: 10,
            longestStreak: 15,
            lastCompletedAt: threeDaysAgoDate,
            completionHistory: [threeDaysAgoDate],
          );

      // Act
      final completed = habit.completeToday();

      // Assert
      expect(
        completed.currentStreak,
        1,
        reason: 'Streak should reset to 1 after gap',
      );
      expect(
        completed.longestStreak,
        15,
        reason: 'Longest streak should be preserved',
      );
    });

    test('Same day completion is idempotent', () {
      // Arrange
      final habit = Habit.create(
        id: 'test-4',
        userId: 'user-1',
        name: 'Gratitud',
        description: 'Agradecer',
      );

      // Act
      final firstComplete = habit.completeToday();
      final secondComplete = firstComplete.completeToday();

      // Assert
      expect(
        secondComplete.currentStreak,
        1,
        reason: 'Should not increase streak on same day',
      );
      expect(
        secondComplete.completionHistory.length,
        1,
        reason: 'Should not add duplicate completion',
      );
      // Verify idempotency - should return same instance when already completed
      expect(
        identical(firstComplete, secondComplete),
        isTrue,
        reason: 'Should return same instance for idempotent operation',
      );
      expect(secondComplete.currentStreak, firstComplete.currentStreak);
      expect(
        secondComplete.completionHistory.length,
        firstComplete.completionHistory.length,
      );
    });
  });
}
