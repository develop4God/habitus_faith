import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/ml/abandonment_predictor.dart';
import 'package:habitus_faith/core/providers/habit_predictor_provider.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:habitus_faith/features/habits/domain/models/risk_level.dart';

/// Test utilities for ML predictor validation and debugging
class MLPredictorTestUtils {
  /// Minimum risk threshold for intervention (default: 0.65)
  /// Can be lowered for testing to trigger interventions more easily
  static double interventionThreshold = RiskThresholds.highRiskThreshold;

  /// Reset threshold to default value
  static void resetThreshold() {
    interventionThreshold = RiskThresholds.highRiskThreshold;
  }

  /// Set a custom threshold for testing (useful for FAST_TIME mode)
  /// Example: setThreshold(0.3) to trigger interventions at medium risk
  static void setThreshold(double threshold) {
    assert(threshold >= 0.0 && threshold <= 1.0,
        'Threshold must be between 0.0 and 1.0');
    interventionThreshold = threshold;
    debugPrint(
        'ML_TEST_UTILS 🧪 Intervention threshold set to: $threshold (was ${RiskThresholds.highRiskThreshold})');
  }

  /// Check if a risk value requires intervention using custom threshold
  static bool requiresIntervention(double risk) {
    final requires = risk >= interventionThreshold;
    debugPrint(
        'ML_TEST_UTILS 🧪 Risk $risk ${requires ? '≥' : '<'} threshold $interventionThreshold → ${requires ? 'INTERVENTION' : 'no action'}');
    return requires;
  }

  /// Create a high-risk habit for testing
  /// Returns a habit that should trigger ML intervention
  static Habit createHighRiskHabit({
    String? id,
    String? userId,
    String? name,
    HabitCategory category = HabitCategory.spiritual,
    int daysOld = 30,
    int daysSinceLastCompletion = 10,
  }) {
    final now = DateTime.now();
    return Habit(
      id: id ?? 'test-high-risk-${now.millisecondsSinceEpoch}',
      userId: userId ?? 'test-user',
      name: name ?? 'High Risk Test Habit',
      category: category,
      createdAt: now.subtract(Duration(days: daysOld)),
      targetMinutes: 30,
      difficultyLevel: 4,
      currentStreak: 1,
      completionHistory: [
        now.subtract(Duration(days: daysSinceLastCompletion)),
        now.subtract(Duration(days: daysSinceLastCompletion + 2)),
      ],
      lastCompletedAt: now.subtract(Duration(days: daysSinceLastCompletion)),
      completedToday: false,
      isArchived: false,
    );
  }

  /// Create a low-risk habit for testing
  /// Returns a habit that should NOT trigger ML intervention
  static Habit createLowRiskHabit({
    String? id,
    String? userId,
    String? name,
    HabitCategory category = HabitCategory.spiritual,
  }) {
    final now = DateTime.now();
    return Habit(
      id: id ?? 'test-low-risk-${now.millisecondsSinceEpoch}',
      userId: userId ?? 'test-user',
      name: name ?? 'Low Risk Test Habit',
      category: category,
      createdAt: now.subtract(const Duration(days: 30)),
      targetMinutes: 15,
      difficultyLevel: 2,
      currentStreak: 15,
      completionHistory: List.generate(
        20,
        (i) => now.subtract(Duration(days: i)),
      ),
      lastCompletedAt: now.subtract(const Duration(days: 1)),
      completedToday: false,
      isArchived: false,
    );
  }

  /// Validate predictor initialization
  /// Ensures predictor is ready before making predictions
  static Future<void> validatePredictorInitialized(
      AbandonmentPredictor predictor) async {
    debugPrint('ML_TEST_UTILS 🧪 Validating predictor initialization...');

    if (!predictor.isInitialized) {
      debugPrint('ML_TEST_UTILS 🧪 ⚠️ Predictor not initialized, initializing...');
      await predictor.initialize();
    }

    if (!predictor.isInitialized) {
      throw StateError(
          'ML_TEST_UTILS 🧪 ❌ Predictor failed to initialize - TFLite may be unavailable');
    }

    debugPrint('ML_TEST_UTILS 🧪 ✅ Predictor is initialized and ready');
  }

