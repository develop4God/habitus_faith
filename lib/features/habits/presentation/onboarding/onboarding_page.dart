import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/predefined_habit.dart';
import '../../domain/models/predefined_habits_data.dart';
import '../../domain/habit.dart';
import '../../data/storage/storage_providers.dart';
import 'onboarding_providers.dart';
import '../../../../l10n/app_localizations.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selectedHabits = ref.watch(selectedHabitsProvider);
    final onboardingState = ref.watch(onboardingNotifierProvider);
    final isLoading = onboardingState.isLoading;
    final hasError = onboardingState.hasError;

    // Show error message if onboarding failed
    if (hasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.onboardingErrorMessage,
                semanticsLabel: l10n.onboardingErrorMessage,
              ),
              backgroundColor: Colors.red.shade600,
              action: SnackBarAction(
                label: l10n.retry,
                textColor: Colors.white,
                onPressed: () async {
                  final success = await ref
                      .read(onboardingNotifierProvider.notifier)
                      .retry();
                  if (success && context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/home');
                  }
                },
              ),
              duration: const Duration(seconds: 6),
            ),
          );
        }
      });
    }

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
                l10n.welcomeToHabitusFaith,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1a202c),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.selectUpToThreeHabits,
                style: const TextStyle(fontSize: 18, color: Color(0xff64748b)),
              ),
              const SizedBox(height: 8),
              Text(
                '${selectedHabits.length}/3 ${l10n.days}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: selectedHabits.length >= 3
                      ? const Color(0xff10b981)
                      : const Color(0xff64748b),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate responsive grid parameters based on screen width
                    final width = constraints.maxWidth;
                    final crossAxisCount = width > 600 ? 3 : 2;
                    final spacing = width > 600 ? 20.0 : 16.0;
                    // Adjust aspect ratio based on available height
                    final itemHeight = constraints.maxHeight /
                        (predefinedHabits.length / crossAxisCount).ceil();
                    final itemWidth =
                        (width - (spacing * (crossAxisCount + 1))) /
                            crossAxisCount;
                    final aspectRatio = (itemWidth / itemHeight).clamp(
                      0.7,
                      1.2,
                    );

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                        childAspectRatio: aspectRatio,
                      ),
                      itemCount: predefinedHabits.length,
                      itemBuilder: (context, index) {
                        final habit = predefinedHabits[index];
                        final isSelected = selectedHabits.contains(habit.id);

                        return _HabitCard(
                          key: Key('habit_card_${habit.id}'),
                          habit: habit,
                          isSelected: isSelected,
                          onTap: () {
                            if (isSelected) {
                              ref
                                  .read(onboardingNotifierProvider.notifier)
                                  .deselectHabit(habit.id);
                            } else if (selectedHabits.length < 3) {
                              ref
                                  .read(onboardingNotifierProvider.notifier)
                                  .selectHabit(habit.id);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.maxThreeHabits)),
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  // Skip button
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        key: const Key('skip_onboarding_button'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xff6366f1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: isLoading
                            ? null
                            : () async {
                                // Mark onboarding as complete without selecting habits
                                final storage = ref.read(
                                  jsonStorageServiceProvider,
                                );
                                await storage.setBool(
                                  'onboarding_complete',
                                  true,
                                );
                                if (context.mounted) {
                                  Navigator.of(
                                    context,
                                  ).pushReplacementNamed('/home');
                                }
                              },
                        child: Text(
                          l10n.cancel,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff6366f1),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Continue button
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        key: const Key('continue_onboarding_button'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff6366f1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        onPressed: selectedHabits.isEmpty || isLoading
                            ? null
                            : () async {
                                debugPrint(
                                  'OnboardingPage: continue pressed - creating habits',
                                );

                                // Prepare translated habits
                                final translatedHabits = selectedHabits.map((
                                  habitId,
                                ) {
                                  final predefinedHabit = predefinedHabits
                                      .firstWhere((h) => h.id == habitId);
                                  return TranslatedHabit(
                                    id: habitId,
                                    name: _getTranslatedName(
                                      l10n,
                                      predefinedHabit.nameKey,
                                    ),
                                    description: _getTranslatedDescription(
                                      l10n,
                                      predefinedHabit.descriptionKey,
                                    ),
                                    category: PredefinedHabitCategoryX(
                                      predefinedHabit.category,
                                    ).toDomainCategory(),
                                    emoji: predefinedHabit.emoji,
                                  );
                                }).toList();

                                await ref
                                    .read(onboardingNotifierProvider.notifier)
                                    .completeOnboarding(
                                      translatedHabits: translatedHabits,
                                    );
                                debugPrint(
                                  'OnboardingPage: completeOnboarding finished',
                                );
                                if (context.mounted) {
                                  debugPrint(
                                    'OnboardingPage: navigating to /home',
                                  );
                                  Navigator.of(
                                    context,
                                  ).pushReplacementNamed('/home');
                                }
                              },
                        child: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                l10n.continueButton,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper function to translate predefined habit names
String _getTranslatedName(AppLocalizations l10n, String key) {
  switch (key) {
    case 'predefinedHabit_morningPrayer_name':
      return l10n.predefinedHabit_morningPrayer_name;
    case 'predefinedHabit_bibleReading_name':
      return l10n.predefinedHabit_bibleReading_name;
    case 'predefinedHabit_worship_name':
      return l10n.predefinedHabit_worship_name;
    case 'predefinedHabit_gratitude_name':
      return l10n.predefinedHabit_gratitude_name;
    case 'predefinedHabit_exercise_name':
      return l10n.predefinedHabit_exercise_name;
    case 'predefinedHabit_healthyEating_name':
      return l10n.predefinedHabit_healthyEating_name;
    case 'predefinedHabit_sleep_name':
      return l10n.predefinedHabit_sleep_name;
    case 'predefinedHabit_meditation_name':
      return l10n.predefinedHabit_meditation_name;
    case 'predefinedHabit_learning_name':
      return l10n.predefinedHabit_learning_name;
    case 'predefinedHabit_creativity_name':
      return l10n.predefinedHabit_creativity_name;
    case 'predefinedHabit_familyTime_name':
      return l10n.predefinedHabit_familyTime_name;
    case 'predefinedHabit_service_name':
      return l10n.predefinedHabit_service_name;
    default:
      return key;
  }
}

// Helper function to translate predefined habit descriptions
String _getTranslatedDescription(AppLocalizations l10n, String key) {
  switch (key) {
    case 'predefinedHabit_morningPrayer_description':
      return l10n.predefinedHabit_morningPrayer_description;
    case 'predefinedHabit_bibleReading_description':
      return l10n.predefinedHabit_bibleReading_description;
    case 'predefinedHabit_worship_description':
      return l10n.predefinedHabit_worship_description;
    case 'predefinedHabit_gratitude_description':
      return l10n.predefinedHabit_gratitude_description;
    case 'predefinedHabit_exercise_description':
      return l10n.predefinedHabit_exercise_description;
    case 'predefinedHabit_healthyEating_description':
      return l10n.predefinedHabit_healthyEating_description;
    case 'predefinedHabit_sleep_description':
      return l10n.predefinedHabit_sleep_description;
    case 'predefinedHabit_meditation_description':
      return l10n.predefinedHabit_meditation_description;
    case 'predefinedHabit_learning_description':
      return l10n.predefinedHabit_learning_description;
    case 'predefinedHabit_creativity_description':
      return l10n.predefinedHabit_creativity_description;
    case 'predefinedHabit_familyTime_description':
      return l10n.predefinedHabit_familyTime_description;
    case 'predefinedHabit_service_description':
      return l10n.predefinedHabit_service_description;
    default:
      return key;
  }
}

// Helper function to map predefined category to HabitCategory
extension PredefinedHabitCategoryX on PredefinedHabitCategory {
  HabitCategory toDomainCategory() {
    switch (this) {
      case PredefinedHabitCategory.spiritual:
        return HabitCategory.spiritual;
      case PredefinedHabitCategory.physical:
        return HabitCategory.physical;
      case PredefinedHabitCategory.mental:
        return HabitCategory.mental;
      case PredefinedHabitCategory.relational:
        return HabitCategory.relational;
    }
  }
}

class _HabitCard extends StatelessWidget {
  final PredefinedHabit habit;
  final bool isSelected;
  final VoidCallback onTap;

  const _HabitCard({
    super.key,
    required this.habit,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Get localized name and description
    String getName(String key) {
      switch (key) {
        case 'predefinedHabit_morningPrayer_name':
          return l10n.predefinedHabit_morningPrayer_name;
        case 'predefinedHabit_bibleReading_name':
          return l10n.predefinedHabit_bibleReading_name;
        case 'predefinedHabit_worship_name':
          return l10n.predefinedHabit_worship_name;
        case 'predefinedHabit_gratitude_name':
          return l10n.predefinedHabit_gratitude_name;
        case 'predefinedHabit_exercise_name':
          return l10n.predefinedHabit_exercise_name;
        case 'predefinedHabit_healthyEating_name':
          return l10n.predefinedHabit_healthyEating_name;
        case 'predefinedHabit_sleep_name':
          return l10n.predefinedHabit_sleep_name;
        case 'predefinedHabit_meditation_name':
          return l10n.predefinedHabit_meditation_name;
        case 'predefinedHabit_learning_name':
          return l10n.predefinedHabit_learning_name;
        case 'predefinedHabit_creativity_name':
          return l10n.predefinedHabit_creativity_name;
        case 'predefinedHabit_familyTime_name':
          return l10n.predefinedHabit_familyTime_name;
        case 'predefinedHabit_service_name':
          return l10n.predefinedHabit_service_name;
        default:
          return key;
      }
    }

    String getDescription(String key) {
      switch (key) {
        case 'predefinedHabit_morningPrayer_description':
          return l10n.predefinedHabit_morningPrayer_description;
        case 'predefinedHabit_bibleReading_description':
          return l10n.predefinedHabit_bibleReading_description;
        case 'predefinedHabit_worship_description':
          return l10n.predefinedHabit_worship_description;
        case 'predefinedHabit_gratitude_description':
          return l10n.predefinedHabit_gratitude_description;
        case 'predefinedHabit_exercise_description':
          return l10n.predefinedHabit_exercise_description;
        case 'predefinedHabit_healthyEating_description':
          return l10n.predefinedHabit_healthyEating_description;
        case 'predefinedHabit_sleep_description':
          return l10n.predefinedHabit_sleep_description;
        case 'predefinedHabit_meditation_description':
          return l10n.predefinedHabit_meditation_description;
        case 'predefinedHabit_learning_description':
          return l10n.predefinedHabit_learning_description;
        case 'predefinedHabit_creativity_description':
          return l10n.predefinedHabit_creativity_description;
        case 'predefinedHabit_familyTime_description':
          return l10n.predefinedHabit_familyTime_description;
        case 'predefinedHabit_service_description':
          return l10n.predefinedHabit_service_description;
        default:
          return key;
      }
    }

    final habitName = getName(habit.nameKey);
    final habitDescription = getDescription(habit.descriptionKey);
    final semanticLabel = isSelected
        ? '$habitName ${l10n.selected}. $habitDescription'
        : '$habitName. $habitDescription';

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
            borderRadius: BorderRadius.circular(16),
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
            padding: const EdgeInsets.all(12.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Responsive emoji size based on card size
                final emojiSize = (constraints.maxWidth * 0.35).clamp(
                  32.0,
                  56.0,
                );
                final titleSize = (constraints.maxWidth * 0.12).clamp(
                  12.0,
                  16.0,
                );
                final descSize = (constraints.maxWidth * 0.09).clamp(
                  10.0,
                  12.0,
                );

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected)
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Color(0xff6366f1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 20),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          habit.emoji,
                          style: TextStyle(fontSize: emojiSize),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: Text(
                        getName(habit.nameKey),
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff1a202c),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Flexible(
                      child: Text(
                        getDescription(habit.descriptionKey),
                        style: TextStyle(
                          fontSize: descSize,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
