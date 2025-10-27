import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitus_faith/core/services/notifications/notification_service.dart';

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
