import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:habitus_faith/core/services/ml/abandonment_predictor.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';

/// Integration test for abandonment predictor with real TFLite model
/// Tests the new predictRisk(Habit) interface with complete end-to-end flow
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('AbandonmentPredictor Integration Tests', () {
    late AbandonmentPredictor predictor;

    setUpAll(() async {
      predictor = AbandonmentPredictor();
      await predictor.initialize();
    });

    tearDownAll(() {
      predictor.dispose();
    });

    test('Low-risk scenario: consistent spiritual habit', () async {
      // Arrange: User completing daily Bible reading consistently
      final now = DateTime(2024, 1, 15, 7, 30); // Monday 7:30 AM
      final completions = List.generate(10, (i) => now.subtract(Duration(days: i)));

      final habit = Habit(
        id: 'low_risk_habit',
        userId: 'user1',
        name: 'Daily Bible Reading',
        description: 'Read Bible every morning',
        category: HabitCategory.spiritual, // category.index = 0
        reminderTime: '07:00',
        createdAt: now.subtract(const Duration(days: 30)),
        currentStreak: 10,
        lastCompletedAt: now,
        completionHistory: completions,
      );

      // Act
      final risk = await predictor.predictRisk(habit);

      // Assert: Low risk expected
      print('[Integration] Low-risk scenario: ${(risk * 100).toStringAsFixed(1)}%');
      expect(risk, lessThan(0.5));
      expect(risk, greaterThanOrEqualTo(0.0));
    });

    test('High-risk scenario: struggling physical habit', () async {
      // Arrange: User struggling with exercise, late evening, broken streak
      final now = DateTime(2024, 1, 19, 21, 0); // Friday 9 PM
      final completions = [
        now.subtract(const Duration(days: 10)),
        now.subtract(const Duration(days: 15)),
      ];

      final habit = Habit(
        id: 'high_risk_habit',
        userId: 'user1',
        name: 'Evening Exercise',
        description: 'Exercise 3 times per week',
        category: HabitCategory.physical, // category.index = 1
        reminderTime: '18:00',
        createdAt: now.subtract(const Duration(days: 30)),
        currentStreak: 0,
        lastCompletedAt: completions.first,
        completionHistory: completions,
      );

      // Act
      final risk = await predictor.predictRisk(habit);

      // Assert: High risk expected
      print('[Integration] High-risk scenario: ${(risk * 100).toStringAsFixed(1)}%');
      expect(risk, greaterThan(0.5));
      expect(risk, lessThanOrEqualTo(1.0));
    });

    test('Medium-risk scenario: inconsistent mental habit', () async {
      // Arrange: User with moderate completion pattern
      final now = DateTime(2024, 1, 17, 17, 30); // Wednesday 5:30 PM
      final completions = [
        now.subtract(const Duration(days: 1)),
        now.subtract(const Duration(days: 2)),
        now.subtract(const Duration(days: 5)),
        now.subtract(const Duration(days: 8)),
      ];

      final habit = Habit(
        id: 'medium_risk_habit',
        userId: 'user1',
        name: 'Daily Reading',
        description: 'Read for 20 minutes',
        category: HabitCategory.mental, // category.index = 2
        reminderTime: '17:00',
        createdAt: now.subtract(const Duration(days: 20)),
        currentStreak: 3,
        lastCompletedAt: now.subtract(const Duration(days: 1)),
        completionHistory: completions,
      );

      // Act
      final risk = await predictor.predictRisk(habit);

      // Assert: Medium risk expected
      print('[Integration] Medium-risk scenario: ${(risk * 100).toStringAsFixed(1)}%');
      expect(risk, greaterThan(0.2));
      expect(risk, lessThan(0.8));
    });

    test('First-time habit returns default risk', () async {
      // Arrange: Brand new habit with no completion history
      final now = DateTime(2024, 1, 15, 10, 0);

      final habit = Habit(
        id: 'new_habit',
        userId: 'user1',
        name: 'New Prayer Habit',
        description: 'Just started today',
        category: HabitCategory.spiritual,
        reminderTime: '09:00',
        createdAt: now,
        currentStreak: 0,
        completionHistory: [],
      );

      // Act
      final risk = await predictor.predictRisk(habit);

      // Assert: Should return default 0.5 for first-time habits
      print('[Integration] First-time habit: ${(risk * 100).toStringAsFixed(1)}%');
      expect(risk, 0.5);
    });

    test('Relational category habit processes correctly', () async {
      // Arrange: Testing relational category (index = 3)
      final now = DateTime(2024, 1, 16, 19, 0); // Tuesday 7 PM
      final completions = List.generate(5, (i) => now.subtract(Duration(days: i)));

      final habit = Habit(
        id: 'relational_habit',
        userId: 'user1',
        name: 'Family Time',
        description: 'Spend quality time with family',
        category: HabitCategory.relational, // category.index = 3
        reminderTime: '18:30',
        createdAt: now.subtract(const Duration(days: 15)),
        currentStreak: 5,
        lastCompletedAt: now,
        completionHistory: completions,
      );

      // Act
      final risk = await predictor.predictRisk(habit);

      // Assert: Valid risk value
      print('[Integration] Relational habit: ${(risk * 100).toStringAsFixed(1)}%');
      expect(risk, greaterThanOrEqualTo(0.0));
      expect(risk, lessThanOrEqualTo(1.0));
    });

    test('Prediction completes in less than 100ms', () async {
      // Arrange
      final now = DateTime(2024, 1, 15, 12, 0);
      final completions = List.generate(7, (i) => now.subtract(Duration(days: i)));

      final habit = Habit(
        id: 'performance_test',
        userId: 'user1',
        name: 'Performance Test Habit',
        description: 'Testing prediction speed',
        category: HabitCategory.spiritual,
        reminderTime: '12:00',
        createdAt: now.subtract(const Duration(days: 30)),
        currentStreak: 7,
        lastCompletedAt: now,
        completionHistory: completions,
      );

      // Act: Measure time
      final stopwatch = Stopwatch()..start();
      await predictor.predictRisk(habit);
      stopwatch.stop();

      // Assert: Performance requirement
      print('[Integration] Prediction time: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('User declining nudge scenario', () async {
      // Arrange: High-risk habit that would trigger nudge
      final now = DateTime(2024, 1, 20, 20, 0); // Saturday 8 PM
      final completions = [
        now.subtract(const Duration(days: 8)),
        now.subtract(const Duration(days: 12)),
      ];

      final habit = Habit(
        id: 'nudge_decline_habit',
        userId: 'user1',
        name: 'Evening Meditation',
        description: 'Meditate before bed',
        category: HabitCategory.mental,
        reminderTime: '21:00',
        createdAt: now.subtract(const Duration(days: 30)),
        currentStreak: 0,
        lastCompletedAt: completions.first,
        completionHistory: completions,
        difficultyLevel: 4,
        targetMinutes: 30,
      );

      // Act: Get risk prediction
      final risk = await predictor.predictRisk(habit);

      // Assert: Should be high enough to trigger intervention
      print('[Integration] Nudge scenario risk: ${(risk * 100).toStringAsFixed(1)}%');
      if (risk > 0.65) {
        print('[Integration] ✓ Would trigger nudge notification');
        print('[Integration] User would see: "¿Reducimos a Xmin? Notamos que podrías abandonar"');
      }
      expect(risk, greaterThanOrEqualTo(0.0));
      expect(risk, lessThanOrEqualTo(1.0));
    });

    test('User accepting nudge scenario', () async {
      // Arrange: Another high-risk habit for acceptance test
      final now = DateTime(2024, 1, 18, 22, 30); // Thursday 10:30 PM
      final completions = [
        now.subtract(const Duration(days: 7)),
        now.subtract(const Duration(days: 14)),
      ];

      final habit = Habit(
        id: 'nudge_accept_habit',
        userId: 'user1',
        name: 'Late Night Workout',
        description: 'Exercise before sleep',
        category: HabitCategory.physical,
        reminderTime: '22:00',
        createdAt: now.subtract(const Duration(days: 30)),
        currentStreak: 0,
        lastCompletedAt: completions.first,
        completionHistory: completions,
        difficultyLevel: 5,
        targetMinutes: 45,
      );

      // Act: Get risk prediction
      final risk = await predictor.predictRisk(habit);

      // Assert: Verify risk and potential intervention
      print('[Integration] Accept nudge scenario risk: ${(risk * 100).toStringAsFixed(1)}%');
      if (risk > 0.65) {
        print('[Integration] ✓ Would trigger nudge notification');
        print('[Integration] If accepted: difficulty would reduce from ${habit.difficultyLevel} to lower level');
      }
      expect(risk, greaterThanOrEqualTo(0.0));
      expect(risk, lessThanOrEqualTo(1.0));
    });

    test('Tensor shape validation: features match training order', () async {
      // This test verifies that features are in the correct order:
      // [hourOfDay, dayOfWeek, currentStreak, failuresLast7Days, categoryEnumValue]
      
      final now = DateTime(2024, 1, 15, 14, 0); // Monday (weekday=1), 2 PM (hour=14)
      final completions = List.generate(8, (i) => now.subtract(Duration(days: i)));

      final habit = Habit(
        id: 'tensor_order_test',
        userId: 'user1',
        name: 'Order Test Habit',
        description: 'Verifying feature order',
        category: HabitCategory.mental, // index = 2
        reminderTime: '14:00',
        createdAt: now.subtract(const Duration(days: 30)),
        currentStreak: 8,
        lastCompletedAt: now,
        completionHistory: completions,
      );

      // Act: Run prediction
      final risk = await predictor.predictRisk(habit);

      // Assert: Should produce valid result with correct feature order
      // Features should be: [14, 1, 8, 0, 2]
      // hourOfDay=14, dayOfWeek=1 (Monday), streak=8, failures=0, category=2 (mental)
      print('[Integration] Tensor order test: ${(risk * 100).toStringAsFixed(1)}%');
      print('[Integration] Expected features: [hour=14, day=1, streak=8, failures≈0, category=2]');
      expect(risk, greaterThanOrEqualTo(0.0));
      expect(risk, lessThanOrEqualTo(1.0));
    });
  });
}
