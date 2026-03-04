# Test Fixes — 2026-03-04

## Summary

Fixed **9 failing tests** across 2 test files. All tests now pass with `EXIT=0`.

---

## Fix 1 — `AbandonmentPredictor` Static Override Backward Compatibility

**Files changed:**
- `lib/core/services/ml/abandonment_predictor.dart`

**Tests fixed (5):**
- `test/unit/services/ml/abandonment_predictor_asset_override_test.dart`
  1. `initialization succeeds with both overrides set`
  2. `assetStringLoaderOverride receives correct asset paths`
  3. `predictions work with custom scaler params`
  4. `invalid scaler params cause schema validation to detect mismatch`
  5. `re-initialization after dispose requires fresh overrides`

**Root Cause (real production bug):**

A prior DI refactoring migrated `AbandonmentPredictor` from static override fields
(`assetLoaderOverride`, `assetStringLoaderOverride`) to a constructor-injected
`IAssetLoader` — which is the correct architectural direction.

However, the refactoring **removed** the fallback logic in `initialize()` that
previously used those static fields. The static fields still exist in the class,
and the test stubs (`installFakeTflite()` / `uninstallFakeTflite()`) still set
them. As a result, tests that called `AbandonmentPredictor()` with no constructor
arguments (the legacy API) received a `StateError: assetLoader is required`.

**Fix:**

`initialize()` now resolves an "effective loader" in priority order:
1. `_assetLoader` (constructor-injected — preferred, used in production)
2. Static overrides via `_StaticOverrideAssetLoader` adapter (backward-compatible
   fallback for test stubs)
3. Throws `StateError` if neither is present.

A private adapter class `_StaticOverrideAssetLoader implements IAssetLoader` was
added at the bottom of the file to bridge the static function fields to the
`IAssetLoader` interface without changing the public API.

This preserves:
- ✅ All existing tests that use `installFakeTflite()` (static override path)
- ✅ All production code that passes `assetLoader:` via constructor
- ✅ The specific coverage tests for the `assetStringLoaderOverride` mechanism

---

## Fix 2 — `HouseholdSpinnerPage` Missing Localization in Tests

**Files changed:**
- `test/widgets/household_spinner_test.dart`

**Tests fixed (4):**
- `User can see household spinner page when household tasks exist`
- `User sees empty state when no household tasks exist`
- `UI is responsive and modern with proper styling`
- `Empty add button navigates back to add tasks`

**Root Cause (test setup bug):**

`HouseholdSpinnerPage.build()` uses `AppLocalizations.of(context)!` to get
localized strings. The tests wrapped the widget in `MaterialApp` without
providing `localizationsDelegates` or `supportedLocales`, so
`AppLocalizations.of(context)` returned `null` and the `!` operator threw:

```
_TypeError: Null check operator used on a null value
  household_spinner_page.dart:352
```

The page then failed to render at all, causing cascading assertion failures
(expected text widgets were never created).

**Fix:**

Added a `_localizedApp()` helper function to the test file that wraps the
widget-under-test in a properly configured `MaterialApp` with:
- `AppLocalizations.delegate`
- `GlobalMaterialLocalizations.delegate`
- `GlobalWidgetsLocalizations.delegate`
- `GlobalCupertinoLocalizations.delegate`
- `supportedLocales: [Locale('es'), Locale('en')]`
- `locale: Locale('es')` (matches the Spanish text assertions in tests)

All 4 failing test cases were updated to use `_localizedApp()` instead of the
bare `MaterialApp(home: ...)` + outer `ProviderScope` pattern.

---

## Test Counts Before / After

| Suite | Before | After |
|---|---|---|
| `test/unit/` | 556 pass, **5 fail** | **561 pass, 0 fail** |
| `test/widgets/` | 103 pass, **4 fail** | **107 pass, 0 fail** |
| **Total** | 659 pass, **9 fail** | **668 pass, 0 fail** |

