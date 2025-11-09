# Observability, i18n & DevTools Enhancement

This task addresses 4 key improvements for production debugging and complete i18n coverage:

## 1. Strategic Debug Logging for Backend Services

**Files**: 
- `lib/core/services/ml/abandonment_predictor.dart`
- `lib/core/services/ai/behavioral_engine.dart`
- `lib/core/services/background_task_service.dart`

**Methods**: `predictRisk`, `detectFailurePattern`, `findOptimalTime`, `findOptimalDays`, `performSync`, `_syncHabitsToFirestore`

**Context**: Backend services (ML predictor, behavioral engine, WorkManager background sync) currently lack visibility into their execution flow, making it difficult to diagnose issues on problematic devices (e.g., Xiaomi with aggressive battery optimization). This is particularly critical for WorkManager which has known reliability issues on certain manufacturers.

**Required changes**: Add comprehensive `debugPrint()` statements at key execution points to track:

- **Method entry/exit**: Log when methods start and complete with relevant parameters
  ```dart
  debugPrint('AbandonmentPredictor.predictRisk: Starting for habit ${habit.id}');
  // ... logic ...
  debugPrint('AbandonmentPredictor.predictRisk: Completed with risk ${risk.level}');
  ```

- **Performance metrics**: Measure execution time for ML operations
  ```dart
  final stopwatch = Stopwatch()..start();
  final result = await _model.predict(features);
  debugPrint('ML inference took ${stopwatch.elapsedMilliseconds}ms');
  ```

- **Decision points**: Log why certain paths are taken
  ```dart
  if (habit.completionHistory.length < minDataPoints) {
    debugPrint('Skipping prediction: insufficient data (${habit.completionHistory.length} < $minDataPoints)');
    return RiskLevel.unknown;
  }
  ```

- **Error conditions**: Log failures with context
  ```dart
  debugPrint('BackgroundTaskService: Sync failed for user ${userId}: $error');
  ```

**Note**: `debugPrint()` is automatically removed by tree-shaking in release builds, so there's no production performance impact.

## 2. DevToolsBanner Extension for Backend Status

**File**: `lib/dev_tools/fast_time_banner.dart`

**Current behavior**: Banner only shows FAST_TIME mode status with simulated date/time and 288x multiplier.

**Required changes**: Transform `FastTimeBanner` into a comprehensive `DevToolsBanner` that displays real-time backend health metrics:

**Architecture**:
- Rename class to `DevToolsBanner` (keep `FastTimeBanner` as deprecated alias for compatibility)
- Add expandable/collapsible view (tap to show details)
- Implement real-time status polling via providers

**Display metrics**:
1. **FAST_TIME status** (existing): Speed multiplier and simulated time
2. **Background Sync**: Last successful sync timestamp or failure with reason
   - Format: "Last sync: 2m ago ✓" or "Sync failed: 5m ago (Network error) ✗"
3. **ML Model**: Initialization status and last prediction
   - Format: "ML: Loaded ✓ | Last pred: 3m ago (Medium risk)"
4. **WorkManager**: Active status and restrictions (critical for Xiaomi debugging)
   - Format: "WorkMgr: Active ✓" or "WorkMgr: Restricted ⚠️ (Battery optimization)"
5. **Last Predictor Run**: Timestamp and result summary
   - Format: "Predictor: 8m ago → 2 high-risk habits"

**Visual design**:
- Color coding: Green (all OK), Orange (FAST_TIME active or warnings), Red (critical errors)
- Collapsed state: Single line with icons showing overall health
- Expanded state: Multi-line detailed view with all metrics
- Only visible in debug mode (`kDebugMode`)

**Implementation approach**: Create new Riverpod providers to expose backend service status:

```dart
// lib/core/providers/diagnostics_providers.dart
@riverpod
BackgroundSyncStatus backgroundSyncStatus(ref) {
  // Watch background service, return last sync time/status
}

@riverpod
Future<MLModelStatus> mlModelStatus(ref) async {
  // Check AbandonmentPredictor initialization state
}

@riverpod
Future<WorkManagerStatus> workManagerStatus(ref) async {
  // Query WorkManager status via platform channels if needed
}
```

The banner should poll these providers every 5 seconds when expanded, or every 30 seconds when collapsed to minimize overhead.

