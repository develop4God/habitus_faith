import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/remote_config_service.dart';

/// Provider for Remote Config service singleton
final remoteConfigServiceProvider = FutureProvider<RemoteConfigService>((ref) async {
  return await RemoteConfigService.getInstance();
});

/// Provider for ML predictor enabled flag
final mlPredictorEnabledProvider = FutureProvider<bool>((ref) async {
  final remoteConfig = await ref.watch(remoteConfigServiceProvider.future);
  return remoteConfig.isMLPredictorEnabled;
});

/// Provider for ML predictor minimum habits
final mlPredictorMinHabitsProvider = FutureProvider<int>((ref) async {
  final remoteConfig = await ref.watch(remoteConfigServiceProvider.future);
  return remoteConfig.mlPredictorMinHabits;
});

/// Provider for ML prediction threshold
final mlPredictionThresholdProvider = FutureProvider<double>((ref) async {
  final remoteConfig = await ref.watch(remoteConfigServiceProvider.future);
  return remoteConfig.mlPredictionThreshold;
});

/// Provider for analytics enabled flag
final analyticsEnabledProvider = FutureProvider<bool>((ref) async {
  final remoteConfig = await ref.watch(remoteConfigServiceProvider.future);
  return remoteConfig.isAnalyticsEnabled;
});

/// Provider for crashlytics enabled flag
final crashlyticsEnabledProvider = FutureProvider<bool>((ref) async {
  final remoteConfig = await ref.watch(remoteConfigServiceProvider.future);
  return remoteConfig.isCrashlyticsEnabled;
});
