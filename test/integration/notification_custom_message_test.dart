import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/habits/domain/models/micro_habit.dart';
import 'package:habitus_faith/features/habits/domain/models/habit_notification.dart';
import 'package:habitus_faith/features/habits/data/storage/json_habits_repository.dart';
import 'package:habitus_faith/features/habits/data/storage/json_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';

/// Test Suite 5: Custom Message Integration
/// Verifies that custom notification messages from AI-generated habits
/// are properly saved and handled when notifications are present or absent.
void main() {
  group('Custom Message Integration Tests', () {
    late JsonHabitsRepository repository;
    late JsonStorageService storageService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storageService = JsonStorageService(prefs);
      repository = JsonHabitsRepository(
        storage: storageService,
        userId: 'test-user-123',
        idGenerator: () => DateTime.now().microsecondsSinceEpoch.toString(),
      );
    });

    /// Test 5.1: Saves notification body as custom message
    test('persists custom message from notification', () async {
      // Arrange
      const microHabit = MicroHabit(
        id: 'test-1',
        action: 'Prayer 10 min',
        purpose: 'Connect with God',
        verse: 'Psalm 5:3',
        scheduledTime: '07:00',
        notifications: [
          NotificationConfig(
            time: '06:55',
            title: 'Prayer time',
            body: 'Prepare your space',
          ),
        ],
      );

      // Act - Create habit with notification settings
      final result = await repository.createHabit(
        name: microHabit.action,
        category: HabitCategory.spiritual,
        notificationSettings: HabitNotificationSettings(
          timing: NotificationTiming.atEventTime,
          eventTime: microHabit.scheduledTime,
          customMessage: microHabit.notifications?.first.body,
        ),
      );

      // Assert
      expect(result.isSuccess(), true);
      final saved = result.value;
      expect(saved.notificationSettings, isNotNull);
      expect(saved.notificationSettings?.customMessage, 'Prepare your space');
      expect(saved.notificationSettings?.eventTime, '07:00');
    });

    /// Test 5.2: Handles missing notifications gracefully
    test('creates habit when notifications array is null', () async {
      // Arrange
      const microHabit = MicroHabit(
        id: 'test-2',
        action: 'Prayer',
        purpose: 'Daily prayer',
        verse: 'Psalm 5:3',
        scheduledTime: '07:00',
        notifications: null, // No notifications
      );

      // Act - Create habit with notification settings but no custom message
      final result = await repository.createHabit(
        name: microHabit.action,
        category: HabitCategory.spiritual,
        notificationSettings: HabitNotificationSettings(
          timing: NotificationTiming.atEventTime,
          eventTime: microHabit.scheduledTime,
          customMessage: microHabit.notifications?.first.body, // Will be null
        ),
      );

      // Assert
      expect(result.isSuccess(), true);
      final saved = result.value;
      expect(saved.notificationSettings, isNotNull);
      expect(saved.notificationSettings?.customMessage, isNull);
      expect(saved.notificationSettings?.eventTime, '07:00');
    });

    /// Test 5.3: Handles empty notifications array
    test('creates habit when notifications array is empty', () async {
      // Arrange
      const microHabit = MicroHabit(
        id: 'test-3',
        action: 'Prayer',
        purpose: 'Daily prayer',
        verse: 'Psalm 5:3',
        scheduledTime: '07:00',
        notifications: [], // Empty list
      );

      // Act
      final result = await repository.createHabit(
        name: microHabit.action,
        category: HabitCategory.spiritual,
        notificationSettings: microHabit.scheduledTime != null
            ? HabitNotificationSettings(
                timing: NotificationTiming.atEventTime,
                eventTime: microHabit.scheduledTime,
                customMessage: microHabit.notifications?.isNotEmpty == true
                    ? microHabit.notifications!.first.body
                    : null,
              )
            : null,
      );

      // Assert
      expect(result.isSuccess(), true);
      final saved = result.value;
      expect(saved.notificationSettings?.customMessage, isNull);
    });
  });
}