## 3. Complete i18n Coverage for Error Messages

**Files**: 
- `lib/l10n/app_en.arb` (master)
- `lib/l10n/app_es.arb`
- `lib/l10n/app_fr.arb`
- `lib/l10n/app_pt.arb`
- `lib/l10n/app_zh.arb`

**Context**: Error messages from backend services (ML predictions, background sync, network failures, validation errors) are currently hardcoded in English or missing entirely from the UI layer. This prevents proper localization testing and creates poor UX for non-English users.

**Required translations** (add to all 5 language files with appropriate translations):

**ML/Predictor errors**:
```json
"error_ml_prediction_failed": "Unable to calculate abandonment risk",
"error_ml_model_not_loaded": "Prediction model unavailable. Please restart the app.",
"error_ml_insufficient_data": "Need at least {days} days of data for predictions",
"@error_ml_insufficient_data": {
  "placeholders": {
    "days": {"type": "int"}
  }
}
```

**Background sync errors**:
```json
"error_background_sync_failed": "Sync failed: {reason}",
"error_background_sync_network": "No internet connection. Changes will sync when online.",
"error_background_sync_permission": "Background sync disabled. Enable in settings.",
"@error_background_sync_failed": {
  "placeholders": {
    "reason": {"type": "String"}
  }
}
```

**WorkManager status messages**:
```json
"status_workmanager_active": "Background sync active",
"status_workmanager_restricted": "Background sync may be limited by battery optimization",
"status_workmanager_disabled": "Background sync disabled in system settings"
```

**Behavioral engine messages**:
```json
"message_pattern_detected_weekend": "You tend to skip weekends. Try setting a reminder?",
"message_pattern_detected_evening": "Evening completion rate is low. Consider morning habits?",
"message_optimal_time_found": "Your best completion time is {time}",
"@message_optimal_time_found": {
  "placeholders": {
    "time": {"type": "String", "example": "8:00 AM"}
  }
}
```

**General backend errors**:
```json
"error_network_timeout": "Request timed out. Check your connection.",
"error_firebase_permission_denied": "Access denied. Please sign in again.",
"error_unknown": "An unexpected error occurred. Please try again."
```

**DevToolsBanner labels**:
```json
"dev_banner_title": "Developer Tools",
"dev_banner_last_sync": "Last sync: {time}",
"dev_banner_ml_status": "ML Model: {status}",
"dev_banner_workmanager": "Background: {status}",
"dev_banner_fast_time": "Time: {multiplier}x (Simulated: {date})"
```

**Implementation note**: Update all hardcoded error strings in service classes to use `AppLocalizations.of(context)` or pass localized strings from the UI layer. For services without BuildContext, consider adding error code enums that the UI layer maps to localized strings.

## 4. Test Suite Refactoring

**Files**: All files in `test/` directory

**Context**: There are 6 baseline test failures (pre-existing, unrelated to Clock PR). These need analysis to determine if they represent:
- Real bugs that need fixing
- Tests broken by legitimate refactoring (need updating)
- Obsolete tests for removed features (should be deleted)

Additionally, tests should use proper dependency injection patterns (Clock already implemented, extend to other services).

**Required actions**:

**Phase 1 - Test Failure Analysis**:
- Run full test suite and document each failure:
  ```
  Test: test/unit/services/some_test.dart:125
  Failure: Expected X but got Y
  Root cause: [Test assumes DateTime.now() but Clock now injected]
  Action: Update test to inject FixedClock
  ```

**Phase 2 - Fix or Remove**:
- **Fix tests** that fail due to Clock refactoring or legitimate code changes
  - Inject `Clock.fixed()` via test helpers: `createContainerWithFixedClock(DateTime(2025, 11, 15))`
  - Update assertions to match new behavior
  
- **Remove tests** only if:
  - They test features that no longer exist
  - They duplicate coverage provided by better tests
  - They test implementation details rather than behavior
  
- **Never remove** tests just because they're inconvenient to fix

**Phase 3 - Add Missing Coverage**:
Create integration tests for new observability features:

```dart
// test/integration/backend_diagnostics_test.dart
test('DevToolsBanner shows correct WorkManager status', () async {
  // Mock WorkManager restricted state
  // Verify banner displays warning color and message
});

test('Background sync failure appears in DevToolsBanner', () async {
  // Trigger sync failure
  // Verify banner shows error with timestamp
  // Verify localized error message displayed
});
```

