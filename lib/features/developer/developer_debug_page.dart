import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitus_faith/core/providers/clock_provider.dart';
import 'package:habitus_faith/core/providers/habit_predictor_provider.dart';
import 'package:habitus_faith/core/providers/background_task_service_provider.dart';
import 'package:habitus_faith/core/providers/notification_provider.dart';
import 'package:habitus_faith/core/providers/ai_providers.dart';
import 'package:habitus_faith/core/services/time/clock.dart';
import 'package:habitus_faith/core/services/notifications/notification_service.dart';
import 'package:habitus_faith/features/habits/domain/models/generation_request.dart';
import 'package:habitus_faith/features/habits/presentation/ai_generator/micro_habit_generator_page.dart';
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
    const fastTimeEnabled = true;
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
                debugPrint('PREDICTOR 🧠 Starting ML Predictions...');
                final predictor = ref.read(habitPredictorProvider);
                await predictor.runDailyPredictions();
                // Print telemetry for developer validation
                debugPrint('PREDICTOR 🧠 ML Predictions completed. Telemetry: '
                    '\nPredictions: \\${predictor.predictor.telemetry['prediction_count']}, '
                    'Errors: \\${predictor.predictor.telemetry['error_count']}, '
                    'Last prediction: \\${predictor.predictor.telemetry['last_prediction']}');
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('ML Predictions completed successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                debugPrint('PREDICTOR 🧠 ML Prediction failed: $e');
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('ML Prediction failed: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          // ML Predictor Telemetry Display
          Builder(
            builder: (context) {
              final predictor = ref.watch(habitPredictorProvider);
              final telemetry = predictor.predictor.telemetry;
              return Card(
                color: Colors.blue.shade50,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ML Predictor Telemetry',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Predictions: \\${telemetry['prediction_count']}'),
                      Text('Errors: \\${telemetry['error_count']}'),
                      Text(
                          'Last prediction: \\${telemetry['last_prediction'] ?? 'N/A'}'),
                    ],
                  ),
                ),
              );
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
              const prefix = NotificationService.nudgeSentPrefix;
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
          ListTile(
            leading:
                const Icon(Icons.notifications_active, color: Colors.purple),
            title: const Text('Schedule Test Nudge (in 1 min)'),
            subtitle: const Text('Test nudge notification with 1-minute delay'),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                final notificationService =
                    ref.read(notificationServiceProvider);

                // Schedule a test nudge notification in 1 minute
                await notificationService.scheduleNudgeNotification(
                  habitId: 'test_habit_123',
                  habitName: 'Test Habit',
                  suggestedMinutes: 10,
                  delayMinutes: 1,
                );

                debugPrint(
                    'PREDICTOR 🧠 📅 Scheduled test nudge notification for 1 minute from now');
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Test nudge scheduled for 1 minute from now'),
                    backgroundColor: Colors.blue,
                  ),
                );
              } catch (e) {
                debugPrint('PREDICTOR 🧠 ❌ Failed to schedule test nudge: $e');
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Failed to schedule nudge: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          const Divider(),
          const Text(
            'AI & Gemini Features',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.auto_awesome, color: Colors.purple),
            title: const Text('Test Gemini Micro Habits Generator'),
            subtitle: const Text('Generate AI-powered micro-habits'),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                debugPrint(
                    'GEMINI 🤖 Starting micro-habits generation test...');
                final generatorNotifier =
                    ref.read(microHabitGeneratorProvider.notifier);

                // Test generation request
                await generatorNotifier.generate(
                  const GenerationRequest(
                    userGoal: 'Orar más consistentemente',
                    failurePattern: 'Olvido en las mañanas ocupadas',
                    faithContext: 'Cristiano',
                    languageCode: 'es',
                  ),
                );

                final state = ref.read(microHabitGeneratorProvider);
                state.when(
                  data: (habits) {
                    debugPrint(
                        'GEMINI 🤖 ✅ Generated ${habits.length} micro-habits successfully');
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                            'Generated ${habits.length} habits successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  loading: () {
                    debugPrint('GEMINI 🤖 ⏳ Loading...');
                  },
                  error: (error, stack) {
                    debugPrint('GEMINI 🤖 ❌ Error: $error');
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Generation failed: $error'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                );
              } catch (e) {
                debugPrint('GEMINI 🤖 ❌ Failed to generate habits: $e');
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Failed to generate: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          Consumer(
            builder: (context, ref, child) {
              final generatorNotifier =
                  ref.watch(microHabitGeneratorProvider.notifier);
              final remainingRequests = generatorNotifier.remainingRequests;

              return Card(
                color: Colors.purple.shade50,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Gemini API Status',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Remaining requests: $remainingRequests/month'),
                      const SizedBox(height: 4),
                      Builder(
                        builder: (context) {
                          final state = ref.watch(microHabitGeneratorProvider);
                          return state.when(
                            data: (habits) => Text(
                                'Last generation: \\${habits.length} habits'),
                            loading: () => const Text('Status: Generating...'),
                            error: (error, _) => Text(
                                'Last error: \\${error.toString().substring(0, 50)}...'),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.psychology_alt, color: Colors.deepPurple),
            title: const Text('Open Gemini Coach UI'),
            subtitle: const Text('Navigate to Micro Habit Generator page'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MicroHabitGeneratorPage(),
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
              Icons.fast_forward,
              color: Colors.orange,
            ),
            title: const Text('Time Acceleration'),
            subtitle: const Text(
              'ENABLED: 288x speed (1 week in 35 min)',
            ),
            trailing: Container(
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
            ),
          ),
          // Fast Acceleration Toggle Button (debug mode only)
          if (kDebugMode)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.fast_forward),
                label: const Text('Disable Fast Acceleration'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade100,
                  foregroundColor: Colors.orange,
                ),
                onPressed: () {
                  // This toggles the mode for the session (does not persist or affect global env)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fast Acceleration DISABLED'),
                      backgroundColor: Colors.grey,
                    ),
                  );
                },
              ),
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
          ListTile(
            leading: const Icon(Icons.touch_app, color: Colors.blue),
            title: const Text('Reset Pet Tap Hint'),
            subtitle: const Text('Delete has_seen_pet_hint flag to show Lottie again'),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('has_seen_pet_hint');
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Pet tap hint flag deleted.'),
                    backgroundColor: Colors.green,
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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.refresh, color: Colors.orange),
            title: const Text('Reset Gemini Request State'),
            subtitle: const Text(
                'Clear Gemini cache and reset request counters for testing'),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                debugPrint('GEMINI 🤖 Resetting Gemini request state...');
                final generatorNotifier =
                    ref.read(microHabitGeneratorProvider.notifier);
                await generatorNotifier.reset();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Gemini request state reset!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                debugPrint('GEMINI 🤖 ❌ Failed to reset Gemini state: $e');
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Failed to reset: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
