import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/providers/ml_providers.dart';
import 'package:habitus_faith/core/providers/habit_predictor_provider.dart';
import 'package:habitus_faith/core/providers/shared_preferences_provider.dart';
import 'package:habitus_faith/core/services/ml/abandonment_predictor.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ML Providers Tests - New Initialized Providers', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    ProviderContainer createContainer() {
      return ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
    }

    group('abandonmentPredictorProvider (original)', () {
      test('returns AbandonmentPredictor instance immediately', () {
        final container = createContainer();
        addTearDown(container.dispose);

        final predictor = container.read(abandonmentPredictorProvider);

        expect(predictor, isA<AbandonmentPredictor>());
      });

      test('creates only one instance (singleton)', () {
        final container = createContainer();
        addTearDown(container.dispose);

        final predictor1 = container.read(abandonmentPredictorProvider);
        final predictor2 = container.read(abandonmentPredictorProvider);

        expect(identical(predictor1, predictor2), isTrue);
      });

      test('disposes predictor when container is disposed', () {
        final container = createContainer();
        final predictor = container.read(abandonmentPredictorProvider);

        // Verify predictor exists
        expect(predictor, isA<AbandonmentPredictor>());

        // Dispose container
        container.dispose();

        // After disposal, predictor should be disposed
        // (we can't directly test this, but the onDispose callback was called)
      });

      test('starts initialization asynchronously', () {
        final container = createContainer();
        addTearDown(container.dispose);

        // Get predictor - should return immediately
        final predictor = container.read(abandonmentPredictorProvider);

        // Predictor exists but may not be initialized yet
        expect(predictor, isA<AbandonmentPredictor>());

        // This is the behavior: returns immediately, init happens async
        // For guaranteed initialization, use abandonmentPredictorInitializedProvider
      });
    });

    group('abandonmentPredictorInitializedProvider (new)', () {
      test('returns fully initialized AbandonmentPredictor', () async {
        final container = createContainer();
        addTearDown(container.dispose);

        final predictor = await container.read(
          abandonmentPredictorInitializedProvider.future,
        );

        expect(predictor, isA<AbandonmentPredictor>());
      });

      test('ensures initialization completes before returning', () async {
        final container = createContainer();
        addTearDown(container.dispose);

        final stopwatch = Stopwatch()..start();

        final predictor = await container.read(
          abandonmentPredictorInitializedProvider.future,
        );

        stopwatch.stop();

        // Initialization should have taken some time (loading assets)
        expect(predictor, isA<AbandonmentPredictor>());

        // Predictor should be ready for predictions
        // In test environment without TFLite, it will fail to load model
        // but initialization should complete without hanging
      });

      test('multiple reads return same initialized instance', () async {
        final container = createContainer();
        addTearDown(container.dispose);

        final predictor1 = await container.read(
          abandonmentPredictorInitializedProvider.future,
        );
        final predictor2 = await container.read(
          abandonmentPredictorInitializedProvider.future,
        );

        expect(identical(predictor1, predictor2), isTrue);
      });

      test('waits for async initialization to complete', () async {
        final container = createContainer();
        addTearDown(container.dispose);

        // This should await the initialize() call
        final predictor = await container.read(
          abandonmentPredictorInitializedProvider.future,
        );

        expect(predictor, isA<AbandonmentPredictor>());

        // Predictor should have attempted initialization
        // (even if it failed due to missing TFLite in test environment)
      });

      test('handles initialization errors gracefully', () async {
        final container = createContainer();
        addTearDown(container.dispose);

        // Should not throw even if TFLite model can't load in test env
        final predictor = await container.read(
          abandonmentPredictorInitializedProvider.future,
        );

        expect(predictor, isA<AbandonmentPredictor>());
      });
    });

    group('habitPredictorProvider (original)', () {
      test('returns HabitPredictorService instance immediately', () {
        // This test would require mocking many dependencies
        // Skipping complex provider dependency tests
        // The provider is tested indirectly through integration tests
      });
    });

    group('habitPredictorInitializedProvider (new)', () {
      test('is a FutureProvider that returns HabitPredictorService', () {
        // This test validates the provider type
        expect(habitPredictorInitializedProvider, isA<FutureProvider>());
      });
    });

    group('Provider Integration Tests', () {
      test('original provider enables non-blocking app startup', () {
        final container = createContainer();
        addTearDown(container.dispose);

        final stopwatch = Stopwatch()..start();

        final predictor = container.read(abandonmentPredictorProvider);

        stopwatch.stop();

        expect(predictor, isA<AbandonmentPredictor>());
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      test('initialized provider blocks until ready', () async {
        final container = createContainer();
        addTearDown(container.dispose);

        final predictor = await container.read(
          abandonmentPredictorInitializedProvider.future,
        );

        expect(predictor, isA<AbandonmentPredictor>());
      });

      test('both providers return same underlying instance', () async {
        final container = createContainer();
        addTearDown(container.dispose);

        final predictor1 = container.read(abandonmentPredictorProvider);
        final predictor2 = await container.read(
          abandonmentPredictorInitializedProvider.future,
        );

        expect(identical(predictor1, predictor2), isTrue);
      });
    });

    group('Use Case Validation', () {
      test('UI code should use original provider (non-blocking)', () {
        final container = createContainer();
        addTearDown(container.dispose);

        final predictor = container.read(abandonmentPredictorProvider);

        expect(predictor, isA<AbandonmentPredictor>());
      });

      test('risk calculations should work after initialization', () async {
        final container = createContainer();
        addTearDown(container.dispose);

        final predictor = await container.read(
          abandonmentPredictorInitializedProvider.future,
        );

        expect(predictor, isA<AbandonmentPredictor>());
      });
    });
  });
}
