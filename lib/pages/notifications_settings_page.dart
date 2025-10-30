import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitus_faith/core/providers/notification_provider.dart';
import 'package:habitus_faith/core/services/background_task_service.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';

class NotificationsSettingsPage extends ConsumerStatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  ConsumerState<NotificationsSettingsPage> createState() =>
      _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState
    extends ConsumerState<NotificationsSettingsPage> {
  bool _notificationsEnabled = true;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  bool _mlPredictionsEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final notificationService = ref.read(notificationServiceProvider);
      final enabled = await notificationService.areNotificationsEnabled();
      final timeStr = await notificationService.getNotificationTime();
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      // Load ML predictions setting
      final backgroundTaskService = BackgroundTaskService();
      final mlEnabled = await backgroundTaskService.arePredictionsEnabled();

      setState(() {
        _notificationsEnabled = enabled;
        _selectedTime = TimeOfDay(hour: hour, minute: minute);
        _mlPredictionsEnabled = mlEnabled;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() {
      _notificationsEnabled = value;
    });

    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.setNotificationsEnabled(value);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? AppLocalizations.of(context)!.notificationsEnabled
              : AppLocalizations.of(context)!.notificationsDisabled,
        ),
      ),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });

      final timeStr =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.setNotificationTime(timeStr);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)!.notificationTimeUpdated} ${picked.format(context)}',
          ),
        ),
      );
    }
  }

  Future<void> _toggleMLPredictions(bool value) async {
    setState(() {
      _mlPredictionsEnabled = value;
    });

    final backgroundTaskService = BackgroundTaskService();
    await backgroundTaskService.setPredictionsEnabled(value);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'ML predictions enabled. You will receive smart nudges to help maintain your habits.'
              : 'ML predictions disabled. Smart nudges will not be shown.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.notificationSettings),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationSettings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.enableNotifications,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: _notificationsEnabled,
                    onChanged: _toggleNotifications,
                    title: Text(
                      _notificationsEnabled
                          ? l10n.notificationsOn
                          : l10n.notificationsOff,
                    ),
                    subtitle: Text(
                      l10n.receiveReminderNotifications,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.notificationTime,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(l10n.selectNotificationTime),
                    subtitle: Text(
                      '${l10n.currentTime}: ${_selectedTime.format(context)}',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: _notificationsEnabled ? _selectTime : null,
                    enabled: _notificationsEnabled,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Smart Predictions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: _mlPredictionsEnabled,
                    onChanged: _toggleMLPredictions,
                    title: Text(
                      _mlPredictionsEnabled
                          ? 'Predictions Enabled'
                          : 'Predictions Disabled',
                    ),
                    subtitle: const Text(
                      'Receive smart nudges to help maintain your habits based on ML predictions',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Daily at 6:00 AM, we analyze your habits and send helpful suggestions if we detect abandonment risk.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 48,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.notificationInfo,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
