import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:habitus_faith/core/services/notifications/notification_service.dart';
import 'package:habitus_faith/core/providers/firebase_init_provider.dart';
import 'package:habitus_faith/core/providers/firebase_services_provider.dart';
import 'package:habitus_faith/core/providers/language_provider.dart';
import '../../features/habits/presentation/habits_providers.dart';

// Provider for NotificationService instance - Pure Riverpod DI with Constructor Injection
// Follows SOLID principles: Dependencies are injected, not created internally
final notificationServiceProvider = Provider<NotificationService>((ref) {
  // Ensure Firebase is initialized before creating the service
  final firebaseReady = ref.read(firebaseReadyProvider);
  if (!firebaseReady) {
    debugPrint('⚠️ NotificationService: Created before Firebase ready!');
  }

  // Inject all dependencies via constructor (Dependency Injection)
  // Using ref.watch() to ensure provider rebuilds if Firebase reinitializes
  final service = NotificationService(
    firebaseMessaging: ref.watch(firebaseMessagingProvider),
    firestore: ref.watch(firebaseFirestoreProvider),
    auth: ref.watch(firebaseAuthProvider),
  );

  // 🔴 CRITICAL: Dispose service when provider is disposed
  // Prevents memory leaks by cancelling all stream subscriptions
  ref.onDispose(() {
    debugPrint(
        '[NotificationServiceProvider] Disposing service and cleaning up resources');
    service.dispose();
  });

  return service;
});

// Provider for NotificationService initialization
// This MUST be called before using NotificationService to ensure Firebase is ready
final notificationInitProvider = FutureProvider<void>((ref) async {
  // Wait for Firebase to initialize first
  await ref.watch(firebaseInitProvider.future);
  debugPrint('🔥 NotificationService: Firebase ready, creating service...');

  // Get current language from the app language provider
  final currentLocale = ref.read(appLanguageProvider);
  final languageCode = currentLocale.languageCode;

  // Now it's safe to create and initialize the notification service
  final notificationService = ref.read(notificationServiceProvider);
  await notificationService.initialize(languageCode: languageCode);
});

// Provider for checking if notifications are enabled
final notificationsEnabledProvider = FutureProvider<bool>((ref) async {
  // Ensure notification service is initialized
  await ref.watch(notificationInitProvider.future);

  final notificationService = ref.read(notificationServiceProvider);
  return await notificationService.areNotificationsEnabled();
});

// Provider for getting notification time
final notificationTimeProvider = FutureProvider<String>((ref) async {
  // Ensure notification service is initialized
  await ref.watch(notificationInitProvider.future);

  final notificationService = ref.read(notificationServiceProvider);
  return await notificationService.getNotificationTime();
});

// Provider to reschedule habit notifications when app starts
// This listens to the habits stream and reschedules notifications when habits are loaded
final habitNotificationsSchedulerProvider = FutureProvider<void>((ref) async {
  // Wait for notification service to initialize
  await ref.watch(notificationInitProvider.future);

  // Wait for habits to load
  final habitsAsync = await ref.watch(habitsStreamProvider.future);

  // Reschedule all habit notifications
  final notificationService = ref.read(notificationServiceProvider);
  await notificationService.rescheduleHabitNotifications(habitsAsync);
});
