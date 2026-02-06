import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/habit_predictor_provider.dart';
import '../../features/habits/data/storage/storage_providers.dart';
import '../services/time/time.dart';

/// Service for managing background tasks using WorkManager
/// Handles daily cron jobs for ML predictions and other background operations
class BackgroundTaskService {
  final Clock clock;

  static const String _dailyPredictionTask = 'dailyAbandonmentPrediction';
  static const String _predictionTaskTag = 'daily_prediction_6am';
  static const String _mlPredictionsEnabledKey = 'ml_predictions_enabled';
  static const String _mlPredictionHourKey = 'ml_prediction_hour';

  // FAST_TIME mode constants (288x speed: 1 week in 35 minutes, 1 day in 5 minutes)
  // Minimum 4 real minutes between runs (allows ~80% of a simulated day margin)
  static const int _fastTimeMinCooldownMinutes = 4;

  bool _initialized = false;

  /// Constructor with dependency injection
  BackgroundTaskService({Clock? clock}) : clock = clock ?? const Clock.system();

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

  /// Schedule daily prediction task at configured hour (default 6:00 AM)
  /// Respects battery optimization and user settings
  /// Returns true if scheduled successfully, false otherwise
  Future<bool> scheduleDailyPrediction() async {
    if (!_initialized) {
      developer.log(
        'BackgroundTaskService: Not initialized, cannot schedule task',
        name: 'BackgroundTaskService',
      );
      return false;
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
        return false;
      }

      // Cancel any existing task first
      await Workmanager().cancelByTag(_predictionTaskTag);

      // Get scheduled hour (default to 6 AM)
      final scheduledHour = prefs.getInt(_mlPredictionHourKey) ?? 6;

      // Check if FAST_TIME is enabled (for accelerated testing)
      const fastTime = bool.fromEnvironment('FAST_TIME');
      
      Duration frequency;
      Duration initialDelay;
      
      if (fastTime && kDebugMode) {
        // In FAST_TIME mode (288x speed), run every 5 minutes to check if it's time
        // This allows predictions to run at the correct accelerated time
        // 5 real minutes = 24 simulated hours at 288x speed
        frequency = const Duration(minutes: 5);
        initialDelay = const Duration(seconds: 30); // Start checking soon
        
        developer.log(
          'BackgroundTaskService: FAST_TIME enabled - scheduling frequent checks (every 5 min)',
          name: 'BackgroundTaskService',
        );
      } else {
        // Normal mode: schedule for specific time of day
        final now = clock.now();
        var nextRun = DateTime(now.year, now.month, now.day, scheduledHour, 0);

        // If scheduled time already passed today, schedule for tomorrow
        if (nextRun.isBefore(now)) {
          nextRun = nextRun.add(const Duration(days: 1));
        }

        initialDelay = nextRun.difference(now);
        frequency = const Duration(days: 1);
      }

      await Workmanager().registerPeriodicTask(
        _dailyPredictionTask,
        _dailyPredictionTask,
        frequency: frequency,
        initialDelay: initialDelay,
        existingWorkPolicy: ExistingWorkPolicy.replace,
        constraints: Constraints(
          networkType: NetworkType.notRequired,
          requiresBatteryNotLow: !fastTime, // Ignore battery in fast mode
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        tag: _predictionTaskTag,
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(minutes: 15),
      );

      developer.log(
        'BackgroundTaskService: Daily prediction task scheduled successfully for $scheduledHour:00 (frequency: $frequency, initial delay: $initialDelay)',
        name: 'BackgroundTaskService',
      );

      // Store last scheduled time for status tracking
      await prefs.setString(
        'ml_last_scheduled',
        DateTime.now().toIso8601String(),
      );

      return true;
    } catch (e, stackTrace) {
      developer.log(
        'BackgroundTaskService: Failed to schedule daily prediction: $e',
        name: 'BackgroundTaskService',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
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

  /// Get scheduled hour for predictions
  Future<int> getScheduledHour() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_mlPredictionHourKey) ?? 6;
  }

  /// Set scheduled hour for predictions (Only for Debug)
  Future<void> setScheduledHour(int hour) async {
    assert(kDebugMode, 'setScheduledHour should only be called in debug mode');
    assert(hour >= 0 && hour <= 23, 'Hour must be between 0-23');

    if (hour < 0 || hour > 23) {
      throw ArgumentError('Hour must be between 0-23');
    }

    final prefs = await SharedPreferences.getInstance();
    final previousHour = prefs.getInt(_mlPredictionHourKey);

    try {
      await prefs.setInt(_mlPredictionHourKey, hour);
      final success = await scheduleDailyPrediction();
      if (!success) {
        throw Exception('Failed to reschedule background task');
      }
    } catch (e) {
      developer.log(
        'BackgroundTaskService: Failed to update scheduled hour, rolling back',
        name: 'BackgroundTaskService',
        error: e,
      );
      // Rollback logic
      if (previousHour != null) {
        await prefs.setInt(_mlPredictionHourKey, previousHour);
      } else {
        await prefs.remove(_mlPredictionHourKey);
      }
      await scheduleDailyPrediction();
      rethrow;
    }
  }

  /// Get status of last prediction run
  /// Returns null if no prediction has been run, otherwise returns last run time
  Future<DateTime?> getLastPredictionTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastScheduled = prefs.getString('ml_last_scheduled');
    if (lastScheduled != null) {
      return DateTime.parse(lastScheduled);
    }
    return null;
  }

