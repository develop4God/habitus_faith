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
  });
}