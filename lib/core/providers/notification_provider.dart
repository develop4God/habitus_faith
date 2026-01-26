import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitus_faith/core/services/notifications/notification_service.dart';
import '../../features/habits/presentation/habits_providers.dart';

// Provider for NotificationService instance
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Provider for NotificationService initialization
final notificationInitProvider = FutureProvider<void>((ref) async {
  final notificationService = ref.watch(notificationServiceProvider);
  await notificationService.initialize();
});

// Provider for checking if notifications are enabled
final notificationsEnabledProvider = FutureProvider<bool>((ref) async {
  final notificationService = ref.watch(notificationServiceProvider);
  return await notificationService.areNotificationsEnabled();
});

// Provider for getting notification time
final notificationTimeProvider = FutureProvider<String>((ref) async {
  final notificationService = ref.watch(notificationServiceProvider);
  return await notificationService.getNotificationTime();
});

// Provider to reschedule habit notifications when app starts
// This listens to the habits stream and reschedules notifications when habits are loaded
final habitNotificationsSchedulerProvider = FutureProvider<void>((ref) async {
  try {
    // Wait for notification service to initialize
    await ref.watch(notificationInitProvider.future);
    
    // Watch the habits stream and get the first emission
    final habitsStream = ref.watch(habitsStreamProvider.stream);
    final habitsAsync = await habitsStream.first;
    
    // Reschedule all habit notifications
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.rescheduleAllHabitNotifications(habitsAsync);
  } catch (e) {
    // Log error but don't fail the app initialization
    // The notification service will log any specific errors
    rethrow;
  }
});
