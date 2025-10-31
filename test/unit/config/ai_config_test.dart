import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/config/ai_config.dart';

void main() {
  group('AiConfig Constants', () {
    test('Gemini API configuration matches roadmap', () {
      expect(AiConfig.defaultModel, equals('gemini-1.5-flash'));
      expect(AiConfig.requestTimeout, equals(const Duration(seconds: 30)));
      expect(AiConfig.habitsPerGeneration, equals(3));
    });

    test('Rate limiting matches roadmap (10 requests/month)', () {
      expect(AiConfig.monthlyRequestLimit, equals(10));
    });

    test('Cache configuration matches roadmap (7 days)', () {
      expect(AiConfig.cacheTtl, equals(const Duration(days: 7)));
      expect(AiConfig.targetCacheHitRate, equals(0.8)); // >80%
    });

    test('Habit constraints match roadmap (≤5 minutes)', () {
      expect(AiConfig.maxHabitMinutes, equals(5));
      expect(AiConfig.minHabitMinutes, greaterThan(0));
    });

    test('Input validation constants are configured', () {
      expect(AiConfig.maxInputLength, equals(200));
      expect(AiConfig.blacklistedTerms.length, greaterThan(0));
      expect(AiConfig.blacklistedTerms, contains('ignore'));
      expect(AiConfig.blacklistedTerms, contains('previous'));
      expect(AiConfig.blacklistedTerms, contains('system:'));
      expect(AiConfig.blacklistedTerms, contains('prompt:'));
      expect(AiConfig.blacklistedTerms, contains('instructions'));
    });

    test('Required habit fields are defined', () {
      expect(AiConfig.requiredHabitFields, hasLength(3));
      expect(AiConfig.requiredHabitFields, contains('action'));
      expect(AiConfig.requiredHabitFields, contains('verse'));
      expect(AiConfig.requiredHabitFields, contains('purpose'));
    });

    test('Optional habit fields are defined', () {
      expect(AiConfig.optionalHabitFields, contains('verseText'));
      expect(AiConfig.optionalHabitFields, contains('estimatedMinutes'));
    });

    test('Response format is JSON', () {
      expect(AiConfig.responseFormat, equals('JSON'));
    });

    test('All numeric constants are positive', () {
      expect(AiConfig.requestTimeout.inSeconds, greaterThan(0));
      expect(AiConfig.habitsPerGeneration, greaterThan(0));
      expect(AiConfig.maxInputLength, greaterThan(0));
      expect(AiConfig.monthlyRequestLimit, greaterThan(0));
      expect(AiConfig.cacheTtl.inDays, greaterThan(0));
      expect(AiConfig.maxHabitMinutes, greaterThan(0));
      expect(AiConfig.minHabitMinutes, greaterThan(0));
    });

    test('Min/max habit minutes are logical', () {
      expect(AiConfig.minHabitMinutes, lessThan(AiConfig.maxHabitMinutes));
    });
  });
}
