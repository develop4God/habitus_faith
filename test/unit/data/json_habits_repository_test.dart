import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/features/habits/data/storage/json_storage_service.dart';
import 'package:habitus_faith/features/habits/data/storage/json_habits_repository.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';

void main() {
  late JsonHabitsRepository repository;
  late JsonStorageService storage;
  int idCounter = 0;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    storage = JsonStorageService(prefs);
    idCounter = 0;
    repository = JsonHabitsRepository(
      storage: storage,
      userId: 'test_user',
      idGenerator: () => 'habit_${idCounter++}',
    );
  });

  group('JsonHabitsRepository - Completion Tracking', () {
    test('createHabit creates habit successfully', () async {
      final result = await repository.createHabit(
        name: 'Test Habit',
        description: 'Test Description',
        category: HabitCategory.prayer,
      );

      expect(result.isSuccess(), isTrue);
      final habit = result.value;
      expect(habit.name, 'Test Habit');
      expect(habit.currentStreak, 0);
      expect(habit.completedToday, isFalse);
    });

    test('completeHabit marks habit as completed and creates completion record', () async {
      // Create a habit
      final createResult = await repository.createHabit(
        name: 'Test Habit',
        description: 'Test Description',
      );
      final habitId = createResult.value.id;

      // Complete the habit
      final completeResult = await repository.completeHabit(habitId);

      expect(completeResult.isSuccess(), isTrue);
      final completedHabit = completeResult.value;
      expect(completedHabit.completedToday, isTrue);
      expect(completedHabit.currentStreak, 1);
      expect(completedHabit.completionHistory.length, 1);
    });

    test('completeHabit is idempotent - completing twice same day returns same result', () async {
      final createResult = await repository.createHabit(
        name: 'Test Habit',
        description: 'Test Description',
      );
      final habitId = createResult.value.id;

      // Complete once
      await repository.completeHabit(habitId);

      // Complete again
      final secondComplete = await repository.completeHabit(habitId);

      expect(secondComplete.isSuccess(), isTrue);
      final habit = secondComplete.value;
      expect(habit.currentStreak, 1);
      expect(habit.completionHistory.length, 1);
    });

    test('streak calculation works correctly for consecutive days', () async {
      final createResult = await repository.createHabit(
        name: 'Test Habit',
        description: 'Test Description',
      );
      final habitId = createResult.value.id;

      // Simulate completions on multiple consecutive days
      final now = DateTime.now();
      
      // Manually inject completion records for testing
      final completionsData = <String, dynamic>{
        habitId: {
          _dateKey(now.subtract(const Duration(days: 2))): {
            'habitId': habitId,
            'completedAt': now.subtract(const Duration(days: 2)).toIso8601String(),
          },
          _dateKey(now.subtract(const Duration(days: 1))): {
            'habitId': habitId,
            'completedAt': now.subtract(const Duration(days: 1)).toIso8601String(),
          },
        },
      };
      await storage.saveJson('completions', completionsData);

      // Complete today
      final result = await repository.completeHabit(habitId);

      expect(result.isSuccess(), isTrue);
      final habit = result.value;
      expect(habit.currentStreak, 3); // 3 consecutive days
      expect(habit.completionHistory.length, 3);
    });

    test('streak resets when there is a gap', () async {
      final createResult = await repository.createHabit(
        name: 'Test Habit',
        description: 'Test Description',
      );
      final habitId = createResult.value.id;

      final now = DateTime.now();
      
      // Inject completions with a gap
      final completionsData = <String, dynamic>{
        habitId: {
          _dateKey(now.subtract(const Duration(days: 5))): {
            'habitId': habitId,
            'completedAt': now.subtract(const Duration(days: 5)).toIso8601String(),
          },
          _dateKey(now.subtract(const Duration(days: 4))): {
            'habitId': habitId,
            'completedAt': now.subtract(const Duration(days: 4)).toIso8601String(),
          },
          // Gap here (days 3, 2)
        },
      };
      await storage.saveJson('completions', completionsData);

      // Complete today
      final result = await repository.completeHabit(habitId);

      expect(result.isSuccess(), isTrue);
      final habit = result.value;
      expect(habit.currentStreak, 1); // Reset to 1 because of gap
    });

    test('longestStreak is calculated correctly', () async {
      final createResult = await repository.createHabit(
        name: 'Test Habit',
        description: 'Test Description',
      );
      final habitId = createResult.value.id;

      final now = DateTime.now();
      
      // Create a pattern: 3 days, gap, 5 days
      final completionsData = <String, dynamic>{
        habitId: {
          // First streak of 3
          _dateKey(now.subtract(const Duration(days: 10))): {
            'habitId': habitId,
            'completedAt': now.subtract(const Duration(days: 10)).toIso8601String(),
          },
          _dateKey(now.subtract(const Duration(days: 9))): {
            'habitId': habitId,
            'completedAt': now.subtract(const Duration(days: 9)).toIso8601String(),
          },
          _dateKey(now.subtract(const Duration(days: 8))): {
            'habitId': habitId,
            'completedAt': now.subtract(const Duration(days: 8)).toIso8601String(),
          },
          // Gap
          // Second streak of 5
          _dateKey(now.subtract(const Duration(days: 5))): {
            'habitId': habitId,
            'completedAt': now.subtract(const Duration(days: 5)).toIso8601String(),
          },
          _dateKey(now.subtract(const Duration(days: 4))): {
            'habitId': habitId,
            'completedAt': now.subtract(const Duration(days: 4)).toIso8601String(),
          },
          _dateKey(now.subtract(const Duration(days: 3))): {
            'habitId': habitId,
            'completedAt': now.subtract(const Duration(days: 3)).toIso8601String(),
          },
          _dateKey(now.subtract(const Duration(days: 2))): {
            'habitId': habitId,
            'completedAt': now.subtract(const Duration(days: 2)).toIso8601String(),
          },
          _dateKey(now.subtract(const Duration(days: 1))): {
            'habitId': habitId,
            'completedAt': now.subtract(const Duration(days: 1)).toIso8601String(),
          },
        },
      };
      await storage.saveJson('completions', completionsData);

      // Complete today to make current streak 6
      final result = await repository.completeHabit(habitId);

      expect(result.isSuccess(), isTrue);
      final habit = result.value;
      expect(habit.currentStreak, 6);
      expect(habit.longestStreak, 6); // Longest is the current 6-day streak
    });

    test('deleteHabit removes habit from storage', () async {
      final createResult = await repository.createHabit(
        name: 'Test Habit',
        description: 'Test Description',
      );
      final habitId = createResult.value.id;

      final deleteResult = await repository.deleteHabit(habitId);

      expect(deleteResult.isSuccess(), isTrue);
    });
  });
}

String _dateKey(DateTime date) {
  final dateOnly = DateTime(date.year, date.month, date.day);
  return dateOnly.toIso8601String().split('T')[0];
}
