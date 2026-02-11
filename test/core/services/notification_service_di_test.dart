// test/core/services/notification_service_di_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/service_locator.dart';
import 'package:habitus_faith/core/services/notifications/notification_service.dart';

void main() {
  group('NotificationService DI Integration', () {
    setUp(() {
      // Reset service locator before each test
      ServiceLocator().reset();
    });

    // Note: Tests that instantiate NotificationService are skipped because
    // Firebase needs to be initialized first. These tests verify the DI
    // pattern is correctly implemented without requiring Firebase.

    test('should be registered as lazy singleton in ServiceLocator', () {
      setupServiceLocator();

      expect(ServiceLocator().isRegistered<NotificationService>(), isTrue);
    });

    test('ServiceLocator should support NotificationService registration', () {
      setupServiceLocator();

      // Verify registration without instantiation
      expect(
        ServiceLocator().isRegistered<NotificationService>(),
        isTrue,
        reason: 'NotificationService should be registered',
      );
    });

    test('should support factory method pattern', () {
      // This test verifies the factory method exists
      // Actual instantiation requires Firebase initialization
      expect(
        () => NotificationService.create,
        returnsNormally,
        reason: 'Factory method should exist',
      );
    });
  });
}
