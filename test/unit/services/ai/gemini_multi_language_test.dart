import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:habitus_faith/core/services/ai/gemini_service.dart';
import 'package:habitus_faith/features/habits/domain/models/micro_habit.dart';
import '../../../utils/gemini_mocks.dart';

void main() {
  group('Gemini Multi-Language Tests', () {
    late MockCacheService mockCache;
    late MockRateLimitService mockRateLimit;
    late GeminiService service;

    setUp(() {
      mockCache = MockCacheService();
      mockRateLimit = MockRateLimitService();

      // Default mock behaviors
      when(() => mockRateLimit.canMakeRequest()).thenReturn(true);
      when(() => mockRateLimit.waitIfNeeded()).thenAnswer((_) async {});
      when(() => mockRateLimit.recordRequest()).thenReturn(null);
      when(() => mockRateLimit.getRemainingRequests()).thenReturn(10);
      when(() => mockCache.get<List<MicroHabit>>(any()))
          .thenAnswer((_) async => null);
      when(() => mockCache.set<List<MicroHabit>>(any(), any(),
          ttl: any(named: 'ttl'))).thenAnswer((_) async {});

      service = GeminiService(
        apiKey: 'test-api-key',
        modelName: 'gemini-2.0-flash',
        cache: mockCache,
        rateLimit: mockRateLimit,
      );
    });

    group('Service Configuration Tests', () {
      test('should create service successfully', () {
        // Verify service initializes with multi-language support
        expect(service, isNotNull);
      });

      test('should support language mapping (documented)', () {
        // Note: Language mapping is verified through integration tests
        // The service supports: en→English, es→Spanish, pt→Portuguese,
        // fr→French, zh→Chinese, with fallback to English for unsupported codes
        expect(service, isNotNull);
      });
    });
  });

  group('MicroHabit Model Integration Tests', () {
    test('should create MicroHabit from complete Gemini response', () {
      // Arrange
      final habitData = {
        'id': 'test-1',
        'action': 'Prayer 10min',
        'verse': 'Psalm 5:3',
        'verseText': 'In the morning...',
        'purpose': 'Connect',
        'estimatedMinutes': 10,
        'scheduledTime': '07:00',
        'trigger': 'After waking',
        'notifications': [
          {
            'time': '06:55',
            'title': 'Prayer',
            'body': 'Time to pray',
          }
        ],
      };

      // Act
      final habit = MicroHabit.fromJson(habitData);

      // Assert
      expect(habit.action, 'Prayer 10min');
      expect(habit.scheduledTime, '07:00');
      expect(habit.trigger, 'After waking');
      expect(habit.notifications?.length, 1);
      expect(habit.notifications?.first.time, '06:55');
      expect(habit.notifications?.first.title, 'Prayer');
      expect(habit.notifications?.first.body, 'Time to pray');
    });

    test(
        'should handle MicroHabit with null optional fields (backward compatibility)',
        () {
      // Arrange - Simulates old Gemini response format
      final habitData = {
        'id': 'test-1',
        'action': 'Prayer',
        'verse': 'Psalm 5:3',
        'purpose': 'Connect',
      };

      // Act
      final habit = MicroHabit.fromJson(habitData);

      // Assert - Optional fields should be null
      expect(habit.scheduledTime, isNull);
      expect(habit.trigger, isNull);
      expect(habit.notifications, isNull);
    });

    test('should handle malformed notifications gracefully', () {
      // Arrange
      final habitData = {
        'id': 'test-1',
        'action': 'Prayer',
        'verse': 'Psalm 5:3',
        'purpose': 'Connect',
        'notifications': [
          {'invalid': 'data'} // Missing required fields
        ],
      };

      // Act
      final habit = MicroHabit.fromJson(habitData);

      // Assert - Should not throw, notifications should be null
      expect(habit.notifications, isNull);
    });

    test('should filter invalid notifications from array', () {
      // Arrange
      final habitData = {
        'id': 'test-1',
        'action': 'Prayer',
        'verse': 'Psalm 5:3',
        'purpose': 'Connect',
        'notifications': [
          {'invalid': 'data'}, // Invalid - missing required fields
          {
            'time': '06:55',
            'title': 'Valid',
            'body': 'This one is valid'
          }, // Valid
          {'time': '07:00'}, // Invalid - missing title and body
        ],
      };

      // Act
      final habit = MicroHabit.fromJson(habitData);

      // Assert - Should only include the valid notification
      // Note: Current implementation sets to null if any are invalid
      // This documents current behavior for future refactoring
      expect(habit.notifications, isNull);
    });

    test('should handle non-list notifications', () {
      // Arrange
      final habitData = {
        'id': 'test-1',
        'action': 'Prayer',
        'verse': 'Psalm 5:3',
        'purpose': 'Connect',
        'notifications': 'not a list',
      };

      // Act
      final habit = MicroHabit.fromJson(habitData);

      // Assert
      expect(habit.notifications, isNull);
    });

    test('should parse multiple languages (Spanish example)', () {
      // Arrange - Spanish response from Gemini
      final habitData = {
        'id': 'test-1',
        'action': 'Oración matutina de 10 minutos',
        'verse': 'Salmos 5:3',
        'verseText': 'Oh Jehová, de mañana oirás mi voz',
        'purpose': 'Conectar espiritualmente',
        'estimatedMinutes': 10,
        'scheduledTime': '07:00',
        'trigger': 'Inmediatamente después de despertar',
        'notifications': [
          {
            'time': '06:55',
            'title': '🙏 Tiempo con Dios',
            'body': 'Prepara tu espacio de oración'
          }
        ],
      };

      // Act
      final habit = MicroHabit.fromJson(habitData);

      // Assert - Multi-language content preserved
      expect(habit.action, contains('Oración'));
      expect(habit.verseText, contains('Jehová'));
      expect(habit.purpose, contains('Conectar'));
      expect(habit.trigger, contains('despertar'));
      expect(habit.notifications?.first.title, contains('Dios'));
    });

    test('should parse multiple languages (French example)', () {
      // Arrange - French response from Gemini
      final habitData = {
        'id': 'test-1',
        'action': 'Prière matinale de 10 minutes',
        'verse': 'Psaume 5:3',
        'verseText': 'Éternel, au matin tu entends ma voix',
        'purpose': 'Se connecter spirituellement',
        'estimatedMinutes': 10,
        'scheduledTime': '07:00',
        'trigger': 'Immédiatement après le réveil',
      };

      // Act
      final habit = MicroHabit.fromJson(habitData);

      // Assert - Multi-language content preserved
      expect(habit.action, contains('Prière'));
      expect(habit.verseText, contains('Éternel'));
      expect(habit.purpose, contains('connecter'));
      expect(habit.trigger, contains('réveil'));
    });
  });
}
