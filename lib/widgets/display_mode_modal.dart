import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitus_faith/features/habits/domain/models/display_mode.dart';
import 'package:habitus_faith/features/habits/presentation/onboarding/display_mode_provider.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';

class DisplayModeModal extends StatefulWidget {
  final DisplayMode currentMode;
  final WidgetRef ref;
  final AppLocalizations l10n;

  const DisplayModeModal({
    super.key,
    required this.currentMode,
    required this.ref,
    required this.l10n,
  });

  @override
  State<DisplayModeModal> createState() => _DisplayModeModalState();
}

class _DisplayModeModalState extends State<DisplayModeModal> {
  late DisplayMode localSelectedMode;

  @override
  void initState() {
    super.initState();
    localSelectedMode = widget.currentMode;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.l10n.displayMode,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ...[DisplayMode.compact, DisplayMode.advanced].map((mode) {
            final isSelected = localSelectedMode == mode;
            return ListTile(
              leading: Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected ? Colors.blue : Colors.grey,
              ),
              title: Text(mode == DisplayMode.compact
                  ? widget.l10n.compactMode
                  : widget.l10n.advancedMode),
              subtitle: Text(mode == DisplayMode.compact
                  ? widget.l10n.compactModeSubtitle
                  : widget.l10n.advancedModeSubtitle),
              onTap: () {
                setState(() {
                  localSelectedMode = mode;
                });
              },
              selected: isSelected,
            );
          }),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () async {
                  await widget.ref.read(displayModeProvider.notifier).setDisplayMode(localSelectedMode);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          localSelectedMode == DisplayMode.compact
                              ? widget.l10n.displayModeUpdated(widget.l10n.compactMode)
                              : widget.l10n.displayModeUpdated(widget.l10n.advancedMode),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Text(widget.l10n.save),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

