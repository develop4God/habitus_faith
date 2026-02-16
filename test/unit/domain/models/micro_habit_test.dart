import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/habits/domain/models/micro_habit.dart';

void main() {
  group('NotificationConfig Tests', () {
    test('should create NotificationConfig with all fields', () {
      // Arrange & Act
      const notification = NotificationConfig(
        time: '07:00',
        title: 'Prayer time',
        body: 'Time to pray',
      );

      // Assert
      expect(notification.time, '07:00');
      expect(notification.title, 'Prayer time');
      expect(notification.body, 'Time to pray');
    });

    test('should serialize to JSON correctly', () {
      // Arrange
      const notification = NotificationConfig(
        time: '07:00',
        title: 'Prayer time',
        body: 'Time to pray',
      );

      // Act
      final json = notification.toJson();

      // Assert
      expect(json['time'], '07:00');
      expect(json['title'], 'Prayer time');
      expect(json['body'], 'Time to pray');
    });

    test('should deserialize from JSON correctly', () {
      // Arrange
      final json = {
        'time': '07:00',
        'title': 'Prayer time',
        'body': 'Time to pray',
      };

      // Act
      final notification = NotificationConfig.fromJson(json);

      // Assert
      expect(notification.time, '07:00');
      expect(notification.title, 'Prayer time');
      expect(notification.body, 'Time to pray');
    });
  });

  group('MicroHabit Tests', () {
    test('should create MicroHabit with all fields including new ones', () {
      // Arrange & Act
      final habit = MicroHabit(
        id: 'test-1',
        action: 'Pray 10 minutes',
        verse: 'Psalm 5:3',
        verseText: 'In the morning, Lord...',
        purpose: 'Connect with God',
        estimatedMinutes: 10,
        generatedAt: DateTime(2024, 1, 1),
        scheduledTime: '07:00',
        trigger: 'After waking up',
        notifications: const [
          NotificationConfig(
            time: '06:55',
            title: 'Prayer reminder',
            body: 'Time to prepare',
          ),
        ],
      );

      // Assert
      expect(habit.id, 'test-1');
      expect(habit.action, 'Pray 10 minutes');
      expect(habit.verse, 'Psalm 5:3');
      expect(habit.verseText, 'In the morning, Lord...');
      expect(habit.purpose, 'Connect with God');
      expect(habit.estimatedMinutes, 10);
      expect(habit.scheduledTime, '07:00');
      expect(habit.trigger, 'After waking up');
      expect(habit.notifications?.length, 1);
      expect(habit.notifications?.first.time, '06:55');
    });

    test('should create MicroHabit with null optional fields', () {
      // Arrange & Act
      const habit = MicroHabit(
        id: 'test-1',
        action: 'Pray',
        verse: 'Psalm 5:3',
        purpose: 'Connect',
      );

      // Assert
      expect(habit.scheduledTime, isNull);
      expect(habit.trigger, isNull);
      expect(habit.notifications, isNull);
      expect(habit.verseText, isNull);
      expect(habit.generatedAt, isNull);
    });

    test('should deserialize from JSON with all fields', () {
      // Arrange
      final json = {
        'id': 'test-1',
        'action': 'Pray 10 minutes',
        'verse': 'Psalm 5:3',
        'verseText': 'In the morning...',
        'purpose': 'Connect',
        'estimatedMinutes': 10,
        'generatedAt': '2024-01-01T00:00:00.000',
        'scheduledTime': '07:00',
        'trigger': 'After waking',
        'notifications': [
          {
            'time': '06:55',
            'title': 'Prayer',
            'body': 'Prepare',
          }
        ],
      };

      // Act
      final habit = MicroHabit.fromJson(json);

      // Assert
      expect(habit.id, 'test-1');
      expect(habit.action, 'Pray 10 minutes');
      expect(habit.scheduledTime, '07:00');
      expect(habit.trigger, 'After waking');
      expect(habit.notifications?.length, 1);
      expect(habit.notifications?.first.time, '06:55');
    });

    test('should deserialize from JSON with missing optional fields', () {
      // Arrange
      final json = {
        'id': 'test-1',
        'action': 'Pray',
        'verse': 'Psalm 5:3',
        'purpose': 'Connect',
      };

      // Act
      final habit = MicroHabit.fromJson(json);

      // Assert
      expect(habit.id, 'test-1');
      expect(habit.scheduledTime, isNull);
      expect(habit.trigger, isNull);
      expect(habit.notifications, isNull);
    });

    test('should handle estimatedMinutes as int', () {
      // Arrange
      final json = {
        'id': 'test-1',
        'action': 'Pray',
        'verse': 'Psalm 5:3',
        'purpose': 'Connect',
        'estimatedMinutes': 10,
      };

      // Act
      final habit = MicroHabit.fromJson(json);

      // Assert
      expect(habit.estimatedMinutes, 10);
    });

    test('should handle estimatedMinutes as double', () {
      // Arrange
      final json = {
        'id': 'test-1',
        'action': 'Pray',
        'verse': 'Psalm 5:3',
        'purpose': 'Connect',
        'estimatedMinutes': 10.5,
      };

      // Act
      final habit = MicroHabit.fromJson(json);

      // Assert
      expect(habit.estimatedMinutes, 11); // Rounded
    });

    test('should handle malformed notifications gracefully', () {
      // Arrange
      final json = {
        'id': 'test-1',
        'action': 'Pray',
        'verse': 'Psalm 5:3',
        'purpose': 'Connect',
        'notifications': [
          {'invalid': 'data'} // Missing required fields
        ],
      };

      // Act
      final habit = MicroHabit.fromJson(json);

      // Assert - Should not throw, notifications should be null
      expect(habit.notifications, isNull);
    });

    test('should handle non-list notifications gracefully', () {
      // Arrange
      final json = {
        'id': 'test-1',
        'action': 'Pray',
        'verse': 'Psalm 5:3',
        'purpose': 'Connect',
        'notifications': 'not a list',
      };

      // Act
      final habit = MicroHabit.fromJson(json);

      // Assert - Should not throw, notifications should be null
      expect(habit.notifications, isNull);
    });

    test('should use copyWith to update fields', () {
      // Arrange
      const habit = MicroHabit(
        id: 'test-1',
        action: 'Pray',
        verse: 'Psalm 5:3',
        purpose: 'Connect',
      );

      // Act
      final updated = habit.copyWith(
        scheduledTime: '07:00',
        trigger: 'After waking',
      );

      // Assert
      expect(updated.id, 'test-1');
      expect(updated.scheduledTime, '07:00');
      expect(updated.trigger, 'After waking');
    });
  });
}
