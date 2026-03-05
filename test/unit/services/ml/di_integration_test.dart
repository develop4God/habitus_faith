import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/providers/clock_provider.dart';
import 'package:habitus_faith/core/providers/ml_providers.dart';
import 'package:habitus_faith/core/providers/shared_preferences_provider.dart';
import 'package:habitus_faith/core/services/ml/abandonment_predictor.dart';
import 'package:habitus_faith/core/services/ml/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/tflite_test_stub.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  /// Helper that creates a test container wiring [TestAssetLoader] into the
  /// [abandonmentPredictorProvider] so no native TFLite library is needed.
  ProviderContainer testContainer() {
    return ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        abandonmentPredictorProvider.overrideWith((ref) {
          final clock = ref.watch(clockProvider);
          final predictor = AbandonmentPredictor(
            clock: clock,
            assetLoader: TestAssetLoader(),
            preferencesService: SharedPreferencesService(prefs),
          );
          predictor.initialize();
          ref.onDispose(() => predictor.dispose());
          return predictor;
        }),
      ],
    );
  }

  group('DI integration — provider wires dependencies correctly', () {
    test('abandonmentPredictorProvider returns an AbandonmentPredictor', () {
      final container = testContainer();
      addTearDown(container.dispose);

      final predictor = container.read(abandonmentPredictorProvider);
      expect(predictor, isA<AbandonmentPredictor>());
    });

    test('abandonmentPredictorProvider is a singleton within a container', () {
      final container = testContainer();
      addTearDown(container.dispose);

      final p1 = container.read(abandonmentPredictorProvider);
      final p2 = container.read(abandonmentPredictorProvider);
      expect(identical(p1, p2), isTrue);
    });

    test('separate containers produce independent instances', () {
      final c1 = testContainer();
      final c2 = testContainer();
      addTearDown(c1.dispose);
      addTearDown(c2.dispose);

      final p1 = c1.read(abandonmentPredictorProvider);
      final p2 = c2.read(abandonmentPredictorProvider);
      expect(identical(p1, p2), isFalse);
    });

    test(
        'abandonmentPredictorInitializedProvider returns initialized predictor',
        () async {
      final container = testContainer();
      addTearDown(container.dispose);

      final predictor = await container.read(
        abandonmentPredictorInitializedProvider.future,
      );
      expect(predictor, isA<AbandonmentPredictor>());
      // After awaiting, predictor should be initialized
      expect(predictor.isInitialized, isTrue);
    });

    test('both providers return the same underlying instance', () async {
      final container = testContainer();
      addTearDown(container.dispose);

      final sync = container.read(abandonmentPredictorProvider);
      final async = await container.read(
        abandonmentPredictorInitializedProvider.future,
      );
      expect(identical(sync, async), isTrue);
    });

    test('provider disposes predictor when container is disposed', () async {
      final container = testContainer();
      final predictor = container.read(abandonmentPredictorProvider);
      await container.read(abandonmentPredictorInitializedProvider.future);
      expect(predictor.isInitialized, isTrue);

      container.dispose();
      expect(predictor.isInitialized, isFalse);
    });
  });

  group('DI integration — overrides work correctly in tests', () {
    test('provider override replaces the whole predictor', () {
      final fakePredictor = AbandonmentPredictor(
        interpreter: FakeInterpreter(result: 0.99),
      );

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          abandonmentPredictorProvider.overrideWithValue(fakePredictor),
        ],
      );
      addTearDown(container.dispose);

      final resolved = container.read(abandonmentPredictorProvider);
      expect(identical(resolved, fakePredictor), isTrue);
    });
  });
}
