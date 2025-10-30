import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// Service for ML-based habit abandonment risk prediction
/// Loads TFLite model and provides real-time predictions without server dependency
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
  /// Parameters:
  /// - [hourOfDay]: Current hour (0-23)
  /// - [dayOfWeek]: Current day of week (1-7, Monday=1)
  /// - [currentStreak]: User's current streak
  /// - [recentFailures]: Count of failures in last 7 days
  /// - [hoursSinceReminder]: Hours elapsed since scheduled reminder
  ///
  /// Returns: Probability of abandonment (0.0-1.0)
  ///   - 0.0 = very low risk (likely to complete)
  ///   - 1.0 = very high risk (likely to abandon)
  ///   - Returns 0.0 if model not available
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
