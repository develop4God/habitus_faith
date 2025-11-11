import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../../config/template_constants.dart';
import '../cache/cache_service.dart';
import '../../../features/habits/presentation/onboarding/onboarding_models.dart';

/// Service for matching onboarding profiles to pre-generated habit templates
/// Not a singleton - designed for easy testing with dependency injection
class TemplateMatchingService {
  final ICacheService _cache;
  final http.Client? _httpClient;

  TemplateMatchingService(
    this._cache, {
    http.Client? httpClient,
  }) : _httpClient = httpClient;

  /// Generate a pattern ID from an onboarding profile
  /// Used to match against template fingerprints
  String generatePatternId(OnboardingProfile profile) {
    // Take first two motivations for pattern matching
    final motivationsKey = profile.motivations.take(2).join('_');

    // Use spiritualMaturity for faith-based, or first motivation for wellness
    final maturityOrState =
        profile.spiritualMaturity ?? profile.motivations.first;

    return '${profile.primaryIntent.name}_'
        '${maturityOrState}_'
        '${profile.challenge}_'
        '$motivationsKey';
  }

  /// Find a matching template for the given profile
  /// Returns the generated_habits array from the template, or null if no match
  Future<List<Map<String, dynamic>>?> findMatch(
    OnboardingProfile profile,
    String language,
  ) async {
    try {
      // Generate pattern ID for exact match
      final patternId = generatePatternId(profile);
      log('Looking for template with pattern: $patternId', name: 'templates');

      // Try to get from cache first
      final cacheKey = 'template_${language}_$patternId';
      final cached = await _cache.get<Map<String, dynamic>>(cacheKey);
      if (cached != null) {
        log('Template found in cache', name: 'templates');
        return (cached['generated_habits'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
      }

      // Fetch metadata from GitHub
      final metadata = await _fetchMetadata(language);
      if (metadata == null) {
        log('Failed to fetch metadata', name: 'templates');
        return null;
      }

      // Try exact match first
      final exactMatch = _findExactMatch(metadata, patternId);
      if (exactMatch != null) {
        final template = await _fetchTemplate(language, exactMatch['file']);
        if (template != null) {
          // Cache the template
          await _cache.set(
            cacheKey,
            template,
            ttl: TemplateConstants.cacheDuration,
          );
          log('Exact match found: $patternId', name: 'templates');
          return (template['generated_habits'] as List<dynamic>)
              .cast<Map<String, dynamic>>();
        }
      }

      // Try fuzzy match
      final fuzzyMatch = _findFuzzyMatch(metadata, profile);
      if (fuzzyMatch != null) {
        final template = await _fetchTemplate(language, fuzzyMatch['file']);
        if (template != null) {
          // Cache with a different key for fuzzy matches
          final fuzzyCacheKey = 'template_fuzzy_${language}_$patternId';
          await _cache.set(
            fuzzyCacheKey,
            template,
            ttl: TemplateConstants.cacheDuration,
          );
          log('Fuzzy match found with similarity >= ${TemplateConstants.similarityThreshold}',
              name: 'templates');
          return (template['generated_habits'] as List<dynamic>)
              .cast<Map<String, dynamic>>();
        }
      }

      log('No template match found for pattern: $patternId', name: 'templates');
      return null;
    } catch (e, stack) {
      log('Error finding template match: $e', name: 'templates', error: e);
      log('Stack trace: $stack', name: 'templates');
      return null; // Graceful fallback to Gemini
    }
  }

  /// Fetch the metadata index from GitHub
  Future<Map<String, dynamic>?> _fetchMetadata(String language) async {
    try {
      final cacheKey = 'template_metadata_$language';
      final cached = await _cache.get<Map<String, dynamic>>(cacheKey);
      if (cached != null) {
        return cached;
      }

      final url =
          '${TemplateConstants.baseUrl}/templates-$language/${TemplateConstants.metadataFile}';
      final client = _httpClient ?? http.Client();
      final response = await client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final metadata = jsonDecode(response.body) as Map<String, dynamic>;
        // Cache metadata for shorter duration
        await _cache.set(
          cacheKey,
          metadata,
          ttl: const Duration(hours: 6),
        );
        return metadata;
      }

      log('Failed to fetch metadata: ${response.statusCode}',
          name: 'templates');
      return null;
    } catch (e) {
      log('Error fetching metadata: $e', name: 'templates', error: e);
      return null;
    }
  }

  /// Fetch a specific template from GitHub
  Future<Map<String, dynamic>?> _fetchTemplate(
      String language, String fileName) async {
    try {
      final url = '${TemplateConstants.baseUrl}/templates-$language/$fileName';
      final client = _httpClient ?? http.Client();
      final response = await client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      log('Failed to fetch template: ${response.statusCode}',
          name: 'templates');
      return null;
    } catch (e) {
      log('Error fetching template: $e', name: 'templates', error: e);
      return null;
    }
  }

  /// Find exact pattern ID match in metadata
  Map<String, dynamic>? _findExactMatch(
      Map<String, dynamic> metadata, String patternId) {
    final templates = metadata['templates'] as List<dynamic>?;
    if (templates == null) return null;

    for (final template in templates) {
      if (template['pattern_id'] == patternId) {
        return template as Map<String, dynamic>;
      }
    }
    return null;
  }

  /// Find fuzzy match using profile similarity
  Map<String, dynamic>? _findFuzzyMatch(
      Map<String, dynamic> metadata, OnboardingProfile profile) {
    final templates = metadata['templates'] as List<dynamic>?;
    if (templates == null) return null;

    Map<String, dynamic>? bestMatch;
    double bestSimilarity = 0.0;

    for (final template in templates) {
      final fingerprint = template['fingerprint'] as Map<String, dynamic>;

      // Convert fingerprint to OnboardingProfile for similarity comparison
      final templateProfile = OnboardingProfile(
        primaryIntent: UserIntent.values.firstWhere(
          (e) => e.name == fingerprint['primaryIntent'],
          orElse: () => UserIntent.faithBased,
        ),
        motivations: (fingerprint['motivations'] as List<dynamic>)
            .cast<String>()
            .toList(),
        challenge: fingerprint['challenge'] as String,
        supportLevel: fingerprint['supportLevel'] as String? ?? '',
        spiritualMaturity: fingerprint['spiritualMaturity'] as String?,
        commitment: '',
        completedAt: DateTime.now(),
      );

      final similarity = profile.similarityTo(templateProfile);
      if (similarity >= TemplateConstants.similarityThreshold &&
          similarity > bestSimilarity) {
        bestSimilarity = similarity;
        bestMatch = template as Map<String, dynamic>;
      }
    }

    if (bestMatch != null) {
      log('Fuzzy match similarity: $bestSimilarity', name: 'templates');
    }

    return bestMatch;
  }
}
