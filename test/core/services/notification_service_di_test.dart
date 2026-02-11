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

    test('should create NotificationService via factory method', () {
      final service = NotificationService.create();

      expect(service, isNotNull);
      expect(service, isA<NotificationService>());
    });

    test('should be registered as lazy singleton in ServiceLocator', () {
      setupServiceLocator();

      expect(ServiceLocator().isRegistered<NotificationService>(), isTrue);
    });

    test('should return same instance when accessed multiple times via DI', () {
      setupServiceLocator();

      final service1 = getService<NotificationService>();
      final service2 = getService<NotificationService>();

      expect(service1, same(service2));
    });

    test('should still support singleton pattern for backward compatibility',
        () {
      final service1 = NotificationService();
      final service2 = NotificationService();

      expect(service1, same(service2));
    });

    test('DI instance and singleton should be the same', () {
      setupServiceLocator();

      final diInstance = getService<NotificationService>();
      final singletonInstance = NotificationService();

      // They should be the same instance due to the implementation
      expect(diInstance, same(singletonInstance));
    });
  });
}
