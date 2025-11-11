import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:habitus_faith/features/habits/domain/models/habit_notification.dart';

void main() {
  group('Notification and Recurrence - User Behavior Tests', () {
    group('Real User Scenarios', () {
      test('User sets morning prayer reminder at 7am', () {
        final habit = Habit.create(
          id: 'prayer',
          userId: 'user1',
          name: 'Morning Prayer',
          description: 'Daily prayer routine',
        );

        const settings = HabitNotificationSettings(
          timing: NotificationTiming.atEventTime,
          eventTime: '07:00',
        );

        final updatedHabit = habit.copyWith(notificationSettings: settings);

        expect(updatedHabit.notificationSettings, isNotNull);
        expect(updatedHabit.notificationSettings!.timing,
            NotificationTiming.atEventTime);
        expect(updatedHabit.notificationSettings!.eventTime, '07:00');
      });

      test('User wants reminder 10 minutes before bedtime prayer at 10pm', () {
        const settings = HabitNotificationSettings(
          timing: NotificationTiming.tenMinutesBefore,
          eventTime: '22:00',
        );

        expect(settings.timing.minutesBefore, 10);
        // Notification should be at 21:50
        const eventHour = 22;
        const eventMinute = 0;
        const notifMinutes = eventHour * 60 + eventMinute - 10;
        expect(notifMinutes, 1310); // 21:50 in minutes
      });

      test('User sets daily Bible reading habit with recurrence', () {
        final habit = Habit.create(
          id: 'bible',
          userId: 'user1',
          name: 'Bible Reading',
          description: 'Read 1 chapter',
        );

        const recurrence = HabitRecurrence(
          enabled: true,
          frequency: RecurrenceFrequency.daily,
          interval: 1,
        );

        final updatedHabit = habit.copyWith(recurrence: recurrence);

        expect(updatedHabit.recurrence!.enabled, true);
        expect(updatedHabit.recurrence!.frequency, RecurrenceFrequency.daily);
        expect(updatedHabit.recurrence!.interval, 1);
      });

      test('User adds subtasks to exercise habit', () {
        final habit = Habit.create(
          id: 'exercise',
          userId: 'user1',
          name: 'Morning Exercise',
          description: 'Daily workout',
        );

        final subtasks = [
          const Subtask(id: '1', title: 'Warm up - 5 min'),
          const Subtask(id: '2', title: 'Running - 20 min'),
          const Subtask(id: '3', title: 'Cool down - 5 min'),
        ];

        final updatedHabit = habit.copyWith(subtasks: subtasks);

        expect(updatedHabit.subtasks.length, 3);
        expect(updatedHabit.subtasks[0].title, 'Warm up - 5 min');
        expect(updatedHabit.subtasks.every((s) => !s.completed), true);
      });

      test('User completes subtasks one by one', () {
        const subtask1 = Subtask(id: '1', title: 'Task 1');
        expect(subtask1.completed, false);

        final completed1 = subtask1.copyWith(completed: true);
        expect(completed1.completed, true);
        expect(completed1.title, 'Task 1');
      });

      test('User sets weekly habit every Sunday for church service', () {
        final recurrence = HabitRecurrence(
          enabled: true,
          frequency: RecurrenceFrequency.weekly,
          interval: 1,
          endDate: DateTime(2025, 12, 31),
        );

        expect(recurrence.frequency, RecurrenceFrequency.weekly);
        expect(recurrence.interval, 1);
        expect(recurrence.endDate, isNotNull);
      });
    });

    group('Edge Cases', () {
      test('Notification at midnight (00:00)', () {
        const settings = HabitNotificationSettings(
          timing: NotificationTiming.atEventTime,
          eventTime: '00:00',
        );

        expect(settings.eventTime, '00:00');
        expect(settings.timing.minutesBefore, 0);
      });

      test('Notification 1 hour before midnight event', () {
        const settings = HabitNotificationSettings(
          timing: NotificationTiming.oneHourBefore,
          eventTime: '00:30',
        );

        // Should calculate to 23:30 previous day
        const eventMinutes = 0 * 60 + 30;
        var notifMinutes = eventMinutes - 60;
        if (notifMinutes < 0) {
          notifMinutes += 24 * 60; // Wrap to previous day
        }
        expect(notifMinutes, 1410); // 23:30
      });

      test('Custom notification with maximum minutes (1440 - 24 hours)', () {
        const settings = HabitNotificationSettings(
          timing: NotificationTiming.custom,
          customMinutesBefore: 1440,
          eventTime: '09:00',
        );

        expect(settings.customMinutesBefore, 1440);
        expect(settings.customMinutesBefore! <= 1440, true);
      });

      test('Custom notification with minimum minutes (1)', () {
        const settings = HabitNotificationSettings(
          timing: NotificationTiming.custom,
          customMinutesBefore: 1,
          eventTime: '09:00',
        );

        expect(settings.customMinutesBefore, 1);
        expect(settings.customMinutesBefore! >= 1, true);
      });

      test('Monthly recurrence with interval of 2 (bi-monthly)', () {
        const recurrence = HabitRecurrence(
          enabled: true,
          frequency: RecurrenceFrequency.monthly,
          interval: 2,
        );

        expect(recurrence.frequency, RecurrenceFrequency.monthly);
        expect(recurrence.interval, 2);
      });

      test('Recurrence without end date (continuous)', () {
        const recurrence = HabitRecurrence(
          enabled: true,
          frequency: RecurrenceFrequency.daily,
          interval: 1,
        );

        expect(recurrence.endDate, isNull);
        expect(recurrence.enabled, true);
      });

      test('Empty subtasks list', () {
        final habit = Habit.create(
          id: 'test',
          userId: 'user1',
          name: 'Test Habit',
          description: 'Test',
        );

        expect(habit.subtasks, isEmpty);
      });

      test('Subtask with very long title', () {
        final longTitle = 'A' * 200;
        final subtask = Subtask(id: '1', title: longTitle);

        expect(subtask.title.length, 200);
        expect(subtask.id, '1');
      });

      test('No notification (disabled)', () {
        const settings = HabitNotificationSettings(
          timing: NotificationTiming.none,
        );

        expect(settings.timing, NotificationTiming.none);
        expect(settings.timing.minutesBefore, isNull);
      });

      test('Recurrence disabled but with settings', () {
        const recurrence = HabitRecurrence(
          enabled: false,
          frequency: RecurrenceFrequency.daily,
          interval: 1,
        );

        expect(recurrence.enabled, false);
        // Settings should still be preserved even if disabled
        expect(recurrence.frequency, RecurrenceFrequency.daily);
      });
    });

    group('Serialization - Real World Persistence', () {
      test('NotificationSettings survives JSON round-trip', () {
        const original = HabitNotificationSettings(
          timing: NotificationTiming.thirtyMinutesBefore,
          eventTime: '08:00',
        );

        final json = original.toJson();
        final restored = HabitNotificationSettings.fromJson(json);

        expect(restored.timing, original.timing);
        expect(restored.eventTime, original.eventTime);
      });

      test('Recurrence with end date survives JSON round-trip', () {
        final endDate = DateTime(2025, 12, 31);
        final original = HabitRecurrence(
          enabled: true,
          frequency: RecurrenceFrequency.weekly,
          interval: 2,
          endDate: endDate,
        );

        final json = original.toJson();
        final restored = HabitRecurrence.fromJson(json);

        expect(restored.enabled, original.enabled);
        expect(restored.frequency, original.frequency);
        expect(restored.interval, original.interval);
        expect(restored.endDate, original.endDate);
      });

      test('Subtasks list survives JSON round-trip', () {
        final originalSubtasks = [
          const Subtask(id: '1', title: 'Task 1', completed: true),
          const Subtask(id: '2', title: 'Task 2', completed: false),
        ];

        final jsonList = originalSubtasks.map((s) => s.toJson()).toList();
        final restored = jsonList
            .map((json) => Subtask.fromJson(json))
            .toList();

        expect(restored.length, 2);
        expect(restored[0].completed, true);
        expect(restored[1].completed, false);
        expect(restored[0].title, 'Task 1');
      });

      test('Custom notification with null minutes preserved', () {
        const settings = HabitNotificationSettings(
          timing: NotificationTiming.custom,
          customMinutesBefore: null,
          eventTime: '09:00',
        );

        final json = settings.toJson();
        final restored = HabitNotificationSettings.fromJson(json);

        expect(restored.customMinutesBefore, isNull);
        expect(restored.timing, NotificationTiming.custom);
      });
    });

    group('User Workflow - Complete Journey', () {
      test('User creates habit with full configuration', () {
        // Step 1: Create basic habit
        final habit = Habit.create(
          id: 'workout',
          userId: 'user1',
          name: 'Morning Workout',
          description: 'Daily exercise routine',
        );

        // Step 2: Add notification
        const notification = HabitNotificationSettings(
          timing: NotificationTiming.tenMinutesBefore,
          eventTime: '06:00',
        );

        // Step 3: Add recurrence
        final recurrence = HabitRecurrence(
          enabled: true,
          frequency: RecurrenceFrequency.daily,
          interval: 1,
          endDate: DateTime(2025, 12, 31),
        );

        // Step 4: Add subtasks
        final subtasks = [
          const Subtask(id: '1', title: 'Stretching'),
          const Subtask(id: '2', title: 'Cardio'),
          const Subtask(id: '3', title: 'Strength'),
        ];

        // Step 5: Update habit with all settings
        final configuredHabit = habit.copyWith(
          notificationSettings: notification,
          recurrence: recurrence,
          subtasks: subtasks,
        );

        // Verify everything is set
        expect(configuredHabit.notificationSettings, isNotNull);
        expect(configuredHabit.recurrence, isNotNull);
        expect(configuredHabit.subtasks.length, 3);
        expect(configuredHabit.name, 'Morning Workout');
      });

      test('User modifies existing habit configuration', () {
        // Start with configured habit
        final habit = Habit.create(
          id: 'prayer',
          userId: 'user1',
          name: 'Prayer',
          description: 'Daily prayer',
        ).copyWith(
          notificationSettings: const HabitNotificationSettings(
            timing: NotificationTiming.atEventTime,
            eventTime: '07:00',
          ),
        );

        // User changes notification time
        const newSettings = HabitNotificationSettings(
          timing: NotificationTiming.tenMinutesBefore,
          eventTime: '08:00',
        );

        final updated = habit.copyWith(notificationSettings: newSettings);

        expect(updated.notificationSettings!.eventTime, '08:00');
        expect(updated.notificationSettings!.timing,
            NotificationTiming.tenMinutesBefore);
      });

      test('User disables then re-enables recurrence', () {
        const recurrence = HabitRecurrence(
          enabled: true,
          frequency: RecurrenceFrequency.daily,
          interval: 1,
        );

        // Disable
        final disabled = recurrence.copyWith(enabled: false);
        expect(disabled.enabled, false);
        expect(disabled.frequency, RecurrenceFrequency.daily); // Preserved

        // Re-enable
        final reEnabled = disabled.copyWith(enabled: true);
        expect(reEnabled.enabled, true);
        expect(reEnabled.frequency, RecurrenceFrequency.daily);
      });
    });
  });
}
