import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:habitus_faith/features/habits/domain/models/habit_notification.dart';

void main() {
  group('Habit Notification and Recurrence Tests', () {
    test('HabitNotificationSettings can be created with timing options', () {
      const settings = HabitNotificationSettings(
        timing: NotificationTiming.tenMinutesBefore,
        eventTime: '09:00',
      );

      expect(settings.timing, NotificationTiming.tenMinutesBefore);
      expect(settings.eventTime, '09:00');
      expect(settings.timing.minutesBefore, 10);
    });

    test('HabitNotificationSettings can be serialized to/from JSON', () {
      const settings = HabitNotificationSettings(
        timing: NotificationTiming.atEventTime,
        eventTime: '10:30',
      );

      final json = settings.toJson();
      final restored = HabitNotificationSettings.fromJson(json);

      expect(restored.timing, settings.timing);
      expect(restored.eventTime, settings.eventTime);
    });

    test('HabitRecurrence can be created with frequency and interval', () {
      const recurrence = HabitRecurrence(
        enabled: true,
        frequency: RecurrenceFrequency.daily,
        interval: 2,
      );

      expect(recurrence.enabled, true);
      expect(recurrence.frequency, RecurrenceFrequency.daily);
      expect(recurrence.interval, 2);
    });

    test('HabitRecurrence can be serialized to/from JSON', () {
      final endDate = DateTime(2025, 12, 31);
      final recurrence = HabitRecurrence(
        enabled: true,
        frequency: RecurrenceFrequency.weekly,
        interval: 1,
        endDate: endDate,
      );

      final json = recurrence.toJson();
      final restored = HabitRecurrence.fromJson(json);

      expect(restored.enabled, recurrence.enabled);
      expect(restored.frequency, recurrence.frequency);
      expect(restored.interval, recurrence.interval);
      expect(restored.endDate, recurrence.endDate);
    });

    test('Subtask can be created and toggled', () {
      const subtask = Subtask(
        id: '1',
        title: 'Test subtask',
        completed: false,
      );

      expect(subtask.completed, false);

      final completedSubtask = subtask.copyWith(completed: true);
      expect(completedSubtask.completed, true);
      expect(completedSubtask.title, subtask.title);
    });

    test('Habit can be created with notification settings and subtasks', () {
      const notificationSettings = HabitNotificationSettings(
        timing: NotificationTiming.thirtyMinutesBefore,
        eventTime: '08:00',
      );

      const recurrence = HabitRecurrence(
        enabled: true,
        frequency: RecurrenceFrequency.daily,
        interval: 1,
      );

      const subtask = Subtask(
        id: '1',
        title: 'Complete morning prayer',
        completed: false,
      );

      final habit = Habit.create(
        id: 'test-habit',
        userId: 'test-user',
        name: 'Morning Devotional',
        description: 'Daily morning prayer and meditation',
        category: HabitCategory.spiritual,
      );

      final updatedHabit = habit.copyWith(
        notificationSettings: notificationSettings,
        recurrence: recurrence,
        subtasks: [subtask],
      );

      expect(updatedHabit.notificationSettings, notificationSettings);
      expect(updatedHabit.recurrence, recurrence);
      expect(updatedHabit.subtasks.length, 1);
      expect(updatedHabit.subtasks.first.title, 'Complete morning prayer');
    });

    test('NotificationTiming returns correct minutes before for each option',
        () {
      expect(NotificationTiming.none.minutesBefore, null);
      expect(NotificationTiming.atEventTime.minutesBefore, 0);
      expect(NotificationTiming.tenMinutesBefore.minutesBefore, 10);
      expect(NotificationTiming.thirtyMinutesBefore.minutesBefore, 30);
      expect(NotificationTiming.oneHourBefore.minutesBefore, 60);
      expect(NotificationTiming.custom.minutesBefore, null);
    });
  });
}
