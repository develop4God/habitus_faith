import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/background_task_service.dart';
import 'clock_provider.dart';

/// Provider for BackgroundTaskService with Clock injection
final backgroundTaskServiceProvider = Provider<BackgroundTaskService>((ref) {
  final clock = ref.watch(clockProvider);
  return BackgroundTaskService(clock: clock);
});

/// Provider to initialize the background task service and schedule daily predictions.
final backgroundTaskInitProvider = FutureProvider<void>((ref) async {
  final backgroundTaskService = ref.watch(backgroundTaskServiceProvider);
  await backgroundTaskService.initialize();
  await backgroundTaskService.scheduleDailyPrediction();
});
