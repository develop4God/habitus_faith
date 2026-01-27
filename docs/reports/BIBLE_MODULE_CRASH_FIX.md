# Bible Module Crash Fix - Firestore Permission Issue

## Issue

The app was crashing when navigating to the Bible module with the following error:

```
E/flutter (23321): [ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception: [cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation.
E/flutter (23321): #0      FirebaseFirestoreHostApi.documentReferenceGet
E/flutter (23321): #3      NotificationService.initialize.<anonymous closure> (line 127)
```

## Root Cause

The NotificationService was attempting to read notification settings from Firestore without proper error handling when the user didn't have the necessary permissions. This occurred in the auth state listener during initialization.

## Fix Applied

**File**: `lib/core/services/notifications/notification_service.dart`

**Changes**:
1. Wrapped Firestore access in the auth state listener (lines 127-151) with a try-catch block
2. Added graceful fallback to default settings when Firestore access fails
3. Added appropriate logging to track when Firestore access is denied

**Before**:
```dart
final settingsDoc = await _firestore
    .collection('users')
    .doc(userId)
    .collection('settings')
    .doc('notifications')
    .get();
// ... process settings without error handling
```

**After**:
```dart
try {
  final settingsDoc = await _firestore
      .collection('users')
      .doc(userId)
      .collection('settings')
      .doc('notifications')
      .get();
  // ... process settings
} catch (e) {
  developer.log(
    'NotificationService: Failed to read/save Firestore settings (using defaults): $e',
    name: 'NotificationService',
  );
  // Continue with default settings if Firestore access fails
}
```

## Impact

- ✅ App no longer crashes when navigating to Bible module
- ✅ Notification service gracefully handles Firestore permission denials
- ✅ Default notification settings are used when Firestore is unavailable
- ✅ No breaking changes to existing functionality
- ✅ Other Firestore access points already had proper error handling

## Testing

The fix prevents the unhandled exception and allows the app to continue functioning with default notification settings when Firestore permissions are not available.

## Firestore Security Rules Note

If you want to enable notification settings sync across devices, ensure your Firestore security rules allow authenticated users to read/write their own notification settings:

```javascript
match /users/{userId}/settings/notifications {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

---
**Date**: January 26, 2026
**Status**: Fixed ✅
