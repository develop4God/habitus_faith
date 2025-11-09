import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/background_task_service.dart';
import 'clock_provider.dart';

part 'background_task_service_provider.g.dart';

/// Provider for BackgroundTaskService with Clock injection
@riverpod
BackgroundTaskService backgroundTaskService(Ref ref) {
  final clock = ref.watch(clockProvider);
  return BackgroundTaskService(clock: clock);
}
