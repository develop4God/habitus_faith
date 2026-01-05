import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitus_faith/core/providers/language_provider.dart';
import 'package:habitus_faith/features/habits/domain/models/display_mode.dart';
import 'package:habitus_faith/features/habits/presentation/onboarding/display_mode_provider.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';
import 'package:habitus_faith/pages/language_settings_page.dart';
import 'package:habitus_faith/pages/notifications_settings_page.dart';
import 'package:habitus_faith/pages/home_page.dart';
import 'package:habitus_faith/widgets/display_mode_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

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
          // Botón para exportar estadísticas
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Builder(
              builder: (context) {
                return ElevatedButton.icon(
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
                              content:
                                  Text('No hay estadísticas para exportar.')),
                        );
                      }
                      return;
                    }
                    try {
                      final downloadsDir = await getExternalStorageDirectory();
                      final now =
                          DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
                      final file = File(
                          '${downloadsDir?.path ?? '/storage/emulated/0/Download'}/statistics_export_$now.json');
                      await file.writeAsString(statsJson);
                      if (navigator.mounted) {
                        messenger.showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Estadísticas exportadas en: \n${file.path}')),
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
                );
              },
            ),
          ),
          const Divider(),
          // Developer Settings button (only in debug mode)
          if (!const bool.fromEnvironment('dart.vm.product'))
            ListTile(
              leading: const Icon(Icons.bug_report, color: Colors.deepPurple),
              title: const Text('Developer Settings'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).pushNamed('/devtools');
              },
            ),
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
