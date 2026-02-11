import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:habitus_faith/core/services/notifications/notification_service.dart';
import 'package:habitus_faith/core/providers/firebase_init_provider.dart';
import '../../features/habits/presentation/habits_providers.dart';

// Provider for NotificationService instance - Pure Riverpod DI
// Note: This provider should only be accessed after Firebase is initialized
// The notificationInitProvider ensures proper initialization order
final notificationServiceProvider = Provider<NotificationService>((ref) {
  // Check if Firebase is ready (for debugging)
  final firebaseReady = ref.read(firebaseReadyProvider);
  if (!firebaseReady) {
    debugPrint('⚠️ NotificationService: Created before Firebase ready!');
  }

  return NotificationService.create();
});

// Provider for NotificationService initialization
// This MUST be called before using NotificationService to ensure Firebase is ready
final notificationInitProvider = FutureProvider<void>((ref) async {
  // Wait for Firebase to initialize first
  await ref.watch(firebaseInitProvider.future);
  debugPrint('🔥 NotificationService: Firebase ready, creating service...');

  // Now it's safe to create and initialize the notification service
  final notificationService = ref.read(notificationServiceProvider);
  await notificationService.initialize();
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
