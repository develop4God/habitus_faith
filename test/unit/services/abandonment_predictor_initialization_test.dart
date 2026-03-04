import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/ml/abandonment_predictor.dart';
import 'package:habitus_faith/core/services/ml/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/tflite_test_stub.dart';

/// Edge-case tests for AbandonmentPredictor.initialize()
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AbandonmentPredictor.initialize — edge cases', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('throws StateError when assetLoader is null', () async {
      final predictor = AbandonmentPredictor();
      await expectLater(
        () => predictor.initialize(),
        throwsA(isA<StateError>()),
      );
      expect(predictor.isInitialized, isFalse);
      predictor.dispose();
    });

    test('StateError message contains helpful hint', () async {
      final predictor = AbandonmentPredictor();
      try {
        await predictor.initialize();
        fail('Expected StateError was not thrown');
      } on StateError catch (e) {
        expect(e.message, contains('assetLoader'));
      } finally {
        predictor.dispose();
      }
    });

    test('is idempotent — second initialize() call is a no-op', () async {
      final predictor = AbandonmentPredictor(
        assetLoader: TestAssetLoader(),
      );
      await predictor.initialize();
      expect(predictor.isInitialized, isTrue);

      // Second call should not re-run initialization
      await predictor.initialize();
      expect(predictor.isInitialized, isTrue);
      predictor.dispose();
    });

    test('initialized flag is set even when preferencesService is null',
        () async {
      final predictor = AbandonmentPredictor(
        assetLoader: TestAssetLoader(),
        // intentionally omitting preferencesService
      );
      await predictor.initialize();

      // Should initialize successfully without preferences
      expect(predictor.isInitialized, isTrue);
      predictor.dispose();
    });

    test('initialized flag is set when preferencesService is provided',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final predictor = AbandonmentPredictor(
        assetLoader: TestAssetLoader(),
        preferencesService: SharedPreferencesService(prefs),
      );
      await predictor.initialize();

      expect(predictor.isInitialized, isTrue);
      predictor.dispose();
    });

    test('isInitialized is false before initialize() is called', () {
      final predictor = AbandonmentPredictor(
        assetLoader: TestAssetLoader(),
      );
      expect(predictor.isInitialized, isFalse);
      predictor.dispose();
    });

    test('isInitialized is true when interpreter is injected via constructor',
        () {
      final predictor = AbandonmentPredictor(
        interpreter: FakeInterpreter(),
      );
      // Interpreter injection sets _initialized = true immediately
      expect(predictor.isInitialized, isTrue);
      predictor.dispose();
    });

    test('dispose resets isInitialized', () async {
      final predictor = AbandonmentPredictor(
        assetLoader: TestAssetLoader(),
      );
      await predictor.initialize();
      expect(predictor.isInitialized, isTrue);

      predictor.dispose();
      expect(predictor.isInitialized, isFalse);
    });

    test('telemetry defaults to 0 when preferencesService is null', () async {
      final predictor = AbandonmentPredictor(
        assetLoader: TestAssetLoader(),
      );
      await predictor.initialize();

      final telemetry = predictor.telemetry;
      expect(telemetry['prediction_count'], 0);
      expect(telemetry['error_count'], 0);
      predictor.dispose();
    });
  });
}
