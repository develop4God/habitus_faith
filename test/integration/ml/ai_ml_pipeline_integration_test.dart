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

  // Install deterministic fake TFLite interpreter once for the whole suite.
  // FakeInterpreter(result: 0.3) → every inference returns 0.30 probability.
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await installFakeTflite(result: 0.3);
  });

  tearDownAll(() {
    uninstallFakeTflite();
  });

  setUp(() async {
    // Fresh SharedPreferences state for every test so telemetry counters reset.
    SharedPreferences.setMockInitialValues({});
  });

  // ─────────────────────────────────────────────────────────────────────────
  // GROUP 1 – Predictor lifecycle
  // High value: verifies the service can be initialised, used and disposed
  // safely in all combinations that production code uses.
  // ─────────────────────────────────────────────────────────────────────────
  group('Predictor lifecycle', () {
    test('starts uninitialised', () {
      final predictor = AbandonmentPredictor();
      expect(predictor.isInitialized, isFalse);
      // Synchronous dispose of uninitialised predictor must not throw.
      expect(() => predictor.dispose(), returnsNormally);
    });

    test('initialises exactly once (idempotent)', () async {
      final predictor = AbandonmentPredictor();
      await predictor.initialize();
      await predictor.initialize(); // second call must be a no-op
      await predictor.initialize(); // third call must be a no-op

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

    test('multiple dispose() calls are safe', () async {
      final predictor = AbandonmentPredictor();
      await predictor.initialize();

      await predictor.dispose();
      // Second dispose should not throw.
      expect(() => predictor.dispose(), returnsNormally);
    });

    test('returns neutral risk (0.5) when not initialised', () async {
      final predictor = AbandonmentPredictor(); // never initialised
      final habit = MLPredictorTestUtils.createLowRiskHabit();
      final risk = await predictor.predictRisk(habit);

      // defaultRiskWhenUninitialized == 0.5 — safe, non-alarming default.
      expect(risk, equals(AbandonmentPredictor.defaultRiskWhenUninitialized));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // GROUP 2 – Feature extraction → prediction integration
  // High value: verifies that MLFeaturesCalculator and AbandonmentPredictor
  // work together correctly with real Habit objects.
  // ─────────────────────────────────────────────────────────────────────────
  group('Feature extraction integrates with prediction', () {
    late AbandonmentPredictor predictor;

    setUp(() async {
      predictor = AbandonmentPredictor();
      await predictor.initialize();
    });

    tearDown(() async => predictor.dispose());

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
      final high = MLPredictorTestUtils.createHighRiskHabit(
        daysSinceLastCompletion: 10,
      );

      final lowFailures = MLFeaturesCalculator.countRecentFailures(low, 7);
      final highFailures = MLFeaturesCalculator.countRecentFailures(high, 7);

      // High-risk fixture has 8+ days without completion → more missed days.
      expect(highFailures, greaterThanOrEqualTo(lowFailures),
          reason: 'High-risk habit should have >= failures than low-risk');
    });

    test('prediction result is in [0, 1] for any valid habit', () async {
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
    });

    test('same habit always produces the same prediction (deterministic)',
        () async {
      final habit = MLPredictorTestUtils.createLowRiskHabit();

      final predictions = <double>[];
      for (int i = 0; i < 5; i++) {
        predictions.add(await predictor.predictRisk(habit));
      }

      final unique = predictions.toSet();
      expect(unique.length, equals(1),
          reason:
              'Deterministic fake interpreter must return same value every time');
    });

    test('concurrent predictions complete without errors', () async {
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
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // GROUP 3 – Risk threshold → intervention decision
  // High value: these thresholds gate whether the app sends an intervention
  // notification. Getting them wrong directly hurts the user experience.
  // ─────────────────────────────────────────────────────────────────────────
  group('Risk threshold → intervention decision', () {
    test('risk below high threshold does NOT require intervention', () {
      // Fake interpreter returns 0.30 < 0.65 threshold.
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

    test('zero risk never requires intervention', () {
      expect(RiskThresholds.requiresIntervention(0.0), isFalse);
    });

    test('maximum risk (1.0) always requires intervention', () {
      expect(RiskThresholds.requiresIntervention(1.0), isTrue);
    });

    test('medium risk is correctly classified', () {
      final level =
          RiskThresholds.fromValue(RiskThresholds.mediumRiskThreshold);
      expect(level, isNotNull);
    });

    test('full pipeline: prediction → threshold gate works end-to-end',
        () async {
      // Fake interpreter returns 0.30, which is below the 0.65 intervention threshold.
      final predictor = AbandonmentPredictor();
      await predictor.initialize();

      final habit = MLPredictorTestUtils.createHighRiskHabit(
        daysOld: 30,
        daysSinceLastCompletion: 8,
      );
      final risk = await predictor.predictRisk(habit);

      final needsIntervention = RiskThresholds.requiresIntervention(risk);
      // With fake result 0.30, no intervention should be triggered.
      expect(needsIntervention, isFalse,
          reason: 'Fake interpreter returns 0.30 < 0.65 threshold');
      expect(risk, equals(0.30));

      await predictor.dispose();
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // GROUP 4 – Telemetry accumulates correctly
  // High value: telemetry drives A/B decisions and on-call alerts in prod.
  // ─────────────────────────────────────────────────────────────────────────
  group('Telemetry accumulates correctly', () {
    test('telemetry map contains required keys', () async {
      final predictor = AbandonmentPredictor();
      await predictor.initialize();

      final t = predictor.telemetry;
      expect(t, isA<Map<String, dynamic>>());
      expect(t.containsKey('prediction_count'), isTrue,
          reason: 'Must track prediction count');
      expect(t.containsKey('error_count'), isTrue,
          reason: 'Must track error count');
      expect(t.containsKey('success_rate'), isTrue,
          reason: 'Must expose success rate');

      await predictor.dispose();
    });

    test('prediction_count increments with each call', () async {
      final predictor = AbandonmentPredictor();
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

  // ─────────────────────────────────────────────────────────────────────────
  // GROUP 5 – Rate limiting guards the Gemini API budget
  // High value: without this guard the app exhausts the monthly quota and
  // all AI-powered features go dark until the next billing cycle.
  // ─────────────────────────────────────────────────────────────────────────
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

    test('blocks a second request immediately after the first (5 s delay)', () {
      service.recordRequest();
      // The 5-second minimum delay is enforced synchronously via canMakeRequest().
      expect(service.canMakeRequest(), isFalse,
          reason: 'Must enforce 5-second minimum delay between requests');
    });

    test('blocks all requests once the monthly cap is reached', () {
      // Fill the quota — must be sequential to avoid timestamp dedup.
      // Each call after the first is blocked by the 5-s delay via canMakeRequest()
      // but recordRequest() still increments the internal counter (simulates
      // requests having already been made in the past).
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

      // Re-create service from same SharedPreferences.
      final prefs = await SharedPreferences.getInstance();
      final service2 = RateLimitService(prefs);
      expect(service2.getRemainingRequests(), equals(8),
          reason: 'New service instance must read persisted count');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // GROUP 6 – Graceful degradation (resilience)
  // High value: the app must remain usable when the ML model isn't available
  // (CI/CD, older devices, first cold-start).
  // ─────────────────────────────────────────────────────────────────────────
  group('Graceful degradation', () {
    test('uninitialised predictor returns safe neutral risk, not 0 or 1',
        () async {
      final predictor = AbandonmentPredictor(); // intentionally never init'd

      final habit = MLPredictorTestUtils.createLowRiskHabit();
      final risk = await predictor.predictRisk(habit);

      // 0.5 is the "unknown" sentinel — not falsely safe (0.0) and not
      // falsely alarming (1.0).
      expect(risk, equals(0.5),
          reason: 'defaultRiskWhenUninitialized must be 0.5');
    });

    test('new habit with no history returns default risk (0.5)', () async {
      final predictor = AbandonmentPredictor();
      await predictor.initialize();

      // Habit with zero history — predictor should fall back to default.
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
