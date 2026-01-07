import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'devotional_image_normalizer.dart';
import 'devotional_image_repository.dart';
import '../../../features/habits/data/storage/storage_providers.dart';

/// Provider for the image normalizer service.
final imageNormalizerProvider = Provider<DevotionalImageNormalizer>((ref) {
  return DevotionalImageNormalizer();
});

/// Provider for the devotional image repository.
///
/// This provider uses dependency injection to provide all required services.
final devotionalImageRepositoryProvider =
    Provider<DevotionalImageRepository>((ref) {
  final normalizer = ref.watch(imageNormalizerProvider);
  final prefs = ref.watch(sharedPreferencesProvider);

  return DevotionalImageRepository(
    normalizer: normalizer,
    sharedPreferences: prefs,
  );
});

/// Provider for fetching the daily devotional background image.
///
/// This is a FutureProvider that fetches and caches the image for the day.
final dailyDevotionalImageProvider = FutureProvider<String>((ref) async {
  final repository = ref.watch(devotionalImageRepositoryProvider);
  return repository.getImageForToday(width: 800, height: 400);
});
