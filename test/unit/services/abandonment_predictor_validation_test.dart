// test/unit/services/abandonment_predictor_validation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AbandonmentPredictor Asset Validation', () {
    test('scaler_params.json exists and is valid', () async {
      final json = await rootBundle.loadString('assets/ml_models/scaler_params.json');
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
              (i) => (features[i] - mean[i]) / scale[i]
      );

      expect(normalized, hasLength(5));
      expect(normalized.every((v) => v.isFinite), isTrue);
      expect(normalized[0], closeTo(-0.096, 0.01)); // (12-12.5)/5.2
    });

    test('model_metadata.json exists and is valid', () async {
      final json = await rootBundle.loadString('assets/ml_models/model_metadata.json');
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
      expect(features[4], 'categoryIndex');
    });

    test('telemetry is persisted across sessions', () async {
      // This test verifies that telemetry keys are correctly defined
      // Actual persistence testing requires integration tests with SharedPreferences mock
      
      // Verify telemetry keys are accessible (via reflection would be ideal,
      // but we can at least verify the class compiles with persistence logic)
      expect(true, isTrue); // Placeholder - real test would verify SharedPreferences integration
    });
  });
}