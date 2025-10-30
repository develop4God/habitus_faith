import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ml/abandonment_predictor.dart';
import '../../pages/habits_page.dart';

/// Provider for AbandonmentPredictor singleton
/// Automatically initializes on first access and disposes when ref is invalidated
final abandonmentPredictorProvider = Provider<AbandonmentPredictor>((ref) {
  final predictor = AbandonmentPredictor();

  // Initialize asynchronously
  predictor.initialize();

  // Dispose when provider is disposed
  ref.onDispose(() {
    predictor.dispose();
  });

  return predictor;
});

/// Family provider for getting abandonment risk for a specific habit
/// Returns Future<double> representing probability of abandonment (0.0-1.0)
///
/// Returns 0.0 for:
/// - Habits already completed today
/// - Habits that don't exist
/// - Any errors during prediction
final habitRiskProvider =
    FutureProvider.family<double, String>((ref, habitId) async {
  // Watch habits stream to get current habit state
  final habitsAsync = ref.watch(jsonHabitsStreamProvider);

  return habitsAsync.when(
    data: (habits) async {
      // Find the specific habit
      final habit = habits.where((h) => h.id == habitId).firstOrNull;

      if (habit == null) {
        return 0.0; // Habit not found
      }

      // Don't show risk for already completed habits
      if (habit.completedToday) {
        return 0.0;
      }

      // Get predictor
      final predictor = ref.read(abandonmentPredictorProvider);

      try {
        // Use new predictRisk interface that takes a Habit directly
        final risk = await predictor.predictRisk(habit);

        return risk;
      } catch (e) {
        // Error during prediction - gracefully degrade
        return 0.0;
      }
    },
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});
