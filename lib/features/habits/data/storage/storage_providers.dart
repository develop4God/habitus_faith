import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'json_storage_service.dart';
import 'json_habits_repository.dart';
import '../../domain/habits_repository.dart';

/// Provider for SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden with actual instance',
  );
});

/// Provider for JsonStorageService
final jsonStorageServiceProvider = Provider<JsonStorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return JsonStorageService(prefs);
});

/// Provider for user ID (currently hardcoded for local storage)
/// In production, this would come from authentication
final localUserIdProvider = Provider<String>((ref) {
  // For local storage, use a fixed user ID
  return 'local_user';
});

/// Provider for JsonHabitsRepository
final jsonHabitsRepositoryProvider = Provider<HabitsRepository>((ref) {
  final storage = ref.watch(jsonStorageServiceProvider);
  final userId = ref.watch(localUserIdProvider);

  return JsonHabitsRepository(
    storage: storage,
    userId: userId,
    idGenerator: () => const Uuid().v4(),
  );
});

/// Provider to check if onboarding is complete
final onboardingCompleteProvider = Provider<bool>((ref) {
  final storage = ref.watch(jsonStorageServiceProvider);
  return storage.getBool('onboarding_complete', defaultValue: false);
});

/// Provider to mark onboarding as complete
final completeOnboardingProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final storage = ref.read(jsonStorageServiceProvider);
    await storage.setBool('onboarding_complete', true);
    // Invalidate the onboardingCompleteProvider to refresh
    ref.invalidate(onboardingCompleteProvider);
  };
});
