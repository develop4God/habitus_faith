import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Service for managing Firebase Remote Config feature flags
/// Provides centralized access to remotely configured features
class RemoteConfigService {
  static RemoteConfigService? _instance;
  final FirebaseRemoteConfig _remoteConfig;

  // Private constructor for singleton
  RemoteConfigService._(this._remoteConfig);

  /// Get singleton instance
  static Future<RemoteConfigService> getInstance() async {
    if (_instance == null) {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await _initializeConfig(remoteConfig);
      _instance = RemoteConfigService._(remoteConfig);
    }
    return _instance!;
  }

  /// Initialize Remote Config with defaults and settings
  static Future<void> _initializeConfig(FirebaseRemoteConfig config) async {
    try {
      // Set config settings
      await config.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );

      // Set default values
      await config.setDefaults({
        'enable_ml_predictor': true,
        'ml_predictor_min_habits': 3,
        'ml_prediction_threshold': 0.7,
        'enable_analytics': true,
        'enable_crashlytics': true,
      });

      // Fetch and activate latest values
      await config.fetchAndActivate();

      debugPrint('RemoteConfigService: Initialized successfully');
    } catch (e) {
      debugPrint('RemoteConfigService: Error initializing - $e');
      // Continue with defaults if remote config fails
    }
  }

  /// Check if ML predictor feature is enabled
  bool get isMLPredictorEnabled {
    try {
      return _remoteConfig.getBool('enable_ml_predictor');
    } catch (e) {
      debugPrint('RemoteConfigService: Error getting ML predictor flag - $e');
      return true; // Default to enabled
    }
  }

  /// Get minimum number of habits required for ML predictions
  int get mlPredictorMinHabits {
    try {
      return _remoteConfig.getInt('ml_predictor_min_habits');
    } catch (e) {
      debugPrint('RemoteConfigService: Error getting min habits - $e');
      return 3; // Default
    }
  }

  /// Get ML prediction threshold (0.0-1.0)
  double get mlPredictionThreshold {
    try {
      return _remoteConfig.getDouble('ml_prediction_threshold');
    } catch (e) {
      debugPrint('RemoteConfigService: Error getting threshold - $e');
      return 0.7; // Default
    }
  }

  /// Check if analytics is enabled
  bool get isAnalyticsEnabled {
    try {
      return _remoteConfig.getBool('enable_analytics');
    } catch (e) {
      debugPrint('RemoteConfigService: Error getting analytics flag - $e');
      return true; // Default to enabled
    }
  }

  /// Check if crashlytics is enabled
  bool get isCrashlyticsEnabled {
    try {
      return _remoteConfig.getBool('enable_crashlytics');
    } catch (e) {
      debugPrint('RemoteConfigService: Error getting crashlytics flag - $e');
      return true; // Default to enabled
    }
  }

  /// Force fetch latest config (call sparingly)
  Future<void> refresh() async {
    try {
      await _remoteConfig.fetchAndActivate();
      debugPrint('RemoteConfigService: Config refreshed successfully');
    } catch (e) {
      debugPrint('RemoteConfigService: Error refreshing config - $e');
    }
  }

  /// Get all current values for debugging
  Map<String, dynamic> getAllValues() {
    return {
      'enable_ml_predictor': isMLPredictorEnabled,
      'ml_predictor_min_habits': mlPredictorMinHabits,
      'ml_prediction_threshold': mlPredictionThreshold,
      'enable_analytics': isAnalyticsEnabled,
      'enable_crashlytics': isCrashlyticsEnabled,
    };
  }
}
