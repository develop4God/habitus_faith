import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/storage/storage_providers.dart';
import '../../domain/models/predefined_habits_data.dart';
import '../../domain/habit.dart';

/// Provider for selected habit IDs
final selectedHabitsProvider = StateProvider<List<String>>((ref) => []);

/// Notifier for onboarding state
class OnboardingNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  OnboardingNotifier(this.ref) : super(const AsyncValue.data(null));

  void selectHabit(String habitId) {
    final current = ref.read(selectedHabitsProvider);
    if (!current.contains(habitId) && current.length < 3) {
      ref.read(selectedHabitsProvider.notifier).state = [...current, habitId];
    }
  }

  void deselectHabit(String habitId) {
    final current = ref.read(selectedHabitsProvider);
    ref.read(selectedHabitsProvider.notifier).state =
        current.where((id) => id != habitId).toList();
  }

  Future<bool> completeOnboarding({int retryCount = 0}) async {
    state = const AsyncValue.loading();

    try {
      final selectedIds = ref.read(selectedHabitsProvider);
      if (selectedIds.isEmpty) {
        state = AsyncValue.error(
            'onboarding_error_no_habits_selected', StackTrace.current);
        return false;
      }

      // Create habits from predefined templates
      final repository = ref.read(jsonHabitsRepositoryProvider);
      final storage = ref.read(jsonStorageServiceProvider);

      for (final habitId in selectedIds) {
        final predefinedHabit =
            predefinedHabits.firstWhere((h) => h.id == habitId);

        // Create habit from predefined template
        await repository.createHabit(
          name: predefinedHabit.nameKey,
          description: predefinedHabit.descriptionKey,
          category: _mapCategory(predefinedHabit.category),
        );
      }

      // Mark onboarding as complete
      await storage.setBool('onboarding_complete', true);

      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      // Allow retry up to 2 times
      if (retryCount < 2) {
        await Future.delayed(Duration(seconds: 1 + retryCount));
        return completeOnboarding(retryCount: retryCount + 1);
      }

      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Retry last failed operation
  Future<bool> retry() async {
    return completeOnboarding();
  }

  HabitCategory _mapCategory(predefinedHabitCategory) {
    switch (predefinedHabitCategory.toString()) {
      case 'PredefinedHabitCategory.spiritual':
        return HabitCategory.prayer;
      case 'PredefinedHabitCategory.physical':
        return HabitCategory.other;
      case 'PredefinedHabitCategory.mental':
        return HabitCategory.other;
      case 'PredefinedHabitCategory.relational':
        return HabitCategory.service;
      default:
        return HabitCategory.other;
    }
  }
}

final onboardingNotifierProvider =
    StateNotifierProvider<OnboardingNotifier, AsyncValue<void>>((ref) {
  return OnboardingNotifier(ref);
});
