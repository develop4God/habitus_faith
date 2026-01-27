import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../../features/habits/domain/habit.dart';
import '../../../features/habits/domain/ml_features_calculator.dart';
import '../../services/time/time.dart';
import 'telemetry_service.dart';

/// Service for ML-based habit abandonment risk prediction
/// Loads TFLite model and provides real-time predictions without server dependency
///
/// Input tensor order (CRITICAL - must match training):
/// [hourOfDay, dayOfWeek, currentStreak, failuresLast7Days, hoursFromReminder]
/// Shape: [1, 5] (batch size 1, 5 features)
///
/// Feature definitions:
/// 1. hourOfDay: Hour when habit was last completed (0-23), default 12 if never completed
/// 2. dayOfWeek: Day of week when last completed (1-7, Monday=1), default 1 if never completed
/// 3. currentStreak: Current streak count
/// 4. failuresLast7Days: Number of missed days in last 7 days
/// 5. hoursFromReminder: Absolute hours from reminder time to now
class AbandonmentPredictor {
  final Clock clock;
  final MLTelemetryService? _telemetryService;
  Interpreter? _interpreter;
  Map<String, dynamic>? _scalerParams;
  Map<String, dynamic>? _modelMetadata;
  bool _initialized = false;

  // Model constants
  static const int featureCount = 5;
  static const double defaultRiskForNewHabits = 0.5;
  static const double defaultRiskWhenUninitialized = 0.5;

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

