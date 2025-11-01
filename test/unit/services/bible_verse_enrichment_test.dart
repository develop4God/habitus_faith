import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/ai/gemini_service.dart';
import 'package:habitus_faith/features/habits/domain/models/micro_habit.dart';

void main() {
  group('Bible Verse Enrichment Tests - Numbered Books', () {
    late GeminiService service;

    setUp(() {
      service = GeminiService(
        apiKey: 'test_key',
        modelName: 'test_model',
        cache: MockCacheService(),
        rateLimit: MockRateLimitService(),
        bibleService: MockBibleDbService(),
      );
    });

    test('parseVerseReference handles "1 Juan" variations', () {
      final testCases = [
        '1 Juan 3:16',
        'I Juan 3:16',
        'primer juan 3:16',
        '1 john 3:16',
      ];

      for (final verseRef in testCases) {
        final result = service.parseVerseReference(verseRef);
        expect(result, isNotNull, reason: 'Failed to parse: $verseRef');
        expect(result!['book'], contains('1'),
            reason: 'Should identify as first book: $verseRef');
      }
    });

    test('parseVerseReference handles "2 Corintios" variations', () {
      final testCases = [
        '2 Corintios 5:17',
        'II Corintios 5:17',
        'segundo corintios 5:17',
        '2 Cor 5:17',
      ];

      for (final verseRef in testCases) {
        final result = service.parseVerseReference(verseRef);
        expect(result, isNotNull, reason: 'Failed to parse: $verseRef');
        expect(result!['book'], contains('2'),
            reason: 'Should identify as second book: $verseRef');
      }
    });

    test('parseVerseReference handles "3 Juan" variations', () {
      final testCases = [
        '3 Juan 1:4',
        'III Juan 1:4',
        'tercer juan 1:4',
      ];

      for (final verseRef in testCases) {
        final result = service.parseVerseReference(verseRef);
        expect(result, isNotNull, reason: 'Failed to parse: $verseRef');
        expect(result!['book'], contains('3'),
            reason: 'Should identify as third book: $verseRef');
      }
    });

    test('parseVerseReference handles "1 Samuel" variations', () {
      final testCases = [
        '1 Samuel 17:47',
        'I Samuel 17:47',
        'primer samuel 17:47',
        '1 Sam 17:47',
      ];

      for (final verseRef in testCases) {
        final result = service.parseVerseReference(verseRef);
        expect(result, isNotNull, reason: 'Failed to parse: $verseRef');
        expect(result!['book'], contains('1'),
            reason: 'Should identify as first book: $verseRef');
      }
    });

    test('parseVerseReference handles "1 Reyes" variations', () {
      final testCases = [
        '1 Reyes 3:9',
        'I Reyes 3:9',
        'primer reyes 3:9',
      ];

      for (final verseRef in testCases) {
        final result = service.parseVerseReference(verseRef);
        expect(result, isNotNull, reason: 'Failed to parse: $verseRef');
      }
    });

    test('parseVerseReference handles "1 Timoteo" variations', () {
      final testCases = [
        '1 Timoteo 4:12',
        'I Timoteo 4:12',
        'primer timoteo 4:12',
        '1 Tim 4:12',
      ];

      for (final verseRef in testCases) {
        final result = service.parseVerseReference(verseRef);
        expect(result, isNotNull, reason: 'Failed to parse: $verseRef');
      }
    });

    test('parseVerseReference handles "1 Pedro" variations', () {
      final testCases = [
        '1 Pedro 5:7',
        'I Pedro 5:7',
        'primer pedro 5:7',
        '1 Pe 5:7',
      ];

      for (final verseRef in testCases) {
        final result = service.parseVerseReference(verseRef);
        expect(result, isNotNull, reason: 'Failed to parse: $verseRef');
      }
    });

    test('parseVerseReference handles abbreviations correctly', () {
      final testCases = {
        'Gn 1:1': 'Génesis',
        'Ex 20:3': 'Éxodo',
        'Sal 23:1': 'Salmos',
        'Mt 5:3': 'Mateo',
        'Ro 8:28': 'Romanos',
        'Ap 21:4': 'Apocalipsis',
      };

      testCases.forEach((abbrev, fullName) {
        final result = service.parseVerseReference(abbrev);
        expect(result, isNotNull, reason: 'Failed to parse: $abbrev');
      });
    });

    test('enrichHabitsWithVerses handles numbered books', () async {
      final testHabits = [
        MicroHabit(
          id: '1',
          action: 'Test 1',
          verse: '1 Juan 4:19',
          purpose: 'Test purpose',
        ),
        MicroHabit(
          id: '2',
          action: 'Test 2',
          verse: '2 Corintios 5:17',
          purpose: 'Test purpose',
        ),
        MicroHabit(
          id: '3',
          action: 'Test 3',
          verse: '1 Timoteo 4:12',
          purpose: 'Test purpose',
        ),
      ];

      final enriched = await service.enrichHabitsWithVerses(testHabits);

      expect(enriched, hasLength(3));
      
      // All habits should have attempted verse text population
      // (may be null if mock service doesn't return text, but should not crash)
      for (final habit in enriched) {
        expect(habit.id, isNotEmpty);
        expect(habit.verse, isNotEmpty);
      }
    });

    test('enrichHabitsWithVerses gracefully handles invalid verse references',
        () async {
      final testHabits = [
        MicroHabit(
          id: '1',
          action: 'Test',
          verse: 'Invalid Book 99:99',
          purpose: 'Test purpose',
        ),
      ];

      // Should not throw, should return habit with null verseText
      final enriched = await service.enrichHabitsWithVerses(testHabits);

      expect(enriched, hasLength(1));
      expect(enriched[0].id, '1');
    });

    test('enrichHabitsWithVerses handles mixed valid and invalid references',
        () async {
      final testHabits = [
        MicroHabit(
          id: '1',
          action: 'Valid',
          verse: 'Salmos 23:1',
          purpose: 'Test',
        ),
        MicroHabit(
          id: '2',
          action: 'Invalid',
          verse: 'NotABook 1:1',
          purpose: 'Test',
        ),
        MicroHabit(
          id: '3',
          action: 'Valid numbered',
          verse: '1 Pedro 5:7',
          purpose: 'Test',
        ),
      ];

      final enriched = await service.enrichHabitsWithVerses(testHabits);

      expect(enriched, hasLength(3));
      expect(enriched[0].id, '1');
      expect(enriched[1].id, '2');
      expect(enriched[2].id, '3');
    });
  });
}

// Mock services for testing
class MockCacheService implements ICacheService {
  @override
  Future<T?> get<T>(String key) async => null;

  @override
  Future<void> set<T>(String key, T value, {Duration? ttl}) async {}

  @override
  Future<void> delete(String key) async {}

  @override
  Future<void> clear() async {}
}

class MockRateLimitService implements IRateLimitService {
  @override
  Future<bool> tryConsumeRequest() async => true;

  @override
  int getRemainingRequests() => 10;
}

class MockBibleDbService {
  Future<String?> getVerse(String book, int chapter, int verse) async {
    // Return mock verse text for testing
    return 'Mock verse text for $book $chapter:$verse';
  }
}

// Minimal interface definitions for testing
abstract class ICacheService {
  Future<T?> get<T>(String key);
  Future<void> set<T>(String key, T value, {Duration? ttl});
  Future<void> delete(String key);
  Future<void> clear();
}

abstract class IRateLimitService {
  Future<bool> tryConsumeRequest();
  int getRemainingRequests();
}
