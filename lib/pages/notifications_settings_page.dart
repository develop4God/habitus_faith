import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitus_faith/core/providers/notification_provider.dart';
import 'package:habitus_faith/core/providers/background_task_service_provider.dart';
import 'package:habitus_faith/core/providers/language_provider.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';
import 'package:habitus_faith/widgets/confirm_notification_dialog.dart';

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
      final backgroundTaskService = ref.read(backgroundTaskServiceProvider);
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

    final currentLocale = ref.read(appLanguageProvider);
    final languageCode = currentLocale.languageCode;

    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.setNotificationsEnabled(value,
        languageCode: languageCode);

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
      // Instead of saving immediately, show a compact confirmation dialog
      final notificationService = ref.read(notificationServiceProvider);
      final existingTimeStr = await notificationService.getNotificationTime();
      final parts = existingTimeStr.split(':');
      final existingHour = int.parse(parts[0]);
      final existingMinute = int.parse(parts[1]);
      final existingTimes = [TimeOfDay(hour: existingHour, minute: existingMinute)];

      // Ensure widget is still mounted before showing dialog (we had awaits above)
      if (!mounted) return;

      // Use the compact dialog which returns the confirmed TimeOfDay or null
      final confirmed = await showConfirmNotificationDialog(
        context,
        proposedTime: picked,
        existingTimes: existingTimes,
        userTimezone: null,
      );

      // Ensure widget is still mounted before using context after async gap
      if (!mounted) return;

      if (confirmed != null) {
        // Update visible selected time only after user confirmed and validation passed
        setState(() {
          _selectedTime = confirmed;
        });

        final timeStr =
            '${confirmed.hour.toString().padLeft(2, '0')}:${confirmed.minute.toString().padLeft(2, '0')}';

        // Capture localization-dependent strings before the async call so we
        // don't use BuildContext across an async gap (fixes use_build_context_synchronously).
        final l10n = AppLocalizations.of(context)!;
        final formatted = confirmed.format(context);

        final currentLocale = ref.read(appLanguageProvider);
        final languageCode = currentLocale.languageCode;

        await notificationService.setNotificationTime(timeStr,
            languageCode: languageCode);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.notificationTimeUpdated(formatted)),
          ),
        );
      }
    }
  }

  Future<void> _toggleMLPredictions(bool value) async {
    setState(() {
      _mlPredictionsEnabled = value;
    });

    final backgroundTaskService = ref.read(backgroundTaskServiceProvider);
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
        appBar: AppBar(title: Text(l10n.notificationSettings)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationSettings)),
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
                    subtitle: Text(l10n.receiveReminderNotifications),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  const Icon(Icons.info_outline, size: 48, color: Colors.blue),
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
