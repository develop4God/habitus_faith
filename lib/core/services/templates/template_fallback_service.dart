import '../../../features/habits/presentation/onboarding/onboarding_models.dart';

/// Service to find similar templates when exact fingerprint match fails
///
/// Uses TemplateScoringEngine to find the best matching template
/// from available assets based on profile similarity
class TemplateFallbackService {
  /// Find the best matching template for a profile
  ///
  /// Returns null if no template scores above threshold (0.75)
  /// Uses TemplateScoringEngine for dimensional similarity matching
  static Future<Map<String, dynamic>?> findSimilarTemplate(
    OnboardingProfile profile, {
    double threshold = 0.75,
  }) async {
    // No plantillas locales: siempre fallback a Gemini
    return null;
  }


}
