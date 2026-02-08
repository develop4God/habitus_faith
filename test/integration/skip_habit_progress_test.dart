import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/features/habits/data/storage/json_habits_repository.dart';
import 'package:habitus_faith/features/habits/data/storage/json_storage_service.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';

/// Integration tests for skip habit functionality and progress calculation
///
/// Tests verify that:
/// 1. Skipped habits do not affect daily progress percentage
/// 2. Progress is calculated correctly when habits are skipped
/// 3. Statistics properly exclude skipped habits from totals
void main() {
  group('Skip Habit Progress Calculation Tests', () {
    late JsonHabitsRepository repository;
    late SharedPreferences prefs;
    late String testUserId;
    int habitIdCounter = 0;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      final storage = JsonStorageService(prefs);
      // Use a unique user ID for each test to ensure isolation
      testUserId = 'test_user_${DateTime.now().millisecondsSinceEpoch}';
      habitIdCounter = 0; // Reset counter for each test
      repository = JsonHabitsRepository(
        storage: storage,
        userId: testUserId,
        idGenerator: () =>
            'habit_${DateTime.now().millisecondsSinceEpoch}_${habitIdCounter++}',
      );
    });

    tearDown(() {
      repository.dispose();
    });

    test(
      'Daily progress should be 100% when all active habits are completed and one is skipped',
      () async {
        // Create 4 habits
        final habit1Result = await repository.createHabit(
          name: 'Prayer',
          category: HabitCategory.spiritual,
          emoji: '🙏',
        );
        final habit2Result = await repository.createHabit(
          name: 'Exercise',
          category: HabitCategory.physical,
          emoji: '💪',
        );
        final habit3Result = await repository.createHabit(
          name: 'Reading',
          category: HabitCategory.mental,
          emoji: '📚',
        );
        final habit4Result = await repository.createHabit(
          name: 'Meditation',
          category: HabitCategory.mental,
          emoji: '🧘',
        );

        late String habit1Id, habit2Id, habit3Id, habit4Id;
        habit1Result.fold(
          (failure) => fail('Failed to create habit 1'),
          (h) => habit1Id = h.id,
        );
        habit2Result.fold(
          (failure) => fail('Failed to create habit 2'),
          (h) => habit2Id = h.id,
        );
        habit3Result.fold(
          (failure) => fail('Failed to create habit 3'),
          (h) => habit3Id = h.id,
        );
        habit4Result.fold(
          (failure) => fail('Failed to create habit 4'),
          (h) => habit4Id = h.id,
        );

        // Complete 3 habits
        await repository.completeHabit(habit1Id);
        await repository.completeHabit(habit2Id);
        await repository.completeHabit(habit3Id);

        // Skip the 4th habit
        await repository.skipHabit(habit4Id);

        // Get all habits and calculate progress
        final habits = await repository.watchHabits().first;

        // Verify habit states
        final h1 = habits.firstWhere((h) => h.id == habit1Id);
        final h2 = habits.firstWhere((h) => h.id == habit2Id);
        final h3 = habits.firstWhere((h) => h.id == habit3Id);
        final h4 = habits.firstWhere((h) => h.id == habit4Id);

        expect(h1.completedToday, isTrue);
        expect(h2.completedToday, isTrue);
        expect(h3.completedToday, isTrue);
        expect(h4.dailyStatus, equals(HabitDailyStatus.skipped));
        expect(h4.completedToday, isFalse);

        // Calculate progress (excluding skipped habits)
        final activeHabits = habits
            .where((h) => h.dailyStatus != HabitDailyStatus.skipped)
            .toList();
        final completedHabits = activeHabits.where((h) => h.completedToday).length;
        final totalHabits = activeHabits.length;
        final completionPercentage =
            totalHabits > 0 ? (completedHabits / totalHabits * 100).round() : 0;

        // Should be 100% (3 completed out of 3 active habits)
        expect(totalHabits, equals(3),
            reason: 'Should have 3 active habits (skipped excluded)');
        expect(completedHabits, equals(3),
            reason: 'Should have 3 completed habits');
        expect(completionPercentage, equals(100),
            reason: 'Should have 100% progress when all active habits are completed');
      },
    );

    test(
      'Daily progress should be 75% when 3 out of 4 active habits are completed (no skipped)',
      () async {
        // Create 4 habits
        final habit1Result = await repository.createHabit(
          name: 'Prayer',
          category: HabitCategory.spiritual,
          emoji: '🙏',
        );
        final habit2Result = await repository.createHabit(
          name: 'Exercise',
          category: HabitCategory.physical,
          emoji: '💪',
        );
        final habit3Result = await repository.createHabit(
          name: 'Reading',
          category: HabitCategory.mental,
          emoji: '📚',
        );
        final habit4Result = await repository.createHabit(
          name: 'Meditation',
          category: HabitCategory.mental,
          emoji: '🧘',
        );

        late String habit1Id, habit2Id, habit3Id;
        habit1Result.fold(
          (failure) => fail('Failed to create habit 1'),
          (h) => habit1Id = h.id,
        );
        habit2Result.fold(
          (failure) => fail('Failed to create habit 2'),
          (h) => habit2Id = h.id,
        );
        habit3Result.fold(
          (failure) => fail('Failed to create habit 3'),
          (h) => habit3Id = h.id,
        );
        habit4Result.fold(
          (failure) => fail('Failed to create habit 4'),
          (h) {}, // Don't need the ID
        );

        // Complete 3 out of 4 habits (leave one pending)
        await repository.completeHabit(habit1Id);
        await repository.completeHabit(habit2Id);
        await repository.completeHabit(habit3Id);

        // Get all habits and calculate progress
        final habits = await repository.watchHabits().first;

        // Calculate progress (no skipped habits)
        final activeHabits = habits
            .where((h) => h.dailyStatus != HabitDailyStatus.skipped)
            .toList();
        final completedHabits = activeHabits.where((h) => h.completedToday).length;
        final totalHabits = activeHabits.length;
        final completionPercentage =
            totalHabits > 0 ? (completedHabits / totalHabits * 100).round() : 0;

        // Should be 75% (3 completed out of 4 active habits)
        expect(totalHabits, equals(4),
            reason: 'Should have 4 active habits');
        expect(completedHabits, equals(3),
            reason: 'Should have 3 completed habits');
        expect(completionPercentage, equals(75),
            reason: 'Should have 75% progress when 3 out of 4 habits are completed');
      },
    );

    test(
      'Skipped habit should have correct daily status and not be completed',
      () async {
        final habitResult = await repository.createHabit(
          name: 'Prayer',
          category: HabitCategory.spiritual,
          emoji: '🙏',
        );

        late String habitId;
        habitResult.fold(
          (failure) => fail('Failed to create habit'),
          (h) => habitId = h.id,
        );

        // Skip the habit
        final skipResult = await repository.skipHabit(habitId);

        late Habit skippedHabit;
        skipResult.fold(
          (failure) => fail('Failed to skip habit'),
          (h) => skippedHabit = h,
        );

        // Verify the habit is skipped and not completed
        expect(skippedHabit.dailyStatus, equals(HabitDailyStatus.skipped));
        expect(skippedHabit.completedToday, isFalse);
        expect(skippedHabit.skippedDates.isNotEmpty, isTrue);
      },
    );

    test(
      'Progress should handle mix of completed, skipped, and pending habits',
      () async {
        // Create 5 habits
        final habits = <String>[];
        for (int i = 0; i < 5; i++) {
          final result = await repository.createHabit(
            name: 'Habit $i',
            category: HabitCategory.spiritual,
            emoji: '✨',
          );
          result.fold(
            (failure) => fail('Failed to create habit $i'),
            (h) => habits.add(h.id),
          );
        }

        // Complete 2 habits
        await repository.completeHabit(habits[0]);
        await repository.completeHabit(habits[1]);

        // Skip 2 habits
        await repository.skipHabit(habits[2]);
        await repository.skipHabit(habits[3]);

        // Leave 1 habit pending (habits[4])

        // Get all habits and calculate progress
        final allHabits = await repository.watchHabits().first;

        // Calculate progress (excluding skipped habits)
        final activeHabits = allHabits
            .where((h) => h.dailyStatus != HabitDailyStatus.skipped)
            .toList();
        final completedHabits = activeHabits.where((h) => h.completedToday).length;
        final totalHabits = activeHabits.length;
        final completionPercentage =
            totalHabits > 0 ? (completedHabits / totalHabits * 100).round() : 0;

        // Should be 67% (2 completed out of 3 active habits: 2 completed + 1 pending)
        expect(totalHabits, equals(3),
            reason: 'Should have 3 active habits (2 skipped excluded)');
        expect(completedHabits, equals(2),
            reason: 'Should have 2 completed habits');
        expect(completionPercentage, equals(67),
            reason: 'Should have 67% progress (2/3)');
      },
    );

    test(
      'Progress should be 0% when all habits are skipped',
      () async {
        // Create 3 habits
        final habits = <String>[];
        for (int i = 0; i < 3; i++) {
          final result = await repository.createHabit(
            name: 'Habit $i',
            category: HabitCategory.spiritual,
            emoji: '✨',
          );
          result.fold(
            (failure) => fail('Failed to create habit $i'),
            (h) => habits.add(h.id),
          );
        }

        // Skip all habits
        for (int i = 0; i < habits.length; i++) {
          final habitId = habits[i];
          final skipResult = await repository.skipHabit(habitId);
          skipResult.fold(
            (failure) => fail('Failed to skip habit $i: $failure'),
            (h) => expect(h.dailyStatus, equals(HabitDailyStatus.skipped)),
          );
        }

        // Get all habits and calculate progress
        final allHabits = await repository.watchHabits().first;

        // Calculate progress (excluding skipped habits)
        final activeHabits = allHabits
            .where((h) => h.dailyStatus != HabitDailyStatus.skipped)
            .toList();
        final totalHabits = activeHabits.length;
        final completionPercentage =
            totalHabits > 0 ? (activeHabits.where((h) => h.completedToday).length / totalHabits * 100).round() : 0;

        // Should be 0% (no active habits)
        expect(totalHabits, equals(0),
            reason: 'Should have 0 active habits (all skipped)');
        expect(completionPercentage, equals(0),
            reason: 'Should have 0% progress when all habits are skipped');
      },
    );
  });
}
