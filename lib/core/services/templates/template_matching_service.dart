import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:string_similarity/string_similarity.dart';
import '../../config/template_constants.dart';
import '../cache/cache_service.dart';
import '../../../features/habits/presentation/onboarding/onboarding_models.dart';
import 'template_scoring_engine.dart';

/// Service for matching onboarding profiles to pre-generated habit templates
/// Not a singleton - designed for easy testing with dependency injection
class TemplateMatchingService {
  final ICacheService _cache;
  final http.Client? _httpClient;
  final FirebaseFirestore? _firestore;
  final TemplateScoringEngine _scoringEngine;

  TemplateMatchingService(
    this._cache, {
    http.Client? httpClient,
    FirebaseFirestore? firestore,
    TemplateScoringEngine? scoringEngine,
  })  : _httpClient = httpClient,
        _firestore = firestore,
        _scoringEngine = scoringEngine ?? TemplateScoringEngine();

  /// Generate a pattern ID from an onboarding profile
  /// Used to match against template fingerprints
  @Deprecated('Use findMatchWithScoring instead for better matching accuracy')
  String generatePatternId(OnboardingProfile profile) {
    debugPrint(
        '[TEMPLATES] WARNING: Using deprecated generatePatternId(). Migrate to findMatchWithScoring()');
    // Orden: primaryIntent, supportLevel, challenge, motivations (2), spiritualMaturity/null
    final motivationsKey = profile.motivations.take(2).join('_');
    final maturityOrState =
        profile.spiritualMaturity ?? profile.motivations.first;
    // Nuevo orden: intent_supportLevel_challenge_motivations_maturityOrState
    return '${profile.primaryIntent.name}_'
        '${profile.supportLevel}_'
        '${profile.challenge}_'
        '${motivationsKey}_'
        '$maturityOrState';
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
      debugPrint(
          '[TEMPLATES] Buscando template con pattern: $patternId, idioma: $language');

      // 1. Buscar en Firestore por fingerprint e idioma
      if (_firestore != null) {
        final docId = '${patternId}_$language';
        debugPrint('[TEMPLATES] Buscando en Firestore: $docId');
        final doc = await _firestore!
            .collection('habit_templates_master')
            .doc(docId)
            .get();
        if (doc.exists) {
          debugPrint('[TEMPLATES] Template encontrado en Firestore: $docId');
          final data = doc.data();
          if (data != null && data['habits'] != null) {
            log('Template found in Firestore: $docId', name: 'templates');
            return (data['habits'] as List<dynamic>)
                .cast<Map<String, dynamic>>();
          }
        }
      }

      // 2. Buscar en cache local
      final cacheKey = 'template_${language}_$patternId';
      final cached = await _cache.get<Map<String, dynamic>>(cacheKey);
      if (cached != null) {
        debugPrint('[TEMPLATES] Template encontrado en cache: $cacheKey');
        log('Template found in cache', name: 'templates');
        return (cached['generated_habits'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
      }

      // 3. Buscar en archivo de templates por idioma en GitHub (nuevo flujo)
      final templateFile = await _fetchTemplateFile(language);
      debugPrint(
          '[TEMPLATES] Archivo de template descargado de GitHub para $language: ${templateFile != null}');
      if (templateFile != null && templateFile['templates'] != null) {
        final templates = templateFile['templates'] as List<dynamic>;
        debugPrint(
            '[TEMPLATES] Total de templates en archivo: ${templates.length}');
        // Coincidencia exacta primero
        final match = templates.firstWhere(
          (t) => t['pattern_id'] == patternId,
          orElse: () => null,
        );
        debugPrint(
            '[TEMPLATES] ¿Match encontrado en archivo GitHub?: ${match != null}');
        if (match != null && match['habits'] != null) {
          log('Template found in GitHub file: $patternId', name: 'templates');
          await _cache.set(
            cacheKey,
            match,
            ttl: TemplateConstants.cacheDuration,
          );
          return (match['habits'] as List<dynamic>)
              .cast<Map<String, dynamic>>();
        }
        // Si no hay match exacto, buscar fuzzy
        double bestScore = 0.0;
        Map<String, dynamic>? bestMatch;
        for (final t in templates) {
          final candidate = t['pattern_id'] as String?;
          if (candidate == null) continue;
          final score =
              StringSimilarity.compareTwoStrings(patternId, candidate);
          if (score > bestScore) {
            bestScore = score;
            bestMatch = t as Map<String, dynamic>;
          }
        }
        debugPrint(
            '[TEMPLATES] Mejor score fuzzy: ${bestScore.toStringAsFixed(2)} para pattern: ${bestMatch?['pattern_id']}');
        if (bestScore >= 0.85 &&
            bestMatch != null &&
            bestMatch['habits'] != null) {
          log('Template fuzzy match in GitHub file: ${bestMatch['pattern_id']}',
              name: 'templates');
          await _cache.set(
            cacheKey,
            bestMatch,
            ttl: TemplateConstants.cacheDuration,
          );
          return (bestMatch['habits'] as List<dynamic>)
              .cast<Map<String, dynamic>>();
        }
      }

      // 4. Si no hay match, fallback a Gemini y otros métodos
      debugPrint(
          '[TEMPLATES] No se encontró template para pattern: $patternId');
      return null;
    } catch (e, stack) {
      debugPrint('[TEMPLATES] Error buscando template: $e');
      debugPrint('[TEMPLATES] Stack: $stack');
      log('Error finding template match: $e', name: 'templates', error: e);
      log('Stack trace: $stack', name: 'templates');
      return null; // Graceful fallback to Gemini
    }
  }

  /// Fetch the template file from GitHub (new structure)
  Future<Map<String, dynamic>?> _fetchTemplateFile(String language) async {
    try {
      final cacheKey = 'template_file_$language';
      final cached = await _cache.get<Map<String, dynamic>>(cacheKey);
      if (cached != null) {
        debugPrint('[TEMPLATES] Archivo template $language obtenido de cache');
        return cached;
      }
      final url =
          '${TemplateConstants.baseUrl}/${TemplateConstants.templateFile(language)}';
      debugPrint('[TEMPLATES] Descargando archivo de: $url');
      final client = _httpClient ?? http.Client();
      final response = await client.get(Uri.parse(url));
      debugPrint('[TEMPLATES] Respuesta HTTP: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint(
            '[TEMPLATES] Archivo template $language descargado y parseado correctamente');
        await _cache.set(cacheKey, data, ttl: TemplateConstants.cacheDuration);
        return data;
      }
      debugPrint(
          '[TEMPLATES] Error HTTP al descargar template: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('[TEMPLATES] Error descargando archivo template: $e');
      return null;
    }
  }

  /// Find a matching template using weighted scoring system
  /// Returns the generated_habits array from the template, or null if no match
  /// This method provides better matching accuracy than the deprecated findMatch
  Future<List<Map<String, dynamic>>?> findMatchWithScoring(
    OnboardingProfile profile,
    String language,
  ) async {
    try {
      debugPrint(
          '[SCORING] Starting template matching for language: $language');

      // Convert profile to vector
      final userVector = UserProfileVector.fromProfile(profile);

      // Load templates from GitHub/cache
      final templateFile = await _fetchTemplateFile(language);
      if (templateFile == null || templateFile['templates'] == null) {
        debugPrint('[SCORING] No template file found for language: $language');
        return null;
      }

      final templates = templateFile['templates'] as List<dynamic>;
      debugPrint('[SCORING] Loaded ${templates.length} templates');

      // Score each template
      TemplateMatchScore? bestMatch;
      double bestScore = 0.0;

      for (final templateData in templates) {
        final patternId = templateData['pattern_id'] as String?;
        if (patternId == null) continue;

        try {
          final templateMetadata = TemplateMetadata.fromPatternId(patternId);
          final score =
              _scoringEngine.calculateScore(userVector, templateMetadata);

          _logScoreBreakdown(patternId, score);

          if (score.totalScore > bestScore) {
            bestScore = score.totalScore;
            bestMatch = score;
          }
        } catch (e) {
          debugPrint('[SCORING] Error scoring template $patternId: $e');
          continue;
        }
      }

      // Return best match if score >= threshold
      if (bestMatch != null &&
          bestScore >= TemplateScoringEngine.goodMatchThreshold) {
        debugPrint('[SCORING] Best match found: ${bestMatch.patternId}');
        debugPrint(
            '[SCORING] Final score: ${bestScore.toStringAsFixed(3)} (${bestMatch.confidence.name})');

        // Find and return the template habits
        final matchedTemplate =
            templates.cast<Map<String, dynamic>?>().firstWhere(
                  (t) => t?['pattern_id'] == bestMatch!.patternId,
                  orElse: () => null,
                );

        if (matchedTemplate != null && matchedTemplate['habits'] != null) {
          log('Template matched with scoring: ${bestMatch.patternId}, score: ${bestScore.toStringAsFixed(3)}',
              name: 'templates');

          // Cache the result
          final cacheKey =
              'template_scoring_${language}_${bestMatch.patternId}';
          await _cache.set(
            cacheKey,
            matchedTemplate,
            ttl: TemplateConstants.cacheDuration,
          );

          return (matchedTemplate['habits'] as List<dynamic>)
              .cast<Map<String, dynamic>>();
        }
      }

      debugPrint(
          '[SCORING] No match found with score >= ${TemplateScoringEngine.goodMatchThreshold} (best: ${bestScore.toStringAsFixed(3)})');
      return null; // Fallback to Gemini
    } catch (e, stack) {
      debugPrint('[SCORING] Error in scoring-based matching: $e');
      debugPrint('[SCORING] Stack: $stack');
      log('Error in scoring-based template matching: $e',
          name: 'templates', error: e);
      return null;
    }
  }

  /// Log score breakdown for debugging
  void _logScoreBreakdown(String patternId, TemplateMatchScore score) {
    debugPrint(
        '[SCORING] Pattern: $patternId, Score: ${score.totalScore.toStringAsFixed(3)}');
    score.dimensionScores.forEach((dimension, value) {
      final capitalizedDimension =
          dimension[0].toUpperCase() + dimension.substring(1);
      debugPrint(
          '[SCORING]   - $capitalizedDimension: ${value.toStringAsFixed(2)}');
    });
  }
}
