import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'template_matching_service.dart';
import '../../providers/ai_providers.dart';

part 'template_providers.g.dart';

/// Provider for the template matching service
/// Not a singleton - creates new instance with cache service dependency
@riverpod
TemplateMatchingService templateMatchingService(Ref ref) {
  final cache = ref.watch(cacheServiceProvider);
  return TemplateMatchingService(cache);
}
