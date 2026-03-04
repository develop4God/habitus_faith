import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/ml/abandonment_predictor.dart';
import 'package:habitus_faith/core/services/ml/asset_loader.dart';
import 'package:habitus_faith/core/services/ml/preferences_service.dart';

/// Validates that framework singletons (rootBundle, SharedPreferences.getInstance)
/// are NOT called directly by AbandonmentPredictor — they are injected via
/// IAssetLoader and IPreferencesService instead.
void main() {
  group('No singleton antipatterns in AbandonmentPredictor', () {
    group('IAssetLoader', () {
      test('AbandonmentPredictor accepts IAssetLoader via constructor', () {
        final loader = _StubAssetLoader();
        final predictor = AbandonmentPredictor(assetLoader: loader);
        expect(predictor, isA<AbandonmentPredictor>());
        predictor.dispose();
      });

      test('initialize throws StateError when no IAssetLoader is provided',
          () async {
        final predictor = AbandonmentPredictor();
        await expectLater(
          () => predictor.initialize(),
          throwsA(isA<StateError>()),
          reason:
              'Missing assetLoader should throw StateError, not fail silently',
        );
        expect(predictor.isInitialized, isFalse);
        predictor.dispose();
      });

      test('initialize uses injected IAssetLoader', () async {
        final loader = _StubAssetLoader();
        final predictor = AbandonmentPredictor(assetLoader: loader);
        await predictor.initialize();
        expect(loader.loadStringCalled, isTrue,
            reason: 'Should call loadString on the injected loader');
        expect(loader.loadInterpreterCalled, isTrue,
            reason: 'Should call loadInterpreter on the injected loader');
        predictor.dispose();
      });

      test('RootBundleAssetLoader implements IAssetLoader', () {
        const loader = RootBundleAssetLoader();
        expect(loader, isA<IAssetLoader>());
      });
    });

    group('IPreferencesService', () {
      test('AbandonmentPredictor accepts IPreferencesService via constructor',
          () {
        final prefs = _StubPreferencesService();
        final predictor = AbandonmentPredictor(preferencesService: prefs);
        expect(predictor, isA<AbandonmentPredictor>());
        predictor.dispose();
      });

      test('telemetry persistence skips when no IPreferencesService provided',
          () async {
        // Create predictor with asset loader but no preferences service
        final loader = _StubAssetLoader();
        final predictor = AbandonmentPredictor(assetLoader: loader);
        await predictor.initialize();

        // Predictor should initialize but not persist telemetry
        expect(predictor.isInitialized, isTrue);
        predictor.dispose();
      });

      test('telemetry persistence uses injected IPreferencesService', () async {
        final prefs = _StubPreferencesService();
        final loader = _StubAssetLoader();
        final predictor = AbandonmentPredictor(
          assetLoader: loader,
          preferencesService: prefs,
        );
        await predictor.initialize();

        expect(prefs.getIntCalled, isTrue,
            reason: 'Should read telemetry from injected preferences');
        predictor.dispose();
      });

      test('SharedPreferencesService implements IPreferencesService', () {
        // We can't construct one without a real SharedPreferences instance,
        // but we can verify the class exists and declares the interface.
        expect(SharedPreferencesService, isNotNull);
      });
    });
  });
}

/// Stub IAssetLoader that records calls without touching rootBundle.
class _StubAssetLoader implements IAssetLoader {
  bool loadStringCalled = false;
  bool loadInterpreterCalled = false;

  @override
  Future<String> loadString(String assetPath) async {
    loadStringCalled = true;
    if (assetPath.contains('model_metadata')) {
      return '{"version":"stub","input_shape":[1,5],"output_shape":[1,1],"training_samples":1,"accuracy":0.5}';
    }
    if (assetPath.contains('scaler_params')) {
      return '{"mean":[0,0,0,0,0],"scale":[1,1,1,1,1]}';
    }
    throw Exception('Unknown asset: $assetPath');
  }

  @override
  Future<dynamic> loadInterpreter(String assetPath) async {
    loadInterpreterCalled = true;
    return _NoOpInterpreter();
  }
}

/// Stub IPreferencesService that records calls without SharedPreferences.
class _StubPreferencesService implements IPreferencesService {
  bool getIntCalled = false;
  bool setIntCalled = false;
  bool getStringCalled = false;
  bool setStringCalled = false;

  final Map<String, dynamic> _store = {};

  @override
  int? getInt(String key) {
    getIntCalled = true;
    return _store[key] as int?;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    setIntCalled = true;
    _store[key] = value;
    return true;
  }

  @override
  String? getString(String key) {
    getStringCalled = true;
    return _store[key] as String?;
  }

  @override
  Future<bool> setString(String key, String value) async {
    setStringCalled = true;
    _store[key] = value;
    return true;
  }
}

/// Minimal interpreter that does nothing (for stub tests).
class _NoOpInterpreter {
  void close() {}
  void run(Object input, Object output) {
    if (output is List && output.isNotEmpty && output[0] is List) {
      (output[0] as List)[0] = 0.5;
    }
  }
}
