import 'package:flutter/material.dart';
import '../features/habits/domain/models/habit_notification.dart';

/// Notification bell button that only asks for the hour and sets daily notification at that hour.
///
/// When pressed, it opens a time picker and returns HabitNotificationSettings
/// with NotificationTiming.atEventTime and the selected hour. Recurrence is always daily (handled in backend).
class NotificationBellButton extends StatelessWidget {
  final HabitNotificationSettings? initialSettings;
  final String? eventTime;
  final ValueChanged<HabitNotificationSettings?> onSettingsChanged;

  const NotificationBellButton({
    super.key,
    required this.initialSettings,
    required this.eventTime,
    required this.onSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = initialSettings != null &&
        initialSettings!.timing != NotificationTiming.none;
    return IconButton(
      icon: Icon(
        isActive ? Icons.notifications_active : Icons.notifications_none,
        color: isActive ? Colors.orange : Colors.grey,
      ),
      tooltip: 'Configurar recordatorio',
      onPressed: () async {
        // Parse eventTime or use now
        TimeOfDay initial = TimeOfDay.now();
        if (eventTime != null && eventTime!.contains(':')) {
          final parts = eventTime!.split(':');
          final hour = int.tryParse(parts[0]) ?? initial.hour;
          final minute = int.tryParse(parts[1]) ?? initial.minute;
          initial = TimeOfDay(hour: hour, minute: minute);
        }
        final picked = await showTimePicker(
          context: context,
          initialTime: initial,
        );
        if (picked != null) {
          final settings = HabitNotificationSettings(
            timing: NotificationTiming.atEventTime,
            eventTime: '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
            // Recurrence is always daily in backend logic
          );
          onSettingsChanged(settings);
        }
      },
    );
  }
}
