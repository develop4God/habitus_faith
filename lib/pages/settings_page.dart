import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitus_faith/core/providers/language_provider.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';
import 'package:habitus_faith/pages/language_settings_page.dart';
import 'package:habitus_faith/pages/notifications_settings_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLanguage = ref.watch(appLanguageProvider.notifier).currentLanguage;

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
        ],
      ),
    );
  }
}
