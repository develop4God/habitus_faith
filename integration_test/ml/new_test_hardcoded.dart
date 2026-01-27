import 'package:flutter_test/flutter_test.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:convert';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/services.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:habitus_faith/features/habits/domain/ml_features_calculator.dart';
import 'package:flutter/foundation.dart';

/// Integration test for ML predictor with TFLite model and scaler
/// This test simulates real user scenarios and runs full end-to-end validation

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('AbandonmentPredictor TFLite Integration', () {
    late Interpreter interpreter;
    late Map<String, dynamic> scalerParams;

    setUpAll(() async {
      // Load TFLite model and scaler parameters only once
      interpreter = await Interpreter.fromAsset(
        'assets/ml_models/predictor.tflite',
      );
      final scalerJson = await rootBundle.loadString(
        'assets/ml_models/scaler_params.json',
      );
      scalerParams = json.decode(scalerJson);
    });

    tearDownAll(() {
      interpreter.close();
    });

    test('Exact notebook scenario - Excellent morning', () async {
      // Mismo input del notebook: [7.0, 1, 45, 0, 1]
      final features = [7.0, 1.0, 45.0, 0.0, 1.0];

      final mean = (scalerParams['mean'] as List).cast<double>();
      final scale = (scalerParams['scale'] as List).cast<double>();
      final normalized = List.generate(
        features.length,
        (i) => (features[i] - mean[i]) / scale[i],
      );

      debugPrint('Raw features: $features');
      debugPrint('Normalized: $normalized');

      final output = List.filled(1, 0.0).reshape([1, 1]);
      interpreter.run([normalized], output);

      debugPrint('Hardcoded excellent morning: ${output[0][0]}');
      expect(output[0][0], lessThan(0.05)); // Debe dar ~0.0131
    });

    test('Exact notebook scenario - Struggling night', () async {
      // Mismo input del notebook: [21.0, 6, 5, 5, 8]
      final features = [21.0, 6.0, 5.0, 5.0, 8.0];

      final mean = (scalerParams['mean'] as List).cast<double>();
      final scale = (scalerParams['scale'] as List).cast<double>();
      final normalized = List.generate(
        features.length,
        (i) => (features[i] - mean[i]) / scale[i],
      );

      debugPrint('Raw features: $features');
      debugPrint('Normalized: $normalized');

      final output = List.filled(1, 0.0).reshape([1, 1]);
      interpreter.run([normalized], output);

      debugPrint('Hardcoded struggling night: ${output[0][0]}');
      expect(output[0][0], greaterThan(0.7)); // Debe dar ~0.7712
    });

    test('Low-risk user scenario returns low abandonment probability',
        () async {
      // Simula usuario real: espiritual, completando hábito diario, cerca del recordatorio
      final now = DateTime(2024, 1, 15, 7, 30); // Lunes 7:30 AM
      final completions = List.generate(
        7,
        (i) => now.subtract(Duration(days: i)),
      );

      final habit = Habit(
        id: 'low_risk',
        userId: 'user1',
        name: 'Bible Reading',
        category: HabitCategory.spiritual,
        reminderTime: '07:00',
        createdAt: now.subtract(const Duration(days: 30)),
        currentStreak: 7,
        completionHistory: completions,
      );

      debugPrint('\n[Low-risk] Completions: $completions');

      final hourOfDay = now.hour.toDouble();
      final dayOfWeek = now.weekday.toDouble();
      final streakAtTime = habit.currentStreak.toDouble();
      final failuresLast7Days = MLFeaturesCalculator.countRecentFailures(
        habit,
        7,
        now: now,
      );
      final hoursFromReminder = MLFeaturesCalculator.calculateHoursFromReminder(
        habit,
        now,
      ).toDouble();

      final features = [
        hourOfDay,
        dayOfWeek,
        streakAtTime,
        failuresLast7Days,
        hoursFromReminder,
      ];

      debugPrint('[Low-risk] Raw features: $features');

      // Normalización
      final mean = (scalerParams['mean'] as List).cast<double>();
      final scale = (scalerParams['scale'] as List).cast<double>();
      final normalized = List.generate(
        features.length,
        (i) => (features[i] - mean[i]) / scale[i],
      );

      debugPrint('[Low-risk] Normalized: $normalized');

      final output = List.filled(1, 0.0).reshape([1, 1]);
      interpreter.run([normalized], output);

      debugPrint('[Low-risk] Predicted risk: ${output[0][0]}');
      expect(output[0][0], lessThan(0.5)); // Espera un riesgo bajo
    });

    test(
      'High-risk user scenario returns high abandonment probability',
      () async {
        // Simula usuario real: mental, con pocos completados, lejos del recordatorio
        final now = DateTime(2024, 1, 19, 21, 0); // Viernes 9 PM
        final completions = [
          now.subtract(const Duration(days: 10)),
          now.subtract(const Duration(days: 15)),
        ];

        final habit = Habit(
          id: 'high_risk',
          userId: 'user1',
          name: 'Exercise',
          category: HabitCategory.mental,
          reminderTime: '07:00',
          createdAt: now.subtract(const Duration(days: 30)),
          currentStreak: 0,
          completionHistory: completions,
        );

        debugPrint('\n[High-risk] Completions: $completions');

        final hourOfDay = now.hour.toDouble();
        final dayOfWeek = now.weekday.toDouble();
        final streakAtTime = habit.currentStreak.toDouble();
        final failuresLast7Days = MLFeaturesCalculator.countRecentFailures(
          habit,
          7,
          now: now,
        );
        final hoursFromReminder =
            MLFeaturesCalculator.calculateHoursFromReminder(
          habit,
          now,
        ).toDouble();

        final features = [
          hourOfDay,
          dayOfWeek,
          streakAtTime,
          failuresLast7Days,
          hoursFromReminder,
        ];

        debugPrint('[High-risk] Raw features: $features');

        final mean = (scalerParams['mean'] as List).cast<double>();
        final scale = (scalerParams['scale'] as List).cast<double>();
        final normalized = List.generate(
          features.length,
          (i) => (features[i] - mean[i]) / scale[i],
        );

        debugPrint('[High-risk] Normalized: $normalized');

        final output = List.filled(1, 0.0).reshape([1, 1]);
        interpreter.run([normalized], output);

        debugPrint('[High-risk] Predicted risk: ${output[0][0]}');
        expect(output[0][0], greaterThan(0.5)); // Espera un riesgo alto
      },
    );

    test('Medium-risk scenario returns intermediate probability', () async {
      // Simula usuario real: físico, racha media, algunos fallos, horario vespertino
      final now = DateTime(2024, 1, 17, 17, 45); // Miércoles 5:45 PM
      final completions = [
        now.subtract(const Duration(days: 1)),
        now.subtract(const Duration(days: 2)),
        now.subtract(const Duration(days: 5)),
      ];

      final habit = Habit(
        id: 'medium_risk',
        userId: 'user1',
        name: 'Workout',
        category: HabitCategory.physical,
        reminderTime: '17:00',
        createdAt: now.subtract(const Duration(days: 20)),
        currentStreak: 3,
        completionHistory: completions,
      );

      debugPrint('\n[Medium-risk] Completions: $completions');

      final hourOfDay = now.hour.toDouble();
      final dayOfWeek = now.weekday.toDouble();
      final streakAtTime = habit.currentStreak.toDouble();
      final failuresLast7Days = MLFeaturesCalculator.countRecentFailures(
        habit,
        7,
        now: now,
      );
      final hoursFromReminder = MLFeaturesCalculator.calculateHoursFromReminder(
        habit,
        now,
      ).toDouble();

      final features = [
        hourOfDay,
        dayOfWeek,
        streakAtTime,
        failuresLast7Days,
        hoursFromReminder,
      ];

      debugPrint('[Medium-risk] Raw features: $features');

      final mean = (scalerParams['mean'] as List).cast<double>();
      final scale = (scalerParams['scale'] as List).cast<double>();
      final normalized = List.generate(
        features.length,
        (i) => (features[i] - mean[i]) / scale[i],
      );

      debugPrint('[Medium-risk] Normalized: $normalized');

      final output = List.filled(1, 0.0).reshape([1, 1]);
      interpreter.run([normalized], output);

      debugPrint('[Medium-risk] Predicted risk: ${output[0][0]}');
      expect(
        output[0][0],
        inInclusiveRange(0.3, 0.7),
      ); // Espera riesgo intermedio
    });

    test('Feature values are deterministic for same inputs', () async {
      final now = DateTime(2024, 1, 15, 15, 0);
      final habit = Habit(
        id: 'test_habit',
        userId: 'user1',
        name: 'Test',
        category: HabitCategory.mental,
        reminderTime: '12:00',
        createdAt: DateTime(2024, 1, 1),
        currentStreak: 5,
        completionHistory: [],
      );

      final hourOfDay = now.hour.toDouble();
      final dayOfWeek = now.weekday.toDouble();
      final streakAtTime = habit.currentStreak.toDouble();
      final failuresLast7Days = MLFeaturesCalculator.countRecentFailures(
        habit,
        7,
        now: now,
      );
      final hoursFromReminder = MLFeaturesCalculator.calculateHoursFromReminder(
        habit,
        now,
      ).toDouble();

      final mean = (scalerParams['mean'] as List).cast<double>();
      final scale = (scalerParams['scale'] as List).cast<double>();
      final features = [
        hourOfDay,
        dayOfWeek,
        streakAtTime,
        failuresLast7Days,
        hoursFromReminder,
      ];
      final normalized1 = List.generate(
        features.length,
        (i) => (features[i] - mean[i]) / scale[i],
      );
      final normalized2 = List.generate(
        features.length,
        (i) => (features[i] - mean[i]) / scale[i],
      );

      final output1 = List.filled(1, 0.0).reshape([1, 1]);
      final output2 = List.filled(1, 0.0).reshape([1, 1]);
      interpreter.run([normalized1], output1);
      interpreter.run([normalized2], output2);

      expect(output1[0][0], output2[0][0]); // Deben ser iguales
    });
  });
}
