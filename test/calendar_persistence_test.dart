import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/features/habits/data/storage/json_habits_repository.dart';
import 'package:habitus_faith/features/habits/data/storage/json_storage_service.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:habitus_faith/features/habits/domain/models/calendar_completion_log.dart';
import 'package:habitus_faith/features/habits/data/storage/calendar_persistence_service.dart';

void main() {
  group('Calendar Navigation and Persistence Tests', () {
    late SharedPreferences prefs;
    late CalendarPersistenceService calendarService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      calendarService = CalendarPersistenceService(prefs);
    });

    test('Should save and retrieve calendar logs for a specific date', () async {
      final testDate = DateTime(2024, 1, 15);
      final logs = [
        CalendarCompletionLog(
          habitId: 'habit_1',
          habitName: 'Morning Prayer',
          date: testDate,
          completed: true,
          note: 'Great start to the day',
        ),
        CalendarCompletionLog(
          habitId: 'habit_2',
          habitName: 'Bible Reading',
          date: testDate,
          completed: false,
        ),
      ];

      // Save logs
      await calendarService.saveLogsForDate(testDate, logs);

      // Retrieve logs
      final retrieved = await calendarService.getLogsForDate(testDate);

      expect(retrieved.length, equals(2));
      expect(retrieved[0].habitId, equals('habit_1'));
      expect(retrieved[0].completed, equals(true));
      expect(retrieved[0].note, equals('Great start to the day'));
      expect(retrieved[1].habitId, equals('habit_2'));
      expect(retrieved[1].completed, equals(false));
    });

    test('Should retrieve logs for a date range', () async {
      final date1 = DateTime(2024, 1, 15);
      final date2 = DateTime(2024, 1, 16);
      final date3 = DateTime(2024, 1, 17);

      // Save logs for different dates
      await calendarService.saveLogsForDate(date1, [
        CalendarCompletionLog(
          habitId: 'habit_1',
          habitName: 'Prayer',
          date: date1,
          completed: true,
        ),
      ]);

      await calendarService.saveLogsForDate(date2, [
        CalendarCompletionLog(
          habitId: 'habit_1',
          habitName: 'Prayer',
          date: date2,
          completed: false,
        ),
      ]);

      await calendarService.saveLogsForDate(date3, [
        CalendarCompletionLog(
          habitId: 'habit_1',
          habitName: 'Prayer',
          date: date3,
          completed: true,
        ),
      ]);

      // Retrieve logs for range
      final logsMap = await calendarService.getLogsForRange(date1, date3);

      expect(logsMap.length, equals(3));
      expect(logsMap['2024-01-15']!.first.completed, equals(true));
      expect(logsMap['2024-01-16']!.first.completed, equals(false));
      expect(logsMap['2024-01-17']!.first.completed, equals(true));
    });

    test('Should return empty list for dates with no logs', () async {
      final testDate = DateTime(2024, 1, 15);
      final retrieved = await calendarService.getLogsForDate(testDate);

      expect(retrieved, isEmpty);
    });

    test('Should properly serialize and deserialize calendar logs', () {
      final testDate = DateTime(2024, 1, 15);
      final log = CalendarCompletionLog(
        habitId: 'habit_1',
        habitName: 'Morning Prayer',
        date: testDate,
        completed: true,
        note: 'Test note',
      );

      final json = log.toJson();
      final restored = CalendarCompletionLog.fromJson(json);

      expect(restored.habitId, equals(log.habitId));
      expect(restored.habitName, equals(log.habitName));
      expect(restored.date, equals(log.date));
      expect(restored.completed, equals(log.completed));
      expect(restored.note, equals(log.note));
    });

    test('Should generate correct date key', () {
      final date1 = DateTime(2024, 1, 5);
      final date2 = DateTime(2024, 12, 25);

      final log1 = CalendarCompletionLog(
        habitId: 'habit_1',
        habitName: 'Test',
        date: date1,
        completed: true,
      );

      final log2 = CalendarCompletionLog(
        habitId: 'habit_2',
        habitName: 'Test',
        date: date2,
        completed: true,
      );

      expect(log1.dateKey, equals('2024-01-05'));
      expect(log2.dateKey, equals('2024-12-25'));
    });

    test('Should update existing logs for a date', () async {
      final testDate = DateTime(2024, 1, 15);

      // Save initial logs
      await calendarService.saveLogsForDate(testDate, [
        CalendarCompletionLog(
          habitId: 'habit_1',
          habitName: 'Prayer',
          date: testDate,
          completed: true,
        ),
      ]);

      // Update with new logs
      await calendarService.saveLogsForDate(testDate, [
        CalendarCompletionLog(
          habitId: 'habit_1',
          habitName: 'Prayer',
          date: testDate,
          completed: false,
        ),
        CalendarCompletionLog(
          habitId: 'habit_2',
          habitName: 'Bible Reading',
          date: testDate,
          completed: true,
        ),
      ]);

      final retrieved = await calendarService.getLogsForDate(testDate);

      expect(retrieved.length, equals(2));
      expect(retrieved[0].completed, equals(false));
      expect(retrieved[1].habitId, equals('habit_2'));
    });
  });

  group('Calendar Integration with Habits', () {
    late SharedPreferences prefs;
    late JsonStorageService storageService;
    late JsonHabitsRepository repository;
    late CalendarPersistenceService calendarService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      storageService = JsonStorageService(prefs);
      repository = JsonHabitsRepository(
        storage: storageService,
        userId: 'test_user',
        idGenerator: () => DateTime.now().microsecondsSinceEpoch.toString(),
      );
      calendarService = CalendarPersistenceService(prefs);
    });

    test('Should sync habit completions to calendar logs', () async {
      // Create test habits
      final result1 = await repository.createHabit(
        name: 'Morning Prayer',
        category: HabitCategory.spiritual,
        emoji: '🙏',
      );

      final result2 = await repository.createHabit(
        name: 'Bible Reading',
        category: HabitCategory.spiritual,
        emoji: '📖',
      );

      late Habit habit1, habit2;
      result1.fold(
        (failure) => fail('Failed to create habit 1'),
        (habit) => habit1 = habit,
      );
      result2.fold(
        (failure) => fail('Failed to create habit 2'),
        (habit) => habit2 = habit,
      );

      // Complete first habit
      final completeResult = await repository.completeHabit(habit1.id);
      late Habit completedHabit;
      completeResult.fold(
        (failure) => fail('Failed to complete habit'),
        (habit) => completedHabit = habit,
      );

      // Sync to calendar
      final habits = [completedHabit, habit2];
      final testDate = DateTime.now();

      final logs = habits.map((habit) {
        return CalendarCompletionLog(
          habitId: habit.id,
          habitName: habit.name,
          date: testDate,
          completed: habit.completedToday,
        );
      }).toList();

      await calendarService.saveLogsForDate(testDate, logs);

      // Verify calendar logs
      final retrieved = await calendarService.getLogsForDate(testDate);

      expect(retrieved.length, equals(2));

      final log1 = retrieved.firstWhere((log) => log.habitId == habit1.id);
      expect(log1.completed, equals(true));
      expect(log1.habitName, equals('Morning Prayer'));

      final log2 = retrieved.firstWhere((log) => log.habitId == habit2.id);
      expect(log2.completed, equals(false));
      expect(log2.habitName, equals('Bible Reading'));
    });
  });
}
