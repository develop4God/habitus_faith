Testing helper instructions

Purpose

Some unit tests run in environments where the TensorFlow Lite native library isn't available (CI or certain developer machines). To avoid runtime errors when initializing the AbandonmentPredictor, use the provided fake interpreter stub.

How to use

1. Import the stub in your test:

```dart
import 'package:habitus_faith/test/utils/tflite_test_stub.dart';
import 'package:habitus_faith/core/services/ml/abandonment_predictor.dart';
```

2. Before calling `predictor.initialize()` set the asset loader override so the predictor uses the fake interpreter instead of loading the native library:

```dart
AbandonmentPredictor.assetLoaderOverride = (asset) async => FakeInterpreter();

final predictor = AbandonmentPredictor();
await predictor.initialize();
```

3. Run tests as usual. The FakeInterpreter returns a deterministic probability (0.3) for predictions so assertions should allow the expected range (0.0 - 1.0) or the known stub value.

Notes

- Tests that already inject a `MockInterpreter` or pass an `interpreter` in the constructor do not need this override.
- Remember to clear the override after tests if you mutate global state:

```dart
AbandonmentPredictor.assetLoaderOverride = null;
```

- The stub is intentionally minimal. For more advanced test scenarios implement a custom FakeInterpreter that inspects input tensors and returns computed outputs.

