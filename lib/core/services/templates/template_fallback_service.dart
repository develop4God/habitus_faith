import 'package:logger/logger.dart';
import '../../../features/habits/presentation/onboarding/onboarding_models.dart';
import '../templates/template_scoring_engine.dart';
import '../habit_template_loader.dart';

/// Service to find similar templates when exact fingerprint match fails
///
/// Uses TemplateScoringEngine to find the best matching template
/// from available assets based on profile similarity
class TemplateFallbackService {
  static final _logger = Logger();

  /// Find the best matching template for a profile
  ///
  /// Returns null if no template scores above threshold (0.75)
  /// Uses TemplateScoringEngine for dimensional similarity matching
  static Future<Map<String, dynamic>?> findSimilarTemplate(
    OnboardingProfile profile, {
    double threshold = 0.75,
  }) async {
    try {
      _logger.i('🔍 Searching for similar template (threshold: $threshold)');

      // Get list of available template fingerprints
      final fingerprints = await _getAvailableTemplateFingerprints();
      _logger.d('Found [1m${fingerprints.length}[0m templates to evaluate');

      // Initialize scoring engine
      final scoringEngine = TemplateScoringEngine();
      final userVector = UserProfileVector.fromProfile(profile);

      Map<String, dynamic>? bestTemplate;
      double bestScore = 0.0;
      String? bestPatternId;

      // Evaluate each template
      for (final fingerprint in fingerprints) {
        try {
          final template = await HabitTemplateLoader.loadTemplate(fingerprint);
          if (template == null) continue;

          // Get pattern from template metadata
          final profileData = template['profile'] as Map<String, dynamic>?;
          if (profileData == null) continue;

          final patternId = _buildPatternId(profileData);
          final templateMetadata = TemplateMetadata.fromPatternId(patternId);

          // Calculate score
          final matchScore =
              scoringEngine.calculateScore(userVector, templateMetadata);

          if (matchScore.totalScore > bestScore) {
            bestScore = matchScore.totalScore;
            bestTemplate = template;
            bestPatternId = patternId;

            _logger.d(
              'New best match: $patternId (score: ${matchScore.totalScore.toStringAsFixed(3)})',
            );
          }
        } catch (e) {
          _logger.w('Error evaluating template $fingerprint: $e');
          continue;
        }
      }

      if (bestScore >= threshold && bestTemplate != null) {
        _logger.i(
          '✅ Found similar template: $bestPatternId (score: ${bestScore.toStringAsFixed(3)})',
        );
        return bestTemplate;
      } else {
        _logger.w(
          '⚠️  No template found above threshold (best: ${bestScore.toStringAsFixed(3)})',
        );
        return null;
      }
    } catch (e) {
      _logger.e('Error in findSimilarTemplate: $e');
      return null;
    }
  }

  /// Get list of available template fingerprints
  /// This should be updated when templates are regenerated
  static Future<List<String>> _getAvailableTemplateFingerprints() async {
    // TODO: Generate a manifest of available templates during build
    // For now, return empty list and let the system fall back to Gemini
    _logger
        .w('Template fingerprint list not available - falling back to Gemini');
    return <String>[];
  }

  /// Build pattern ID from profile data
  /// Format: intent_maturity_challenge_support_motivation1_motivation2
  static String _buildPatternId(Map<String, dynamic> profileData) {
    final intent = profileData['intent'] ?? 'faithBased';
    final maturity = profileData['spiritualMaturity'] ?? '';
    final challenge = profileData['challenge'] ?? 'dontKnowStart';
    final support = profileData['supportLevel'] ?? 'normal';
    final motivations =
        (profileData['motivations'] as List?)?.cast<String>() ?? [];

    // Take up to 2 motivations for pattern
    final motivationsPart = motivations.take(2).join('_');

    return '${intent}_${maturity}_${challenge}_${support}_$motivationsPart';
  }
}
