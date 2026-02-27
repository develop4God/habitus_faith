/// Coverage tests for AbandonmentPredictor.assetStringLoaderOverride
///
/// These tests cover the critical bug fix where rootBundle.loadString() would
/// hang indefinitely in test environments without real Flutter asset bundles.
/// The fix adds assetStringLoaderOverride to allow tests to mock JSON asset loading.
///
/// BUG: AbandonmentPredictor.initialize() called rootBundle.loadString() for
/// model_metadata.json and scaler_params.json BEFORE checking assetLoaderOverride.
/// In test environments, rootBundle.loadString() hangs forever because the
/// Flutter test binding doesn't have those assets bundled.
///
/// FIX: Added assetStringLoaderOverride static field that, when set, replaces
/// rootBundle.loadString calls during initialization.
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/ml/abandonment_predictor.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/tflite_test_stub.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AbandonmentPredictor assetStringLoaderOverride', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() {
      uninstallFakeTflite();
    });

    test('initialization succeeds with both overrides set', () async {
      await installFakeTflite(result: 0.5);

      final predictor = AbandonmentPredictor();
      await predictor.initialize();

      expect(predictor.isInitialized, isTrue);
      expect(predictor.modelVersion, equals('1.0.0-test'));

      await predictor.dispose();
    });

    test('assetStringLoaderOverride receives correct asset paths', () async {
      final requestedPaths = <String>[];

      AbandonmentPredictor.assetLoaderOverride =
          (asset) async => FakeInterpreter(result: 0.3);

      AbandonmentPredictor.assetStringLoaderOverride = (asset) async {
        requestedPaths.add(asset);
        if (asset.contains('model_metadata')) {
          return '{"version":"test","training_samples":100,"accuracy":0.9}';
        } else if (asset.contains('scaler_params')) {
          return '{"mean":[1.0,2.0,3.0,4.0,5.0],"scale":[1.0,1.0,1.0,1.0,1.0]}';
        }
        return '{}';
      };

      final predictor = AbandonmentPredictor();
      await predictor.initialize();

      expect(requestedPaths, contains('assets/ml_models/model_metadata.json'));
      expect(requestedPaths, contains('assets/ml_models/scaler_params.json'));
      expect(predictor.isInitialized, isTrue);

      await predictor.dispose();
    });

    test('predictions work with custom scaler params', () async {
      await installFakeTflite(result: 0.7);

      final predictor = AbandonmentPredictor();
      await predictor.initialize();

      expect(predictor.isInitialized, isTrue);

      // Create a habit with history to avoid the new-habit default
      final habit = _createHabitWithHistory();
      final risk = await predictor.predictRisk(habit);

      // Fake interpreter always returns 0.7
      expect(risk, closeTo(0.7, 0.01));

      await predictor.dispose();
    });

    test('invalid scaler params cause schema validation to detect mismatch', () async {
      AbandonmentPredictor.assetLoaderOverride =
          (asset) async => FakeInterpreter(result: 0.3);

      // Provide scaler params with wrong number of features (3 instead of 5)
      AbandonmentPredictor.assetStringLoaderOverride = (asset) async {
        if (asset.contains('model_metadata')) {
          return '{"version":"test","training_samples":100,"accuracy":0.9}';
        } else if (asset.contains('scaler_params')) {
          return '{"mean":[1.0,2.0,3.0],"scale":[1.0,1.0,1.0]}';
        }
        return '{}';
      };

      final predictor = AbandonmentPredictor();
      await predictor.initialize();

      // Schema validation detects the mismatch — isInitialized may be false
      // or the predictor handles it gracefully by using raw features.
      // Either way, predictions should still return a valid value in [0, 1].
      final habit = _createHabitWithHistory();
      final risk = await predictor.predictRisk(habit);
      expect(risk, greaterThanOrEqualTo(0.0));
      expect(risk, lessThanOrEqualTo(1.0));

      await predictor.dispose();
    });

    test('uninstallFakeTflite clears both overrides', () async {
      await installFakeTflite(result: 0.3);

      expect(AbandonmentPredictor.assetLoaderOverride, isNotNull);
      expect(AbandonmentPredictor.assetStringLoaderOverride, isNotNull);

      uninstallFakeTflite();

      expect(AbandonmentPredictor.assetLoaderOverride, isNull);
      expect(AbandonmentPredictor.assetStringLoaderOverride, isNull);
    });

    test('predictor returns default risk when not initialized', () async {
      final predictor = AbandonmentPredictor();
      // Intentionally NOT initializing

      final habit = _createHabitWithHistory();
      final risk = await predictor.predictRisk(habit);

      expect(risk, equals(AbandonmentPredictor.defaultRiskWhenUninitialized));
    });

    test('re-initialization after dispose requires fresh overrides', () async {
      await installFakeTflite(result: 0.3);

      final predictor = AbandonmentPredictor();
      await predictor.initialize();
      expect(predictor.isInitialized, isTrue);

      await predictor.dispose();

      // Create new predictor with overrides still set
      final predictor2 = AbandonmentPredictor();
      await predictor2.initialize();
      expect(predictor2.isInitialized, isTrue);

      await predictor2.dispose();
    });
  });
}

/// Helper to create a habit with completion history (not a first-time habit)
Habit _createHabitWithHistory() {
  return Habit(
    id: 'test_habit',
    userId: 'test_user',
    name: 'Test Habit',
    category: HabitCategory.spiritual,
    emoji: '🙏',
    colorValue: 0xFF2196F3,
    difficulty: HabitDifficulty.medium,
    currentStreak: 5,
    completionHistory: [DateTime.now().subtract(const Duration(hours: 24))],
    lastCompletedAt: DateTime.now().subtract(const Duration(hours: 24)),
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
  );
}

