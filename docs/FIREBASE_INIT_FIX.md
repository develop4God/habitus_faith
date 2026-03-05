# Firebase Initialization Fix - Follow-up

## Problem Identified

After the Riverpod DI migration, the NotificationService wasn't initializing because:

1. NotificationService accesses Firebase instances in its constructor:
   - `FirebaseMessaging.instance`
   - `FirebaseFirestore.instance`
   - `FirebaseAuth.instance`

2. The provider was creating NotificationService before Firebase was initialized

3. No error logs were visible because there was no listener on `notificationInitProvider`

## Solution Implemented

### 1. Updated notification_provider.dart

Made sure NotificationService is only created AFTER Firebase is initialized:

```dart
final notificationServiceProvider = Provider<NotificationService>((ref) {
  // Check if Firebase is ready (for debugging)
  final firebaseReady = ref.read(firebaseReadyProvider);
  if (!firebaseReady) {
    debugPrint('⚠️ NotificationService: Created before Firebase ready!');
  }
  
  return NotificationService.create();
});

final notificationInitProvider = FutureProvider<void>((ref) async {
  // Wait for Firebase to initialize first
  await ref.watch(firebaseInitProvider.future);
  debugPrint('🔥 NotificationService: Firebase ready, creating service...');
  
  // Now it's safe to create and initialize the notification service
  final notificationService = ref.read(notificationServiceProvider);
  await notificationService.initialize();
});
```

### 2. Updated main.dart

Added listeners to see initialization status and errors:

```dart
// Initialize NotificationService with error handling
ref.listen(notificationInitProvider, (previous, next) {
  next.when(
    data: (_) =>
        debugPrint('✅ NotificationService: Initialized successfully'),
    error: (err, stack) {
      debugPrint('❌ NotificationService: Initialization failed: $err');
      debugPrint('Stack trace: $stack');
    },
    loading: () => debugPrint('🔄 NotificationService: Initializing...'),
  );
});
ref.watch(notificationInitProvider);

// Also added listener for habitNotificationsSchedulerProvider
ref.listen(habitNotificationsSchedulerProvider, (previous, next) {
  next.when(
    data: (_) =>
        debugPrint('✅ HabitNotifications: Rescheduled successfully'),
    error: (err, stack) {
      debugPrint('❌ HabitNotifications: Rescheduling failed: $err');
      debugPrint('Stack trace: $stack');
    },
    loading: () => debugPrint('🔄 HabitNotifications: Rescheduling...'),
  );
});
ref.watch(habitNotificationsSchedulerProvider);
```

## What to Look For Now

After hot restart, you should see:

### 1. Firebase Initialization
```
🔥 [Firebase] Already initialized by native code
```

### 2. NotificationService Creation
```
🔥 NotificationService: Firebase ready, creating service...
🔄 NotificationService: Initializing...
```

### 3. NotificationService Initialization
```
NotificationService: tz.local.name: <timezone>, tz.local.currentTimeZone: ...
NotificationService: Initialized
```

### 4. Firebase Auth Detection
```
🔐 NotificationService: Authenticated user detected: <userId>
📝 NotificationService: Updating lastLogin for user <userId>...
✅ NotificationService: lastLogin updated successfully
```

### 5. FCM Initialization
```
🔔 NotificationService: Initializing FCM...
🎫 NotificationService: FCM Token received: <token>
💾 NotificationService: Attempting to save FCM token to Firestore...
✅ NotificationService: FCM token saved successfully to Firestore
```

### 6. Notifications Rescheduled
```
✅ HabitNotifications: Rescheduled successfully
```

## If You Still Don't See Logs

### Possible Causes:

1. **Firebase not authenticated yet**
   - NotificationService only logs when there's an authenticated user
   - The auth state listener won't trigger without a logged-in user

2. **Error being suppressed**
   - The error listener should now catch and display errors
   - Look for: `❌ NotificationService: Initialization failed:`

3. **Provider not being watched**
   - Hot restart should trigger provider watching
   - Try a full restart: `flutter run`

## Testing Steps

1. **Hot Restart**:
   ```
   Press 'R' in flutter run terminal
   ```

2. **Watch for New Logs**:
   - Look for the emoji prefixes: 🔥, 🔄, ✅, ❌
   - Check for "NotificationService" in logs
   - Check for "Firebase ready" message

3. **If No User Logged In**:
   - Log in to the app
   - Auth state change should trigger:
     ```
     🔐 NotificationService: Authenticated user detected
     ```

4. **Check Firestore**:
   - After login, check users/<userId>
   - Should see `lastLogin` timestamp
   - Should see `fcmToken` field

## Files Modified in This Fix

1. `lib/core/providers/notification_provider.dart`
   - Added Firebase initialization dependency
   - Added debug logging

2. `lib/main.dart`
   - Added listeners for notificationInitProvider
   - Added listener for habitNotificationsSchedulerProvider
   - Better error visibility

## Next Steps

1. **Perform Hot Restart**
   - Press 'R' in the terminal where flutter run is running

2. **Watch Logs**
   - Look for the new debug messages
   - Check for any errors

3. **Test Login** (if not logged in)
   - Open the app
   - Sign in
   - Watch for FCM token and lastLogin logs

4. **Verify Firebase**
   - Check Firestore console
   - Verify data is being written

---

**Status**: Code updated, ready for hot restart  
**Expected**: Full initialization logs with Firebase, FCM, and lastLogin tracking  
**Next**: Press 'R' for hot restart and watch the logs! 🚀

