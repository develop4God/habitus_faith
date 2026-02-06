# ML Predictor and Notification Fix for FAST_TIME Mode

## Problem Statement

The ML predictor and notification system was not working correctly when `FAST_TIME` mode was enabled for accelerated testing. Users reported that even after waiting an hour with fast acceleration enabled (orange banner), no notifications were being sent.

## Root Causes

### 1. Background Task Scheduling Not Respecting Accelerated Time

**Issue**: The `BackgroundTaskService` was using `DateTime.now()` instead of the injected `clock` for scheduling tasks.

**Impact**: 
- When `FAST_TIME=true` is enabled, the app's internal clock runs at 288x speed (1 week in 35 minutes)
- However, WorkManager (Android's background task scheduler) operates at the OS level and always uses real system time
- This caused a mismatch: the app thought it was "tomorrow at 6 AM" in accelerated time, but WorkManager would schedule the task for the actual tomorrow at 6 AM (24 real hours away)
- ML predictions would never run at the expected accelerated time

**Example**:
```
Real time: 10:00 AM Monday
Accelerated time (288x): 2:00 PM Friday (several "days" have passed)
User sets prediction hour: 6 AM
Expected behavior: Task should run in ~16 accelerated hours (~3.3 real minutes)
Actual behavior: Task scheduled for 6 AM Tuesday (20 real hours away)
```

### 2. Missing Cooldown Tracking for Nudge Notifications

**Issue**: The `_showNudgeNotification` method had no cooldown mechanism, even though the debug page had a "Reset Nudge Cooldown" button suggesting one should exist.

**Impact**:
- Without cooldown, the same nudge notification could be sent repeatedly every time the predictor ran
- This could annoy users with notification spam
- The reset button in the debug page was non-functional

## Solutions Implemented

### 1. Fixed Background Task Scheduling for FAST_TIME Mode

**File**: `lib/core/services/background_task_service.dart`

**Changes**:
- Added detection of `FAST_TIME` environment variable
- In `FAST_TIME` mode:
  - Schedule WorkManager to run every 5 minutes (instead of once per day)
  - This allows frequent checks to see if it's "time" in accelerated time
  - Ignore battery optimization constraints for testing convenience
- Added cooldown check in `_executeDailyPrediction()`:
  - Prevents running predictions more than once per 4 real minutes
  - At 288x speed, 4 minutes = ~19 simulated hours, close to one day
  - Stores last run time in SharedPreferences

**Code snippet**:
```dart
// In scheduleDailyPrediction()
const fastTime = bool.fromEnvironment('FAST_TIME');

if (fastTime && kDebugMode) {
  // Run every 5 minutes to check if it's time
  frequency = const Duration(minutes: 5);
  initialDelay = const Duration(seconds: 30);
} else {
  // Normal mode: once per day
  final now = clock.now();
  var nextRun = DateTime(now.year, now.month, now.day, scheduledHour, 0);
  // ... calculate next run time
}
```

### 2. Implemented Cooldown Tracking for Nudge Notifications

**File**: `lib/core/providers/habit_predictor_provider.dart`

**Changes**:
- Added 24-hour cooldown to prevent notification spam
- In `FAST_TIME` mode, cooldown is disabled (set to 0 hours) to allow rapid testing
- Uses injected `clock` for proper time tracking (respects accelerated time)
- Stores last sent timestamp in SharedPreferences with key pattern `nudge_sent_{habitId}`

**Code snippet**:
```dart
// Check cooldown
final cooldownKey = '${NotificationService.nudgeSentPrefix}$habitId';
final lastSentStr = prefs.getString(cooldownKey);

if (lastSentStr != null) {
  final lastSent = DateTime.parse(lastSentStr);
  final hoursSinceLastSent = clock.now().difference(lastSent).inHours;
  
  const fastTime = bool.fromEnvironment('FAST_TIME');
  const cooldownHours = fastTime ? 0 : 24;
  
  if (hoursSinceLastSent < cooldownHours) {
    return; // Skip notification - cooldown not expired
  }
}

// Send notification and store timestamp
await notificationService.showImmediateNotification(...);
await prefs.setString(cooldownKey, clock.now().toIso8601String());
```

## Testing Instructions

### Testing with FAST_TIME Enabled

1. **Run the app with FAST_TIME enabled**:
   ```bash
   flutter run --dart-define=FAST_TIME=true
   ```

2. **Verify orange banner appears**: This confirms FAST_TIME is active (time runs at 288x speed)

3. **Open Developer Debug Page**:
   - Navigate to Settings → Developer Debug Tools
   - The page should show "Time Acceleration: ENABLED: 288x speed"

4. **Configure ML Predictor Hour**:
   - In Developer Debug Page, tap "Change Prediction Hour"
   - Set a time that's coming up soon in accelerated time
   - For example, if accelerated time shows 2:00 PM, set prediction hour to 3:00 PM
   - This means predictions should run in ~1 accelerated hour = ~12 real seconds

5. **Monitor Background Tasks**:
   - Background task should be scheduled with 30-second initial delay
   - Then runs every 5 real minutes to check if it's time
   - Look for log messages: `BackgroundTaskService: FAST_TIME - running predictions`

6. **Manually Trigger Predictions** (for immediate testing):
   - In Developer Debug Page, tap "Run ML Predictor Now"
   - This forces immediate execution regardless of scheduled time
   - Check for success message

7. **Verify Nudge Notifications**:
   - Create a habit with some history (completed days and missed days)
   - Wait for predictor to run (or trigger manually)
   - If habit is high-risk, a nudge notification should appear
   - Second run should NOT send another notification (cooldown active)
   - In FAST_TIME mode, cooldown is 0, so you can test repeatedly

8. **Reset Nudge Cooldown** (if needed for testing):
   - In Developer Debug Page, tap "Reset Nudge Cooldown"
   - This allows nudge notifications to be sent again immediately

### Testing in Normal Mode

1. **Run without FAST_TIME**:
   ```bash
   flutter run
   ```

2. **Verify normal scheduling**:
   - Background task scheduled for next occurrence of configured hour (default 6 AM)
   - Runs once per day
   - Battery optimization constraints apply

3. **Verify cooldown**:
   - Nudge notifications have 24-hour cooldown
   - Same habit won't get nudged twice in one day

## Technical Details

### Time Acceleration Math

At 288x speed:
- 1 real second = 288 simulated seconds = 4.8 simulated minutes
- 1 real minute = 4.8 simulated hours
- 5 real minutes = 24 simulated hours (1 day)
- 35 real minutes = 1 simulated week

### WorkManager Frequency Limitation

WorkManager on Android has a minimum frequency of 15 minutes for periodic tasks. Our implementation:
- Requests 5-minute frequency in FAST_TIME mode
- Android may actually run it at 15-minute intervals
- Still functional, just slower than ideal
- For instant testing, use the "Run ML Predictor Now" button

### Background Isolate Constraints

The `_executeDailyPrediction` function runs in a separate isolate with limitations:
- Cannot access Firestore directly
- Must use JSON storage (SharedPreferences)
- Must create its own ProviderContainer
- All dependencies must be re-initialized

## Files Modified

1. `lib/core/services/background_task_service.dart`
   - Added FAST_TIME detection and special scheduling logic
   - Added cooldown check in background task execution

2. `lib/core/providers/habit_predictor_provider.dart`
   - Added cooldown tracking for nudge notifications
   - Made cooldown respect FAST_TIME mode

## Related Debug Features

The Developer Debug Page (`lib/features/developer/developer_debug_page.dart`) provides:
- "Change Prediction Hour": Set custom hour for ML predictions
- "Run ML Predictor Now": Force immediate execution
- "Reset Nudge Cooldown": Clear all nudge notification cooldowns
- Time acceleration status display

## Future Improvements

1. **Better WorkManager Integration**:
   - Consider using OneTime tasks in FAST_TIME mode instead of Periodic
   - Calculate exact next run time in accelerated time
   - More precise scheduling

2. **Enhanced Logging**:
   - Add telemetry for background task execution
   - Track success/failure rates
   - Monitor actual vs expected run times

3. **UI Indicators**:
   - Show last prediction run time in UI
   - Display next scheduled run time (accounting for acceleration)
   - Visual indication of high-risk habits

## Conclusion

These changes ensure that the ML predictor and notification system work correctly in both normal mode and FAST_TIME accelerated testing mode. Users can now:
- Test the full prediction cycle in minutes instead of days
- Receive timely nudge notifications when habits are at risk
- Debug and validate the ML system behavior effectively
