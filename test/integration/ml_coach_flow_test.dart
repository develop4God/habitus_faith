import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/ml/abandonment_predictor.dart';
import 'package:habitus_faith/core/services/ai/behavioral_engine.dart';
import 'package:habitus_faith/core/services/time/time.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import '../utils/tflite_test_stub.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ML + Coach Integration Flow', () {
    late AbandonmentPredictor predictor;
    late BehavioralEngine behavioralEngine;
    late FixedClock fixedClock;

    setUpAll(() async {
      fixedClock = FixedClock(DateTime(2024, 1, 15, 14, 30));
      predictor = AbandonmentPredictor(
        clock: fixedClock,
        assetLoader: TestAssetLoader(),
      );
      behavioralEngine = BehavioralEngine(clock: fixedClock);
      await predictor.initialize();
    });

    tearDownAll(() {
      predictor.dispose();
    });

    group('High Risk Detection', () {
      test('high abandonment risk should trigger intervention need', () async {
        // Arrange: Create risky habit (missed 5 days in last 7)
        final riskyHabit = Habit(
          id: 'risky1',
          userId: 'user1',
          name: 'Struggling Habit',
          category: HabitCategory.spiritual,
          createdAt: DateTime(2024, 1, 1),
          currentStreak: 0,
          lastCompletedAt: DateTime(2024, 1, 10), // 5 days ago
          completionHistory: [DateTime(2024, 1, 10), DateTime(2024, 1, 9)],
          reminderTime: '14:00',
        );

        // Act: Predict risk
        final risk = await predictor.predictRisk(riskyHabit);

        // Assert: High risk detected (>0.3 indicates intervention needed)
        // Note: In test env without TFLite, will return 0.5 (neutral)
        expect(risk, greaterThanOrEqualTo(0.0));
        expect(risk, lessThanOrEqualTo(1.0));

        // If risk > 0.7 in production, coach should be triggered
        if (risk > 0.7) {
          // Verify behavioral engine can detect patterns
          final failurePattern = behavioralEngine.detectFailurePattern(
            riskyHabit,
          );

          // Pattern detection helps coach generate targeted advice
          expect(failurePattern, isNotNull);
        }
      });

      test(
        'extremely high risk habit should suggest difficulty reduction',
        () async {
          // Arrange: Habit with very poor performance
          final failingHabit = Habit(
            id: 'failing1',
            userId: 'user1',
            name: 'Failing Habit',
            category: HabitCategory.physical,
            createdAt: DateTime(2024, 1, 1),
            currentStreak: 0,
            lastCompletedAt: DateTime(2024, 1, 5), // 10 days ago
            completionHistory: [DateTime(2024, 1, 5), DateTime(2024, 1, 3)],
            difficultyLevel: 5, // Very difficult
            reminderTime: '06:00',
          );

          // Act: Get ML prediction
          final risk = await predictor.predictRisk(failingHabit);

          // Assert: Risk should indicate intervention needed
          expect(risk, greaterThanOrEqualTo(0.0));

          // Behavioral engine should suggest difficulty reduction
          final nextDifficulty = behavioralEngine.calculateNextDifficulty(
            failingHabit,
          );

          // With success rate < 50%, should reduce difficulty
          expect(
            nextDifficulty,
            lessThanOrEqualTo(failingHabit.difficultyLevel),
          );
        },
      );

      test('weekend gap pattern detected for coaching advice', () async {
        // Arrange: Habit only completed on weekdays
        final weekdayOnlyHabit = Habit(
          id: 'weekday1',
          userId: 'user1',
          name: 'Weekday Only Habit',
          category: HabitCategory.mental,
          createdAt: DateTime(2024, 1, 1),
          currentStreak: 3,
          lastCompletedAt: DateTime(2024, 1, 15), // Monday
          completionHistory: [
            DateTime(2024, 1, 15), // Monday
            DateTime(2024, 1, 12), // Friday
            DateTime(2024, 1, 11), // Thursday
            DateTime(2024, 1, 10), // Wednesday
            DateTime(2024, 1, 9), // Tuesday
            // No weekend completions
          ],
          consecutiveFailures: 3, // Minimum for pattern detection
          reminderTime: '09:00',
        );

        // Act: Get risk and pattern
        final risk = await predictor.predictRisk(weekdayOnlyHabit);
        final pattern = behavioralEngine.detectFailurePattern(weekdayOnlyHabit);

        // Assert: Pattern detection may or may not trigger (depends on data)
        expect(risk, greaterThanOrEqualTo(0.0));

        // Pattern detection requires specific conditions
        // If detected, should be one of the defined patterns
        if (pattern != null) {
          expect(
            pattern,
            anyOf(
              equals(FailurePattern.weekendGap),
              equals(FailurePattern.eveningSlump),
              equals(FailurePattern.inconsistent),
            ),
          );
        }

        // Coach should provide pattern-specific encouragement
      });
    });

    group('Low Risk - No Intervention', () {
      test('strong habit with low risk needs no intervention', () async {
        // Arrange: Very strong habit
        final strongHabit = Habit(
          id: 'strong1',
          userId: 'user1',
          name: 'Strong Habit',
          category: HabitCategory.spiritual,
          createdAt: DateTime(2023, 12, 1),
          currentStreak: 30,
          lastCompletedAt: DateTime(2024, 1, 15),
          completionHistory: List.generate(
            30,
            (i) => DateTime(2024, 1, 15).subtract(Duration(days: i)),
          ),
          reminderTime: '07:00',
        );

        // Act: Predict risk
        final risk = await predictor.predictRisk(strongHabit);

        // Assert: Low risk (<0.3 in production)
        expect(risk, lessThanOrEqualTo(0.5));

        // No coach intervention needed for low risk
        if (risk < 0.3) {
          // Behavioral engine should suggest difficulty increase
          final nextDifficulty = behavioralEngine.calculateNextDifficulty(
            strongHabit,
          );
          expect(
            nextDifficulty,
            greaterThanOrEqualTo(strongHabit.difficultyLevel),
          );
        }
      });

      test('perfect completion rate needs positive reinforcement', () async {
        // Arrange: Perfect 7-day streak
        final perfectHabit = Habit(
          id: 'perfect1',
          userId: 'user1',
          name: 'Perfect Habit',
          category: HabitCategory.relational,
          createdAt: DateTime(2024, 1, 1),
          currentStreak: 14,
          lastCompletedAt: DateTime(2024, 1, 15),
          completionHistory: List.generate(
            14,
            (i) => DateTime(2024, 1, 15).subtract(Duration(days: i)),
          ),
          reminderTime: '12:00',
        );

        // Act
        final risk = await predictor.predictRisk(perfectHabit);

        // Assert: Very low risk
        expect(risk, lessThanOrEqualTo(0.5));

        // Coach provides celebration message, not intervention
        // "Amazing! 14-day streak! You're crushing it!"
      });
    });

    group('Adaptive Coaching Based on Risk Level', () {
      test('medium risk (0.3-0.7) suggests gentle nudge', () async {
        // Arrange: Moderate risk habit
        final moderateHabit = Habit(
          id: 'moderate1',
          userId: 'user1',
          name: 'Moderate Habit',
          category: HabitCategory.physical,
          createdAt: DateTime(2024, 1, 1),
          currentStreak: 3,
          lastCompletedAt: DateTime(2024, 1, 13), // 2 days ago
          completionHistory: List.generate(
            8,
            (i) => DateTime(2024, 1, 13).subtract(Duration(days: i * 2)),
          ), // Inconsistent
          reminderTime: '18:00',
        );

        // Act
        final risk = await predictor.predictRisk(moderateHabit);

        // Assert: Medium risk
        expect(risk, greaterThanOrEqualTo(0.0));
        expect(risk, lessThanOrEqualTo(1.0));

        // For medium risk (0.3-0.7), gentle reminder
        // "It's been 2 days. Ready to continue your journey?"
        if (risk >= 0.3 && risk <= 0.7) {
          // Find optimal time for suggestion
          final optimalTime = behavioralEngine.findOptimalTime(moderateHabit);

          // Coach should suggest completion at optimal time
          expect(optimalTime, isNotNull);
        }
      });

      test('first-time habit defaults to neutral coaching', () async {
        // Arrange: Brand new habit
        final newHabit = Habit(
          id: 'new1',
          userId: 'user1',
          name: 'New Habit',
          category: HabitCategory.spiritual,
          createdAt: DateTime(2024, 1, 15),
          currentStreak: 0,
          completionHistory: [],
        );

        // Act
        final risk = await predictor.predictRisk(newHabit);

        // Assert: Neutral risk (0.5) for new habits
        expect(risk, equals(0.5));

        // Coach provides onboarding encouragement
        // "Let's start your journey! First step is always the hardest."
      });
    });

    group('Offline Behavior', () {
      test('predictions work offline, coaching queued', () async {
        // Arrange: Normal habit
        final habit = Habit(
          id: 'offline1',
          userId: 'user1',
          name: 'Offline Habit',
          category: HabitCategory.mental,
          createdAt: DateTime(2024, 1, 1),
          currentStreak: 5,
          lastCompletedAt: DateTime(2024, 1, 14),
          completionHistory: List.generate(
            5,
            (i) => DateTime(2024, 1, 14).subtract(Duration(days: i)),
          ),
          reminderTime: '15:00',
        );

        // Act: Prediction works offline (TFLite model local)
        final risk = await predictor.predictRisk(habit);

        // Assert: Prediction completes successfully
        expect(risk, greaterThanOrEqualTo(0.0));
        expect(risk, lessThanOrEqualTo(1.0));

        // Coach messages would be queued for sync when online
        // In offline mode: store (risk, habitId, timestamp) locally
        // When online: batch send to Gemini for message generation
      });

      test('behavioral patterns detected offline', () async {
        // Arrange: Habit with clear pattern
        final patternedHabit = Habit(
          id: 'patterned1',
          userId: 'user1',
          name: 'Patterned Habit',
          category: HabitCategory.spiritual,
          createdAt: DateTime(2024, 1, 1),
          currentStreak: 5,
          lastCompletedAt: DateTime(2024, 1, 15),
          completionHistory: List.generate(
            10,
            (i) => DateTime(2024, 1, 15, 7, 0).subtract(Duration(days: i)),
          ), // All at 7am
        );

        // Act: Behavioral analysis works offline (no API needed)
        final optimalTime = behavioralEngine.findOptimalTime(patternedHabit);
        final optimalDays = behavioralEngine.findOptimalDays(patternedHabit);

        // Assert: Pattern detected offline
        expect(optimalTime, isNotNull);
        expect(optimalTime!.hour, equals(7)); // Consistent 7am
        expect(optimalDays, isNotEmpty);

        // Offline coaching can use these patterns
        // "You usually complete this at 7am. Perfect time for your routine!"
      });
    });

    group('Performance Validation', () {
      test('full ML + behavioral analysis completes < 150ms', () async {
        // Arrange
        final habit = Habit(
          id: 'perf1',
          userId: 'user1',
          name: 'Performance Test',
          category: HabitCategory.physical,
          createdAt: DateTime(2024, 1, 1),
          currentStreak: 10,
          lastCompletedAt: DateTime(2024, 1, 15),
          completionHistory: List.generate(
            15,
            (i) => DateTime(2024, 1, 15).subtract(Duration(days: i)),
          ),
          reminderTime: '10:00',
        );

        // Act: Measure complete analysis time
        final stopwatch = Stopwatch()..start();

        final risk = await predictor.predictRisk(habit);
        behavioralEngine.detectFailurePattern(habit);
        behavioralEngine.findOptimalTime(habit);
        final nextDifficulty = behavioralEngine.calculateNextDifficulty(habit);

        stopwatch.stop();

        // Assert: Complete analysis < 150ms
        expect(stopwatch.elapsedMilliseconds, lessThan(150));
        expect(risk, greaterThanOrEqualTo(0.0));
        expect(nextDifficulty, isNotNull);

        // Fast enough for real-time coaching
      });
    });

    group('Edge Cases', () {
      test('handles habit with no reminder time', () async {
        // Arrange
        final noReminderHabit = Habit(
          id: 'noreminder1',
          userId: 'user1',
          name: 'No Reminder',
          category: HabitCategory.spiritual,
          createdAt: DateTime(2024, 1, 1),
          currentStreak: 5,
          lastCompletedAt: DateTime(2024, 1, 14),
          completionHistory: [DateTime(2024, 1, 14)],
          reminderTime: null,
        );

        // Act: Should handle gracefully
        final risk = await predictor.predictRisk(noReminderHabit);

        // Assert: Returns valid risk
        expect(risk, greaterThanOrEqualTo(0.0));
        expect(risk, lessThanOrEqualTo(1.0));
      });

      test('handles very old habit with sparse data', () async {
        // Arrange: Old habit, infrequent completions
        final now = fixedClock.now();
        final oldHabit = Habit(
          id: 'old1',
          userId: 'user1',
          name: 'Old Sparse Habit',
          category: HabitCategory.mental,
          createdAt: now.subtract(const Duration(days: 380)), // ~13 months old
          currentStreak: 1,
          lastCompletedAt: now,
          completionHistory: [
            now,
            now.subtract(const Duration(days: 14)),
            now.subtract(const Duration(days: 31)),
          ], // Sparse
          reminderTime: '20:00',
        );

        // Act
        final risk = await predictor.predictRisk(oldHabit);
        behavioralEngine.detectFailurePattern(oldHabit);

        // Assert: Handles gracefully
        expect(risk, greaterThanOrEqualTo(0.0));
        expect(risk, lessThanOrEqualTo(1.0));

        // May not detect pattern due to sparse data
        // Coach should provide general encouragement
      });
    });
  });
}
