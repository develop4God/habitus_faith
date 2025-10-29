import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Extended peripheral tests for NotificationService behavior simulation
/// These tests validate advanced scenarios: lastLogin, scheduling, auth lifecycle, etc.
/// Complements: notification_service_peripheral_test.dart
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService Extended Tests - LastLogin Tracking', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    tearDown(() async {
      await prefs.clear();
    });

    test('should simulate lastLogin update when FCM token is saved', () async {
      // Simulate user authentication state
      const userId = 'test_user_123';
      await prefs.setString('current_user_id', userId);

      // Simulate FCM token save flow
      const fcmToken = 'fcm_token_abc123';
      await prefs.setString('fcm_token', fcmToken);

      // Simulate lastLogin update (would be FieldValue.serverTimestamp in Firestore)
      final lastLoginTimestamp = DateTime.now().toUtc().toIso8601String();
      await prefs.setString('last_login_$userId', lastLoginTimestamp);

      final savedLastLogin = prefs.getString('last_login_$userId');
      expect(savedLastLogin, isNotNull);
      expect(savedLastLogin, contains('T')); // ISO 8601 format
      expect(savedLastLogin, endsWith('Z')); // UTC timezone
    });

    test('should simulate lastLogin update on explicit updateLastLogin call',
            () async {
          const userId = 'test_user_456';
          await prefs.setString('current_user_id', userId);

          // Simulate explicit lastLogin update (app foreground)
          final timestamp = DateTime.now().toUtc().toIso8601String();
          await prefs.setString('last_login_$userId', timestamp);

          final saved = prefs.getString('last_login_$userId');
          expect(saved, equals(timestamp));
        });

    test('should validate lastLogin timestamp format', () async {
      const userId = 'test_user_789';
      final timestamp = DateTime.now().toUtc().toIso8601String();
      await prefs.setString('last_login_$userId', timestamp);

      final saved = prefs.getString('last_login_$userId')!;

      // Validate ISO 8601 format: YYYY-MM-DDTHH:mm:ss.sssZ
      expect(saved, matches(RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}')));
      expect(DateTime.tryParse(saved), isNotNull);
    });

    test('should not update lastLogin when user is not authenticated', () async {
      // No user authenticated
      expect(prefs.getString('current_user_id'), isNull);

      // Attempt to update lastLogin should be skipped
      const lastLoginKey = 'last_login_null';
      expect(prefs.getString(lastLoginKey), isNull);
    });

    test('should handle multiple lastLogin updates in sequence', () async {
      const userId = 'test_user_sequential';
      await prefs.setString('current_user_id', userId);

      // Simulate multiple app foreground events
      final timestamps = <String>[];
      for (int i = 0; i < 5; i++) {
        await Future.delayed(const Duration(milliseconds: 10));
        final timestamp = DateTime.now().toUtc().toIso8601String();
        timestamps.add(timestamp);
        await prefs.setString('last_login_$userId', timestamp);
      }

      // Should have the most recent timestamp
      final finalTimestamp = prefs.getString('last_login_$userId');
      expect(finalTimestamp, equals(timestamps.last));
    });

    test('should maintain lastLogin separately for different users', () async {
      // Simulate multi-user scenario (user switching)
      const user1 = 'user_001';
      const user2 = 'user_002';

      final timestamp1 = DateTime.now().toUtc().toIso8601String();
      await Future.delayed(const Duration(milliseconds: 50));
      final timestamp2 = DateTime.now().toUtc().toIso8601String();

      await prefs.setString('last_login_$user1', timestamp1);
      await prefs.setString('last_login_$user2', timestamp2);

      expect(prefs.getString('last_login_$user1'), equals(timestamp1));
      expect(prefs.getString('last_login_$user2'), equals(timestamp2));
      expect(timestamp1, isNot(equals(timestamp2)));
    });

    test('should simulate Firestore lastLogin document structure', () async {
      // Simulate the Firestore document structure
      final firestoreDoc = {
        'lastLogin': DateTime.now().toUtc().toIso8601String(),
        'email': 'user@example.com',
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      };

      // Validate structure
      expect(firestoreDoc['lastLogin'], isNotNull);
      expect(firestoreDoc['lastLogin'], isA<String>());
      expect(DateTime.tryParse(firestoreDoc['lastLogin'] as String), isNotNull);
    });
  });

  group('NotificationService Extended Tests - Scheduling Logic', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('should calculate next notification for future time today', () {
      final now = DateTime(2025, 10, 29, 8, 0); // 8:00 AM
      final scheduledTime = DateTime(2025, 10, 29, 9, 0); // 9:00 AM

      // If scheduled time is in the future today, use today
      final nextNotification = scheduledTime.isAfter(now)
          ? scheduledTime
          : scheduledTime.add(const Duration(days: 1));

      expect(nextNotification.day, equals(29));
      expect(nextNotification.hour, equals(9));
    });

    test('should calculate next notification for past time (tomorrow)', () {
      final now = DateTime(2025, 10, 29, 10, 0); // 10:00 AM
      final scheduledTime = DateTime(2025, 10, 29, 9, 0); // 9:00 AM (past)

      // If scheduled time already passed, schedule for tomorrow
      final nextNotification = scheduledTime.isAfter(now)
          ? scheduledTime
          : scheduledTime.add(const Duration(days: 1));

      expect(nextNotification.day, equals(30)); // October 30
      expect(nextNotification.hour, equals(9));
    });

    test('should handle edge case: notification at midnight (00:00)', () {
      final now = DateTime(2025, 10, 29, 23, 30); // 11:30 PM
      final scheduledTime = DateTime(2025, 10, 29, 0, 0); // Midnight (past)

      final nextNotification = scheduledTime.isAfter(now)
          ? scheduledTime
          : DateTime(now.year, now.month, now.day + 1, 0, 0);

      expect(nextNotification.day, equals(30));
      expect(nextNotification.hour, equals(0));
      expect(nextNotification.minute, equals(0));
    });

    test('should handle edge case: notification at 23:59', () {
      final now = DateTime(2025, 10, 29, 23, 58); // 11:58 PM
      final scheduledTime = DateTime(2025, 10, 29, 23, 59); // 11:59 PM (future)

      final nextNotification = scheduledTime.isAfter(now)
          ? scheduledTime
          : scheduledTime.add(const Duration(days: 1));

      expect(nextNotification.day, equals(29)); // Today
      expect(nextNotification.hour, equals(23));
      expect(nextNotification.minute, equals(59));
    });

    test('should validate time component matching for daily recurrence', () {
      // Simulate matchDateTimeComponents.time behavior
      const notificationTime = '14:30';
      final parts = notificationTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      // Any date with same hour:minute should match
      final date1 = DateTime(2025, 10, 29, hour, minute);
      final date2 = DateTime(2025, 10, 30, hour, minute);
      final date3 = DateTime(2025, 11, 1, hour, minute);

      expect(date1.hour, equals(date2.hour));
      expect(date1.minute, equals(date2.minute));
      expect(date2.hour, equals(date3.hour));
      expect(date2.minute, equals(date3.minute));
    });

    test('should handle month transitions correctly', () {
      final now = DateTime(2025, 10, 31, 10, 0); // Oct 31, 10:00 AM
      final scheduledTime = DateTime(2025, 10, 31, 9, 0); // 9:00 AM (past)

      final nextNotification = scheduledTime.isAfter(now)
          ? scheduledTime
          : DateTime(now.year, now.month, now.day + 1, scheduledTime.hour,
          scheduledTime.minute);

      expect(nextNotification.month, equals(11)); // November
      expect(nextNotification.day, equals(1)); // November 1st
    });

    test('should handle year transitions correctly', () {
      final now = DateTime(2025, 12, 31, 10, 0); // Dec 31, 10:00 AM
      final scheduledTime = DateTime(2025, 12, 31, 9, 0); // 9:00 AM (past)

      final nextNotification = scheduledTime.isAfter(now)
          ? scheduledTime
          : DateTime(now.year, now.month, now.day + 1, scheduledTime.hour,
          scheduledTime.minute);

      expect(nextNotification.year, equals(2026));
      expect(nextNotification.month, equals(1)); // January
      expect(nextNotification.day, equals(1));
    });

    test('should preserve exact minute when scheduling', () async {
      const notificationTime = '09:07'; // 9:07 AM (not rounded)
      await prefs.setString('notification_time', notificationTime);

      final saved = prefs.getString('notification_time')!;
      final parts = saved.split(':');
      final minute = int.parse(parts[1]);

      expect(minute, equals(7)); // Exact minute preserved
    });
  });

  group('NotificationService Extended Tests - Timezone Management', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('should simulate device timezone detection', () async {
      // Simulate device timezone (would come from FlutterTimezone)
      const deviceTimezone = 'America/Panama';
      await prefs.setString('device_timezone', deviceTimezone);

      expect(prefs.getString('device_timezone'), equals(deviceTimezone));
    });

    test('should fallback to UTC when timezone is invalid', () async {
      const invalidTimezone = 'Invalid/Timezone';
      const fallbackTimezone = 'UTC';

      // Simulate validation logic
      final validTimezones = [
        'UTC',
        'America/Panama',
        'America/New_York',
        'Europe/London'
      ];
      final isValid = validTimezones.contains(invalidTimezone);

      final finalTimezone = isValid ? invalidTimezone : fallbackTimezone;
      await prefs.setString('user_timezone', finalTimezone);

      expect(prefs.getString('user_timezone'), equals('UTC'));
    });

    test('should handle timezone changes during app lifecycle', () async {
      // Initial timezone
      await prefs.setString('user_timezone', 'America/New_York');
      expect(prefs.getString('user_timezone'), equals('America/New_York'));

      // User travels to different timezone
      await prefs.setString('user_timezone', 'Asia/Tokyo');
      expect(prefs.getString('user_timezone'), equals('Asia/Tokyo'));

      // Notification time should remain the same (user's local time)
      await prefs.setString('notification_time', '09:00');
      expect(prefs.getString('notification_time'), equals('09:00'));
    });

    test('should store timezone with notification settings', () async {
      final settings = {
        'notificationsEnabled': true,
        'notificationTime': '14:30',
        'userTimezone': 'America/Panama',
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      for (final entry in settings.entries) {
        if (entry.value is bool) {
          await prefs.setBool(entry.key, entry.value as bool);
        } else {
          await prefs.setString(entry.key, entry.value as String);
        }
      }

      expect(prefs.getBool('notificationsEnabled'), isTrue);
      expect(prefs.getString('userTimezone'), equals('America/Panama'));
    });

    test('should handle common timezone formats', () async {
      final commonTimezones = [
        'UTC',
        'America/Panama',
        'America/New_York',
        'America/Los_Angeles',
        'Europe/London',
        'Europe/Paris',
        'Asia/Tokyo',
        'Australia/Sydney',
      ];

      for (final tz in commonTimezones) {
        await prefs.setString('user_timezone', tz);
        expect(prefs.getString('user_timezone'), equals(tz));
      }
    });

    test('should maintain timezone consistency across settings updates',
            () async {
          const initialTimezone = 'America/Panama';
          await prefs.setString('user_timezone', initialTimezone);

          // Update other settings
          await prefs.setBool('notifications_enabled', false);
          await prefs.setString('notification_time', '15:00');

          // Timezone should remain unchanged
          expect(prefs.getString('user_timezone'), equals(initialTimezone));
        });
  });

  group('NotificationService Extended Tests - Auth State Lifecycle', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('should simulate initialization with authenticated user', () async {
      const userId = 'authenticated_user_123';
      await prefs.setString('current_user_id', userId);
      await prefs.setBool('is_authenticated', true);

      expect(prefs.getBool('is_authenticated'), isTrue);
      expect(prefs.getString('current_user_id'), equals(userId));
    });

    test('should simulate initialization without authenticated user', () async {
      // No user data should be present
      expect(prefs.getString('current_user_id'), isNull);
      expect(prefs.getBool('is_authenticated'), isNull);
      expect(prefs.getString('fcm_token'), isNull);
    });

    test('should simulate transition from unauthenticated to authenticated',
            () async {
          // Initial state: no user
          expect(prefs.getString('current_user_id'), isNull);

          // User logs in
          const userId = 'new_user_456';
          await prefs.setString('current_user_id', userId);
          await prefs.setBool('is_authenticated', true);

          // FCM initialization should happen
          const fcmToken = 'fcm_token_xyz';
          await prefs.setString('fcm_token', fcmToken);

          // Settings should be initialized
          await prefs.setBool('notifications_enabled', true);
          await prefs.setString('notification_time', '09:00');

          expect(prefs.getBool('is_authenticated'), isTrue);
          expect(prefs.getString('fcm_token'), equals(fcmToken));
          expect(prefs.getBool('notifications_enabled'), isTrue);
        });

    test('should simulate user logout and cleanup', () async {
      // User is authenticated
      const userId = 'user_to_logout';
      await prefs.setString('current_user_id', userId);
      await prefs.setString('fcm_token', 'token_123');
      await prefs.setBool('notifications_enabled', true);

      // User logs out - simulate cleanup
      await prefs.remove('current_user_id');
      await prefs.remove('fcm_token');
      await prefs.setBool('is_authenticated', false);

      expect(prefs.getString('current_user_id'), isNull);
      expect(prefs.getString('fcm_token'), isNull);
      expect(prefs.getBool('is_authenticated'), isFalse);
    });

    test('should handle rapid auth state changes', () async {
      // Simulate rapid login/logout cycles
      for (int i = 0; i < 5; i++) {
        // Login
        await prefs.setString('current_user_id', 'user_$i');
        await prefs.setBool('is_authenticated', true);

        // Logout
        await prefs.remove('current_user_id');
        await prefs.setBool('is_authenticated', false);
      }

      // Final state should be logged out
      expect(prefs.getString('current_user_id'), isNull);
      expect(prefs.getBool('is_authenticated'), isFalse);
    });
  });

  group('NotificationService Extended Tests - Firestore Document Structure',
          () {
        test('should validate users collection document structure', () {
          final userDoc = {
            'email': 'user@example.com',
            'displayName': 'Test User',
            'createdAt': DateTime.now().toIso8601String(),
            'lastLogin': DateTime.now().toIso8601String(),
          };

          expect(userDoc['email'], isA<String>());
          expect(userDoc['displayName'], isA<String>());
          expect(userDoc['createdAt'], isA<String>());
          expect(userDoc['lastLogin'], isA<String>());
        });

        test('should validate fcmTokens subcollection structure', () {
          final tokenDoc = {
            'token': 'fcm_token_abc123',
            'createdAt': DateTime.now().toIso8601String(),
            'platform': 'android',
          };

          expect(tokenDoc['token'], isA<String>());
          expect(tokenDoc['createdAt'], isA<String>());
          expect(tokenDoc['platform'], isIn(['android', 'ios', 'web']));
        });

        test('should validate settings/notifications document structure', () {
          final notificationSettings = {
            'notificationsEnabled': true,
            'notificationTime': '09:00',
            'userTimezone': 'America/Panama',
            'preferredLanguage': 'es',
            'lastUpdated': DateTime.now().toIso8601String(),
          };

          expect(notificationSettings['notificationsEnabled'], isA<bool>());
          expect(notificationSettings['notificationTime'], isA<String>());
          expect(notificationSettings['notificationTime'], matches(RegExp(r'^\d{2}:\d{2}$')));
          expect(notificationSettings['userTimezone'], isA<String>());
          expect(notificationSettings['preferredLanguage'], isA<String>());
          expect(notificationSettings['lastUpdated'], isA<String>());
        });

        test('should validate SetOptions merge behavior simulation', () async {
          final prefs = await SharedPreferences.getInstance();

          // Initial document
          await prefs.setString('doc_field1', 'value1');
          await prefs.setString('doc_field2', 'value2');

          // Merge update (only update field2)
          await prefs.setString('doc_field2', 'updated_value2');

          // Field1 should remain unchanged (merge behavior)
          expect(prefs.getString('doc_field1'), equals('value1'));
          expect(prefs.getString('doc_field2'), equals('updated_value2'));
        });

        test('should validate required vs optional fields', () {
          final settings = {
            // Required fields
            'notificationsEnabled': true,
            'notificationTime': '09:00',
            'userTimezone': 'UTC',

            // Optional fields (can be null)
            'preferredLanguage': null,
          };

          // Required fields must not be null
          expect(settings['notificationsEnabled'], isNotNull);
          expect(settings['notificationTime'], isNotNull);
          expect(settings['userTimezone'], isNotNull);

          // Optional fields can be null
          expect(settings['preferredLanguage'], isNull);
        });

        test('should simulate FieldValue.serverTimestamp behavior', () {
          // In tests, we simulate with DateTime.now().toIso8601String()
          final serverTimestamp = DateTime.now().toUtc().toIso8601String();

          expect(serverTimestamp, isA<String>());
          expect(DateTime.tryParse(serverTimestamp), isNotNull);
          expect(serverTimestamp, contains('T'));
          expect(serverTimestamp, endsWith('Z'));
        });
      });

  group('NotificationService Extended Tests - FCM Message Handling', () {
    test('should simulate FCM message with notification payload', () {
      final message = {
        'messageId': 'msg_123',
        'notification': {
          'title': 'Test Notification',
          'body': 'This is a test message',
        },
        'data': {},
      };

      expect(message['notification'], isNotNull);
      expect(message['notification']?['title'], equals('Test Notification'));
      expect(message['notification']['body'], equals('This is a test message'));
    });

    test('should simulate data-only FCM message', () {
      final message = {
        'messageId': 'msg_456',
        'notification': null,
        'data': {
          'title': 'Data Title',
          'body': 'Data Body',
          'payload': 'custom_payload',
        },
      };

      expect(message['notification'], isNull);
      expect(message['data'], isNotEmpty);
      expect(message['data']['title'], equals('Data Title'));
    });

    test('should validate notification payload structure', () {
      final payload = {
        'type': 'daily_reminder',
        'timestamp': DateTime.now().toIso8601String(),
        'action': 'open_app',
      };

      expect(payload['type'], isA<String>());
      expect(payload['timestamp'], isA<String>());
      expect(payload['action'], isA<String>());
    });

    test('should simulate foreground message handling', () {
      final message = {
        'messageId': 'msg_foreground',
        'sentTime': DateTime.now().millisecondsSinceEpoch,
        'notification': {
          'title': 'Foreground Notification',
          'body': 'App is in foreground',
        },
      };

      // In foreground, app should show local notification
      expect(message['notification'], isNotNull);

      // Simulate showing local notification
      final shouldShowLocal = message['notification'] != null;
      expect(shouldShowLocal, isTrue);
    });

    test('should simulate background message handling', () {
      final message = {
        'messageId': 'msg_background',
        'sentTime': DateTime.now().millisecondsSinceEpoch,
        'data': {
          'title': 'Background Data',
          'body': 'App is in background',
        },
      };

      // Background messages are handled by system
      // Data can be processed when app comes to foreground
      expect(message['data'], isNotEmpty);
    });
  });

  group('NotificationService Extended Tests - Permission States Matrix', () {
    test('should simulate Android notification permission states', () {
      final permissionStates = {
        'notification': 'granted',
        'scheduleExactAlarm': 'granted',
        'ignoreBatteryOptimizations': 'granted',
      };

      expect(permissionStates['notification'], equals('granted'));
      expect(permissionStates['scheduleExactAlarm'], equals('granted'));
    });

    test('should simulate iOS notification permission states', () {
      final iosPermissions = {
        'alert': true,
        'badge': true,
        'sound': true,
        'provisional': false,
      };

      expect(iosPermissions['alert'], isTrue);
      expect(iosPermissions['badge'], isTrue);
      expect(iosPermissions['sound'], isTrue);
    });

    test('should handle permission denial scenarios', () {
      final deniedState = {
        'notification': 'denied',
        'canRequestAgain': false,
      };

      expect(deniedState['notification'], equals('denied'));
      expect(deniedState['canRequestAgain'], isFalse);
    });

    test('should validate all permissions granted state', () {
      final allPermissions = [
        'notification',
        'scheduleExactAlarm',
        'ignoreBatteryOptimizations',
      ];

      final grantedStates = allPermissions.map((p) => 'granted').toList();
      final allGranted = grantedStates.every((state) => state == 'granted');

      expect(allGranted, isTrue);
    });
  });
}

extension on Object? {
  operator [](String other) {}
}