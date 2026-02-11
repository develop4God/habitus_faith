// test/core/services/service_locator_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/service_locator.dart';
import 'package:habitus_faith/core/services/notifications/notification_service.dart';

void main() {
  group('ServiceLocator', () {
    setUp(() {
      // Reset service locator before each test
      ServiceLocator().reset();
    });

    test('should register and retrieve lazy singleton', () {
      final locator = ServiceLocator();
      locator.registerLazySingleton<TestService>(() => TestService());

      final instance1 = locator.get<TestService>();
      final instance2 = locator.get<TestService>();

      expect(instance1, isNotNull);
      expect(instance2, isNotNull);
      expect(instance1, same(instance2)); // Should be same instance
    });

    test('should register and retrieve singleton', () {
      final locator = ServiceLocator();
      final service = TestService();
      locator.registerSingleton<TestService>(service);

      final retrieved = locator.get<TestService>();

      expect(retrieved, isNotNull);
      expect(retrieved, same(service));
    });

    test('should register and retrieve factory instances', () {
      final locator = ServiceLocator();
      locator.registerFactory<TestService>(() => TestService());

      final instance1 = locator.get<TestService>();
      final instance2 = locator.get<TestService>();

      expect(instance1, isNotNull);
      expect(instance2, isNotNull);
      expect(
          instance1, isNot(same(instance2))); // Should be different instances
    });

    test('should check if service is registered', () {
      final locator = ServiceLocator();

      expect(locator.isRegistered<TestService>(), isFalse);

      locator.registerLazySingleton<TestService>(() => TestService());

      expect(locator.isRegistered<TestService>(), isTrue);
    });

    test('should unregister service', () {
      final locator = ServiceLocator();
      locator.registerLazySingleton<TestService>(() => TestService());

      expect(locator.isRegistered<TestService>(), isTrue);

      locator.unregister<TestService>();

      expect(locator.isRegistered<TestService>(), isFalse);
    });

    test('should throw StateError when service not registered', () {
      final locator = ServiceLocator();

      expect(
        () => locator.get<TestService>(),
        throwsA(isA<StateError>()),
      );
    });

    test('should reset all registrations', () {
      final locator = ServiceLocator();
      locator.registerLazySingleton<TestService>(() => TestService());

      expect(locator.isRegistered<TestService>(), isTrue);

      locator.reset();

      expect(locator.isRegistered<TestService>(), isFalse);
    });

    test('setupServiceLocator should register NotificationService', () {
      setupServiceLocator();

      expect(ServiceLocator().isRegistered<NotificationService>(), isTrue);

      // Note: Cannot instantiate NotificationService in tests without Firebase initialization
      // This test only verifies the registration, not instantiation
    });

    test('getService global function should work with ServiceLocator', () {
      final locator = ServiceLocator();
      locator.registerLazySingleton<TestService>(() => TestService());

      final service1 = getService<TestService>();
      final service2 = getService<TestService>();

      expect(service1, isNotNull);
      expect(service2, isNotNull);
      expect(
          service1, same(service2)); // Should be same instance (lazy singleton)
    });

    test('serviceLocator getter should return singleton instance', () {
      final locator1 = serviceLocator;
      final locator2 = serviceLocator;

      expect(locator1, same(locator2));
      expect(locator1, same(ServiceLocator()));
    });
  });
}

// Test service for testing purposes
class TestService {
  final String id = DateTime.now().microsecondsSinceEpoch.toString();
}
