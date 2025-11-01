import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/core/services/cache/cache_service.dart';
import 'package:habitus_faith/features/habits/domain/models/micro_habit.dart';

void main() {
  group('CacheService', () {
    late SharedPreferences prefs;
    late CacheService cache;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      cache = CacheService(prefs);
    });

    test('stores and retrieves List<MicroHabit>', () async {
      final habits = [
        MicroHabit(
          id: '1',
          action: 'Orar 3min al despertar',
          verse: 'Salmos 5:3',
          verseText: 'Oh Jehová, de mañana oirás mi voz',
          purpose: 'Comenzar el día reconociendo a Dios',
          estimatedMinutes: 3,
        ),
      ];

      await cache.set('test_key', habits);
      final retrieved = await cache.get<List<MicroHabit>>('test_key');

      expect(retrieved, isNotNull);
      expect(retrieved!.length, equals(1));
      expect(retrieved[0].action, equals('Orar 3min al despertar'));
    });

    test('returns null for non-existent key', () async {
      final result = await cache.get<List<MicroHabit>>('missing_key');
      expect(result, isNull);
    });

    test('deletes expired cache entries', () async {
      final habits = [
        MicroHabit(
          id: '1',
          action: 'Test action',
          verse: 'Test 1:1',
          purpose: 'Test purpose',
        ),
      ];

      // Set cache with 1-second TTL
      await cache.set('test_key', habits, ttl: const Duration(seconds: 1));

      // Should exist immediately
      expect(await cache.get<List<MicroHabit>>('test_key'), isNotNull);

      // Wait for expiry
      await Future.delayed(const Duration(seconds: 2));

      // Should be null after expiry
      expect(await cache.get<List<MicroHabit>>('test_key'), isNull);
    });

    test('clear removes all cache entries', () async {
      final habits = [
        MicroHabit(
          id: '1',
          action: 'Test',
          verse: 'Test 1:1',
          purpose: 'Test',
        ),
      ];

      await cache.set('key1', habits);
      await cache.set('key2', habits);

      await cache.clear();

      expect(await cache.get<List<MicroHabit>>('key1'), isNull);
      expect(await cache.get<List<MicroHabit>>('key2'), isNull);
    });

    test('delete removes specific key', () async {
      final habits = [
        MicroHabit(
          id: '1',
          action: 'Test',
          verse: 'Test 1:1',
          purpose: 'Test',
        ),
      ];

      await cache.set('key1', habits);
      await cache.set('key2', habits);

      await cache.delete('key1');

      expect(await cache.get<List<MicroHabit>>('key1'), isNull);
      expect(await cache.get<List<MicroHabit>>('key2'), isNotNull);
    });
  });
}
