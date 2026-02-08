# Nudge Notification Implementation

## Overview
Nudge notifications are ML-based suggestions to reduce habit difficulty when the system predicts a high risk of abandonment. They use **flutter_local_notifications** directly, NOT WorkManager.

## Architecture

### Components
1. **NotificationService** - Handles all local notifications including nudges
2. **HabitPredictorService** - Triggers nudge notifications based on ML predictions
3. **WorkManager** - Only used for scheduling ML prediction background tasks (not for notifications)

## How It Works

### Production Flow
1. **WorkManager** schedules daily ML prediction task (default 6:00 AM)
2. **Background task** runs `HabitPredictorService.runDailyPredictions()`
3. **ML predictor** calculates abandonment risk for each habit
4. If risk is high, **HabitPredictorService** calls `_showNudgeNotification()`
5. **NotificationService.showImmediateNotification()** displays the nudge instantly

### Testing Flow (Developer/QA)
1. Developer taps **"Schedule Test Nudge (in 1 min)"** in Developer Debug Page
2. **NotificationService.scheduleNudgeNotification()** schedules a test nudge
3. Notification appears after specified delay (default 1 minute)
4. Can be tested without waiting for ML predictions

## Key Features

### Immediate Nudges (Production)
- Triggered by ML predictions in real-time
- Uses `showImmediateNotification()` for instant delivery
- Respects 24-hour cooldown per habit (disabled in FAST_TIME mode)

### Scheduled Nudges (Testing)
- **New feature** for easy developer/QA testing
- Allows minute-level scheduling (1-60 minutes)
- Uses `scheduleNudgeNotification()` with configurable delay
- Localized messages in 5 languages (es, en, fr, pt, zh)

### Localization
Both immediate and scheduled nudges support:
- Spanish (es) - default
- English (en)
- French (fr)
- Portuguese (pt)
- Chinese (zh)

## Developer Tools

### Reset Nudge Cooldown
- Clears all cooldown timestamps
- Allows immediate re-sending of nudges for testing
- Location: Developer Debug Page

### Schedule Test Nudge
- Schedules a test nudge notification
- Default: 1 minute delay
- Parameters:
  - `habitId`: test_habit_123
  - `habitName`: Test Habit
  - `suggestedMinutes`: 10
  - `delayMinutes`: 1 (customizable)

## WorkManager vs flutter_local_notifications

### WorkManager Usage (Background Tasks)
- **Purpose**: Schedule periodic ML prediction tasks
- **Frequency**: Daily at configured hour (default 6:00 AM)
- **File**: `background_task_service.dart`
- **What it does**: Runs ML predictions in background isolate

### flutter_local_notifications Usage (Notifications)
- **Purpose**: Show and schedule all notifications
- **Types**: 
  - Immediate nudges (instant)
  - Scheduled nudges (delayed)
  - Habit reminders (recurring)
  - Daily reminders (daily)
- **File**: `notification_service.dart`
- **What it does**: Displays notifications to user

## Important Notes

1. **Nudges do NOT use WorkManager** - They use flutter_local_notifications directly
2. **WorkManager is only for ML prediction scheduling** - Not for notification delivery
3. **Cooldown system** - Prevents spam (24 hours in production, disabled in FAST_TIME)
4. **Testing support** - Easy minute-level scheduling for QA validation
5. **Localization** - Automatic based on user's selected language

## Code Locations

- **NotificationService**: `lib/core/services/notifications/notification_service.dart`
- **HabitPredictorService**: `lib/core/providers/habit_predictor_provider.dart`
- **BackgroundTaskService**: `lib/core/services/background_task_service.dart`
- **Developer Debug Page**: `lib/features/developer/developer_debug_page.dart`

## Testing Nudge Notifications

### Quick Test (1 minute)
1. Open app in debug mode
2. Navigate to Developer Debug Page (About > tap version 7 times)
3. Tap "Schedule Test Nudge (in 1 min)"
4. Wait 1 minute
5. Notification appears with test message

### Production Test
1. Create a habit with completion history
2. Run "Run ML Predictor Now" in Developer Debug Page
3. If habit has high risk (>65%), immediate nudge appears
4. Check logs for "PREDICTOR 🧠" messages

## Log Messages

All nudge-related logs use `PREDICTOR 🧠` emoji for easy filtering:
- `PREDICTOR 🧠 📅 Scheduled test nudge notification for X minute(s) from now`
- `PREDICTOR 🧠 ✅ Successfully updated habit...`
- `PREDICTOR 🧠 ❌ Failed to...`

## Future Enhancements

- [ ] Add configurable delay minutes in UI
- [ ] Support for custom nudge messages
- [ ] Analytics for nudge effectiveness
- [ ] A/B testing for nudge timing
