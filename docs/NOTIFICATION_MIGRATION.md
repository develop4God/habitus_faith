# Notification Service Migration

This document describes the NotificationService migration from Devocional_nuevo to Habitus Faith.

## Overview

The NotificationService has been successfully migrated from the Devocional_nuevo repository to Habitus Faith. This service provides:

- Local push notifications using `flutter_local_notifications`
- Remote notifications via Firebase Cloud Messaging (FCM)
- Timezone-aware notification scheduling
- Permission handling for Android and iOS
- Firestore integration for syncing notification settings across devices

## Architecture

### Service Layer
- **Location**: `lib/core/services/notifications/notification_service.dart`
- **Pattern**: Singleton
- **Dependencies**: 
  - Firebase Cloud Messaging for remote notifications
  - Flutter Local Notifications for local notifications
  - Firestore for settings persistence
  - Firebase Auth for user authentication
  - Timezone for scheduling

### Provider Layer
- **Location**: `lib/core/providers/notification_provider.dart`
- **Providers**:
  - `notificationServiceProvider`: Provides the NotificationService instance
  - `notificationInitProvider`: Handles service initialization
  - `notificationsEnabledProvider`: Manages notification enabled state
  - `notificationTimeProvider`: Manages notification time configuration

### UI Layer
- **Settings Page**: `lib/pages/settings_page.dart` - Links to notification settings
- **Notification Settings Page**: `lib/pages/notifications_settings_page.dart` - Full notification configuration UI

## Features

### 1. Notification Configuration
Users can:
- Enable/disable notifications
- Select notification time using time picker
- View current notification settings

### 2. Firestore Synchronization
The following settings are synced to Firestore:
- Notification enabled/disabled state
- Notification time
- User timezone
- FCM token
- Preferred language

**Important**: Habits data remains in local JSON storage and is NOT synced to Firestore.

### 3. Localization
Notification settings UI is fully localized in:
- English (en)
- Spanish (es)
- French (fr)
- Portuguese (pt)
- Chinese (zh)

## Android Configuration

### Permissions Added
The following permissions were added to `AndroidManifest.xml`:
- `POST_NOTIFICATIONS` - Required for Android 13+
- `VIBRATE` - For notification vibration
- `RECEIVE_BOOT_COMPLETED` - To reschedule notifications after device restart
- `SCHEDULE_EXACT_ALARM` - For exact notification scheduling
- `USE_EXACT_ALARM` - For alarm functionality
- `WAKE_LOCK` - To wake device for notifications

### Broadcast Receivers
Two receivers were added:
- `ScheduledNotificationBootReceiver` - Reschedules notifications after boot
- `ScheduledNotificationReceiver` - Handles scheduled notifications

## Dependencies

The following packages were added to `pubspec.yaml`:
- `flutter_local_notifications: ^18.0.1` - Local notification support
- `timezone: ^0.9.4` - Timezone handling
- `firebase_messaging: ^15.1.5` - FCM support
- `flutter_timezone: ^3.0.1` - Device timezone detection
- `permission_handler: ^11.3.1` - Permission management

## Usage

### Initialization
The NotificationService is automatically initialized in `main.dart` when the app starts:

```dart
// In MyApp widget
ref.watch(notificationInitProvider);
```

### Accessing the Service
```dart
// Get the service instance
final notificationService = ref.read(notificationServiceProvider);

// Enable/disable notifications
await notificationService.setNotificationsEnabled(true);

// Set notification time
await notificationService.setNotificationTime('09:00');

// Show immediate notification
await notificationService.showImmediateNotification(
  'Title',
  'Body',
  payload: 'payload_data',
);
```

## Testing

Tests are located at:
- `test/core/services/notifications/notification_service_test.dart`

The tests verify:
- Provider definitions are correct
- Providers can be instantiated
- Existing functionality remains intact

## Integration with Existing Code

The migration was designed to be non-breaking:
- No changes to existing habits functionality
- Habits continue to use JSON local storage
- Notification settings use Firestore independently
- All existing tests continue to pass

## Next Steps

To fully activate notifications:
1. Deploy Firebase Cloud Functions to send scheduled notifications
2. Configure FCM in Firebase Console
3. Test notifications on physical devices (emulators have limited notification support)
4. Add notification sound assets if custom sounds are desired
5. Configure iOS notification capabilities in Xcode

## Troubleshooting

### Notifications not appearing
- Check that permissions are granted on the device
- Verify Firebase is properly initialized
- Ensure user is authenticated (anonymous or signed in)
- Check Firestore security rules allow reading/writing notification settings

### Timezone issues
- The service uses the device's local timezone
- Ensure timezone data is properly initialized
- Check that Flutter Timezone plugin is installed correctly

## Security Considerations

- Notification settings in Firestore should have appropriate security rules
- FCM tokens are stored per user and should not be shared
- Permission requests follow platform best practices
- All sensitive data is properly scoped to authenticated users
