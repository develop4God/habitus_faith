import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  Map<String, dynamic>? _modelMetadata;
  bool _initialized = false;
  
  // Telemetry tracking (persisted across sessions)
  int _predictionCount = 0;
  int _errorCount = 0;
  DateTime? _lastPredictionTime;
  DateTime? _lastTelemetryReset;

  // Telemetry persistence keys
  static const String _telemetryPredictionCountKey = 'ml_prediction_count';
  static const String _telemetryErrorCountKey = 'ml_error_count';
  static const String _telemetryLastPredictionKey = 'ml_last_prediction';
  static const String _telemetryLastResetKey = 'ml_last_reset';

  /// Get model version
  String? get modelVersion => _modelMetadata?['version'];
  
  /// Get model metadata
  Map<String, dynamic>? get metadata => _modelMetadata;
  
  /// Get prediction statistics
  Map<String, dynamic> get telemetry => {
    'prediction_count': _predictionCount,
    'error_count': _errorCount,
    'last_prediction': _lastPredictionTime?.toIso8601String(),
    'last_reset': _lastTelemetryReset?.toIso8601String(),
    'success_rate': _predictionCount > 0 
        ? ((_predictionCount - _errorCount) / _predictionCount) 
        : 0.0,
  };

  /// Initialize the predictor by loading model and scaler params
  Future<void> initialize() async {
    if (_initialized) {
      debugPrint('AbandonmentPredictor: Already initialized');
      return;
    }

    try {
      // Load model metadata
      debugPrint('AbandonmentPredictor: Loading model metadata...');
      final metadataJson =
          await rootBundle.loadString('assets/ml_models/model_metadata.json');
      _modelMetadata = json.decode(metadataJson) as Map<String, dynamic>;
      debugPrint('AbandonmentPredictor: Model version ${_modelMetadata!['version']} loaded');
      
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

      // Load persisted telemetry
      await _loadTelemetry();

      _initialized = true;
      debugPrint('AbandonmentPredictor: Initialization complete');
      debugPrint('AbandonmentPredictor: Model metadata - Training samples: ${_modelMetadata!['training_samples']}, Accuracy: ${_modelMetadata!['accuracy']}');
      debugPrint('AbandonmentPredictor: Telemetry - Predictions: $_predictionCount, Errors: $_errorCount');
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
      _errorCount++;
      return 0.0;
    }

    try {
      // Track prediction attempt
      _predictionCount++;
      _lastPredictionTime = DateTime.now();
      
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
          'AbandonmentPredictor: Predicted risk = ${(probability * 100).toStringAsFixed(1)}% '
          '(model v${_modelMetadata?['version']})');

      // Save telemetry after successful prediction
      await _saveTelemetry();

      return probability.clamp(0.0, 1.0);
    } catch (e) {
      debugPrint('AbandonmentPredictor: Prediction failed: $e');
      _errorCount++;
      // Save telemetry even on error
      await _saveTelemetry();
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

  /// Load persisted telemetry from SharedPreferences
  Future<void> _loadTelemetry() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _predictionCount = prefs.getInt(_telemetryPredictionCountKey) ?? 0;
      _errorCount = prefs.getInt(_telemetryErrorCountKey) ?? 0;
      
      final lastPredictionStr = prefs.getString(_telemetryLastPredictionKey);
      if (lastPredictionStr != null) {
        _lastPredictionTime = DateTime.parse(lastPredictionStr);
      }
      
      final lastResetStr = prefs.getString(_telemetryLastResetKey);
      if (lastResetStr != null) {
        _lastTelemetryReset = DateTime.parse(lastResetStr);
        
        // Reset telemetry weekly (every 7 days)
        if (DateTime.now().difference(_lastTelemetryReset!).inDays > 7) {
          debugPrint('AbandonmentPredictor: Weekly telemetry reset triggered');
          await _resetTelemetry();
        }
      } else {
        // First time - initialize reset timestamp
        _lastTelemetryReset = DateTime.now();
        await prefs.setString(_telemetryLastResetKey, _lastTelemetryReset!.toIso8601String());
      }
      
      debugPrint('AbandonmentPredictor: Telemetry loaded - Predictions: $_predictionCount, Errors: $_errorCount');
    } catch (e) {
      debugPrint('AbandonmentPredictor: Failed to load telemetry: $e');
      // Continue with default values
    }
  }

  /// Save telemetry to SharedPreferences
  Future<void> _saveTelemetry() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setInt(_telemetryPredictionCountKey, _predictionCount);
      await prefs.setInt(_telemetryErrorCountKey, _errorCount);
      
      if (_lastPredictionTime != null) {
        await prefs.setString(_telemetryLastPredictionKey, _lastPredictionTime!.toIso8601String());
      }
    } catch (e) {
      debugPrint('AbandonmentPredictor: Failed to save telemetry: $e');
      // Non-critical - continue execution
    }
  }

  /// Reset telemetry counters (called weekly)
  Future<void> _resetTelemetry() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Log final stats before reset
      debugPrint(
        'AbandonmentPredictor: Resetting telemetry - '
        'Final stats: $_predictionCount predictions, $_errorCount errors, '
        'success rate: ${telemetry['success_rate']}'
      );
      
      // Reset counters
      _predictionCount = 0;
      _errorCount = 0;
      _lastTelemetryReset = DateTime.now();
      
      await prefs.setInt(_telemetryPredictionCountKey, 0);
      await prefs.setInt(_telemetryErrorCountKey, 0);
      await prefs.setString(_telemetryLastResetKey, _lastTelemetryReset!.toIso8601String());
      
      debugPrint('AbandonmentPredictor: Telemetry reset complete');
    } catch (e) {
      debugPrint('AbandonmentPredictor: Failed to reset telemetry: $e');
    }
  }
}