  /// Check if predictions are stale (not run in last 48 hours)
  Future<bool> arePredictionsStale() async {
    final lastTime = await getLastPredictionTime();
    if (lastTime == null) return true;

    final now = clock.now();
    final hoursSinceLastRun = now.difference(lastTime).inHours;
    return hoursSinceLastRun > 48;
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
          return await _executeDailyPrediction();

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

/// Execute daily prediction task in background isolate
/// Returns true if successful, false otherwise
Future<bool> _executeDailyPrediction() async {
  developer.log(
    'BackgroundTaskService: Starting daily prediction execution',
    name: 'BackgroundTaskService',
  );

  ProviderContainer? container;

  try {
    // Check if predictions are enabled (re-check in isolate)
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('ml_predictions_enabled') ?? true;

    if (!enabled) {
      developer.log(
        'BackgroundTaskService: ML predictions disabled, skipping',
        name: 'BackgroundTaskService',
      );
      return true; // Not an error, just disabled
    }

    // Check if we should run based on time
    const fastTime = bool.fromEnvironment('FAST_TIME');
    if (fastTime && kDebugMode) {
      // In FAST_TIME mode, check if enough time has passed since last run
      // This prevents running too frequently when WorkManager checks every 5 minutes
      const lastRunKey = 'ml_last_run_time';
      final lastRunStr = prefs.getString(lastRunKey);
      final scheduledHour = prefs.getInt('ml_prediction_hour') ?? 6;
      
      if (lastRunStr != null) {
        final lastRun = DateTime.parse(lastRunStr);
        final now = DateTime.now();
        
        // In FAST_TIME (288x), 1 day = 5 minutes
        // Only run if at least 4 minutes have passed (allows ~80% of a simulated day margin)
        if (now.difference(lastRun).inMinutes < BackgroundTaskService._fastTimeMinCooldownMinutes) {
          developer.log(
            'BackgroundTaskService: FAST_TIME - skipping, last run was ${now.difference(lastRun).inMinutes} minutes ago',
            name: 'BackgroundTaskService',
          );
          return true; // Not time yet
        }
      }
      
      // Store this run time
      await prefs.setString(lastRunKey, DateTime.now().toIso8601String());
      
      developer.log(
        'BackgroundTaskService: FAST_TIME - running predictions (scheduled hour: $scheduledHour)',
        name: 'BackgroundTaskService',
      );
    }

    // Initialize ProviderContainer in isolate
    container = ProviderContainer(
      overrides: [
        // Force JSON storage in isolate (Firestore not available in background isolate)
        // SharedPreferences must be initialized separately in isolate
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );

    // Get the predictor service and run predictions
    final predictor = container.read(habitPredictorProvider);

    // Run predictions with timeout protection (max 5 minutes)
    await predictor.runDailyPredictions().timeout(
      const Duration(minutes: 5),
      onTimeout: () {
        developer.log(
          'BackgroundTaskService: Prediction task timed out after 5 minutes',
          name: 'BackgroundTaskService',
        );
        throw TimeoutException('Daily prediction task exceeded 5 minutes');
      },
    );

    developer.log(
      'BackgroundTaskService: Daily prediction task completed successfully',
      name: 'BackgroundTaskService',
    );

    return true;
  } on TimeoutException catch (e) {
    developer.log(
      'BackgroundTaskService: Prediction timeout: $e',
      name: 'BackgroundTaskService',
      error: e,
    );
    return false;
  } catch (e) {
    developer.log(
      'BackgroundTaskService: Prediction execution error: $e',
      name: 'BackgroundTaskService',
      error: e,
    );
    return false;
  } finally {
    // Clean up container
    container?.dispose();
  }
}