  /// Constructor with optional clock and telemetry service injection
  AbandonmentPredictor({
    Clock? clock,
    MLTelemetryService? telemetryService,
    Interpreter? interpreter, // Add this for test injection
  })  : clock = clock ?? const Clock.system(),
        _telemetryService = telemetryService {
    if (interpreter != null) {
      _interpreter = interpreter;
      _initialized = true;
    }
  }

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
      debugPrint('AbandonmentPredictor.initialize: Already initialized');
      return;
    }

    debugPrint('AbandonmentPredictor.initialize: Starting initialization...');

    try {
      // Load model metadata
      debugPrint('AbandonmentPredictor.initialize: Loading model metadata...');
      final metadataJson = await rootBundle.loadString(
        'assets/ml_models/model_metadata.json',
      );
      _modelMetadata = json.decode(metadataJson) as Map<String, dynamic>;
      debugPrint(
        'AbandonmentPredictor.initialize: Model version ${_modelMetadata!['version']} loaded',
      );

      // Load TFLite model from assets
      debugPrint('AbandonmentPredictor.initialize: Loading TFLite model...');
      _interpreter = await Interpreter.fromAsset(
        'assets/ml_models/predictor.tflite',
      );
      debugPrint(
        'AbandonmentPredictor.initialize: TFLite model loaded successfully',
      );

      // Load scaler parameters
      debugPrint('AbandonmentPredictor: Loading scaler params...');
      final scalerJson = await rootBundle.loadString(
        'assets/ml_models/scaler_params.json',
      );
      _scalerParams = json.decode(scalerJson) as Map<String, dynamic>;
      debugPrint('AbandonmentPredictor: Scaler params loaded successfully');

      // Validate model schema
      _validateModelSchema();

      // Load persisted telemetry
      await _loadTelemetry();

      _initialized = true;
      debugPrint('AbandonmentPredictor: Initialization complete');
      debugPrint(
        'AbandonmentPredictor: Model metadata - Training samples: ${_modelMetadata!['training_samples']}, Accuracy: ${_modelMetadata!['accuracy']}',
      );
      debugPrint(
        'AbandonmentPredictor: Telemetry - Predictions: $_predictionCount, Errors: $_errorCount',
      );
    } catch (e) {
      debugPrint('AbandonmentPredictor: Initialization failed: $e');
      // Non-critical failure - predictor will return 0.0 for predictions
      _initialized = false;
    }
  }

  /// Validate that model schema matches expected configuration
  /// Throws if there's a critical mismatch
  void _validateModelSchema() {
    const expectedInputShape = [1, featureCount];
    const expectedOutputShape = [1, 1];

    // Validate metadata (log warnings instead of throwing)
    if (_modelMetadata != null) {
      final inputShape = _modelMetadata!['input_shape'] as List?;
      final outputShape = _modelMetadata!['output_shape'] as List?;

      if (inputShape != null &&
          (inputShape[0] != expectedInputShape[0] ||
              inputShape[1] != expectedInputShape[1])) {
        debugPrint(
          '⚠️ Schema mismatch: expected input shape $expectedInputShape, got $inputShape',
        );
        _initialized = false; // Mark as not initialized
        return; // Exit validation, predictRisk() will return default 0.5
      }

      if (outputShape != null &&
          (outputShape[0] != expectedOutputShape[0] ||
              outputShape[1] != expectedOutputShape[1])) {
        debugPrint(
          '⚠️ Schema mismatch: expected output shape $expectedOutputShape, got $outputShape',
        );
        _initialized = false;
        return;
      }
    }

    // Validate scaler params match expected feature count
    if (_scalerParams != null) {
      final mean = (_scalerParams!['mean'] as List);
      final scale = (_scalerParams!['scale'] as List);

      if (mean.length != featureCount) {
        debugPrint(
          '⚠️ Schema mismatch: expected $featureCount features in mean, got ${mean.length}',
        );
        _initialized = false;
        return;
      }

      if (scale.length != featureCount) {
        debugPrint(
          '⚠️ Schema mismatch: expected $featureCount features in scale, got ${scale.length}',
        );
        _initialized = false;
        return;
      }
    }

    debugPrint(
      'AbandonmentPredictor: Schema validation passed - input shape: $expectedInputShape, features: $featureCount',
    );
  }

  /// Normalize features using StandardScaler parameters from training
  /// Applies: (feature - mean) / scale element-wise
  List<double> _normalizeFeatures(List<double> features) {
    if (_scalerParams == null) {
      debugPrint(
        'AbandonmentPredictor: Scaler params not loaded, returning raw features',
      );
      return features;
    }

    final mean = (_scalerParams!['mean'] as List).cast<double>();
    final scale = (_scalerParams!['scale'] as List).cast<double>();

    if (mean.length != features.length || scale.length != features.length) {
      debugPrint(
        'AbandonmentPredictor: Feature length mismatch, returning raw features',
      );
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
  /// 5. Hours from reminder (MLFeaturesCalculator.calculateHoursFromReminder(habit, now))
  Future<double> predictRisk(Habit habit) async {
    if (!_initialized || _interpreter == null) {
      debugPrint(
        'AbandonmentPredictor: Not initialized, returning neutral risk $defaultRiskWhenUninitialized',
      );
      _errorCount++;
      return defaultRiskWhenUninitialized; // Return neutral risk when not initialized
    }

    try {
      // Track prediction attempt
      _predictionCount++;
      _lastPredictionTime = clock.now();

      // ⚠️ CRITICAL: Handle first-time habits (no history) → return default risk
      if (habit.completionHistory.isEmpty && habit.currentStreak == 0) {
        debugPrint(
          'AbandonmentPredictor: First-time habit detected, returning default risk $defaultRiskForNewHabits',
        );
        return defaultRiskForNewHabits;
      }

      // Extract features from habit (EXACT order as specified in requirements)
      final hourOfDay = habit.lastCompletedAt?.hour ?? 12;
      final dayOfWeek = habit.lastCompletedAt?.weekday ?? 1;
      final currentStreak = habit.currentStreak;
      final failuresLast7Days = MLFeaturesCalculator.countRecentFailures(
        habit,
        7,
      );
      final hoursFromReminder = MLFeaturesCalculator.calculateHoursFromReminder(
        habit,
        clock.now(),
      );

      // Prepare input features in exact order:
      // [hourOfDay, dayOfWeek, currentStreak, failuresLast7Days, hoursFromReminder]
      final rawFeatures = [
        hourOfDay.toDouble(),
        dayOfWeek.toDouble(),
        currentStreak.toDouble(),
        failuresLast7Days.toDouble(),
        hoursFromReminder.toDouble(),
      ];

      // Validate feature count
      if (rawFeatures.length != featureCount) {
        throw Exception(
          'Feature count mismatch: expected $featureCount, got ${rawFeatures.length}',
        );
      }

      debugPrint(
        'AbandonmentPredictor: Raw features [hour=$hourOfDay, day=$dayOfWeek, '
        'streak=$currentStreak, failures=$failuresLast7Days, hoursFromReminder=$hoursFromReminder]',
      );

      // Normalize features using StandardScaler (x - mean) / std
      final normalizedFeatures = _normalizeFeatures(rawFeatures);

      // Prepare input tensor [1, 5] - batch size 1, 5 features
      // Input must be 2D array: [[hourOfDay, dayOfWeek, currentStreak, failuresLast7Days, hoursFromReminder]]
      final input = [normalizedFeatures];

      // Prepare output tensor [1, 1] - batch size 1, 1 output
      final output = List.filled(1, List.filled(1, 0.0));

      // Run inference
      _interpreter!.run(input, output);

      // Extract probability (value between 0 and 1)
      final probability = output[0][0];

      debugPrint(
        'AbandonmentPredictor: Predicted risk = ${(probability * 100).toStringAsFixed(1)}% '
        '(model v${_modelMetadata?['version']})',
      );

      // Log to telemetry service if available
      if (_telemetryService != null) {
        await _telemetryService.logPrediction(
          habit: habit,
          predictedRisk: probability,
        );
      }

      // Save internal telemetry after successful prediction
      await _saveTelemetry();

      return probability.clamp(0.0, 1.0);
    } catch (e, stackTrace) {
      // Log error with stack trace for debugging
      debugPrint('AbandonmentPredictor: ML prediction failed: $e');
      debugPrint('Stack trace: $stackTrace');
      _errorCount++;
      // Save telemetry even on error
      await _saveTelemetry();
      // Return neutral risk instead of 0.0 to avoid false "no risk" signal
      return defaultRiskWhenUninitialized;
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
  @Deprecated(
    'Use predictRisk(Habit) instead. This method will be removed in a future version.',
  )
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
        'AbandonmentPredictor: Predicted risk = ${(probability * 100).toStringAsFixed(1)}%',
      );

      return probability.clamp(0.0, 1.0);
    } catch (e) {
      debugPrint('AbandonmentPredictor: Prediction failed: $e');
      return 0.0; // Graceful degradation
    }
  }

  /// Dispose resources and flush telemetry
  Future<void> dispose() async {
    // Flush telemetry buffer before disposing
    if (_telemetryService != null) {
      await _telemetryService.flush();
      debugPrint('AbandonmentPredictor: Flushed telemetry buffer');
    }

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
        if (clock.now().difference(_lastTelemetryReset!).inDays > 7) {
          debugPrint('AbandonmentPredictor: Weekly telemetry reset triggered');
          await _resetTelemetry();
        }
      } else {
        // First time - initialize reset timestamp
        _lastTelemetryReset = clock.now();
        await prefs.setString(
          _telemetryLastResetKey,
          _lastTelemetryReset!.toIso8601String(),
        );
      }

      debugPrint(
        'AbandonmentPredictor: Telemetry loaded - Predictions: $_predictionCount, Errors: $_errorCount',
      );
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
        await prefs.setString(
          _telemetryLastPredictionKey,
          _lastPredictionTime!.toIso8601String(),
        );
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
        'success rate: ${telemetry['success_rate']}',
      );

      // Reset counters
      _predictionCount = 0;
      _errorCount = 0;
      _lastTelemetryReset = clock.now();

      await prefs.setInt(_telemetryPredictionCountKey, 0);
      await prefs.setInt(_telemetryErrorCountKey, 0);
      await prefs.setString(
        _telemetryLastResetKey,
        _lastTelemetryReset!.toIso8601String(),
      );

      debugPrint('AbandonmentPredictor: Telemetry reset complete');
    } catch (e) {
      debugPrint('AbandonmentPredictor: Failed to reset telemetry: $e');
    }
  }
}
