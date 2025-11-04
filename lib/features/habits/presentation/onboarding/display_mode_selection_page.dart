import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/display_mode.dart';
import 'display_mode_provider.dart';
import '../../../../l10n/app_localizations.dart';

/// Display mode selection screen shown during onboarding
class DisplayModeSelectionPage extends ConsumerStatefulWidget {
  const DisplayModeSelectionPage({super.key});

  @override
  ConsumerState<DisplayModeSelectionPage> createState() =>
      _DisplayModeSelectionPageState();
}

class _DisplayModeSelectionPageState
    extends ConsumerState<DisplayModeSelectionPage> {
  DisplayMode? _selectedMode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text(
                l10n.chooseYourExperience,
                key: const Key('choose_experience_title'),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1a202c),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.displayModeDescription,
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xff64748b),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _ModeCard(
                        key: const Key('simple_mode_card'),
                        mode: DisplayMode.simple,
                        title: l10n.simpleMode,
                        description: l10n.simpleModeDescription,
                        features: [
                          l10n.simpleModeFeature1,
                          l10n.simpleModeFeature2,
                          l10n.simpleModeFeature3,
                        ],
                        icon: Icons.sentiment_satisfied_alt,
                        isSelected: _selectedMode == DisplayMode.simple,
                        onTap: () {
                          setState(() {
                            _selectedMode = DisplayMode.simple;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      _ModeCard(
                        key: const Key('advanced_mode_card'),
                        mode: DisplayMode.advanced,
                        title: l10n.advancedMode,
                        description: l10n.advancedModeDescription,
                        features: [
                          l10n.advancedModeFeature1,
                          l10n.advancedModeFeature2,
                          l10n.advancedModeFeature3,
                        ],
                        icon: Icons.auto_awesome,
                        isSelected: _selectedMode == DisplayMode.advanced,
                        onTap: () {
                          setState(() {
                            _selectedMode = DisplayMode.advanced;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          l10n.changeAnytime,
                          key: const Key('change_anytime_text'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xff94a3b8),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  key: const Key('select_mode_button'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff6366f1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  onPressed: _selectedMode == null
                      ? null
                      : () async {
                          await ref
                              .read(displayModeProvider.notifier)
                              .setDisplayMode(_selectedMode!);
                          if (context.mounted) {
                            Navigator.of(context)
                                .pushReplacementNamed('/onboarding');
                          }
                        },
                  child: Text(
                    l10n.selectMode,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final DisplayMode mode;
  final String title;
  final String description;
  final List<String> features;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeCard({
    super.key,
    required this.mode,
    required this.title,
    required this.description,
    required this.features,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final semanticLabel = isSelected
        ? '$title. $description. Selected.'
        : '$title. $description. Tap to select.';

    return Semantics(
      label: semanticLabel,
      button: true,
      selected: isSelected,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isSelected ? const Color(0xff6366f1) : Colors.grey.shade200,
              width: isSelected ? 3 : 1,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: const Color(0xff6366f1).withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xff6366f1).withValues(alpha: 0.1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        size: 32,
                        color: isSelected
                            ? const Color(0xff6366f1)
                            : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? const Color(0xff6366f1)
                                  : const Color(0xff1a202c),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Color(0xff6366f1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                ...features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 20,
                            color: isSelected
                                ? const Color(0xff6366f1)
                                : Colors.grey.shade400,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
