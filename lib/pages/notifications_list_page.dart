import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/habits/domain/habit.dart';
import '../features/habits/domain/models/habit_notification.dart';
import '../features/habits/data/storage/storage_providers.dart';
import '../pages/habits_page.dart';
import '../l10n/app_localizations.dart';

class NotificationsListPage extends ConsumerWidget {
  const NotificationsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final habitsAsync = ref.watch(jsonHabitsStreamProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Notificaciones'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: habitsAsync.when(
        data: (habits) {
          // Filter habits that have notifications enabled
          final habitsWithNotifications = habits.where((habit) {
            return habit.notificationSettings != null &&
                habit.notificationSettings!.timing != NotificationTiming.none;
          }).toList();

          if (habitsWithNotifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay notificaciones programadas',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: habitsWithNotifications.length,
            itemBuilder: (context, index) {
              final habit = habitsWithNotifications[index];
              return _buildNotificationCard(context, habit);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, Habit habit) {
    final settings = habit.notificationSettings!;
    final isEnabled = settings.timing != NotificationTiming.none;

    String notificationTime = '';
    if (settings.eventTime != null) {
      final parts = settings.eventTime!.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      int adjustedMinutes = hour * 60 + minute;
      if (settings.timing.minutesBefore != null) {
        adjustedMinutes -= settings.timing.minutesBefore!;
      } else if (settings.timing == NotificationTiming.custom &&
          settings.customMinutesBefore != null) {
        adjustedMinutes -= settings.customMinutesBefore!;
      }

      if (adjustedMinutes < 0) adjustedMinutes += 24 * 60;

      final adjustedHour = (adjustedMinutes ~/ 60) % 24;
      final adjustedMinute = adjustedMinutes % 60;

      notificationTime =
          '${adjustedHour.toString().padLeft(2, '0')}:${adjustedMinute.toString().padLeft(2, '0')}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getCategoryIcon(habit.category),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notificationTime.isNotEmpty ? notificationTime : 'Sin hora',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Status or toggle
          if (isEnabled)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Encendido',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(HabitCategory category) {
    switch (category) {
      case HabitCategory.spiritual:
        return Icons.church;
      case HabitCategory.physical:
        return Icons.fitness_center;
      case HabitCategory.mental:
        return Icons.psychology;
      case HabitCategory.relational:
        return Icons.people;
      case HabitCategory.other:
        return Icons.category;
    }
  }
}
