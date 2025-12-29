import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

/// Service to load pre-cached habit templates from assets
///
/// Templates are generated offline using Python scoring engine
/// and stored as JSON files named by their cache fingerprint.
///
/// This provides instant habit generation (~100ms) vs AI generation (~5-10s)
class HabitTemplateLoader {
  static final _logger = Logger();

  /// Load a template by its cache fingerprint
  ///
  /// Returns null if template doesn't exist (will fallback to AI)
  static Future<Map<String, dynamic>?> loadTemplate(String fingerprint) async {
    try {
      final path = 'assets/habit_templates_v2/$fingerprint.json';
      _logger.i('Loading template from: $path');

      final jsonString = await rootBundle.loadString(path);
      final template = json.decode(jsonString) as Map<String, dynamic>;

      _logger.i('✅ Template loaded successfully: ${template['template_id']}');
      return template;
    } on FlutterError catch (e) {
      _logger.w('Template not found for fingerprint: $fingerprint');
      _logger.d('Error: $e');
      return null;
    } catch (e) {
      _logger.e('Error loading template: $e');
      return null;
    }
  }

  /// Parse habits from a loaded template
  ///
  /// Returns a list of habit maps ready for consumption
  static List<Map<String, dynamic>> parseHabits(
    Map<String, dynamic> template,
  ) {
    final habitsJson = template['habits'] as List;
    return habitsJson.map((h) => h as Map<String, dynamic>).toList();
  }

  /// Get template metadata
  static Map<String, dynamic> getMetadata(Map<String, dynamic> template) {
    return {
      'template_id': template['template_id'],
      'version': template['version'],
      'fingerprint': template['fingerprint'],
      'generated_by': template['generated_by'],
    };
  }

  /// Get the profile that generated this template
  static Map<String, dynamic> getProfile(Map<String, dynamic> template) {
    return template['profile'] as Map<String, dynamic>;
  }

  /// Validate that a template has the expected structure
  static bool validateTemplate(Map<String, dynamic> template) {
    final requiredFields = ['template_id', 'fingerprint', 'version', 'profile', 'habits'];

    for (final field in requiredFields) {
      if (!template.containsKey(field)) {
        _logger.e('Template missing required field: $field');
        return false;
      }
    }

    final habits = template['habits'] as List?;
    if (habits == null || habits.isEmpty) {
      _logger.e('Template has no habits');
      return false;
    }

    if (habits.length < 3) {
      _logger.w('Template has fewer than 3 habits: ${habits.length}');
    }

    return true;
  }
}

