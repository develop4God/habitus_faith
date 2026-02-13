import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/ml/abandonment_predictor.dart';
import 'package:habitus_faith/core/services/time/time.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AbandonmentPredictor Extended Coverage Tests', () {
    late AbandonmentPredictor predictor;
    late Clock clock;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      clock = const Clock.system();
      predictor = AbandonmentPredictor(clock: clock);
    });

    tearDown(() {
      predictor.dispose();
    });

    group('Telemetry Tests', () {
      test('tracks prediction count across multiple predictions', () async {
        await predictor.initialize();

        // Skip if model failed to initialize (TFLite not available in CI)
        if (!predictor.isInitialized) {
          markTestSkipped('TensorFlow Lite not available in test environment');
          return;
        }

        final habit = Habit(
          id: 'test-1',
          userId: 'user1',
          name: 'Test Habit',
          category: HabitCategory.spiritual,
          createdAt: DateTime.now(),
          currentStreak: 5,
          completionHistory: [DateTime.now()],
        );

        await predictor.predictRisk(habit);
        await predictor.predictRisk(habit);
        await predictor.predictRisk(habit);

        final telemetry = predictor.telemetry;
        expect(telemetry['prediction_count'], equals(3));
      });

      test('tracks error count when predictions fail', () async {
        final habit = Habit(
          id: 'test-1',
          userId: 'user1',
          name: 'Test Habit',
          category: HabitCategory.spiritual,
          createdAt: DateTime.now(),
        );

        await predictor.predictRisk(habit);
        await predictor.predictRisk(habit);

        final telemetry = predictor.telemetry;
        expect(telemetry['error_count'], equals(2));
      });

      test('calculates success rate correctly', () async {
        await predictor.initialize();

        // Skip if model failed to initialize (TFLite not available in CI)
        if (!predictor.isInitialized) {
          markTestSkipped('TensorFlow Lite not available in test environment');
          return;
        }

        final habit = Habit(
          id: 'test-1',
          userId: 'user1',
          name: 'Test Habit',
          category: HabitCategory.spiritual,
          createdAt: DateTime.now(),
          currentStreak: 3,
          completionHistory: [DateTime.now()],
        );

        await predictor.predictRisk(habit);

        final telemetry = predictor.telemetry;
        expect(telemetry['success_rate'], greaterThan(0.0));
      });

      test('telemetry getter returns map with required fields', () {
        final telemetry = predictor.telemetry;

        expect(telemetry, containsPair('prediction_count', isA<int>()));
        expect(telemetry, containsPair('error_count', isA<int>()));
        expect(telemetry, containsPair('success_rate', isA<double>()));
      });
    });

    group('Prediction Edge Cases', () {
      test('handles habit with no completion history', () async {
        await predictor.initialize();

        final habit = Habit(
          id: 'new-habit',
          userId: 'user1',
          name: 'New Habit',
          category: HabitCategory.physical,
          createdAt: DateTime.now(),
          currentStreak: 0,
          completionHistory: [],
        );

        final risk = await predictor.predictRisk(habit);

        expect(risk, equals(AbandonmentPredictor.defaultRiskForNewHabits));
      });

      test('handles different habit categories', () async {
        await predictor.initialize();

        for (final category in HabitCategory.values) {
          final habit = Habit(
            id: 'habit-${category.name}',
            userId: 'user1',
            name: 'Habit ${category.name}',
            category: category,
            createdAt: DateTime.now(),
            currentStreak: 3,
            completionHistory: [
              // ignore: prefer_const_constructors
              DateTime.now().subtract(Duration(days: 1)),
            ],
          );

          final risk = await predictor.predictRisk(habit);

          expect(risk, greaterThanOrEqualTo(0.0));
          expect(risk, lessThanOrEqualTo(1.0));
        }
      });
    });

    group('Error Handling', () {
      test('gracefully handles initialization failures', () async {
        expect(() => predictor.initialize(), returnsNormally);
      });

      test('saves telemetry even when prediction fails', () async {
        final habit = Habit(
          id: 'test-habit',
          userId: 'user1',
          name: 'Test Habit',
          category: HabitCategory.spiritual,
          createdAt: DateTime.now(),
        );

        await predictor.predictRisk(habit);

        final telemetry = predictor.telemetry;
        expect(telemetry['error_count'], greaterThan(0));
      });
    });

    group('Metadata', () {
      test('exposes model version after initialization', () async {
        await predictor.initialize();

        final version = predictor.modelVersion;
        expect(version, anyOf(isNull, isA<String>()));
      });
    });

    group('Disposal', () {
      test('dispose can be called multiple times safely', () async {
        await predictor.initialize();

        expect(() => predictor.dispose(), returnsNormally);
        expect(() => predictor.dispose(), returnsNormally);
      });
    });

    group('Legacy Method', () {
      test('legacy predictAbandonmentRisk still works', () async {
        await predictor.initialize();

        // ignore: deprecated_member_use_from_same_package
        final risk = await predictor.predictAbandonmentRisk(
          hourOfDay: 14,
          dayOfWeek: 3,
          currentStreak: 5,
          recentFailures: 1,
          hoursSinceReminder: 2,
        );

        expect(risk, isA<double>());
        expect(risk, greaterThanOrEqualTo(0.0));
        expect(risk, lessThanOrEqualTo(1.0));
      });
    });
  });
}
