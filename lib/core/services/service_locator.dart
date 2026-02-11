// lib/core/services/service_locator.dart
/// Service Locator for Dependency Injection
///
/// This service locator provides a simple DI container for managing
/// singleton instances of services throughout the application.
///
/// Usage:
///   // Setup in main():
///   setupServiceLocator();
///
///   // Get service instance:
///   final service = getService<NotificationService>();

library;

import 'package:habitus_faith/core/services/notifications/notification_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  final Map<Type, dynamic Function()> _factories = {};
  final Map<Type, dynamic> _singletons = {};

  /// Register a factory that creates a new instance each time
  void registerFactory<T>(T Function() factory) {
    _factories[T] = factory;
  }

  /// Register a singleton instance
  void registerSingleton<T>(T instance) {
    _singletons[T] = instance;
  }

  /// Register a lazy singleton factory
  /// The instance is created on first access and reused afterward
  void registerLazySingleton<T>(T Function() factory) {
    _factories[T] = () {
      if (!_singletons.containsKey(T)) {
        _singletons[T] = factory();
      }
      return _singletons[T];
    };
  }

  /// Get an instance of the registered service
  T get<T>() {
    if (_singletons.containsKey(T)) {
      return _singletons[T] as T;
    }
    if (_factories.containsKey(T)) {
      return _factories[T]!() as T;
    }
    throw StateError(
        'Service ${T.toString()} not registered. Did you forget to call setupServiceLocator() in main()?');
  }

  /// Check if a service is registered
  bool isRegistered<T>() =>
      _factories.containsKey(T) || _singletons.containsKey(T);

  /// Reset all registrations (mainly for testing)
  void reset() {
    _factories.clear();
    _singletons.clear();
  }

  /// Unregister a specific service
  void unregister<T>() {
    _factories.remove(T);
    _singletons.remove(T);
  }
}

/// Setup all service registrations
void setupServiceLocator() {
  final locator = ServiceLocator();

  // Register NotificationService as lazy singleton
  locator.registerLazySingleton<NotificationService>(
    NotificationService.create,
  );
}

/// Global service locator instance
ServiceLocator get serviceLocator => ServiceLocator._instance;

/// Convenient global function to get service
T getService<T>() => ServiceLocator().get<T>();
