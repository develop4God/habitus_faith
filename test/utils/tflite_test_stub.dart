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

/// Install the fake interpreter into AbandonmentPredictor for tests.
/// Optional `result` allows customizing the returned probability.
Future<void> installFakeTflite({double result = 0.3}) async {
  AbandonmentPredictor.assetLoaderOverride =
      (asset) async => FakeInterpreter(result: result);
}

/// Remove any installed override and reset to normal behavior.
void uninstallFakeTflite() {
  AbandonmentPredictor.assetLoaderOverride = null;
}
