import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/ml/asset_loader.dart';
import '../../utils/tflite_test_stub.dart';

/// Contract tests for IAssetLoader implementations.
///
/// Any class that implements IAssetLoader must satisfy every test in this file.
void main() {
  group('IAssetLoader contract — TestAssetLoader', () {
    late TestAssetLoader loader;

    setUp(() => loader = TestAssetLoader());

    test('loadString returns non-empty JSON for model_metadata path', () async {
      final result = await loader.loadString(
        'assets/ml_models/model_metadata.json',
      );
      expect(result, isNotEmpty);
      expect(result, contains('"version"'));
    });

    test('loadString returns non-empty JSON for scaler_params path', () async {
      final result = await loader.loadString(
        'assets/ml_models/scaler_params.json',
      );
      expect(result, isNotEmpty);
      expect(result, contains('"mean"'));
      expect(result, contains('"scale"'));
    });

    test('loadString throws for unknown path', () async {
      await expectLater(
        () => loader.loadString('assets/unknown/file.json'),
        throwsA(anything),
      );
    });

    test('loadInterpreter returns an object with run() method', () async {
      final interpreter = await loader.loadInterpreter(
        'assets/ml_models/predictor.tflite',
      );
      expect(interpreter, isNotNull);
      // Must support run(input, output) — verified by dynamic call
      final output = [
        [0.0]
      ];
      expect(() => (interpreter as dynamic).run([[1.0, 1.0, 1.0, 1.0, 1.0]], output),
          returnsNormally);
    });

    test('loadInterpreter result can be closed', () async {
      final interpreter = await loader.loadInterpreter(
        'assets/ml_models/predictor.tflite',
      );
      expect(() => (interpreter as dynamic).close(), returnsNormally);
    });

    test('TestAssetLoader respects custom result probability', () async {
      final customLoader = TestAssetLoader(interpreterResult: 0.9);
      final interpreter = await customLoader.loadInterpreter('any');
      final output = [
        [0.0]
      ];
      (interpreter as dynamic).run([[0.0, 0.0, 0.0, 0.0, 0.0]], output);
      expect(output[0][0], closeTo(0.9, 0.001));
    });
  });

  group('IAssetLoader contract — RootBundleAssetLoader type check', () {
    test('RootBundleAssetLoader implements IAssetLoader', () {
      const loader = RootBundleAssetLoader();
      expect(loader, isA<IAssetLoader>());
    });
  });
}
