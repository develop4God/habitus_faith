import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:habitus_faith/core/services/ml/abandonment_predictor.dart';

/// Minimal fake Interpreter for tests that cannot load the native TFLite library.
/// Provides `run` and `close` with deterministic behavior.
class FakeInterpreter implements Interpreter {
  final double result;
  FakeInterpreter({this.result = 0.3});

  @override
  void close() {}

  @override
  void run(Object input, Object output) {
    // Provide a deterministic output for tests: return provided probability
    try {
      if (output is List && output.isNotEmpty && output[0] is List) {
        (output[0] as List)[0] = result;
      }
    } catch (_) {
      // Ignore and let tests validate ranges
    }
  }

  // The Interpreter interface has many members; tests only need run/close.
  // Provide no-op implementations for the rest via noSuchMethod.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Default fake model metadata JSON for tests
const _fakeModelMetadataJson = '''
{
  "version": "1.0.0-test",
  "training_samples": 1000,
  "accuracy": 0.85,
  "features": ["hourOfDay", "dayOfWeek", "currentStreak", "failuresLast7Days", "hoursFromReminder"],
  "feature_count": 5
}
''';

/// Default fake scaler params JSON for tests
const _fakeScalerParamsJson = '''
{
  "mean": [12.0, 4.0, 5.0, 2.0, 3.0],
  "scale": [6.0, 2.0, 5.0, 2.0, 4.0]
}
''';

/// Install the fake interpreter into AbandonmentPredictor for tests.
/// Also installs fake JSON asset loader to prevent rootBundle.loadString from hanging.
/// Optional `result` allows customizing the returned probability.
Future<void> installFakeTflite({double result = 0.3}) async {
  AbandonmentPredictor.assetLoaderOverride =
      (asset) async => FakeInterpreter(result: result);

  // Also override asset string loading to prevent rootBundle.loadString from
  // hanging indefinitely in test environments without real asset bundles.
  AbandonmentPredictor.assetStringLoaderOverride = (asset) async {
    if (asset.contains('model_metadata')) {
      return _fakeModelMetadataJson;
    } else if (asset.contains('scaler_params')) {
      return _fakeScalerParamsJson;
    }
    return '{}';
  };
}

/// Remove any installed override and reset to normal behavior.
void uninstallFakeTflite() {
  AbandonmentPredictor.assetLoaderOverride = null;
  AbandonmentPredictor.assetStringLoaderOverride = null;
}
