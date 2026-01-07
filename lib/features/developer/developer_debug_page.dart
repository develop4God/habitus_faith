import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitus_faith/core/providers/clock_provider.dart';
import 'package:habitus_faith/core/services/time/clock.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
            child: Text('Developer tools are only available in debug mode.')),
      );
    }
    const fastTimeEnabled = bool.fromEnvironment('FAST_TIME');
    final clock = ref.watch(clockProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Debug Tools'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Developer Tools',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.bug_report, color: Colors.deepPurple),
            title: const Text('Show App Info'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('App Info'),
                  content: Text('Date: \\${DateTime.now()}\nMode: DEBUG'),
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
          const Divider(),
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
                    child: Text(
                      '288x',
                      style: TextStyle(
                        color: Colors.orange.shade900,
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
                'Current simulated time: \\${clock.now()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange,
                    ),
              ),
            ),
          const Divider(),
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
              // Show the NotificationBellButton in a dialog for demo
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
                            content: Text('Notification set: '
                                '${settings?.timing.displayName ?? 'None'} @ ${settings?.eventTime ?? ''}')),
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
          // Add more developer tools here as needed
        ],
      ),
    );
  }
}
