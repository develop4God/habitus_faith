import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration loader for secure API key management
/// Supports both .env files and --dart-define overrides
class EnvConfig {
  /// Load environment variables from .env file
  /// Should be called in main() before runApp()
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      // .env file not found - will fall back to dart-define
      // This is acceptable for CI/CD environments
    }
  }

  /// Get Gemini API key from environment
  /// Checks .env file first, then --dart-define override
  /// Throws ApiKeyMissingException if not configured or invalid
  static String get geminiApiKey {
    final key = dotenv.env['GEMINI_API_KEY'] ??
        const String.fromEnvironment('GEMINI_API_KEY');

    if (key.isEmpty) {
      throw ApiKeyMissingException(
          'GEMINI_API_KEY not found. Add to .env or use --dart-define');
    }

    // Gemini keys typically start with "AIza"
    if (!key.startsWith('AIza')) {
      throw ApiKeyMissingException('Invalid GEMINI_API_KEY format');
    }

    return key;
  }

  /// Get Gemini model name from environment
  /// Defaults to gemini-1.5-flash if not specified
  static String get geminiModel =>
      dotenv.env['GEMINI_MODEL'] ??
      const String.fromEnvironment('GEMINI_MODEL',
          defaultValue: 'gemini-1.5-flash');
}

/// Exception thrown when GEMINI_API_KEY is not configured
class ApiKeyMissingException implements Exception {
  final String message;

  ApiKeyMissingException([
    this.message = 'GEMINI_API_KEY not configured. '
        'Add it to .env file or use --dart-define=GEMINI_API_KEY=your_key',
  ]);

  @override
  String toString() => 'ApiKeyMissingException: $message';
}
