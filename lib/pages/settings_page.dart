import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitus_faith/core/providers/language_provider.dart';
import 'package:habitus_faith/core/providers/clock_provider.dart';
import 'package:habitus_faith/core/services/time/clock.dart';
import 'package:habitus_faith/features/habits/domain/models/display_mode.dart';
import 'package:habitus_faith/features/habits/presentation/onboarding/display_mode_provider.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';
import 'package:habitus_faith/pages/language_settings_page.dart';
import 'package:habitus_faith/pages/notifications_settings_page.dart';
import 'package:habitus_faith/pages/home_page.dart';
import 'package:habitus_faith/widgets/display_mode_modal.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLanguage =
        ref.watch(appLanguageProvider.notifier).currentLanguage;
    final currentMode = ref.watch(displayModeProvider);
    final clock = ref.watch(clockProvider);
    const fastTimeEnabled = bool.fromEnvironment('FAST_TIME');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomePage()),
              (route) => false,
            );
          },
        ),
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            subtitle: Text('${currentLanguage.flag} ${currentLanguage.name}'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LanguageSettingsPage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(l10n.notifications),
            subtitle: Text(l10n.notificationSettings),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsSettingsPage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              currentMode == DisplayMode.compact
                  ? Icons.check_circle_outline
                  : Icons.insights,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(l10n.displayMode),
            subtitle: Text(
              currentMode == DisplayMode.compact
                  ? l10n.compactModeSubtitle
                  : l10n.advancedModeSubtitle,
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () =>
                _showDisplayModeDialog(context, ref, l10n, currentMode),
          ),
          const Divider(),
          // Developer Settings Section (only visible in debug mode)
          if (kDebugMode) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Developer Settings',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ListTile(
              // ignore: prefer_const_constructors
              leading: Icon(
                fastTimeEnabled ? Icons.fast_forward : Icons.schedule,
                color: fastTimeEnabled ? Colors.orange : Colors.grey,
              ),
              title: const Text('Time Acceleration'),
              // ignore: prefer_const_constructors
              subtitle: Text(
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
                  'Current simulated time: ${clock.now()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.orange,
                      ),
                ),
              ),
            const Divider(),
          ],
        ],
      ),
    );
  }

  void _showDisplayModeDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    DisplayMode currentMode,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return DisplayModeModal(currentMode: currentMode, ref: ref, l10n: l10n);
      },
    );
  }
}
