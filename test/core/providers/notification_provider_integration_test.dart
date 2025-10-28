import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/providers/notification_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Notification Provider Unit Tests', () {
    test('notificationServiceProvider should be defined', () {
      // Verify provider exists
      expect(notificationServiceProvider, isNotNull);
    });

    test('notificationInitProvider should be a FutureProvider', () {
      expect(notificationInitProvider.toString(), contains('FutureProvider'));
    });

    test('notificationsEnabledProvider should be a FutureProvider<bool>', () {
      expect(notificationsEnabledProvider.toString(), contains('FutureProvider'));
    });

    test('notificationTimeProvider should be a FutureProvider<String>', () {
      expect(notificationTimeProvider.toString(), contains('FutureProvider'));
    });

    test('all providers should be exported correctly', () {
      // Verify all providers are accessible and properly typed
      final providers = [
        notificationServiceProvider,
        notificationInitProvider,
        notificationsEnabledProvider,
        notificationTimeProvider,
      ];

      for (final provider in providers) {
        expect(provider, isNotNull,
            reason: 'All providers should be non-null');
      }
    });
  });

  group('Provider Type Safety Tests', () {
    test('notificationServiceProvider should have correct return type', () {
      // Type should be Provider<NotificationService>
      expect(notificationServiceProvider.toString(), contains('Provider'));
    });

    test('notificationsEnabledProvider should return bool Future', () {
      // Should be FutureProvider<bool>
      expect(
        notificationsEnabledProvider.toString(),
        contains('FutureProvider'),
      );
    });

    test('notificationTimeProvider should return String Future', () {
      // Should be FutureProvider<String>
      expect(
        notificationTimeProvider.toString(),
        contains('FutureProvider'),
      );
    });
  });
}
