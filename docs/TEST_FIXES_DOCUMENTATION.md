# Test Fixes & Bug Documentation

## Summary

**Date:** 2026-02-27  
**Previous:** 1137 passing, 9 failing (31+ minutes run time)  
**After fix:** 1165 passing, 0 failing (1:12 run time)

---

## Bug #1: `AbandonmentPredictor.initialize()` hangs on `rootBundle.loadString()` in tests

### Severity: **Critical (blocked 9 tests, added 30+ min to CI)**

### Root Cause
`AbandonmentPredictor.initialize()` called `rootBundle.loadString()` to load `model_metadata.json` and `scaler_params.json` **before** checking the `assetLoaderOverride` field. The existing `assetLoaderOverride` only replaced the TFLite interpreter loading — not the JSON asset loading.

In Flutter test environments, `rootBundle.loadString()` hangs indefinitely when the requested asset isn't in the test asset bundle. Since `model_metadata.json` and `scaler_params.json` are ML assets not included in `flutter_test`, the call never resolves and the test times out after 10 minutes.

### Impact
- **9 test failures** all in `test/integration/ml/ai_ml_pipeline_integration_test.dart`
- **30+ minutes wasted** on timeouts (3 tests × 10min + 3 tests × 30s)
- All tests that called `AbandonmentPredictor.initialize()` were affected
- Other test files with `installFakeTflite()` had the same latent bug

### Fix

**File: `lib/core/services/ml/abandonment_predictor.dart`**
1. Added `static Future<String> Function(String asset)? assetStringLoaderOverride;` field
2. Modified `initialize()` to check `assetStringLoaderOverride` before calling `rootBundle.loadString()`
3. Both metadata and scaler JSON loading now respect the override

**File: `test/utils/tflite_test_stub.dart`**  
4. Updated `installFakeTflite()` to also set `assetStringLoaderOverride` with fake JSON data
5. Updated `uninstallFakeTflite()` to clear both overrides
6. Added fake model metadata and scaler params constants

### Production Impact
This is **NOT a production bug** — it only affects test environments. In production, `rootBundle.loadString()` works correctly because the assets are bundled in the APK/IPA. However, the fix improves the code's testability and follows the dependency inversion principle.

### Tests Added
- `test/unit/services/ml/abandonment_predictor_asset_override_test.dart` (8 new tests)
  - Initialization with both overrides set
  - Correct asset paths received
  - Custom scaler params integration
  - Invalid scaler params graceful failure
  - Override cleanup verification
  - Default risk when not initialized
  - Re-initialization after dispose

---

## Files Changed

| File | Change |
|------|--------|
| `lib/core/services/ml/abandonment_predictor.dart` | Added `assetStringLoaderOverride`, use it in `initialize()` |
| `test/utils/tflite_test_stub.dart` | `installFakeTflite` now mocks JSON loading too |
| `test/unit/services/ml/abandonment_predictor_asset_override_test.dart` | **NEW** - 8 coverage tests for the fix |

---

## Test Results

### Before Fix
```
31:37 +1137 -9: Some tests failed.
```
9 failures, all TimeoutException in `ai_ml_pipeline_integration_test.dart`:
1. ML features calculator integrates with habit predictor (10min timeout)
2. Concurrent ML predictions maintain independence (30s timeout)
3. ML predictor telemetry is available (10min timeout)
4. ML predictor handles rapid successive predictions (30s timeout)
5. Integration: Rate limiting prevents API overuse (passed)
6. Integration: ML predictor with configurable threshold (30s timeout)
7. Integration: Predictor lifecycle management (10min timeout)

### After Fix
```
01:12 +1165: All tests passed!
```
All 1165 tests pass in 72 seconds. Total test count increased by 28 (from test restructuring + new coverage tests).

