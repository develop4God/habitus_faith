import 'package:tflite_flutter/tflite_flutter.dart';

/// Minimal fake Interpreter for tests that cannot load the native TFLite library.
/// Provides `run` and `close` with deterministic behavior.
class FakeInterpreter implements Interpreter {
  @override
  void close() {}

  @override
  void run(Object input, Object output) {
    // Provide a deterministic output for tests: return 0.3 probability
    // Expect output shape [1][1]
    try {
      if (output is List && output.isNotEmpty && output[0] is List) {
        (output[0] as List)[0] = 0.3;
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

