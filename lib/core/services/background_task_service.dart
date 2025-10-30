import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing background tasks using WorkManager
/// Handles daily cron jobs for ML predictions and other background operations
class BackgroundTaskService {
  static const String _dailyPredictionTask = 'dailyAbandonmentPrediction';
  static const String _predictionTaskTag = 'daily_prediction_6am';
  static const String _mlPredictionsEnabledKey = 'ml_predictions_enabled';

  static final BackgroundTaskService _instance = BackgroundTaskService._internal();

  factory BackgroundTaskService() => _instance;

  BackgroundTaskService._internal();

  bool _initialized = false;

  /// Initialize the background task service
  /// Must be called before scheduling any tasks
  Future<void> initialize() async {
    if (_initialized) {
      developer.log(
        'BackgroundTaskService: Already initialized',
        name: 'BackgroundTaskService',
      );
      return;
    }

    try {
      // Initialize Workmanager
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: kDebugMode,
      );

      _initialized = true;
      developer.log(
        'BackgroundTaskService: Initialization complete',
        name: 'BackgroundTaskService',
      );
    } catch (e) {
      developer.log(
        'BackgroundTaskService: Initialization failed: $e',
        name: 'BackgroundTaskService',
        error: e,
      );
      _initialized = false;
    }
  }

  /// Schedule daily prediction task at 6:00 AM
  /// Respects battery optimization and user settings
  Future<void> scheduleDailyPrediction() async {
    if (!_initialized) {
      developer.log(
        'BackgroundTaskService: Not initialized, cannot schedule task',
        name: 'BackgroundTaskService',
      );
      return;
    }

    try {
      // Check if ML predictions are enabled
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool(_mlPredictionsEnabledKey) ?? true;

      if (!enabled) {
        developer.log(
          'BackgroundTaskService: ML predictions disabled, cancelling task',
          name: 'BackgroundTaskService',
        );
        await cancelDailyPrediction();
        return;
      }

      // Cancel any existing task first
      await Workmanager().cancelByTag(_predictionTaskTag);

      // Schedule daily task at 6:00 AM
      // initialDelay calculates time until next 6 AM
      final now = DateTime.now();
      var nextRun = DateTime(now.year, now.month, now.day, 6, 0);
      
      // If 6 AM already passed today, schedule for tomorrow
      if (nextRun.isBefore(now)) {
        nextRun = nextRun.add(const Duration(days: 1));
      }

      final initialDelay = nextRun.difference(now);

      await Workmanager().registerPeriodicTask(
        _dailyPredictionTask,
        _dailyPredictionTask,
        frequency: const Duration(days: 1),
        initialDelay: initialDelay,
        existingWorkPolicy: ExistingWorkPolicy.replace,
        constraints: Constraints(
          networkType: NetworkType.not_required,
          requiresBatteryNotLow: true, // Respect battery optimization
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        tag: _predictionTaskTag,
      );

      developer.log(
        'BackgroundTaskService: Daily prediction task scheduled for 6:00 AM (next run: $nextRun)',
        name: 'BackgroundTaskService',
      );
    } catch (e) {
      developer.log(
        'BackgroundTaskService: Failed to schedule daily prediction: $e',
        name: 'BackgroundTaskService',
        error: e,
      );
    }
  }

  /// Cancel daily prediction task
  Future<void> cancelDailyPrediction() async {
    if (!_initialized) {
      return;
    }

    try {
      await Workmanager().cancelByTag(_predictionTaskTag);
      developer.log(
        'BackgroundTaskService: Daily prediction task cancelled',
        name: 'BackgroundTaskService',
      );
    } catch (e) {
      developer.log(
        'BackgroundTaskService: Failed to cancel daily prediction: $e',
        name: 'BackgroundTaskService',
        error: e,
      );
    }
  }

  /// Check if ML predictions are enabled
  Future<bool> arePredictionsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_mlPredictionsEnabledKey) ?? true;
  }

  /// Enable or disable ML predictions
  Future<void> setPredictionsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_mlPredictionsEnabledKey, enabled);
    
    developer.log(
      'BackgroundTaskService: ML predictions enabled set to $enabled',
      name: 'BackgroundTaskService',
    );

    if (enabled) {
      await scheduleDailyPrediction();
    } else {
      await cancelDailyPrediction();
    }
  }

  /// Cancel all background tasks
  Future<void> cancelAll() async {
    if (!_initialized) {
      return;
    }

    try {
      await Workmanager().cancelAll();
      developer.log(
        'BackgroundTaskService: All background tasks cancelled',
        name: 'BackgroundTaskService',
      );
    } catch (e) {
      developer.log(
        'BackgroundTaskService: Failed to cancel all tasks: $e',
        name: 'BackgroundTaskService',
        error: e,
      );
    }
  }
}

/// Callback dispatcher for background tasks
/// This function runs in a separate isolate
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    developer.log(
      'BackgroundTaskService: Executing task: $task',
      name: 'BackgroundTaskService',
    );

    try {
      switch (task) {
        case BackgroundTaskService._dailyPredictionTask:
          // Task execution is delegated to HabitPredictorProvider
          // which will be triggered by the provider system
          developer.log(
            'BackgroundTaskService: Daily prediction task triggered',
            name: 'BackgroundTaskService',
          );
          return true;

        default:
          developer.log(
            'BackgroundTaskService: Unknown task: $task',
            name: 'BackgroundTaskService',
          );
          return false;
      }
    } catch (e) {
      developer.log(
        'BackgroundTaskService: Task execution failed: $e',
        name: 'BackgroundTaskService',
        error: e,
      );
      return false;
    }
  });
}
