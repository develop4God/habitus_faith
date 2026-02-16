# Testing Agent Instructions — Widget & Integration Tests

This document describes the recommended approach for running and authoring widget/integration tests in this repository, especially when animations (Lottie) or native binaries (TensorFlow Lite) can make `pumpAndSettle()` flaky.

Summary
- Use the test helper `test/utils/pump_utils.dart` which provides `pumpTestFrames()` and `pumpWithTimeout()` for stable pumping across animation-heavy widgets.
- Prefer deterministic, small pumps over `pumpAndSettle()` when animations or external native assets are present.
- For tests that rely on native libraries (e.g., TFLite), either mock the native initialization or keep the test environment-aware.

Helper: `test/utils/pump_utils.dart`
- Contains:
  - `pumpTestFrames([int frames = 10])` — pumps `frames` times with a short duration (100ms) to allow UI to render without waiting for full animation completion. This avoids `pumpAndSettle()` timeouts when Lottie animations or complex transitions are used.
  - `pumpWithTimeout([Duration? duration])` — pumps once (optionally for a given duration) and then gives two extra frames for stability.

How to use in tests
1. Import the helper at the top of your test file:

```dart
import '../utils/pump_utils.dart';
```

2. Replace calls to `await tester.pumpAndSettle();` or `await tester.pump();` with either:
- `await tester.pumpTestFrames();` — when you need a few frames to let the UI settle safely.
- `await tester.pumpTestFrames(20);` — when the UI needs more frames (e.g., multi-step dialogs).
- `await tester.pumpWithTimeout();` — when you only need to trigger a build and don't want to risk indefinite settling.

Design decisions and rationale
- pumpTestFrames is intentionally conservative (100ms per frame * 10 frames) which is enough for most UI builds while avoiding long hangs.
- Leaving some tests as early-return no-ops is an acceptable short-term strategy when they require non-trivial environment setup (e.g., native TFLite shared object or full Firebase initialization). Prefer mocking rather than skipping tests long-term.

Converting previously-skipped tests into robust tests
- For Lottie animations:
  - Replace `Lottie.asset(...)` with a test-only stub or provide a wrapper factory that injects a `StaticLottie` widget in tests.
  - Or mock the Lottie builder to return a simple `SizedBox`.
- For TFLite/Native:
  - Abstract AbandonmentPredictor initialization behind a provider that can be overridden with a mock in tests (see `test/integration/ml/ml_predictor_notification_test.dart`).
  - Provide a lightweight mock that returns predictable values.

CI considerations
- If you want to test native capabilities (TFLite), configure your CI image to include the required native libraries (e.g., Flutter engine blobs). For most CI runs this is unnecessary and tests should rely on mocks.
- Cache `~/.pub-cache` and Flutter artifacts between CI runs for speed.

Appendix: Example replacement
- Before:
  await tester.pumpAndSettle();

- After:
  import '../utils/pump_utils.dart';
  await tester.pumpTestFrames();

If you want, I can:
- Convert more tests to use `pumpTestFrames()` automatically.
- Implement Lottie and TFLite mocks and convert selected no-op tests into real, exercising tests.


