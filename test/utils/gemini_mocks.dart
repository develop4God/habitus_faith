import 'package:mocktail/mocktail.dart';
import 'package:habitus_faith/core/services/ai/rate_limit_service.dart';
import 'package:habitus_faith/core/services/cache/cache_service.dart';
import 'package:habitus_faith/bible_reader_core/src/bible_db_service.dart';

/// Mock for RateLimitService
class MockRateLimitService extends Mock implements IRateLimitService {}

/// Mock for CacheService
class MockCacheService extends Mock implements ICacheService {}

/// Mock for BibleDbService
class MockBibleDbService extends Mock implements BibleDbService {}

/// Helper to create a valid Gemini API response
Map<String, dynamic> createValidGeminiResponse({
  int habitCount = 5,
  String language = 'es',
}) {
  final habits = List.generate(habitCount, (index) {
    return {
      'action': 'Test habit action ${index + 1}',
      'verse': 'Matthew ${index + 1}:${index + 1}',
      'verseText': 'Test verse text ${index + 1}',
      'purpose': 'Test purpose ${index + 1}',
      'estimatedMinutes': 5,
    };
  });

  return {'habits': habits};
}

/// Helper to create malformed Gemini responses for testing error handling
String createMalformedResponse(String type) {
  switch (type) {
    case 'empty':
      return '';
    case 'invalid_json':
      return 'This is not valid JSON';
    case 'not_array':
      return '{"habits": "not an array"}';
    case 'missing_fields':
      return '[{"action": "Only action field"}]';
    case 'wrong_count':
      return '[{"action": "Only one habit", "verse": "John 3:16", "verseText": "...", "purpose": "...", "estimatedMinutes": 5}]';
    default:
      return '{}';
  }
}
