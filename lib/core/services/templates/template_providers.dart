import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'template_matching_service.dart';
import '../../providers/ai_providers.dart';

part 'template_providers.g.dart';

/// Provider for the template matching service
/// Not a singleton - creates new instance with cache service dependency
@riverpod
TemplateMatchingService templateMatchingService(
    TemplateMatchingServiceRef ref) {
  final cache = ref.watch(cacheServiceProvider);
  return TemplateMatchingService(cache);
}
