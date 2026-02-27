import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Interface for loading assets needed by AbandonmentPredictor.
///
/// Abstracts away [rootBundle] and [Interpreter.fromAsset] so the predictor
/// can be tested without framework singletons.
abstract class IAssetLoader {
  /// Load a text asset at the given path.
  Future<String> loadString(String assetPath);

  /// Load a TFLite interpreter from the given asset path.
  /// Return type is [dynamic] so tests can supply simple doubles.
  Future<dynamic> loadInterpreter(String assetPath);
}

/// Production implementation backed by [rootBundle] and [Interpreter].
class RootBundleAssetLoader implements IAssetLoader {
  const RootBundleAssetLoader();

  @override
  Future<String> loadString(String assetPath) =>
      rootBundle.loadString(assetPath);

  @override
  Future<dynamic> loadInterpreter(String assetPath) =>
      Interpreter.fromAsset(assetPath);
}
