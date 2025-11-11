/// Constants for habit template system
class TemplateConstants {
  /// Base URL for fetching templates from GitHub
  static const String baseUrl =
      'https://raw.githubusercontent.com/develop4God/habitus_faith/main/habit_templates';

  /// Metadata index file name
  static const String metadataFile = 'metadata.json';

  /// Cache duration for templates
  static const Duration cacheDuration = Duration(hours: 24);

  /// Similarity threshold for fuzzy matching profiles
  static const double similarityThreshold = 0.75;

  /// Maximum number of templates to cache locally
  static const int maxCachedTemplates = 50;
}
