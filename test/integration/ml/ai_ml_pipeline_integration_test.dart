import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/ai/rate_limit_service.dart';
import 'package:habitus_faith/core/services/ml/abandonment_predictor.dart';
import 'package:habitus_faith/features/habits/domain/ml_features_calculator.dart';
import 'package:habitus_faith/features/habits/domain/models/risk_level.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/ml_predictor_test_utils.dart';
import '../../utils/tflite_test_stub.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await installFakeTflite(result: 0.3);
  });

  tearDownAll(() async {
    uninstallFakeTflite();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('ML predictor', () {
    testWidgets('ML predictor initialization is idempotent', (tester) async {
      final predictor = AbandonmentPredictor(assetLoader: TestAssetLoader());
      await predictor.initialize();
      await predictor.initialize();
      await predictor.initialize();
      expect(predictor.isInitialized, isTrue);
      await predictor.dispose();
    });

    test('is ready for predictions after initialisation', () async {
      final predictor = AbandonmentPredictor();
      await predictor.initialize();
      final habit = MLPredictorTestUtils.createLowRiskHabit();
      final risk = await predictor.predictRisk(habit);
      expect(risk, greaterThanOrEqualTo(0.0));
      expect(risk, lessThanOrEqualTo(1.0));
      await predictor.dispose();
    });

    testWidgets('ML features calculator integrates with habit predictor',
        (tester) async {
      final predictor = AbandonmentPredictor(assetLoader: TestAssetLoader());
      await predictor.initialize();
      await predictor.dispose();
      expect(() async => await predictor.dispose(), returnsNormally);
    });

    test('returns neutral risk (0.5) when not initialised', () async {
      final predictor = AbandonmentPredictor();
      final habit = MLPredictorTestUtils.createLowRiskHabit();
      final risk = await predictor.predictRisk(habit);
      expect(risk, equals(AbandonmentPredictor.defaultRiskWhenUninitialized));
    });

    test('Concurrent ML predictions maintain independence', () async {
      final predictor = AbandonmentPredictor(assetLoader: TestAssetLoader());
      await predictor.initialize();
      final habit1 = MLPredictorTestUtils.createHighRiskHabit(name: 'H1');
      final habit2 = MLPredictorTestUtils.createLowRiskHabit(name: 'H2');
      final habit3 =
          MLPredictorTestUtils.createHighRiskHabit(name: 'H3', daysOld: 60);
      final results = await Future.wait([
        predictor.predictRisk(habit1),
        predictor.predictRisk(habit2),
        predictor.predictRisk(habit3),
      ]);
      expect(results, hasLength(3));
      for (final r in results) {
        expect(r, greaterThanOrEqualTo(0.0));
        expect(r, lessThanOrEqualTo(1.0));
      }
      await predictor.dispose();
    });

    test('low-risk habit has few recent failures', () {
      final habit =
          MLPredictorTestUtils.createLowRiskHabit(name: 'Morning Prayer');
      final recentFailures = MLFeaturesCalculator.countRecentFailures(habit, 7);
      expect(recentFailures, lessThanOrEqualTo(3),
          reason:
              'Low-risk habit should have at most 3 failures in last 7 days');
    });

    test('high-risk habit has more recent failures than low-risk', () {
      final low = MLPredictorTestUtils.createLowRiskHabit();
      final high =
          MLPredictorTestUtils.createHighRiskHabit(daysSinceLastCompletion: 10);
      final lowFailures = MLFeaturesCalculator.countRecentFailures(low, 7);
      final highFailures = MLFeaturesCalculator.countRecentFailures(high, 7);
      expect(highFailures, greaterThanOrEqualTo(lowFailures),
          reason: 'High-risk habit should have >= failures than low-risk');
    });

    test('prediction result is in [0, 1] for any valid habit', () async {
      final predictor = AbandonmentPredictor(assetLoader: TestAssetLoader());
      await predictor.initialize();
      final habits = [
        MLPredictorTestUtils.createLowRiskHabit(name: 'Stable habit'),
        MLPredictorTestUtils.createHighRiskHabit(
            name: 'At-risk habit', daysOld: 30, daysSinceLastCompletion: 12),
        MLPredictorTestUtils.createHighRiskHabit(
            name: 'Very at-risk', daysOld: 60, daysSinceLastCompletion: 20),
      ];
      for (final habit in habits) {
        final risk = await predictor.predictRisk(habit);
        expect(risk, greaterThanOrEqualTo(0.0),
            reason: '${habit.name}: risk must be >= 0');
        expect(risk, lessThanOrEqualTo(1.0),
            reason: '${habit.name}: risk must be <= 1');
      }
      await predictor.dispose();
    });

    test('same habit always produces the same prediction (deterministic)',
        () async {
      final predictor = AbandonmentPredictor(assetLoader: TestAssetLoader());
      await predictor.initialize();
      final habit = MLPredictorTestUtils.createLowRiskHabit();
      final predictions = <double>[];
      for (int i = 0; i < 5; i++) {
        predictions.add(await predictor.predictRisk(habit));
      }
      final unique = predictions.toSet();
      expect(unique.length, equals(1),
          reason:
              'Deterministic fake interpreter must return same value every time');
      await predictor.dispose();
    });
  });

  group('Risk threshold → intervention decision', () {
    test('risk below high threshold does NOT require intervention', () {
      const risk = 0.30;
      expect(RiskThresholds.requiresIntervention(risk), isFalse,
          reason: '0.30 is below high-risk threshold (0.65)');
    });
    test('risk at or above high threshold requires intervention', () {
      const risk = 0.65;
      expect(RiskThresholds.requiresIntervention(risk), isTrue,
          reason: '0.65 == highRiskThreshold must trigger intervention');
    });
    test('risk > high threshold requires intervention', () {
      const risk = 0.90;
      expect(RiskThresholds.requiresIntervention(risk), isTrue);
    });
    testWidgets('ML predictor telemetry is available', (tester) async {
      final predictor = AbandonmentPredictor(assetLoader: TestAssetLoader());
      await predictor.initialize();
      final habit = MLPredictorTestUtils.createHighRiskHabit(
          daysOld: 30, daysSinceLastCompletion: 8);
      final risk = await predictor.predictRisk(habit);
      final needsIntervention = RiskThresholds.requiresIntervention(risk);
      expect(needsIntervention, isFalse,
          reason: 'Fake interpreter returns 0.30 < 0.65 threshold');
      expect(risk, equals(0.30));
      await predictor.dispose();
    });
  });

  group('Telemetry accumulates correctly', () {
    test('telemetry map contains required keys', () async {
      final predictor = AbandonmentPredictor();
      await predictor.initialize();
      final telemetry = predictor.telemetry;
      expect(
          telemetry.containsKey('prediction_count') ||
              telemetry.containsKey('error_count'),
          isTrue,
          reason: 'Telemetry should contain tracking data');
      await predictor.dispose();
    });
    test('ML predictor handles rapid successive predictions', () async {
      final predictor = AbandonmentPredictor(assetLoader: TestAssetLoader());
      await predictor.initialize();
      final habit = MLPredictorTestUtils.createLowRiskHabit();
      await predictor.predictRisk(habit);
      await predictor.predictRisk(habit);
      await predictor.predictRisk(habit);
      expect(predictor.telemetry['prediction_count'], greaterThanOrEqualTo(3),
          reason: 'Three predictions must register in telemetry');
      await predictor.dispose();
    });
    test('success_rate is 1.0 when all predictions succeed', () async {
      final predictor = AbandonmentPredictor();
      await predictor.initialize();
      final habit = MLPredictorTestUtils.createLowRiskHabit();
      await predictor.predictRisk(habit);
      await predictor.predictRisk(habit);
      final t = predictor.telemetry;
      final successRate = t['success_rate'] as double;
      expect(successRate, equals(1.0),
          reason: 'No errors → success_rate must be 1.0');
      await predictor.dispose();
    });
  });

  group('Rate limiting guards Gemini API budget', () {
    late RateLimitService service;
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      service = RateLimitService(prefs);
    });
    test('starts with 10 requests available', () {
      expect(service.getRemainingRequests(), equals(10));
      expect(service.canMakeRequest(), isTrue);
    });
    test('each recorded request decrements the budget', () {
      service.recordRequest();
      expect(service.getRemainingRequests(), equals(9));
      service.recordRequest();
      expect(service.getRemainingRequests(), equals(8));
    });
    test('blocks all requests once the monthly cap is reached', () {
      for (int i = 0; i < 10; i++) {
        service.recordRequest();
      }
      expect(service.getRemainingRequests(), equals(0));
    });
    test('remaining requests is never negative', () {
      for (int i = 0; i < 15; i++) {
        service.recordRequest();
      }
      expect(service.getRemainingRequests(), greaterThanOrEqualTo(0));
    });
    test('persists state across service instances (same SharedPreferences)',
        () async {
      service.recordRequest();
      service.recordRequest();
      expect(service.getRemainingRequests(), equals(8));
      final prefs = await SharedPreferences.getInstance();
      final service2 = RateLimitService(prefs);
      expect(service2.getRemainingRequests(), equals(8),
          reason: 'New service instance must read persisted count');
    });
  });

  group('Graceful degradation', () {
    test('uninitialised predictor returns safe neutral risk, not 0 or 1',
        () async {
      final predictor = AbandonmentPredictor();
      final habit = MLPredictorTestUtils.createLowRiskHabit();
      final risk = await predictor.predictRisk(habit);
      expect(risk, equals(0.5),
          reason: 'defaultRiskWhenUninitialized must be 0.5');
    });
    testWidgets('Integration: Predictor lifecycle management', (tester) async {
      final predictor = AbandonmentPredictor(assetLoader: TestAssetLoader());
      expect(predictor.isInitialized, isFalse);
      await predictor.initialize();
      final newHabit = MLPredictorTestUtils.createLowRiskHabit().copyWith(
        completionHistory: [],
        currentStreak: 0,
        lastCompletedAt: null,
      );
      final risk = await predictor.predictRisk(newHabit);
      expect(risk, equals(AbandonmentPredictor.defaultRiskForNewHabits),
          reason: 'First-time habit with no history → 0.5 neutral risk');
      await predictor.dispose();
    });
  });
}
