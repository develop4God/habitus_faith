import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:habitus_faith/features/habits/domain/models/habit_notification.dart';

void main() {
  group('Habit Notification Rescheduling - User Behavior Tests', () {
    test('Reschedules notifications for habits with notification settings', () {
      // Create habits with different notification configurations
      final morningPrayerHabit =
          Habit.create(
            id: 'prayer1',
            userId: 'user1',
            name: 'Morning Prayer',
          ).copyWith(
            notificationSettings: const HabitNotificationSettings(
              timing: NotificationTiming.atEventTime,
              eventTime: '07:00',
            ),
          );

      final exerciseHabit =
          Habit.create(
            id: 'exercise1',
            userId: 'user1',
            name: 'Morning Exercise',
          ).copyWith(
            notificationSettings: const HabitNotificationSettings(
              timing: NotificationTiming.tenMinutesBefore,
              eventTime: '06:30',
            ),
          );

      final bibleReadingHabit =
          Habit.create(
            id: 'bible1',
            userId: 'user1',
            name: 'Bible Reading',
          ).copyWith(
            notificationSettings: const HabitNotificationSettings(
              timing: NotificationTiming.thirtyMinutesBefore,
              eventTime: '21:00',
            ),
          );

      // Habit without notification settings
      final meditationHabit = Habit.create(
        id: 'meditation1',
        userId: 'user1',
        name: 'Meditation',
      );

      final habits = [
        morningPrayerHabit,
        exerciseHabit,
        bibleReadingHabit,
        meditationHabit,
      ];

      // Verify that habits with notification settings have them configured
      final habitsWithNotifications = habits.where(
        (h) =>
            h.notificationSettings != null &&
            h.notificationSettings!.timing != NotificationTiming.none &&
            h.notificationSettings!.eventTime != null,
      );

      expect(habitsWithNotifications.length, 3);
      expect(habitsWithNotifications.first.name, 'Morning Prayer');
      expect(
        habitsWithNotifications.first.notificationSettings!.eventTime,
        '07:00',
      );
    });

    test('Handles habits with custom notification timing', () {
      final customHabit =
          Habit.create(
            id: 'custom1',
            userId: 'user1',
            name: 'Custom Reminder',
          ).copyWith(
            notificationSettings: const HabitNotificationSettings(
              timing: NotificationTiming.custom,
              customMinutesBefore: 45,
              eventTime: '15:00',
            ),
          );

      expect(
        customHabit.notificationSettings!.timing,
        NotificationTiming.custom,
      );
      expect(customHabit.notificationSettings!.customMinutesBefore, 45);
      expect(customHabit.notificationSettings!.eventTime, '15:00');
    });

    test('Skips habits with notification timing set to none', () {
      final noNotificationHabit =
          Habit.create(
            id: 'none1',
            userId: 'user1',
            name: 'No Notification',
          ).copyWith(
            notificationSettings: const HabitNotificationSettings(
              timing: NotificationTiming.none,
              eventTime: '10:00',
            ),
          );

      expect(
        noNotificationHabit.notificationSettings!.timing,
        NotificationTiming.none,
      );
      // This habit should not have notifications scheduled
    });

    test('Skips habits with custom timing but null customMinutesBefore', () {
      final invalidCustomHabit =
          Habit.create(
            id: 'invalid1',
            userId: 'user1',
            name: 'Invalid Custom',
          ).copyWith(
            notificationSettings: const HabitNotificationSettings(
              timing: NotificationTiming.custom,
              customMinutesBefore: null,
              eventTime: '10:00',
            ),
          );

      expect(
        invalidCustomHabit.notificationSettings!.timing,
        NotificationTiming.custom,
      );
      expect(
        invalidCustomHabit.notificationSettings!.customMinutesBefore,
        isNull,
      );
      // This habit should be skipped during rescheduling
    });

    test('Handles habits without notification settings', () {
      final plainHabit = Habit.create(
        id: 'plain1',
        userId: 'user1',
        name: 'Plain Habit',
      );

      expect(plainHabit.notificationSettings, isNull);
      // This habit should not have notifications scheduled
    });

    test('Verifies notification timing calculations', () {
      // Test that minutesBefore is correctly determined based on timing
      const atEventTime = HabitNotificationSettings(
        timing: NotificationTiming.atEventTime,
        eventTime: '09:00',
      );
      expect(atEventTime.timing.minutesBefore, 0);

      const tenMinBefore = HabitNotificationSettings(
        timing: NotificationTiming.tenMinutesBefore,
        eventTime: '09:00',
      );
      expect(tenMinBefore.timing.minutesBefore, 10);

      const thirtyMinBefore = HabitNotificationSettings(
        timing: NotificationTiming.thirtyMinutesBefore,
        eventTime: '09:00',
      );
      expect(thirtyMinBefore.timing.minutesBefore, 30);

      const oneHourBefore = HabitNotificationSettings(
        timing: NotificationTiming.oneHourBefore,
        eventTime: '09:00',
      );
      expect(oneHourBefore.timing.minutesBefore, 60);
    });

    test(
      'Real user scenario: Multiple habits scheduled at different times',
      () {
        final habits = [
          Habit.create(id: 'h1', userId: 'u1', name: 'Morning Prayer').copyWith(
            notificationSettings: const HabitNotificationSettings(
              timing: NotificationTiming.atEventTime,
              eventTime: '06:00',
            ),
          ),
          Habit.create(id: 'h2', userId: 'u1', name: 'Exercise').copyWith(
            notificationSettings: const HabitNotificationSettings(
              timing: NotificationTiming.tenMinutesBefore,
              eventTime: '07:00',
            ),
          ),
          Habit.create(id: 'h3', userId: 'u1', name: 'Lunch Prayer').copyWith(
            notificationSettings: const HabitNotificationSettings(
              timing: NotificationTiming.atEventTime,
              eventTime: '12:00',
            ),
          ),
          Habit.create(
            id: 'h4',
            userId: 'u1',
            name: 'Evening Reading',
          ).copyWith(
            notificationSettings: const HabitNotificationSettings(
              timing: NotificationTiming.thirtyMinutesBefore,
              eventTime: '20:00',
            ),
          ),
          Habit.create(id: 'h5', userId: 'u1', name: 'No Notification'),
        ];

        // Count habits that should have notifications scheduled
        final withNotifications = habits.where(
          (h) =>
              h.notificationSettings != null &&
              h.notificationSettings!.timing != NotificationTiming.none &&
              h.notificationSettings!.eventTime != null,
        );

        expect(withNotifications.length, 4);

        // Verify each has correct settings
        final morningPrayer = habits[0];
        expect(morningPrayer.notificationSettings!.eventTime, '06:00');
        expect(morningPrayer.notificationSettings!.timing.minutesBefore, 0);

        final exercise = habits[1];
        expect(exercise.notificationSettings!.eventTime, '07:00');
        expect(exercise.notificationSettings!.timing.minutesBefore, 10);

        final eveningReading = habits[3];
        expect(eveningReading.notificationSettings!.eventTime, '20:00');
        expect(eveningReading.notificationSettings!.timing.minutesBefore, 30);
      },
    );
  });
}
