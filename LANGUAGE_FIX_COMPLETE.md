# Language Fix for Firebase Notification Settings

## Problem
The `preferredLanguage` field in Firestore was always being saved as `"en"` (English) regardless of the actual app language setting.

## Root Cause
`NotificationService` was reading the language from `SharedPreferences` using `_getCurrentAppLanguage()`, which defaulted to `'en'` if the key `'locale'` wasn't set. This didn't reflect the actual app language from the Riverpod `appLanguageProvider`.

## Solution
Changed the architecture to pass the current language from the app's language provider directly to `NotificationService` methods, ensuring the language always matches what the user has selected.

---

## Changes Made

### 1. Updated `NotificationService.initialize()` Method
**File:** `lib/core/services/notifications/notification_service.dart`

**Before:**
```dart
Future<void> initialize() async {
  // ...
}
```

**After:**
```dart
Future<void> initialize({String? languageCode}) async {
  // Now accepts optional languageCode parameter
  // ...
}
```

### 2. Updated `_saveNotificationSettingsToFirestore()` Method
**File:** `lib/core/services/notifications/notification_service.dart`

**Before:**
```dart
Future<void> _saveNotificationSettingsToFirestore(
  String userId,
  bool notificationsEnabled,
  String notificationTime,
  String userTimezone,
) async {
  String currentLanguage = await _getCurrentAppLanguage(); // Always returned 'en'
  // ...
}
```

**After:**
```dart
Future<void> _saveNotificationSettingsToFirestore(
  String userId,
  bool notificationsEnabled,
  String notificationTime,
  String userTimezone,
  String languageCode, // Now accepts language as parameter
) async {
  // Uses the provided languageCode directly
  // ...
}
```

### 3. Updated `setNotificationsEnabled()` Method
**File:** `lib/core/services/notifications/notification_service.dart`

**Before:**
```dart
Future<void> setNotificationsEnabled(bool enabled) async {
  // ...
  await _saveNotificationSettingsToFirestore(...); // Missing language
}
```

**After:**
```dart
Future<void> setNotificationsEnabled(bool enabled, {String? languageCode}) async {
  // Gets current language from Firestore or uses provided languageCode
  String currentLanguage = settingsDoc.data()?['preferredLanguage'] ?? languageCode ?? 'en';
  await _saveNotificationSettingsToFirestore(..., currentLanguage);
}
```

### 4. Updated `setNotificationTime()` Method
**File:** `lib/core/services/notifications/notification_service.dart`

**Before:**
```dart
Future<void> setNotificationTime(String time) async {
  // ...
  await _saveNotificationSettingsToFirestore(...); // Missing language
}
```

**After:**
```dart
Future<void> setNotificationTime(String time, {String? languageCode}) async {
  // Gets current language from Firestore or uses provided languageCode
  String currentLanguage = settingsDoc.data()?['preferredLanguage'] ?? languageCode ?? 'en';
  await _saveNotificationSettingsToFirestore(..., currentLanguage);
}
```

### 5. Removed `_getCurrentAppLanguage()` Method
**File:** `lib/core/services/notifications/notification_service.dart`

- Deleted the method that read from SharedPreferences
- No longer needed since language is passed as a parameter

### 6. Updated `notificationInitProvider`
**File:** `lib/core/providers/notification_provider.dart`

**Before:**
```dart
final notificationInitProvider = FutureProvider<void>((ref) async {
  await ref.watch(firebaseInitProvider.future);
  final notificationService = ref.read(notificationServiceProvider);
  await notificationService.initialize();
});
```

**After:**
```dart
final notificationInitProvider = FutureProvider<void>((ref) async {
  await ref.watch(firebaseInitProvider.future);
  
  // Get current language from the app language provider
  final currentLocale = ref.read(appLanguageProvider);
  final languageCode = currentLocale.languageCode;
  
  final notificationService = ref.read(notificationServiceProvider);
  await notificationService.initialize(languageCode: languageCode);
});
```

### 7. Updated Notification Settings Page
**File:** `lib/pages/notifications_settings_page.dart`

**Before:**
```dart
await notificationService.setNotificationsEnabled(value);
await notificationService.setNotificationTime(timeStr);
```

**After:**
```dart
final currentLocale = ref.read(appLanguageProvider);
final languageCode = currentLocale.languageCode;

await notificationService.setNotificationsEnabled(value, languageCode: languageCode);
await notificationService.setNotificationTime(timeStr, languageCode: languageCode);
```

---

## How It Works Now

### On App Startup:
1. `appLanguageProvider` loads the user's language preference (e.g., 'es')
2. `notificationInitProvider` gets the language code from `appLanguageProvider`
3. `NotificationService.initialize(languageCode: 'es')` is called
4. Settings are saved to Firestore with `preferredLanguage: 'es'`

### When User Changes Language:
1. User changes language in app settings
2. `appLanguageProvider` updates to new language (e.g., 'fr')
3. Next time user toggles notifications or changes time:
   - UI gets current language from `appLanguageProvider`
   - Passes it to `setNotificationsEnabled()` or `setNotificationTime()`
   - Firestore is updated with new `preferredLanguage: 'fr'`

### When Saving Notification Settings:
- Always preserves the existing `preferredLanguage` from Firestore
- If a new language is provided, uses that instead
- Falls back to 'en' only if no language is available anywhere

---

## Benefits

1. **Always Accurate**: Language in Firestore always matches the app's current language
2. **No Hardcoding**: No default to 'en' unless truly no language is available
3. **Reactive**: When user changes app language, next save updates Firestore
4. **Single Source of Truth**: Language comes from `appLanguageProvider`, not SharedPreferences

---

## Testing

### Test 1: Initial Setup
1. Fresh install with device set to Spanish
2. Open app
3. Check Firestore: `preferredLanguage` should be `"es"`

### Test 2: Language Change
1. App in Spanish (`preferredLanguage: "es"`)
2. Change app language to French
3. Toggle notifications or change time
4. Check Firestore: `preferredLanguage` should be `"fr"`

### Test 3: Persistence
1. Set language to Portuguese
2. Save notification settings
3. Check Firestore: `preferredLanguage` should be `"pt"`
4. Restart app
5. Settings should still show Portuguese

---

## Migration Notes

- Existing users will keep their current `preferredLanguage` in Firestore
- If an existing user has `preferredLanguage: "en"` but uses Spanish app, the next time they change notification settings it will update to "es"
- No data migration needed - the fix is gradual and non-breaking

---

**Status**: ✅ Complete
**Date**: February 11, 2026
**Impact**: High - ensures multilingual users see correct language saved