**Phase 4 - Improve Test Patterns**:
- Ensure all time-dependent tests use `Clock` injection (not just new tests)
- Add tests for new debug logging (verify logs output in debug mode)
- Add tests for i18n coverage (all error paths have translations)

## Acceptance Criteria

**Observability**:
- All major methods in `AbandonmentPredictor`, `BehavioralEngine`, and `BackgroundTaskService` have entry/exit debug logs
- Performance metrics logged for ML inference operations
- Error conditions logged with sufficient context for debugging
- Debug logs visible when running `flutter run` in debug mode but absent in release builds

**DevToolsBanner**:
- Banner displays all 5 backend status indicators (FAST_TIME, sync, ML, WorkManager, predictor)
- Tap to expand/collapse functionality works smoothly
- Color coding reflects system health (green/orange/red)
- Status updates in real-time (5-second poll when expanded, 30-second when collapsed)
- Only visible in debug mode with proper feature flags
- No performance impact on main UI thread

**i18n Coverage**:
- All error messages have entries in all 5 language files (en, es, fr, pt, zh)
- Translations are contextually appropriate (not just machine-translated)
- Placeholders work correctly for dynamic values (`{days}`, `{reason}`, `{time}`)
- No hardcoded English strings remain in backend service error paths
- `AppLocalizations` properly used throughout UI error displays

**Tests**:
- All 596 tests pass (590 existing + new coverage for this task)
- 6 baseline failures are either fixed or documented with justification for removal
- New tests cover DevToolsBanner functionality (status display, color coding, polling)
- New tests cover i18n (all error paths return localized strings)
- All tests use proper DI patterns (Clock, mocked services)
- No flaky tests (deterministic, repeatable results)

**Code Quality**:
- Code passes `dart format` with no changes needed
- Code passes `dart analyze --fatal-infos` with zero errors or warnings
- No regressions in existing functionality (habits tracking, ML predictions, sync)
- Documentation updated for new DevToolsBanner usage
- README includes note about backend diagnostics banner for development

## Files to Update

**Debug Logging**:
- `lib/core/services/ml/abandonment_predictor.dart`: Add logs to `predictRisk()`, `initialize()`, `dispose()`
- `lib/core/services/ai/behavioral_engine.dart`: Add logs to `detectFailurePattern()`, `findOptimalTime()`, `findOptimalDays()`, `generatePersonalizedNudge()`
- `lib/core/services/background_task_service.dart`: Add logs to `performSync()`, `_syncHabitsToFirestore()`, error handlers

**DevToolsBanner**:
- `lib/dev_tools/fast_time_banner.dart`: Rename to `dev_tools_banner.dart`, extend functionality
- `lib/core/providers/diagnostics_providers.dart`: Create new file with status providers
- `lib/core/services/diagnostics/`: Create new directory with helper classes if needed

**i18n**:
- `lib/l10n/app_en.arb`: Add ~25 new translation keys (master file)
- `lib/l10n/app_es.arb`: Spanish translations
- `lib/l10n/app_fr.arb`: French translations
- `lib/l10n/app_pt.arb`: Portuguese translations
- `lib/l10n/app_zh.arb`: Chinese translations

**Service Updates** (for i18n integration):
- `lib/core/services/ml/abandonment_predictor.dart`: Return error codes instead of hardcoded strings
- `lib/core/services/ai/behavioral_engine.dart`: Return error codes for UI layer translation
- `lib/core/services/background_task_service.dart`: Propagate error codes to UI

**Tests**:
- `test/unit/services/abandonment_predictor_test.dart`: Fix/update failing tests
- `test/unit/services/behavioral_engine_test.dart`: Fix/update failing tests  
- `test/unit/services/background_task_service_test.dart`: Fix/update failing tests
- `test/integration/backend_diagnostics_test.dart`: New file for DevToolsBanner tests
- `test/unit/l10n/translation_completeness_test.dart`: Add verification for new keys
- All other failing test files: Analyze and fix or remove with justification

**Documentation**:
- `README.md`: Add section on DevToolsBanner usage for development/debugging
- `test/TESTING_GUIDE.md`: Update with patterns for testing observability features
