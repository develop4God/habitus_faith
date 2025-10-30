import 'package:flutter_test/flutter_test.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:habitus_faith/features/habits/domain/ml_features_calculator.dart';

/// Integration test for ML predictor with TFLite model and scaler
/// This test simulates real user scenarios and runs full end-to-end validation

void main() {
  group('AbandonmentPredictor TFLite Integration', () {
    late Interpreter interpreter;
    late Map<String, dynamic> scalerParams;

    setUpAll(() async {
      // Load TFLite model and scaler parameters only once
      interpreter =
          await Interpreter.fromAsset('assets/ml_models/predictor.tflite');
      final scalerJson =
          await rootBundle.loadString('assets/ml_models/scaler_params.json');
      scalerParams = json.decode(scalerJson);
    });

    tearDownAll(() {
      interpreter.close();
    });

    test('Low-risk user scenario returns low abandonment probability',
        () async {
      // Simula usuario real: espiritual, completando hábito diario, cerca del recordatorio
      final now = DateTime(2024, 1, 15, 7, 30); // Lunes 7:30 AM
      final completions =
          List.generate(7, (i) => now.subtract(Duration(days: i)));

      final habit = Habit(
        id: 'low_risk',
        userId: 'user1',
        name: 'Bible Reading',
        description: 'Read Bible daily',
        category: HabitCategory.spiritual,
        reminderTime: '07:00',
        createdAt: now.subtract(const Duration(days: 30)),
        currentStreak: 7,
        completionHistory: completions,
      );

      final hourOfDay = now.hour.toDouble();
      final dayOfWeek = now.weekday.toDouble();
      final streakAtTime = habit.currentStreak.toDouble();
      final failuresLast7Days =
          MLFeaturesCalculator.countRecentFailures(habit, 7).toDouble();
      final hoursFromReminder =
          MLFeaturesCalculator.calculateHoursFromReminder(habit, now)
              .toDouble();

      // Normalización
      final mean = (scalerParams['mean'] as List).cast<double>();
      final scale = (scalerParams['scale'] as List).cast<double>();
      final features = [
        hourOfDay,
        dayOfWeek,
        streakAtTime,
        failuresLast7Days,
        hoursFromReminder
      ];
      final normalized = List.generate(
          features.length, (i) => (features[i] - mean[i]) / scale[i]);

      final output = List.filled(1, 0.0).reshape([1, 1]);
      interpreter.run([normalized], output);

      print('[Low-risk] Predicted risk: ${output[0][0]}');
      expect(output[0][0], lessThan(0.5)); // Espera un riesgo bajo
    });

    test('High-risk user scenario returns high abandonment probability',
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
        description: 'Exercise daily',
        category: HabitCategory.mental,
        reminderTime: '07:00',
        createdAt: now.subtract(const Duration(days: 30)),
        currentStreak: 0,
        completionHistory: completions,
      );

      final hourOfDay = now.hour.toDouble();
      final dayOfWeek = now.weekday.toDouble();
      final streakAtTime = habit.currentStreak.toDouble();
      final failuresLast7Days =
          MLFeaturesCalculator.countRecentFailures(habit, 7).toDouble();
      final hoursFromReminder =
          MLFeaturesCalculator.calculateHoursFromReminder(habit, now)
              .toDouble();

      final mean = (scalerParams['mean'] as List).cast<double>();
      final scale = (scalerParams['scale'] as List).cast<double>();
      final features = [
        hourOfDay,
        dayOfWeek,
        streakAtTime,
        failuresLast7Days,
        hoursFromReminder
      ];
      final normalized = List.generate(
          features.length, (i) => (features[i] - mean[i]) / scale[i]);

      final output = List.filled(1, 0.0).reshape([1, 1]);
      interpreter.run([normalized], output);

      print('[High-risk] Predicted risk: ${output[0][0]}');
      expect(output[0][0], greaterThan(0.5)); // Espera un riesgo alto
    });

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
        description: 'Workout 3 times a week',
        category: HabitCategory.physical,
        reminderTime: '17:00',
        createdAt: now.subtract(const Duration(days: 20)),
        currentStreak: 3,
        completionHistory: completions,
      );

      final hourOfDay = now.hour.toDouble();
      final dayOfWeek = now.weekday.toDouble();
      final streakAtTime = habit.currentStreak.toDouble();
      final failuresLast7Days =
          MLFeaturesCalculator.countRecentFailures(habit, 7).toDouble();
      final hoursFromReminder =
          MLFeaturesCalculator.calculateHoursFromReminder(habit, now)
              .toDouble();

      final mean = (scalerParams['mean'] as List).cast<double>();
      final scale = (scalerParams['scale'] as List).cast<double>();
      final features = [
        hourOfDay,
        dayOfWeek,
        streakAtTime,
        failuresLast7Days,
        hoursFromReminder
      ];
      final normalized = List.generate(
          features.length, (i) => (features[i] - mean[i]) / scale[i]);

      final output = List.filled(1, 0.0).reshape([1, 1]);
      interpreter.run([normalized], output);

      print('[Medium-risk] Predicted risk: ${output[0][0]}');
      expect(
          output[0][0], inInclusiveRange(0.3, 0.7)); // Espera riesgo intermedio
    });

    test('Feature values are deterministic for same inputs', () async {
      final now = DateTime(2024, 1, 15, 15, 0);
      final habit = Habit(
        id: 'test_habit',
        userId: 'user1',
        name: 'Test',
        description: 'Test',
        category: HabitCategory.mental,
        reminderTime: '12:00',
        createdAt: DateTime(2024, 1, 1),
        currentStreak: 5,
        completionHistory: [],
      );

      final hourOfDay = now.hour.toDouble();
      final dayOfWeek = now.weekday.toDouble();
      final streakAtTime = habit.currentStreak.toDouble();
      final failuresLast7Days =
          MLFeaturesCalculator.countRecentFailures(habit, 7).toDouble();
      final hoursFromReminder =
          MLFeaturesCalculator.calculateHoursFromReminder(habit, now)
              .toDouble();

      final mean = (scalerParams['mean'] as List).cast<double>();
      final scale = (scalerParams['scale'] as List).cast<double>();
      final features = [
        hourOfDay,
        dayOfWeek,
        streakAtTime,
        failuresLast7Days,
        hoursFromReminder
      ];
      final normalized1 = List.generate(
          features.length, (i) => (features[i] - mean[i]) / scale[i]);
      final normalized2 = List.generate(
          features.length, (i) => (features[i] - mean[i]) / scale[i]);

      final output1 = List.filled(1, 0.0).reshape([1, 1]);
      final output2 = List.filled(1, 0.0).reshape([1, 1]);
      interpreter.run([normalized1], output1);
      interpreter.run([normalized2], output2);

      expect(output1[0][0], output2[0][0]); // Deben ser iguales
    });
  });
}
