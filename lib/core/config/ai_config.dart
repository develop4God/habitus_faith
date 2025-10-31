/// Centralized configuration constants for AI services
/// All values reference Week 7-8 Roadmap specifications
class AiConfig {
  AiConfig._(); // Private constructor to prevent instantiation

  // ========== Gemini API Configuration ==========

  /// Gemini model name (Roadmap: "gemini-1.5-flash")
  static const String defaultModel = 'gemini-1.5-flash';

  /// API request timeout in seconds (Roadmap: <30 seconds)
  static const Duration requestTimeout = Duration(seconds: 30);

  /// Expected number of habits per generation (Roadmap: "EXACTAMENTE 3")
  static const int habitsPerGeneration = 3;

  // ========== Input Validation ==========

  /// Maximum characters for user input fields (Security hardening)
  static const int maxInputLength = 200;

  /// Blacklisted terms for prompt injection prevention
  static const List<String> blacklistedTerms = [
    'ignore',
    'previous',
    'system:',
    'prompt:',
    'instructions',
  ];

  // ========== Rate Limiting ==========

  /// Monthly request limit (Roadmap: "10 requests/month")
  static const int monthlyRequestLimit = 10;

  // ========== Caching ==========

  /// Cache time-to-live (Roadmap: "7 day expiry")
  static const Duration cacheTtl = Duration(days: 7);

  /// Target cache hit rate (Roadmap: ">80%")
  static const double targetCacheHitRate = 0.8;

  // ========== Habit Generation Constraints ==========

  /// Maximum estimated minutes per micro-habit (Roadmap: "5 minutos o menos")
  static const int maxHabitMinutes = 5;

  /// Minimum estimated minutes for a valid habit
  static const int minHabitMinutes = 1;

  // ========== Response Format ==========

  /// JSON response format identifier for Gemini prompts
  static const String responseFormat = 'JSON';

  /// Required fields in each habit object
  static const List<String> requiredHabitFields = [
    'action',
    'verse',
    'purpose',
  ];

  /// Optional fields in each habit object
  static const List<String> optionalHabitFields = [
    'verseText',
    'estimatedMinutes',
  ];
}
