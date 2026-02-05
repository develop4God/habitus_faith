import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitus_faith/core/providers/clock_provider.dart';
import 'package:habitus_faith/core/providers/habit_predictor_provider.dart';
import 'package:habitus_faith/core/providers/background_task_service_provider.dart';
import 'package:habitus_faith/core/services/time/clock.dart';
import 'package:habitus_faith/core/services/notifications/notification_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/core/providers/scheduled_hour_provider.dart';

import '../../widgets/notification_bell_button.dart';

/// A page for developer/debug tools, only visible in debug mode.
class DeveloperDebugPage extends ConsumerWidget {
  const DeveloperDebugPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kDebugMode) {
      // Prevent access in release mode
      return const Scaffold(
        body: Center(
          child: Text('Developer tools are only available in debug mode.'),
        ),
      );
    }
    const fastTimeEnabled = bool.fromEnvironment('FAST_TIME');
    final clock = ref.watch(clockProvider);
    final backgroundTaskService = ref.watch(backgroundTaskServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Debug Tools'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'ML & Background Tasks',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // Replace FutureBuilder with Riverpod async provider usage
          Consumer(
            builder: (context, ref, child) {
              final scheduledHourAsync = ref.watch(scheduledHourProvider);

              return scheduledHourAsync.when(
                data: (scheduledHour) => ListTile(
                  leading: const Icon(Icons.access_time, color: Colors.blue),
                  title: const Text('Change Prediction Hour'),
                  subtitle: Text('Currently scheduled for: $scheduledHour:00'),
                  trailing: const Icon(Icons.edit),
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(hour: scheduledHour, minute: 0),
                    );
                    if (picked != null) {
                      try {
                        await backgroundTaskService
                            .setScheduledHour(picked.hour);
                        ref.invalidate(
                            scheduledHourProvider); // Refresh the provider
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Scheduled hour updated to ${picked.hour}:00')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to update hour: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
                loading: () => const ListTile(
                  leading: Icon(Icons.access_time, color: Colors.grey),
                  title: Text('Change Prediction Hour'),
                  subtitle: Text('Loading...'),
                  enabled: false,
                ),
                error: (e, _) => ListTile(
                  leading: const Icon(Icons.error, color: Colors.red),
                  title: const Text('Change Prediction Hour'),
                  subtitle: Text('Error loading hour: $e'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.psychology, color: Colors.blue),
            title: const Text('Run ML Predictor Now'),
            subtitle: const Text('Force runs the daily abandonment prediction'),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                final predictor = ref.read(habitPredictorProvider);
                await predictor.runDailyPredictions();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('ML Predictions completed successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('ML Prediction failed: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.notification_important, color: Colors.orange),
            title: const Text('Reset Nudge Cooldown'),
            subtitle: const Text(
                'Allows sending the same nudge notification immediately'),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              final prefs = await SharedPreferences.getInstance();
              final prefix = NotificationService.nudgeSentPrefix;
              final keys =
                  prefs.getKeys().where((k) => k.startsWith(prefix)).toList();
              for (final key in keys) {
                await prefs.remove(key);
              }
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Nudge cooldowns reset successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          const Divider(),
          const Text(
            'System Tools',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.bug_report, color: Colors.deepPurple),
            title: const Text('Show App Info'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('App Info'),
                  content: Text('Date: ${DateTime.now()}\nMode: DEBUG'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              fastTimeEnabled ? Icons.fast_forward : Icons.schedule,
              color: fastTimeEnabled ? Colors.orange : Colors.grey,
            ),
            title: const Text('Time Acceleration'),
            subtitle: const Text(
              fastTimeEnabled
                  ? 'ENABLED: 288x speed (1 week in 35 min)'
                  : 'Disabled (use --dart-define=FAST_TIME=true)',
            ),
            trailing: fastTimeEnabled
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '288x',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          ),
          if (fastTimeEnabled && clock is DebugClock)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Current simulated time: ${clock.now()}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.orange),
              ),
            ),
          ListTile(
            leading: const Icon(Icons.restart_alt, color: Colors.red),
            title: const Text('Reset Onboarding Completion'),
            subtitle: const Text('Delete onboarding_complete flag for testing'),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('onboarding_complete');
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('onboarding_complete flag deleted.'),
                    backgroundColor: Colors.red,
                  ),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          const Divider(),
          // Bell button for notification test/demo
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.orange),
            title: const Text('Test Notification Bell'),
            subtitle: const Text('Open notification config dialog'),
            onTap: () async {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Notification Bell Demo'),
                  content: NotificationBellButton(
                    initialSettings: null,
                    eventTime: '08:00',
                    onSettingsChanged: (settings) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Notification set: '
                            '${settings?.timing.displayName ?? 'None'} @ ${settings?.eventTime ?? ''}',
                          ),
                        ),
                      );
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Exportar estadísticas (JSON)'),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                final prefs = await SharedPreferences.getInstance();
                final statsJson = prefs.getString('user_statistics');
                if (statsJson == null) {
                  if (navigator.mounted) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('No hay estadísticas para exportar.'),
                      ),
                    );
                  }
                  return;
                }
                try {
                  final downloadsDir = await getExternalStorageDirectory();
                  final now = DateTime.now();
                  final formatted =
                      '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
                  final file = File(
                    '${downloadsDir?.path ?? '/storage/emulated/0/Download'}/statistics_export_$formatted.json',
                  );
                  await file.writeAsString(statsJson);
                  if (navigator.mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Estadísticas exportadas en: \n${file.path}',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (navigator.mounted) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Error al exportar: $e')),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
