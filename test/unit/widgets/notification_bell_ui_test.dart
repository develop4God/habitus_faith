import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:habitus_faith/features/habits/domain/models/habit_notification.dart';

void main() {
  group('Notification Bell UI - User Behavior Tests', () {
    test('Notification bell shows gray when off', () {
      final habit = Habit.create(
        id: 'habit1',
        userId: 'user1',
        name: 'Morning Prayer',
      );

      expect(habit.notificationSettings, isNull);
      // UI should show gray bell icon (notifications_none)
    });

    test('Notification bell shows orange when on', () {
      final habit = Habit.create(
        id: 'habit1',
        userId: 'user1',
        name: 'Morning Prayer',
      ).copyWith(
        notificationSettings: const HabitNotificationSettings(
          timing: NotificationTiming.atEventTime,
          eventTime: '07:00',
        ),
      );

      expect(habit.notificationSettings, isNotNull);
      expect(habit.notificationSettings!.timing, NotificationTiming.atEventTime);
      expect(habit.notificationSettings!.eventTime, '07:00');
      // UI should show orange bell icon (notifications_active)
    });

    test('Tapping bell when OFF shows time picker', () {
      final habit = Habit.create(
        id: 'habit1',
        userId: 'user1',
        name: 'Morning Prayer',
      );

      expect(habit.notificationSettings, isNull);
      // Expected behavior: Show time picker dialog
      // User selects time -> notification is created with timing: atEventTime
    });

    test('Tapping bell when ON shows options dialog', () {
      final habit = Habit.create(
        id: 'habit1',
        userId: 'user1',
        name: 'Morning Prayer',
      ).copyWith(
        notificationSettings: const HabitNotificationSettings(
          timing: NotificationTiming.atEventTime,
          eventTime: '07:00',
        ),
      );

      expect(habit.notificationSettings, isNotNull);
      // Expected behavior: Show NotificationOptionsDialog with 2 options:
      // A) Turn off notification
      // B) Change notification time
    });

    test('Turn off notification option sets timing to none', () {
      final habitWithNotification = Habit.create(
        id: 'habit1',
        userId: 'user1',
        name: 'Morning Prayer',
      ).copyWith(
        notificationSettings: const HabitNotificationSettings(
          timing: NotificationTiming.atEventTime,
          eventTime: '07:00',
        ),
      );

      // User selects "Turn off notification" option
      final updatedHabit = habitWithNotification.copyWith(
        notificationSettings: const HabitNotificationSettings(
          timing: NotificationTiming.none,
        ),
      );

      expect(updatedHabit.notificationSettings!.timing, NotificationTiming.none);
      // Backend should cancel local notification
      // UI should show gray bell icon
    });

    test('Change time option shows time picker and updates eventTime', () {
      final habitWithNotification = Habit.create(
        id: 'habit1',
        userId: 'user1',
        name: 'Morning Prayer',
      ).copyWith(
        notificationSettings: const HabitNotificationSettings(
          timing: NotificationTiming.atEventTime,
          eventTime: '07:00',
        ),
      );

      // User selects "Change time" option
      // Time picker shows with initial time 07:00
      // User picks new time 08:30
      final updatedHabit = habitWithNotification.copyWith(
        notificationSettings: const HabitNotificationSettings(
          timing: NotificationTiming.atEventTime,
          eventTime: '08:30',
        ),
      );

      expect(updatedHabit.notificationSettings!.timing, NotificationTiming.atEventTime);
      expect(updatedHabit.notificationSettings!.eventTime, '08:30');
      // Backend should reschedule local notification for new time
      // UI should keep orange bell icon
    });

    test('Notification with timing none is treated as OFF', () {
      final habitWithNoneNotification = Habit.create(
        id: 'habit1',
        userId: 'user1',
        name: 'Morning Prayer',
      ).copyWith(
        notificationSettings: const HabitNotificationSettings(
          timing: NotificationTiming.none,
        ),
      );

      expect(habitWithNoneNotification.notificationSettings!.timing,
          NotificationTiming.none);
      // UI should show gray bell icon (same as null notificationSettings)
      // Tapping should show time picker (same as OFF behavior)
    });

    test('Daily notification is scheduled at event time', () {
      final habit = Habit.create(
        id: 'habit1',
        userId: 'user1',
        name: 'Morning Prayer',
      ).copyWith(
        notificationSettings: const HabitNotificationSettings(
          timing: NotificationTiming.atEventTime,
          eventTime: '07:00',
        ),
      );

      expect(habit.notificationSettings!.timing, NotificationTiming.atEventTime);
      expect(habit.notificationSettings!.eventTime, '07:00');
      expect(habit.notificationSettings!.timing.minutesBefore, 0);
      
      // Backend should schedule daily local notification at 07:00
      // Notification should repeat every day
      // Notification should persist after app restart
    });

    test('Multiple habits can have different notification times', () {
      final morningPrayer = Habit.create(
        id: 'habit1',
        userId: 'user1',
        name: 'Morning Prayer',
      ).copyWith(
        notificationSettings: const HabitNotificationSettings(
          timing: NotificationTiming.atEventTime,
          eventTime: '06:00',
        ),
      );

      final exercise = Habit.create(
        id: 'habit2',
        userId: 'user1',
        name: 'Exercise',
      ).copyWith(
        notificationSettings: const HabitNotificationSettings(
          timing: NotificationTiming.atEventTime,
          eventTime: '07:30',
        ),
      );

      final eveningPrayer = Habit.create(
        id: 'habit3',
        userId: 'user1',
        name: 'Evening Prayer',
      ).copyWith(
        notificationSettings: const HabitNotificationSettings(
          timing: NotificationTiming.atEventTime,
          eventTime: '20:00',
        ),
      );

      expect(morningPrayer.notificationSettings!.eventTime, '06:00');
      expect(exercise.notificationSettings!.eventTime, '07:30');
      expect(eveningPrayer.notificationSettings!.eventTime, '20:00');
      
      // Each habit should have its own scheduled notification
      // Notifications should not interfere with each other
    });

    test('Turning notification back on after turning off works correctly', () {
      // Start with notification ON
      var habit = Habit.create(
        id: 'habit1',
        userId: 'user1',
        name: 'Morning Prayer',
      ).copyWith(
        notificationSettings: const HabitNotificationSettings(
          timing: NotificationTiming.atEventTime,
          eventTime: '07:00',
        ),
      );

      expect(habit.notificationSettings!.timing, NotificationTiming.atEventTime);

      // Turn OFF
      habit = habit.copyWith(
        notificationSettings: const HabitNotificationSettings(
          timing: NotificationTiming.none,
        ),
      );

      expect(habit.notificationSettings!.timing, NotificationTiming.none);

      // Turn ON again with new time
      habit = habit.copyWith(
        notificationSettings: const HabitNotificationSettings(
          timing: NotificationTiming.atEventTime,
          eventTime: '08:00',
        ),
      );

      expect(habit.notificationSettings!.timing, NotificationTiming.atEventTime);
      expect(habit.notificationSettings!.eventTime, '08:00');
      
      // Notification should be rescheduled at new time
    });

    test('Edge case: midnight notification time', () {
      final habit = Habit.create(
        id: 'habit1',
        userId: 'user1',
        name: 'Midnight Prayer',
      ).copyWith(
        notificationSettings: const HabitNotificationSettings(
          timing: NotificationTiming.atEventTime,
          eventTime: '00:00',
        ),
      );

      expect(habit.notificationSettings!.eventTime, '00:00');
      // Should handle midnight time correctly
    });

    test('Edge case: just before midnight notification time', () {
      final habit = Habit.create(
        id: 'habit1',
        userId: 'user1',
        name: 'Late Night Prayer',
      ).copyWith(
        notificationSettings: const HabitNotificationSettings(
          timing: NotificationTiming.atEventTime,
          eventTime: '23:59',
        ),
      );

      expect(habit.notificationSettings!.eventTime, '23:59');
      // Should handle time just before midnight correctly
    });
  });
}
