import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../../features/habits/domain/habit.dart';
import '../../../features/habits/domain/ml_features_calculator.dart';

/// Service for ML-based habit abandonment risk prediction
/// Loads TFLite model and provides real-time predictions without server dependency
///
/// Input tensor order (CRITICAL - must match training):
/// [hourOfDay, dayOfWeek, currentStreak, failuresLast7Days, categoryEnumValue]
/// Shape: [1, 5] (batch size 1, 5 features)
class AbandonmentPredictor {
  Interpreter? _interpreter;
  Map<String, dynamic>? _scalerParams;
  bool _initialized = false;

  /// Initialize the predictor by loading model and scaler params
  Future<void> initialize() async {
    if (_initialized) {
      debugPrint('AbandonmentPredictor: Already initialized');
      return;
    }

    try {
      // Load TFLite model from assets
      debugPrint('AbandonmentPredictor: Loading TFLite model...');
      _interpreter =
          await Interpreter.fromAsset('assets/ml_models/predictor.tflite');
      debugPrint('AbandonmentPredictor: TFLite model loaded successfully');

      // Load scaler parameters
      debugPrint('AbandonmentPredictor: Loading scaler params...');
      final scalerJson =
          await rootBundle.loadString('assets/ml_models/scaler_params.json');
      _scalerParams = json.decode(scalerJson) as Map<String, dynamic>;
      debugPrint('AbandonmentPredictor: Scaler params loaded successfully');

      _initialized = true;
      debugPrint('AbandonmentPredictor: Initialization complete');
    } catch (e) {
      debugPrint('AbandonmentPredictor: Initialization failed: $e');
      // Non-critical failure - predictor will return 0.0 for predictions
      _initialized = false;
    }
  }

  /// Normalize features using StandardScaler parameters from training
  /// Applies: (feature - mean) / scale element-wise
  List<double> _normalizeFeatures(List<double> features) {
    if (_scalerParams == null) {
      debugPrint(
          'AbandonmentPredictor: Scaler params not loaded, returning raw features');
      return features;
    }

    final mean = (_scalerParams!['mean'] as List).cast<double>();
    final scale = (_scalerParams!['scale'] as List).cast<double>();

    if (mean.length != features.length || scale.length != features.length) {
      debugPrint(
          'AbandonmentPredictor: Feature length mismatch, returning raw features');
      return features;
    }

    final normalized = <double>[];
    for (int i = 0; i < features.length; i++) {
      normalized.add((features[i] - mean[i]) / scale[i]);
    }

    return normalized;
  }

