import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'background_task_service_provider.dart';

/// Provider for the currently scheduled ML prediction hour.
/// Fetched from BackgroundTaskService.
final scheduledHourProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(backgroundTaskServiceProvider);
  return service.getScheduledHour();
});
