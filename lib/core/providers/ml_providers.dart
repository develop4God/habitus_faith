import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ml/abandonment_predictor.dart';
import '../services/ml/asset_loader.dart';
import '../services/ml/preferences_service.dart';
import '../../features/habits/presentation/habits_providers.dart';
import 'clock_provider.dart';
import 'shared_preferences_provider.dart';

/// Provider for AbandonmentPredictor singleton
/// Automatically initializes on first access and disposes when ref is invalidated
///
/// NOTE: This provider returns the predictor immediately, but initialization happens async.
/// Use abandonmentPredictorInitializedProvider if you need to ensure initialization is complete.
final abandonmentPredictorProvider = Provider<AbandonmentPredictor>((ref) {
  final clock = ref.watch(clockProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  final predictor = AbandonmentPredictor(
    clock: clock,
    assetLoader: const RootBundleAssetLoader(),
    preferencesService: SharedPreferencesService(prefs),
  );

  // Initialize asynchronously (non-blocking for app startup)
  predictor.initialize();

  // Dispose when provider is disposed
  ref.onDispose(() {
    predictor.dispose();
  });

  return predictor;
});

/// Provider that ensures AbandonmentPredictor is fully initialized before returning
/// Use this in background tasks or when you need guaranteed initialization
final abandonmentPredictorInitializedProvider =
    FutureProvider<AbandonmentPredictor>((ref) async {
  final predictor = ref.watch(abandonmentPredictorProvider);

  // Wait for initialization to complete
  await predictor.initialize();

  return predictor;
});

/// Family provider for getting abandonment risk for a specific habit
/// Returns Future<double> representing probability of abandonment (0.0-1.0)
///
/// Returns 0.0 for:
/// - Habits already completed today
/// - Habits that don't exist
/// - Any errors during prediction
final habitRiskProvider = FutureProvider.family<double, String>((
  ref,
  habitId,
) async {
  // Watch habits stream to get current habit state
  final habitsAsync = ref.watch(habitsStreamProvider);

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
        // Use new predictRisk interface that encapsulates feature extraction
        // and ensures consistent ordering of features for ML model
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
