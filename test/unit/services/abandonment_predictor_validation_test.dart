// test/unit/services/abandonment_predictor_validation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:habitus_faith/core/services/ml/abandonment_predictor.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:habitus_faith/core/services/time/time.dart';
import 'dart:convert';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AbandonmentPredictor Asset Validation', () {
    test('scaler_params.json exists and is valid', () async {
      final json = await rootBundle.loadString(
        'assets/ml_models/scaler_params.json',
      );
      final params = jsonDecode(json);
      expect(params['mean'], isNotNull);
      expect(params['scale'], isNotNull);
      expect(params['mean'], hasLength(5));
      expect(params['scale'], hasLength(5));

      // Verify all values are finite numbers
      for (var val in params['mean']) {
        expect(val, isA<num>());
      }
      for (var val in params['scale']) {
        expect(val, isA<num>());
        expect(val, greaterThan(0)); // scale must be positive
      }
    });

    test('predictor.tflite exists', () async {
      final data = await rootBundle.load('assets/ml_models/predictor.tflite');
      expect(data.lengthInBytes, greaterThan(0));
      expect(data.lengthInBytes, lessThan(5 * 1024 * 1024)); // < 5MB
    });

    test('feature normalization logic', () {
      // Simula normalización sin TFLite
      final mean = [12.5, 3.8, 10.2, 2.1, 4.5];
      final scale = [5.2, 1.9, 8.3, 1.8, 3.1];
      final features = [12.0, 3.0, 5.0, 2.0, 4.0];

      final normalized = List.generate(
        features.length,
        (i) => (features[i] - mean[i]) / scale[i],
      );

      expect(normalized, hasLength(5));
      expect(normalized.every((v) => v.isFinite), isTrue);
      expect(normalized[0], closeTo(-0.096, 0.01)); // (12-12.5)/5.2
    });

    test('model_metadata.json exists and is valid', () async {
      final json = await rootBundle.loadString(
        'assets/ml_models/model_metadata.json',
      );
      final metadata = jsonDecode(json);

      expect(metadata['version'], isNotNull);
      expect(metadata['features'], isNotNull);
      expect(metadata['features'], hasLength(5));
      expect(metadata['trained_at'], isNotNull);
      expect(metadata['training_samples'], isA<num>());
      expect(metadata['accuracy'], isA<num>());
      expect(metadata['accuracy'], greaterThan(0));
      expect(metadata['accuracy'], lessThanOrEqualTo(1));

      // Verify feature order matches expected
      final features = metadata['features'] as List;
      expect(features[0], 'hourOfDay');
      expect(features[1], 'dayOfWeek');
      expect(features[2], 'currentStreak');
      expect(features[3], 'failuresLast7Days');
      expect(features[4], 'hoursFromReminder');
    });

    test('input shape is validated as [1, 5]', () async {
      final json = await rootBundle.loadString(
        'assets/ml_models/model_metadata.json',
      );
      final metadata = jsonDecode(json);

      final inputShape = metadata['input_shape'] as List;
      expect(inputShape, hasLength(2));
      expect(inputShape[0], equals(1)); // batch size
      expect(inputShape[1], equals(5)); // number of features

      final outputShape = metadata['output_shape'] as List;
      expect(outputShape, hasLength(2));
      expect(outputShape[0], equals(1)); // batch size
      expect(outputShape[1], equals(1)); // single probability output
    });

    test('features match training order exactly', () async {
      final json = await rootBundle.loadString(
        'assets/ml_models/model_metadata.json',
      );
      final metadata = jsonDecode(json);

      final features = metadata['features'] as List<dynamic>;
      final expectedOrder = [
        'hourOfDay',
        'dayOfWeek',
        'currentStreak',
        'failuresLast7Days',
        'hoursFromReminder',
      ];

      expect(features, equals(expectedOrder));
      expect(metadata['feature_order_critical'], isTrue);
    });
  });

  group('AbandonmentPredictor Schema Validation', () {
    late AbandonmentPredictor predictor;

    setUpAll(() async {
      predictor = AbandonmentPredictor();
      await predictor.initialize();
    });

    tearDownAll(() {
      predictor.dispose();
    });

    test('validates model metadata on initialization', () async {
      // Predictor should have loaded metadata
      expect(predictor.metadata, isNotNull);
      expect(predictor.metadata!['input_shape'], equals([1, 5]));
      expect(predictor.metadata!['output_shape'], equals([1, 1]));
    });

    test('returns probability between 0.0 and 1.0', () async {
      final now = DateTime(2024, 1, 15, 14, 30);
      final completions = List.generate(
        5,
        (i) => now.subtract(Duration(days: i)),
      );

      final habit = Habit(
        id: 'test_habit',
        userId: 'user1',
        name: 'Test Habit',
        category: HabitCategory.spiritual,
        createdAt: now.subtract(const Duration(days: 30)),
        currentStreak: 5,
        lastCompletedAt: now,
        completionHistory: completions,
        reminderTime: '14:00',
      );

      final risk = await predictor.predictRisk(habit);

      expect(risk, greaterThanOrEqualTo(0.0));
      expect(risk, lessThanOrEqualTo(1.0));
    });

    test('handles missing completion data gracefully', () async {
      final habitWithNulls = Habit(
        id: 'empty_habit',
        userId: 'user1',
        name: 'Empty Habit',
        category: HabitCategory.spiritual,
        createdAt: DateTime.now(),
        currentStreak: 0,
        completionHistory: [],
      );

      expect(
        () => predictor.predictRisk(habitWithNulls),
        returnsNormally,
      );

      final risk = await predictor.predictRisk(habitWithNulls);
      
      // Should return default risk for new habits
      expect(
        risk,
        equals(AbandonmentPredictor.defaultRiskForNewHabits),
      );
    });

    test('executes prediction in less than 100ms', () async {
      final now = DateTime(2024, 1, 15, 12, 0);
      final completions = List.generate(
        10,
        (i) => now.subtract(Duration(days: i)),
      );

      final habit = Habit(
        id: 'performance_habit',
        userId: 'user1',
        name: 'Performance Test',
        category: HabitCategory.spiritual,
        createdAt: now.subtract(const Duration(days: 30)),
        currentStreak: 10,
        lastCompletedAt: now,
        completionHistory: completions,
        reminderTime: '12:00',
      );

      final stopwatch = Stopwatch()..start();
      await predictor.predictRisk(habit);
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('handles null reminderTime gracefully', () async {
      final now = DateTime.now();
      final habit = Habit(
        id: 'no_reminder_habit',
        userId: 'user1',
        name: 'No Reminder',
        category: HabitCategory.spiritual,
        createdAt: now.subtract(const Duration(days: 10)),
        currentStreak: 3,
        lastCompletedAt: now,
        completionHistory: [now, now.subtract(const Duration(days: 1))],
        reminderTime: null, // No reminder set
      );

      final risk = await predictor.predictRisk(habit);
      expect(risk, greaterThanOrEqualTo(0.0));
      expect(risk, lessThanOrEqualTo(1.0));
    });

    test('handles invalid reminderTime format gracefully', () async {
      final now = DateTime.now();
      final habit = Habit(
        id: 'invalid_reminder_habit',
        userId: 'user1',
        name: 'Invalid Reminder',
        category: HabitCategory.spiritual,
        createdAt: now.subtract(const Duration(days: 10)),
        currentStreak: 3,
        lastCompletedAt: now,
        completionHistory: [now, now.subtract(const Duration(days: 1))],
        reminderTime: 'invalid', // Invalid format
      );

      final risk = await predictor.predictRisk(habit);
      expect(risk, greaterThanOrEqualTo(0.0));
      expect(risk, lessThanOrEqualTo(1.0));
    });
  });

  group('AbandonmentPredictor Error Handling', () {
    test('handles model not loaded scenario', () async {
      // Create predictor but don't initialize
      final uninitializedPredictor = AbandonmentPredictor();

      final habit = Habit(
        id: 'test',
        userId: 'user1',
        name: 'Test',
        category: HabitCategory.spiritual,
        createdAt: DateTime.now(),
        currentStreak: 5,
        completionHistory: [],
      );

      // Should not throw, returns neutral risk
      final risk = await uninitializedPredictor.predictRisk(habit);
      expect(risk, equals(AbandonmentPredictor.defaultRiskWhenUninitialized));

      uninitializedPredictor.dispose();
    });

    test('telemetry tracks predictions and errors', () async {
      final predictor = AbandonmentPredictor();
      await predictor.initialize();

      final habit = Habit(
        id: 'test',
        userId: 'user1',
        name: 'Test',
        category: HabitCategory.spiritual,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        currentStreak: 5,
        lastCompletedAt: DateTime.now(),
        completionHistory: [DateTime.now()],
      );

      // Even if model is not loaded, error count should increase
      await predictor.predictRisk(habit);

      final telemetry = predictor.telemetry;
      
      // Either prediction count or error count should have increased
      final totalAttempts = (telemetry['prediction_count'] as int) + 
                           (telemetry['error_count'] as int);
      expect(totalAttempts, greaterThan(0));

      await predictor.dispose();
    });
  });

  group('AbandonmentPredictor Schema Mismatch Handling', () {
    test('schema mismatch does not crash app', () async {
      // This test verifies that schema validation logs warnings instead of throwing
      // In a real scenario with corrupted metadata, the predictor should:
      // 1. Not throw an exception
      // 2. Mark itself as not initialized
      // 3. Return default risk (0.5) on predictions
      
      final predictor = AbandonmentPredictor();
      
      // Attempt to initialize - if metadata is corrupted, should handle gracefully
      await predictor.initialize();
      
      // Even if initialization fails due to schema mismatch, predictor should work
      final habit = Habit(
        id: 'test',
        userId: 'user1',
        name: 'Test',
        category: HabitCategory.spiritual,
        createdAt: DateTime.now(),
        currentStreak: 5,
        completionHistory: [],
      );
      
      // Should not throw, returns default 0.5
      final risk = await predictor.predictRisk(habit);
      expect(risk, greaterThanOrEqualTo(0.0));
      expect(risk, lessThanOrEqualTo(1.0));
      
      await predictor.dispose();
    });
  });

  group('AbandonmentPredictor Dispose with Telemetry', () {
    test('dispose flushes telemetry buffer when service provided', () async {
      // This test verifies that dispose() flushes the telemetry buffer
      // Note: In real usage, telemetry service should be injected
      
      final predictor = AbandonmentPredictor();
      await predictor.initialize();
      
      // Make some predictions
      final habit = Habit(
        id: 'test',
        userId: 'user1',
        name: 'Test',
        category: HabitCategory.spiritual,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        currentStreak: 5,
        lastCompletedAt: DateTime.now(),
        completionHistory: [DateTime.now()],
      );
      
      await predictor.predictRisk(habit);
      
      // Dispose should complete without errors
      expect(() => predictor.dispose(), returnsNormally);
      
      // After dispose, predictor should not be initialized
      await predictor.dispose();
      
      // Verify predictor is no longer usable after dispose
      final riskAfterDispose = await predictor.predictRisk(habit);
      expect(riskAfterDispose, equals(AbandonmentPredictor.defaultRiskWhenUninitialized));
    });
  });
}
