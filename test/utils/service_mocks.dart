import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mock for Gemini AI Service
class MockGeminiService extends Mock {
  /// Mock method for generating habits
  Future<List<Map<String, dynamic>>> generateHabits({
    required List<String> motivations,
    required List<String> challenges,
    required String experience,
  }) async {
    // Return realistic mock data
    return [
      {
        'name': 'Morning Prayer',
        'description': 'Start your day with prayer',
        'category': 'spiritual',
        'difficultyLevel': 2,
        'bibleVerse': 'Matthew 6:9-13',
      },
      {
        'name': 'Daily Bible Reading',
        'description': 'Read one chapter daily',
        'category': 'spiritual',
        'difficultyLevel': 2,
        'bibleVerse': 'Psalm 119:105',
      },
    ];
  }
}

/// Mock for Rate Limit Service
class MockRateLimitService extends Mock {
  Future<bool> checkLimit() async => true;
  Future<void> incrementUsage() async {}
  Future<int> getRemainingRequests() async => 8;
  Future<void> resetMonthly() async {}
}

/// Mock for ML Abandonment Predictor
class MockAbandonmentPredictor extends Mock {
  Future<double> predictAbandonmentRisk({
    required String habitId,
    required String userId,
    required Map<String, dynamic> habitData,
  }) async {
    // Return realistic risk score based on input
    final completionRate = habitData['completionRate'] as double? ?? 0.5;
    final streakDays = habitData['streakDays'] as int? ?? 0;

    // High completion rate and streak = low risk
    if (completionRate > 0.7 && streakDays > 7) {
      return 0.2; // Low risk
    }
    // Medium completion rate = medium risk
    if (completionRate > 0.4) {
      return 0.5; // Medium risk
    }
    // Low completion rate = high risk
    return 0.8; // High risk
  }

  Future<void> initialize() async {}
  bool get isInitialized => true;
}

/// Mock for SharedPreferences (commonly used in services)
class MockSharedPreferences extends Mock implements SharedPreferences {}

/// Helper to create mock SharedPreferences with preset values
MockSharedPreferences mockSharedPreferencesWithData(Map<String, dynamic> data) {
  final prefs = MockSharedPreferences();

  // Setup getters for common types
  data.forEach((key, value) {
    if (value is String) {
      when(() => prefs.getString(key)).thenReturn(value);
    } else if (value is int) {
      when(() => prefs.getInt(key)).thenReturn(value);
    } else if (value is bool) {
      when(() => prefs.getBool(key)).thenReturn(value);
    } else if (value is double) {
      when(() => prefs.getDouble(key)).thenReturn(value);
    } else if (value is List<String>) {
      when(() => prefs.getStringList(key)).thenReturn(value);
    }
  });

  // Setup setters to return true
  when(() => prefs.setString(any(), any())).thenAnswer((_) async => true);
  when(() => prefs.setInt(any(), any())).thenAnswer((_) async => true);
  when(() => prefs.setBool(any(), any())).thenAnswer((_) async => true);
  when(() => prefs.setDouble(any(), any())).thenAnswer((_) async => true);
  when(() => prefs.setStringList(any(), any())).thenAnswer((_) async => true);
  when(() => prefs.remove(any())).thenAnswer((_) async => true);
  when(() => prefs.clear()).thenAnswer((_) async => true);

  return prefs;
}

/// Mock Bible Database Service
class MockBibleDbService extends Mock {
  Future<Map<String, dynamic>?> getVerse({
    required String book,
    required int chapter,
    required int verse,
  }) async {
    return {
      'book': book,
      'chapter': chapter,
      'verse': verse,
      'text': 'For God so loved the world...',
    };
  }

  Future<List<Map<String, dynamic>>> searchVerses(String query) async {
    return [
      {
        'book': 'John',
        'chapter': 3,
        'verse': 16,
        'text': 'For God so loved the world...',
      }
    ];
  }
}
