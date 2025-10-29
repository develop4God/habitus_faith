import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/ml/github_ml_storage.dart';
import 'package:habitus_faith/features/habits/domain/models/completion_record.dart';

void main() {
  group('GitHubMLStorage', () {
    test('saves record without throwing even without token', () async {
      final storage = GitHubMLStorage();
      final record = CompletionRecord(
        habitId: 'test_habit',
        completedAt: DateTime.now(),
        hourOfDay: 10,
        dayOfWeek: 3,
        streakAtTime: 5,
        failuresLast7Days: 1,
        hoursFromReminder: 2,
        completed: true,
      );
      
      // Should not throw even without token (graceful degradation)
      await expectLater(
        storage.saveRecord(record),
        completes,
      );
    });

    test('handles null values gracefully', () async {
      final storage = GitHubMLStorage();
      final record = CompletionRecord(
        habitId: 'test_habit_2',
        completedAt: DateTime.now(),
        hourOfDay: 0,
        dayOfWeek: 1,
        streakAtTime: 0,
        failuresLast7Days: 0,
        hoursFromReminder: 0,
        completed: false,
      );
      
      await expectLater(
        storage.saveRecord(record),
        completes,
      );
    });

    test('handles long habit IDs gracefully', () async {
      final storage = GitHubMLStorage();
      final record = CompletionRecord(
        habitId: 'very_long_habit_id_that_exceeds_normal_length_1234567890',
        completedAt: DateTime.now(),
        hourOfDay: 23,
        dayOfWeek: 7,
        streakAtTime: 100,
        failuresLast7Days: 7,
        hoursFromReminder: 24,
        completed: true,
      );
      
      await expectLater(
        storage.saveRecord(record),
        completes,
      );
    });
  });
}
