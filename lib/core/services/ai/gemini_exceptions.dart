/// Base exception for Gemini AI service errors
class GeminiException implements Exception {
  final String message;

  GeminiException(this.message);

  @override
  String toString() => 'GeminiException: $message';
}

/// Exception thrown when monthly rate limit is exceeded
class RateLimitExceededException extends GeminiException {
  RateLimitExceededException(super.message);

  @override
  String toString() => 'RateLimitExceededException: $message';
}

/// Exception thrown when API response cannot be parsed
class GeminiParseException extends GeminiException {
  final String rawResponse;

  GeminiParseException(super.message, this.rawResponse);

  @override
  String toString() =>
      'GeminiParseException: $message\nRaw response: $rawResponse';
}

/// Exception thrown when GEMINI_API_KEY is not configured
class ApiKeyMissingException extends GeminiException {
  ApiKeyMissingException([super.message = 'GEMINI_API_KEY not configured']);

  @override
  String toString() => 'ApiKeyMissingException: $message';
}

/// Exception thrown when user input fails validation
class InvalidInputException extends GeminiException {
  InvalidInputException(super.message);

  @override
  String toString() => 'InvalidInputException: $message';
}
