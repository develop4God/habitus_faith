/// Constants for habit template system
class TemplateConstants {
  /// Base URL for fetching templates from GitHub (updated to new repo/structure)
  static const String baseUrl =
      'https://raw.githubusercontent.com/develop4God/Habits-json/refs/heads/main';

  /// Main template file per language (new structure)
  static String templateFile(String language) => 'templates-$language.json';

  /// Cache duration for templates
  static const Duration cacheDuration = Duration(hours: 24);

  /// Similarity threshold for fuzzy matching profiles
  static const double similarityThreshold = 0.75;

  /// Maximum number of templates to cache locally
  static const int maxCachedTemplates = 50;
}