  /// Run prediction and log detailed results
  static Future<double> predictWithLogging(
    AbandonmentPredictor predictor,
    Habit habit,
  ) async {
    debugPrint('ML_TEST_UTILS 🧪 ═══════════════════════════════════════');
    debugPrint(
        'ML_TEST_UTILS 🧪 Predicting risk for: "${habit.name}" (id: ${habit.id})');
    debugPrint('ML_TEST_UTILS 🧪 Habit details:');
    debugPrint('ML_TEST_UTILS 🧪   - Age: ${DateTime.now().difference(habit.createdAt).inDays} days');
    debugPrint(
        'ML_TEST_UTILS 🧪   - Days since completion: ${habit.lastCompletedAt != null ? DateTime.now().difference(habit.lastCompletedAt!).inDays : 'never'}');
    debugPrint('ML_TEST_UTILS 🧪   - Current streak: ${habit.currentStreak}');
    debugPrint('ML_TEST_UTILS 🧪   - Difficulty: ${habit.difficultyLevel}');
    debugPrint(
        'ML_TEST_UTILS 🧪   - Completion history: ${habit.completionHistory.length} entries');

    final risk = await predictor.predictRisk(habit);

    debugPrint('ML_TEST_UTILS 🧪 ─────────────────────────────────────────');
    debugPrint(
        'ML_TEST_UTILS 🧪 📊 PREDICTION RESULT: ${(risk * 100).toStringAsFixed(1)}%');
    debugPrint(
        'ML_TEST_UTILS 🧪 Risk Level: ${RiskThresholds.fromValue(risk).displayName}');
    debugPrint(
        'ML_TEST_UTILS 🧪 Intervention: ${requiresIntervention(risk) ? 'YES ✅' : 'NO ❌'}');
    debugPrint(
        'ML_TEST_UTILS 🧪 Threshold: ${(interventionThreshold * 100).toStringAsFixed(1)}%');
    debugPrint('ML_TEST_UTILS 🧪 ═══════════════════════════════════════');

    return risk;
  }

  /// Test helper: Pump with logging
  /// Use instead of pumpAndSettle() for better control
  static Future<void> pumpWithLogging(
    WidgetTester tester, {
    Duration duration = const Duration(milliseconds: 100),
    int times = 1,
  }) async {
    debugPrint(
        'ML_TEST_UTILS 🧪 Pumping widget tree $times times (${duration.inMilliseconds}ms each)...');
    for (int i = 0; i < times; i++) {
      await tester.pump(duration);
    }
    debugPrint('ML_TEST_UTILS 🧪 ✅ Pump complete');
  }

  /// Print ML configuration summary
  static void printConfiguration() {
    debugPrint('ML_TEST_UTILS 🧪 ═══════════════════════════════════════');
    debugPrint('ML_TEST_UTILS 🧪 ML PREDICTOR CONFIGURATION');
    debugPrint('ML_TEST_UTILS 🧪 ─────────────────────────────────────────');
    debugPrint(
        'ML_TEST_UTILS 🧪 Intervention Threshold: ${(interventionThreshold * 100).toStringAsFixed(1)}%');
    debugPrint(
        'ML_TEST_UTILS 🧪 Default High Risk: ${(RiskThresholds.highRiskThreshold * 100).toStringAsFixed(1)}%');
    debugPrint(
        'ML_TEST_UTILS 🧪 Default Medium Risk: ${(RiskThresholds.mediumRiskThreshold * 100).toStringAsFixed(1)}%');
    debugPrint(
        'ML_TEST_UTILS 🧪 FAST_TIME Mode: ${const bool.fromEnvironment('FAST_TIME')}');
    debugPrint('ML_TEST_UTILS 🧪 ═══════════════════════════════════════');
  }
}
