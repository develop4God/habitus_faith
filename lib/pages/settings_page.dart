import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitus_faith/core/providers/language_provider.dart';
import 'package:habitus_faith/features/habits/domain/models/display_mode.dart';
import 'package:habitus_faith/features/habits/presentation/onboarding/display_mode_provider.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';
import 'package:habitus_faith/pages/language_settings_page.dart';
import 'package:habitus_faith/pages/notifications_settings_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLanguage =
        ref.watch(appLanguageProvider.notifier).currentLanguage;
    final currentMode = ref.watch(displayModeProvider);

    return Scaffold(
      appBar: AppBar(
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
        return Consumer(
          builder: (context, ref, child) {
            final selectedMode = ref.watch(displayModeProvider);

            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      l10n.displayMode,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  RadioListTile<DisplayMode>(
                    title: Text(l10n.compactMode),
                    subtitle: Text(l10n.compactModeSubtitle),
                    value: DisplayMode.compact,
                    groupValue: selectedMode,
                    onChanged: (DisplayMode? value) async {
                      if (value != null) {
                        await ref
                            .read(displayModeProvider.notifier)
                            .setDisplayMode(value);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.displayModeUpdated(l10n.compactMode),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  RadioListTile<DisplayMode>(
                    title: Text(l10n.advancedMode),
                    subtitle: Text(l10n.advancedModeSubtitle),
                    value: DisplayMode.advanced,
                    groupValue: selectedMode,
                    onChanged: (DisplayMode? value) async {
                      if (value != null) {
                        await ref
                            .read(displayModeProvider.notifier)
                            .setDisplayMode(value);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.displayModeUpdated(l10n.advancedMode),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
