import 'dart:convert';
import 'package:habitus_faith/core/services/ml/abandonment_predictor.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:habitus_faith/core/services/ml/asset_loader.dart';

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

/// Test [IAssetLoader] that returns fake metadata, scaler params, and a
/// [FakeInterpreter] without touching rootBundle or native libraries.
class TestAssetLoader implements IAssetLoader {
  final double interpreterResult;

  TestAssetLoader({this.interpreterResult = 0.3});

  @override
  Future<String> loadString(String assetPath) async {
    if (assetPath.contains('model_metadata')) {
      return json.encode({
        'version': '1.0.0-test',
        'input_shape': [1, 5],
        'output_shape': [1, 1],
        'training_samples': 1000,
        'accuracy': 0.85,
      });
    }
    if (assetPath.contains('scaler_params')) {
      return json.encode({
        'mean': [12.0, 4.0, 5.0, 2.0, 3.0],
        'scale': [6.0, 2.0, 5.0, 2.0, 4.0],
      });
    }
    throw Exception('Unknown asset: $assetPath');
  }

  @override
  Future<dynamic> loadInterpreter(String assetPath) async {
    return FakeInterpreter(result: interpreterResult);
  }
}

/// Installs fake TFLite interpreter and asset loader overrides for tests.
Future<void> installFakeTflite({double result = 0.3}) async {
  AbandonmentPredictor.assetLoaderOverride =
      (asset) async => FakeInterpreter(result: result);
  AbandonmentPredictor.assetStringLoaderOverride = (asset) async {
    if (asset.contains('model_metadata')) {
      return '{"version":"1.0.0-test","input_shape":[1,5],"output_shape":[1,1],"training_samples":1000,"accuracy":0.85}';
    }
    if (asset.contains('scaler_params')) {
      return '{"mean":[12.0,4.0,5.0,2.0,3.0],"scale":[6.0,2.0,5.0,2.0,4.0]}';
    }
    return '{}';
  };
}

/// Uninstalls fake TFLite interpreter and asset loader overrides after tests.
void uninstallFakeTflite() {
  AbandonmentPredictor.assetLoaderOverride = null;
  AbandonmentPredictor.assetStringLoaderOverride = null;
}