  /// Predict abandonment risk for a habit
  ///
  /// Returns: Probability of abandonment (0.0-1.0)
  ///   - 0.0 = very low risk (likely to complete)
  ///   - 1.0 = very high risk (likely to abandon)
  ///   - 0.5 = default for first-time habits with no history
  ///   - Returns 0.0 if model not available
  ///
  /// ⚠️ CRITICAL: Handles first-time habits (no history) → returns 0.5 default risk
  ///
  /// Input features extracted from habit (order must match training):
  /// 1. Hour of day (lastCompletedAt?.hour ?? 12)
  /// 2. Day of week (lastCompletedAt?.weekday ?? 1)
  /// 3. Current streak
  /// 4. Failures last 7 days (MLFeaturesCalculator.countRecentFailures(habit, 7))
  /// 5. Category enum value (habit.category.index)
  Future<double> predictRisk(Habit habit) async {
    if (!_initialized || _interpreter == null) {
      debugPrint('AbandonmentPredictor: Not initialized, returning 0.0');
      return 0.0;
    }

    try {
      // ⚠️ CRITICAL: Handle first-time habits (no history) → return 0.5 default risk
      if (habit.completionHistory.isEmpty && habit.currentStreak == 0) {
        debugPrint('AbandonmentPredictor: First-time habit detected, returning default risk 0.5');
        return 0.5;
      }

      // Extract features from habit (EXACT order as specified in requirements)
      final hourOfDay = habit.lastCompletedAt?.hour ?? 12;
      final dayOfWeek = habit.lastCompletedAt?.weekday ?? 1;
      final currentStreak = habit.currentStreak;
      final failuresLast7Days = MLFeaturesCalculator.countRecentFailures(habit, 7);
      final categoryEnumValue = habit.category.index;

      // Prepare input features in exact order: 
      // [hourOfDay, dayOfWeek, currentStreak, failuresLast7Days, categoryEnumValue]
      final rawFeatures = [
        hourOfDay.toDouble(),
        dayOfWeek.toDouble(),
        currentStreak.toDouble(),
        failuresLast7Days.toDouble(),
        categoryEnumValue.toDouble(),
      ];

      debugPrint(
          'AbandonmentPredictor: Raw features [hour=$hourOfDay, day=$dayOfWeek, '
          'streak=$currentStreak, failures=$failuresLast7Days, category=$categoryEnumValue]');

      // Normalize features using StandardScaler (x - mean) / std
      final normalizedFeatures = _normalizeFeatures(rawFeatures);

      // Prepare input tensor [1, 5] - batch size 1, 5 features
      // Input must be 2D array: [[hourOfDay, dayOfWeek, currentStreak, failuresLast7Days, categoryEnumValue]]
      final input = [normalizedFeatures];

      // Prepare output tensor [1, 1] - batch size 1, 1 output
      final output = List.filled(1, List.filled(1, 0.0));

      // Run inference
      _interpreter!.run(input, output);

      // Extract probability (value between 0 and 1)
      final probability = output[0][0];

      debugPrint(
          'AbandonmentPredictor: Predicted risk = ${(probability * 100).toStringAsFixed(1)}%');

      return probability.clamp(0.0, 1.0);
    } catch (e) {
      debugPrint('AbandonmentPredictor: Prediction failed: $e');
      return 0.0; // Graceful degradation
    }
  }

  /// Legacy method for backwards compatibility
  /// Predict abandonment risk using individual parameters
  ///
  /// Parameters:
  /// - [hourOfDay]: Current hour (0-23)
  /// - [dayOfWeek]: Current day of week (1-7, Monday=1)
  /// - [currentStreak]: User's current streak
  /// - [recentFailures]: Count of failures in last 7 days
  /// - [hoursSinceReminder]: Hours elapsed since scheduled reminder
  ///
  /// Returns: Probability of abandonment (0.0-1.0)
  @Deprecated('Use predictRisk(Habit) instead. This method will be removed in a future version.')
  Future<double> predictAbandonmentRisk({
    required int hourOfDay,
    required int dayOfWeek,
    required int currentStreak,
    required int recentFailures,
    required int hoursSinceReminder,
  }) async {
    if (!_initialized || _interpreter == null) {
      debugPrint('AbandonmentPredictor: Not initialized, returning 0.0');
      return 0.0;
    }

    try {
      // Prepare input features (same order as training)
      final rawFeatures = [
        hourOfDay.toDouble(),
        dayOfWeek.toDouble(),
        currentStreak.toDouble(),
        recentFailures.toDouble(),
        hoursSinceReminder.toDouble(),
      ];

      // Normalize features
      final normalizedFeatures = _normalizeFeatures(rawFeatures);

      // Prepare input tensor [1, 5] - batch size 1, 5 features
      final input = [normalizedFeatures];

      // Prepare output tensor [1, 1] - batch size 1, 1 output
      final output = List.filled(1, List.filled(1, 0.0));

      // Run inference
      _interpreter!.run(input, output);

      // Extract probability (value between 0 and 1)
      final probability = output[0][0];

      debugPrint(
          'AbandonmentPredictor: Predicted risk = ${(probability * 100).toStringAsFixed(1)}%');

      return probability.clamp(0.0, 1.0);
    } catch (e) {
      debugPrint('AbandonmentPredictor: Prediction failed: $e');
      return 0.0; // Graceful degradation
    }
  }

  /// Dispose resources
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _scalerParams = null;
    _initialized = false;
    debugPrint('AbandonmentPredictor: Disposed');
  }
}
