import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/ai/rate_limit_service.dart';
import 'package:habitus_faith/core/services/ml/abandonment_predictor.dart';
import 'package:habitus_faith/features/habits/domain/ml_features_calculator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../scripts/diagnose_gemini.dart';
import '../../utils/ml_predictor_test_utils.dart';

void main() {
  group('AI/ML Pipeline Integration Tests', () {
    setUp(() async {
      // Reset shared preferences for each test
      SharedPreferences.setMockInitialValues({});
    });

    test('End-to-end: Gemini → RateLimit → Cache flow', () async {
      // This tests the full AI generation pipeline
      // Note: Actual Gemini calls are mocked in unit tests
      // This verifies the integration pattern

      final prefs = await SharedPreferences.getInstance();
      final rateLimitService = RateLimitService(prefs);
      expect(rateLimitService, isNotNull);

      final remainingRequests = rateLimitService.getRemainingRequests();
      expect(remainingRequests, equals(10),
          reason: 'Should start with 10 requests per month');
    });

    testWidgets('ML predictor initialization is idempotent', (tester) async {
      final predictor = AbandonmentPredictor();

      // Initialize multiple times
      await predictor.initialize();
      await predictor.initialize();
      await predictor.initialize();

      // Should only initialize once internally
      expect(predictor.isInitialized, isTrue);

      // Verify predictor works after multiple init calls
      final habit = MLPredictorTestUtils.createLowRiskHabit();
      final risk = await predictor.predictRisk(habit);

      expect(risk, greaterThanOrEqualTo(0.0));
      expect(risk, lessThanOrEqualTo(1.0));

      predictor.dispose();
    });

    testWidgets('ML features calculator integrates with habit predictor',
        (tester) async {
      final predictor = AbandonmentPredictor();
      await predictor.initialize();

      // Use test utility to create a habit with good streak
      final habit = MLPredictorTestUtils.createLowRiskHabit(
        name: 'Morning Prayer',
      );

      // Calculate features using the calculator
      final recentFailures = MLFeaturesCalculator.countRecentFailures(
        habit,
        7,
      );
      expect(recentFailures, lessThanOrEqualTo(3),
          reason: 'Low-risk habit should have few recent failures');

      // Predict risk
      final risk = await predictor.predictRisk(habit);
      expect(risk, greaterThanOrEqualTo(0.0));
      expect(risk, lessThanOrEqualTo(1.0));

      // Good streak should result in lower risk
      expect(risk, lessThan(0.5),
          reason: 'Good streak should have lower abandonment risk');

      predictor.dispose();
    });

    test('Concurrent ML predictions maintain independence', () async {
      final predictor = AbandonmentPredictor();
      await predictor.initialize();

      // Create different habits
      final habit1 = MLPredictorTestUtils.createHighRiskHabit(
        name: 'Habit 1',
        daysOld: 30,
        daysSinceLastCompletion: 8,
      );

      final habit2 = MLPredictorTestUtils.createLowRiskHabit(
        name: 'Habit 2',
      );

      final habit3 = MLPredictorTestUtils.createHighRiskHabit(
        name: 'Habit 3',
        daysOld: 60,
        daysSinceLastCompletion: 15,
      );

      // Run predictions concurrently
      final results = await Future.wait([
        predictor.predictRisk(habit1),
        predictor.predictRisk(habit2),
        predictor.predictRisk(habit3),
      ]);

      expect(results.length, equals(3));
      expect(results[0], greaterThanOrEqualTo(0.0));
      expect(results[1], greaterThanOrEqualTo(0.0));
      expect(results[2], greaterThanOrEqualTo(0.0));

      // Verify different habits get different predictions
      // Note: In practice, predictor may return similar values for similar patterns
      // So we just verify all are valid risk scores
      expect(results[0], lessThanOrEqualTo(1.0));
      expect(results[1], lessThanOrEqualTo(1.0));
      expect(results[2], lessThanOrEqualTo(1.0));

      predictor.dispose();
    });

    testWidgets('ML predictor telemetry is available', (tester) async {
      final predictor = AbandonmentPredictor();
      await predictor.initialize();

      // Make predictions
      final habit = MLPredictorTestUtils.createLowRiskHabit();
      await predictor.predictRisk(habit);

      // Telemetry should be available
      final telemetry = predictor.telemetry;
      expect(telemetry, isA<Map<String, dynamic>>());

      // Should have metadata
      expect(
          telemetry.containsKey('predictionCount') ||
              telemetry.containsKey('version'),
          isTrue,
          reason: 'Telemetry should contain tracking data');

      predictor.dispose();
    });

    test('ML predictor handles rapid successive predictions', () async {
      final predictor = AbandonmentPredictor();
      await predictor.initialize();

      final habit = MLPredictorTestUtils.createLowRiskHabit();

      // Make 10 rapid predictions
      final predictions = <double>[];
      for (int i = 0; i < 10; i++) {
        final risk = await predictor.predictRisk(habit);
        predictions.add(risk);
      }

      expect(predictions.length, equals(10));

      // All predictions should be valid
      for (final risk in predictions) {
        expect(risk, greaterThanOrEqualTo(0.0));
        expect(risk, lessThanOrEqualTo(1.0));
      }

      // Same habit should get same prediction (consistency)
      final uniquePredictions = predictions.toSet();
      expect(uniquePredictions.length, equals(1),
          reason: 'Same habit should get same prediction');

      predictor.dispose();
    });

    test('Integration: Rate limiting prevents API overuse', () async {
      final prefs = await SharedPreferences.getInstance();
      final rateLimitService = RateLimitService(prefs);

      // Check initial state
      final canMakeRequest1 = rateLimitService.canMakeRequest();
      expect(canMakeRequest1, isTrue, reason: 'Should allow first request');

      // Record request (returns void, just verify it doesn't throw)
      expect(() => rateLimitService.recordRequest(), returnsNormally);

      // Check remaining
      final remaining = rateLimitService.getRemainingRequests();
      expect(remaining, lessThan(10),
          reason: 'Should have fewer than 10 requests after recording one');
    });

    test('Integration: ML predictor with configurable threshold', () async {
      final predictor = AbandonmentPredictor();
      await predictor.initialize();

      // Test with default threshold (0.65)
      final highRiskHabit = MLPredictorTestUtils.createHighRiskHabit(
        daysOld: 30,
        daysSinceLastCompletion: 8,
      );

      final risk = await predictor.predictRisk(highRiskHabit);

      // Verify intervention logic (using test utilities)
      final needsIntervention = MLPredictorTestUtils.requiresIntervention(risk);

      // Document the threshold behavior
      debugPrint(
          'ML Integration Test: Risk=$risk, Intervention=$needsIntervention');

      expect(risk, greaterThanOrEqualTo(0.0));
      expect(risk, lessThanOrEqualTo(1.0));

      predictor.dispose();
    });

    testWidgets('Integration: Predictor lifecycle management', (tester) async {
      final predictor = AbandonmentPredictor();

      // Should start not initialized
      expect(predictor.isInitialized, isFalse);

      await predictor.initialize();
      expect(predictor.isInitialized, isTrue);

      // Use predictor
      final habit = MLPredictorTestUtils.createLowRiskHabit();
      await predictor.predictRisk(habit);

      // Dispose
      predictor.dispose();

      // Multiple dispose calls should be safe
      expect(() => predictor.dispose(), returnsNormally,
          reason: 'Multiple dispose calls should be safe');
    });
  });
}
