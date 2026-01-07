import 'dart:convert';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/ml/telemetry_service.dart';
import 'package:habitus_faith/core/services/time/time.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';

void main() {
  group('MLTelemetryService', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MLTelemetryService telemetryService;
    late FixedClock fixedClock;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      fixedClock = FixedClock(DateTime(2024, 1, 15, 14, 30));
      telemetryService = MLTelemetryService(
        firestore: fakeFirestore,
        clock: fixedClock,
        appVersion: '1.1.0',
      );
    });

    group('logPrediction', () {
      test('logs all required features', () async {
        // Arrange
        final habit = Habit(
          id: 'habit1',
          userId: 'user1',
          name: 'Test Habit',
          category: HabitCategory.spiritual,
          createdAt: DateTime(2024, 1, 1),
          currentStreak: 5,
          lastCompletedAt: DateTime(2024, 1, 14, 10, 0),
          completionHistory: [
            DateTime(2024, 1, 14),
            DateTime(2024, 1, 13),
            DateTime(2024, 1, 12),
            DateTime(2024, 1, 11),
            DateTime(2024, 1, 10),
          ],
          reminderTime: '14:00',
        );

        // Act
        await telemetryService.logPrediction(
          habit: habit,
          predictedRisk: 0.35,
        );

        // Assert
        final snapshot = await fakeFirestore.collection('ml_telemetry').get();
        expect(snapshot.docs.length, equals(1));

        final data = snapshot.docs.first.data();
        expect(data, containsPair('feature_1_hourOfDay', 14));
        expect(data, containsPair('feature_2_dayOfWeek', 1)); // Monday
        expect(data, containsPair('feature_3_currentStreak', 5));
        expect(data, containsPair('feature_4_failuresLast7Days', 2));
        expect(data, containsPair('feature_5_hoursFromReminder', 0));
      });

      test('includes prediction risk and abandoned label', () async {
        // Arrange - habit abandoned (>7 days since last completion)
        final abandonedHabit = Habit(
          id: 'habit2',
          userId: 'user1',
          name: 'Abandoned Habit',
          category: HabitCategory.physical,
          createdAt: DateTime(2024, 1, 1),
          currentStreak: 0,
          lastCompletedAt: DateTime(2024, 1, 5), // 10 days ago
          completionHistory: [DateTime(2024, 1, 5)],
        );

        // Act
        await telemetryService.logPrediction(
          habit: abandonedHabit,
          predictedRisk: 0.85,
        );

        // Assert
        final snapshot = await fakeFirestore.collection('ml_telemetry').get();
        final data = snapshot.docs.first.data();

        expect(data['predicted_risk'], equals(0.85));
        expect(data['abandoned'], isTrue);
        expect(data['completed'], isFalse);
        expect(data['days_since_last_completion'], equals(10));
      });

      test('includes metadata (app_version, user_segment)', () async {
        // Arrange - veteran user
        final veteranHabit = Habit(
          id: 'habit3',
          userId: 'user1',
          name: 'Veteran Habit',
          category: HabitCategory.mental,
          createdAt: DateTime(2023, 12, 1), // 45 days old
          currentStreak: 30,
          lastCompletedAt: DateTime(2024, 1, 15),
          completionHistory: List.generate(
            60,
            (i) => DateTime(2024, 1, 15).subtract(Duration(days: i)),
          ),
        );

        // Act
        await telemetryService.logPrediction(
          habit: veteranHabit,
          predictedRisk: 0.15,
        );

        // Assert
        final snapshot = await fakeFirestore.collection('ml_telemetry').get();
        final data = snapshot.docs.first.data();

        expect(data['app_version'], equals('1.1.0'));
        expect(data['user_segment'], equals('veteran'));
        expect(data['habit_category'], equals('mental'));
        expect(data['habit_id'], equals('habit3'));
        expect(data['user_id'], equals('user1'));
      });

      test('correctly identifies new user segment', () async {
        // Arrange - new user (< 7 days old)
        final newHabit = Habit(
          id: 'habit4',
          userId: 'user1',
          name: 'New Habit',
          category: HabitCategory.spiritual,
          createdAt: DateTime(2024, 1, 12), // 3 days old
          currentStreak: 2,
          lastCompletedAt: DateTime(2024, 1, 15),
          completionHistory: [DateTime(2024, 1, 15), DateTime(2024, 1, 14)],
        );

        // Act
        await telemetryService.logPrediction(
          habit: newHabit,
          predictedRisk: 0.5,
        );

        // Assert
        final snapshot = await fakeFirestore.collection('ml_telemetry').get();
        final data = snapshot.docs.first.data();

        expect(data['user_segment'], equals('new'));
      });

      test('correctly identifies active user segment', () async {
        // Arrange - active user (between new and veteran)
        final activeHabit = Habit(
          id: 'habit5',
          userId: 'user1',
          name: 'Active Habit',
          category: HabitCategory.relational,
          createdAt: DateTime(2024, 1, 1), // 14 days old
          currentStreak: 10,
          lastCompletedAt: DateTime(2024, 1, 15),
          completionHistory: List.generate(
            12,
            (i) => DateTime(2024, 1, 15).subtract(Duration(days: i)),
          ),
        );

        // Act
        await telemetryService.logPrediction(
          habit: activeHabit,
          predictedRisk: 0.3,
        );

        // Assert
        final snapshot = await fakeFirestore.collection('ml_telemetry').get();
        final data = snapshot.docs.first.data();

        expect(data['user_segment'], equals('active'));
      });

      test('handles habit without reminder time', () async {
        // Arrange
        final habitNoReminder = Habit(
          id: 'habit6',
          userId: 'user1',
          name: 'No Reminder',
          category: HabitCategory.spiritual,
          createdAt: DateTime(2024, 1, 1),
          currentStreak: 3,
          lastCompletedAt: DateTime(2024, 1, 15),
          completionHistory: [DateTime(2024, 1, 15)],
          reminderTime: null, // No reminder
        );

        // Act
        await telemetryService.logPrediction(
          habit: habitNoReminder,
          predictedRisk: 0.4,
        );

        // Assert
        final snapshot = await fakeFirestore.collection('ml_telemetry').get();
        expect(snapshot.docs.length, equals(1));

        final data = snapshot.docs.first.data();
        expect(data['feature_5_hoursFromReminder'], equals(0)); // Default
      });

      test('handles habit never completed (no lastCompletedAt)', () async {
        // Arrange
        final neverCompletedHabit = Habit(
          id: 'habit7',
          userId: 'user1',
          name: 'Never Completed',
          category: HabitCategory.spiritual,
          createdAt: DateTime(2024, 1, 1),
          currentStreak: 0,
          lastCompletedAt: null,
          completionHistory: [],
        );

        // Act
        await telemetryService.logPrediction(
          habit: neverCompletedHabit,
          predictedRisk: 0.6,
        );

        // Assert
        final snapshot = await fakeFirestore.collection('ml_telemetry').get();
        final data = snapshot.docs.first.data();

        expect(data['abandoned'], isTrue); // 999 days > 7
        expect(data['days_since_last_completion'], equals(999));
      });
    });

    group('exportUserTelemetry', () {
      test('exports telemetry data for specific user', () async {
        // Arrange - create telemetry for multiple users
        final habit1 = Habit(
          id: 'h1',
          userId: 'user1',
          name: 'H1',
          category: HabitCategory.spiritual,
          createdAt: DateTime(2024, 1, 1),
          currentStreak: 5,
          completionHistory: [],
        );
        final habit2 = Habit(
          id: 'h2',
          userId: 'user2',
          name: 'H2',
          category: HabitCategory.physical,
          createdAt: DateTime(2024, 1, 1),
          currentStreak: 3,
          completionHistory: [],
        );

        await telemetryService.logPrediction(habit: habit1, predictedRisk: 0.3);
        await telemetryService.logPrediction(habit: habit2, predictedRisk: 0.7);
        await telemetryService.logPrediction(habit: habit1, predictedRisk: 0.2);

        // Act
        final user1Records = await telemetryService.exportUserTelemetry(
          userId: 'user1',
        );

        // Assert
        expect(user1Records.length, equals(2));
        expect(
          user1Records.every((r) => r['user_id'] == 'user1'),
          isTrue,
        );
      });

      test('respects limit parameter', () async {
        // Arrange
        final habit = Habit(
          id: 'h1',
          userId: 'user1',
          name: 'H1',
          category: HabitCategory.spiritual,
          createdAt: DateTime(2024, 1, 1),
          currentStreak: 5,
          completionHistory: [],
        );

        // Log 5 records
        for (int i = 0; i < 5; i++) {
          await telemetryService.logPrediction(
            habit: habit,
            predictedRisk: 0.1 * i,
          );
        }

        // Act
        final limitedRecords = await telemetryService.exportUserTelemetry(
          userId: 'user1',
          limit: 3,
        );

        // Assert
        expect(limitedRecords.length, equals(3));
      });
    });

    group('exportAllTelemetryAsJson', () {
      test('exports data in training format', () async {
        // Arrange
        final habit = Habit(
          id: 'h1',
          userId: 'user1',
          name: 'Test',
          category: HabitCategory.spiritual,
          createdAt: DateTime(2024, 1, 1),
          currentStreak: 5,
          lastCompletedAt: DateTime(2024, 1, 15),
          completionHistory: [DateTime(2024, 1, 15)],
          reminderTime: '14:00',
        );

        await telemetryService.logPrediction(habit: habit, predictedRisk: 0.3);

        // Act
        final json = await telemetryService.exportAllTelemetryAsJson();

        // Assert
        expect(json, isNotEmpty);
        expect(json, contains('hourOfDay'));
        expect(json, contains('dayOfWeek'));
        expect(json, contains('streakAtTime'));
        expect(json, contains('failuresLast7Days'));
        expect(json, contains('hoursFromReminder'));
        expect(json, contains('abandoned'));
      });

      test('respects limit parameter', () async {
        // Arrange
        final habit = Habit(
          id: 'h1',
          userId: 'user1',
          name: 'Test',
          category: HabitCategory.spiritual,
          createdAt: DateTime(2024, 1, 1),
          currentStreak: 5,
          completionHistory: [],
        );

        for (int i = 0; i < 5; i++) {
          await telemetryService.logPrediction(
            habit: habit,
            predictedRisk: 0.2,
          );
        }

        // Act
        final json = await telemetryService.exportAllTelemetryAsJson(limit: 2);

        // Assert - should have exactly 2 records in JSON array
        final decoded = jsonDecode(json) as List;
        expect(decoded.length, equals(2));
      });
    });

    group('exportAllTelemetryAsCsv', () {
      test('exports data in CSV format matching training data', () async {
        // Arrange
        final habit = Habit(
          id: 'h1',
          userId: 'user1',
          name: 'Test',
          category: HabitCategory.spiritual,
          createdAt: DateTime(2024, 1, 1),
          currentStreak: 5,
          lastCompletedAt: DateTime(2024, 1, 14),
          completionHistory: List.generate(
            5,
            (i) => DateTime(2024, 1, 14).subtract(Duration(days: i)),
          ),
          reminderTime: '14:00',
        );

        await telemetryService.logPrediction(habit: habit, predictedRisk: 0.3);

        // Act
        final csv = await telemetryService.exportAllTelemetryAsCsv();

        // Assert
        expect(csv, isNotEmpty);
        final lines = csv.split('\n');
        expect(lines.length, equals(2)); // Header + 1 data row
        expect(
          lines[0],
          equals(
            'hourOfDay,dayOfWeek,streakAtTime,failuresLast7Days,hoursFromReminder,abandoned',
          ),
        );
        expect(lines[1], contains('14,')); // hourOfDay
        expect(lines[1], contains(',1,')); // dayOfWeek (Monday)
        expect(lines[1], contains(',5,')); // streak
      });

      test('formats abandoned as 0/1 integer', () async {
        // Arrange - abandoned habit
        final abandonedHabit = Habit(
          id: 'h1',
          userId: 'user1',
          name: 'Test',
          category: HabitCategory.spiritual,
          createdAt: DateTime(2024, 1, 1),
          currentStreak: 0,
          lastCompletedAt: DateTime(2024, 1, 5), // 10 days ago
          completionHistory: [],
        );

        await telemetryService.logPrediction(
          habit: abandonedHabit,
          predictedRisk: 0.9,
        );

        // Act
        final csv = await telemetryService.exportAllTelemetryAsCsv();

        // Assert
        final lines = csv.split('\n');
        expect(lines[1].endsWith(',1'), isTrue); // abandoned = 1
      });
    });

    group('getTelemetryStats', () {
      test('returns statistics about collected data', () async {
        // Arrange
        final activeHabit = Habit(
          id: 'h1',
          userId: 'user1',
          name: 'Active',
          category: HabitCategory.spiritual,
          createdAt: DateTime(2024, 1, 1),
          currentStreak: 5,
          lastCompletedAt: DateTime(2024, 1, 15),
          completionHistory: [DateTime(2024, 1, 15)],
        );

        final abandonedHabit = Habit(
          id: 'h2',
          userId: 'user1',
          name: 'Abandoned',
          category: HabitCategory.physical,
          createdAt: DateTime(2024, 1, 1),
          currentStreak: 0,
          lastCompletedAt: DateTime(2024, 1, 5), // 10 days ago
          completionHistory: [],
        );

        // Log 3 active, 2 abandoned
        await telemetryService.logPrediction(
          habit: activeHabit,
          predictedRisk: 0.2,
        );
        await telemetryService.logPrediction(
          habit: activeHabit,
          predictedRisk: 0.3,
        );
        await telemetryService.logPrediction(
          habit: activeHabit,
          predictedRisk: 0.1,
        );
        await telemetryService.logPrediction(
          habit: abandonedHabit,
          predictedRisk: 0.8,
        );
        await telemetryService.logPrediction(
          habit: abandonedHabit,
          predictedRisk: 0.9,
        );

        // Act
        final stats = await telemetryService.getTelemetryStats();

        // Assert
        expect(stats['total_records'], equals(5));
        expect(stats['completed_count'], equals(3));
        expect(stats['abandoned_count'], equals(2));
        expect(stats['abandoned_rate'], closeTo(0.4, 0.01));
      });

      test('returns zero stats when no data', () async {
        // Act
        final stats = await telemetryService.getTelemetryStats();

        // Assert
        expect(stats['total_records'], equals(0));
        expect(stats['completed_count'], equals(0));
        expect(stats['abandoned_count'], equals(0));
      });
    });

    group('Error Handling', () {
      test('handles null Firestore gracefully', () async {
        // Arrange
        final noFirestoreService = MLTelemetryService(
          firestore: null,
          clock: fixedClock,
        );

        final habit = Habit(
          id: 'h1',
          userId: 'user1',
          name: 'Test',
          category: HabitCategory.spiritual,
          createdAt: DateTime(2024, 1, 1),
          currentStreak: 5,
          completionHistory: [],
        );

        // Act & Assert - should not throw
        expect(
          () => noFirestoreService.logPrediction(
            habit: habit,
            predictedRisk: 0.3,
          ),
          returnsNormally,
        );
      });
    });
  });
}
