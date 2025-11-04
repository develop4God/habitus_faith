// lib/core/models/devocional_model.dart

import 'package:flutter/material.dart';

/// Data model for a devotional entry.
///
/// Contains ID, verse, reflection, meditation points, a prayer, and date.
class Devocional {
  final String id;
  final String versiculo; // Bible verse reference
  final String reflexion; // Main reflection text
  final List<ParaMeditar> paraMeditar; // Points for meditation
  final String oracion; // Prayer
  final DateTime date;

  // Additional fields detected in the JSON
  final String? version; // Bible version
  final String? language; // Language code
  final List<String>? tags; // Tags for categorization

  Devocional({
    required this.id,
    required this.versiculo,
    required this.reflexion,
    required this.paraMeditar,
    required this.oracion,
    required this.date,
    this.version,
    this.language,
    this.tags,
  });

  /// Factory constructor to create a [Devocional] instance from JSON.
  ///
  /// Provides default values if any field is null in the JSON.
  factory Devocional.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    final String? dateString = json['date'] as String?;
    if (dateString != null && dateString.isNotEmpty) {
      try {
        parsedDate = DateTime.parse(dateString);
      } catch (e) {
        debugPrint(
            'Error parsing date: $dateString, using DateTime.now(). Error: $e');
        parsedDate = DateTime.now(); // Fallback to current date
      }
    } else {
      parsedDate = DateTime.now(); // Fallback if date is null or empty
    }

    String rawVersiculo = json['versiculo'] ?? '';

    return Devocional(
      id: json['id'] as String? ?? UniqueKey().hashCode.toString(),
      versiculo: rawVersiculo,
      reflexion: json['reflexion'] ?? '',
      paraMeditar: (json['para_meditar'] as List<dynamic>?)
              ?.map(
                  (item) => ParaMeditar.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      oracion: json['oracion'] ?? '',
      date: parsedDate,
      version: json['version'] as String?,
      language: json['language'] as String?,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((tag) => tag as String)
          .toList(),
    );
  }

  /// Converts the devotional to JSON for serialization (useful for saving favorites)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'versiculo': versiculo,
      'reflexion': reflexion,
      'para_meditar': paraMeditar.map((e) => e.toJson()).toList(),
      'oracion': oracion,
      'date': date
          .toIso8601String()
          .split('T')
          .first, // Save only the date (yyyy-MM-dd)
      'version': version,
      'language': language,
      'tags': tags,
    };
  }
}

/// Data model for "Para Meditar" (For Meditation) points.
class ParaMeditar {
  final String cita; // Bible reference/citation
  final String texto; // Meditation text

  ParaMeditar({
    required this.cita,
    required this.texto,
  });

  factory ParaMeditar.fromJson(Map<String, dynamic> json) {
    return ParaMeditar(
      cita: json['cita'] as String? ?? '',
      texto: json['texto'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cita': cita,
      'texto': texto,
    };
  }
}
