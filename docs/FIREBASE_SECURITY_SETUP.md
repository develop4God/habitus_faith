# 🔐 Firebase Configuration Security Guide

## Overview

This guide explains how to properly configure Firebase for the Habitus Faith app after the security remediation that removed hardcoded API keys from the codebase.

## ⚠️ Security Changes Made

### What Changed
- **REMOVED**: Hardcoded Firebase API keys from `lib/firebase_options.dart`
- **ADDED**: Placeholder values requiring proper configuration
- **ADDED**: Firebase Remote Config for feature flags
- **ADDED**: ML Predictor feature flag control

### Why This Matters
- Hardcoded API keys in source code are a **critical security vulnerability**
- Keys can be extracted from compiled apps and misused
- Remote Config allows disabling features without app updates

---

## 🚀 Quick Setup (Required Steps)

### Option 1: Using FlutterFire CLI (Recommended)

The easiest and most secure method:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for all platforms
flutterfire configure

# This will:
# 1. Create/update firebase_options.dart with your API keys
# 2. Download google-services.json for Android
# 3. Download GoogleService-Info.plist for iOS/macOS
# 4. Register your apps in Firebase Console
```

### Option 2: Manual Configuration

#### For Android:

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: `habitus-faith-app`
3. Click "Add App" → Android
4. Follow the wizard to download `google-services.json`
5. Place the file in: `android/app/google-services.json`
6. The file should look like:
   ```json
   {
     "project_info": {
       "project_id": "habitus-faith-app",
       "firebase_url": "...",
       "storage_bucket": "habitus-faith-app.firebasestorage.app"
     },
     "client": [
       {
         "client_info": {
           "mobilesdk_app_id": "1:512385927943:android:c2daf83604d445feca53a2",
           "android_client_info": {
             "package_name": "com.develop4God.habitusFaith"
           }
         },
         "api_key": [
           {
             "current_key": "YOUR_ANDROID_API_KEY_HERE"
           }
         ]
       }
     ]
   }
   ```

#### For iOS/macOS:

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: `habitus-faith-app`
3. Click "Add App" → iOS
4. Follow the wizard to download `GoogleService-Info.plist`
5. Place the file in: `ios/Runner/GoogleService-Info.plist`
6. For macOS, also place in: `macos/Runner/GoogleService-Info.plist`

#### For Web:

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project → Settings → General
3. Scroll to "Your apps" → Web apps
4. Copy your web configuration
5. Update `lib/firebase_options.dart`:
   ```dart
   static const FirebaseOptions web = FirebaseOptions(
     apiKey: 'YOUR_ACTUAL_WEB_API_KEY',  // Replace this
     appId: '1:512385927943:web:YOUR_WEB_APP_ID',
     messagingSenderId: '512385927943',
     projectId: 'habitus-faith-app',
     authDomain: 'habitus-faith-app.firebaseapp.com',
     storageBucket: 'habitus-faith-app.firebasestorage.app',
   );
   ```

---

## 🔧 Firebase Remote Config Setup

### 1. Enable Remote Config in Firebase Console

1. Go to Firebase Console → Your Project
2. Click "Remote Config" in the left menu
3. Click "Create configuration"
4. Add the following parameters:

| Parameter Key | Type | Default Value | Description |
|---------------|------|---------------|-------------|
| `enable_ml_predictor` | Boolean | `true` | Enable/disable ML abandonment predictor |
| `ml_predictor_min_habits` | Number | `3` | Minimum habits required for predictions |
| `ml_prediction_threshold` | Number | `0.7` | Risk threshold for interventions (0.0-1.0) |
| `enable_analytics` | Boolean | `true` | Enable Firebase Analytics |
| `enable_crashlytics` | Boolean | `true` | Enable Firebase Crashlytics |

5. Click "Publish changes"

### 2. Set Conditions (Optional)

You can create conditions to enable/disable features for specific users:

**Example: Gradual ML Predictor Rollout**
```
Condition name: beta_users
Condition: User in random percentile <= 20%
Parameter: enable_ml_predictor = true (for beta users)
Default value: false (for other users)
```

### 3. Test Remote Config

Run the app with:
```bash
flutter run
```

Check logs for:
```
RemoteConfigService: Initialized successfully
PREDICTOR 🧠 ⏭️ ML Predictor disabled via Remote Config
```

Or:
```
RemoteConfigService: Initialized successfully
PREDICTOR 🧠 runDailyPredictions: Fetching all habits...
```

---

## 🔍 Verify Configuration

### Check Firebase Connection

```bash
# Run the app
flutter run

# Check for these messages in logs:
# ✅ Firebase initialized successfully
# ✅ RemoteConfigService: Initialized successfully
# ✅ User authenticated
```

### Check API Keys Are Not Hardcoded

```bash
# Search for the old API key (should return 0 results)
grep -r "AIzaSyC1iKq2eI-0zKxFP5N-VJJxn2YxSmK_g0I" lib/

# Should only find placeholders in firebase_options.dart
grep -r "YOUR_.*_API_KEY" lib/firebase_options.dart
```

### Verify Remote Config

```dart
// In Developer Debug page or add temporary code:
final remoteConfig = await RemoteConfigService.getInstance();
print(remoteConfig.getAllValues());

// Should print:
// {
//   enable_ml_predictor: true,
//   ml_predictor_min_habits: 3,
//   ml_prediction_threshold: 0.7,
//   enable_analytics: true,
//   enable_crashlytics: true
// }
```

---

## 🛡️ Security Best Practices

### DO ✅

- ✅ Use FlutterFire CLI to generate `firebase_options.dart`
- ✅ Add `google-services.json` and `GoogleService-Info.plist` to `.gitignore`
- ✅ Use Firebase App Check for API protection (future enhancement)
- ✅ Rotate API keys if exposed
- ✅ Use Remote Config for feature flags
- ✅ Monitor Firebase Usage dashboard for unusual activity

### DON'T ❌

- ❌ Commit `google-services.json` or `GoogleService-Info.plist` to Git
- ❌ Hardcode API keys in source code
- ❌ Share API keys in public repositories
- ❌ Use production keys in development builds
- ❌ Forget to enable App Check in production

---

## 🚨 If API Keys Were Exposed

If the old API key was compromised:

1. **Immediately delete the exposed key**:
   - Go to Firebase Console → Settings → Service Accounts
   - Delete the compromised key
   - Generate a new key

2. **Check for unauthorized usage**:
   - Firebase Console → Usage & Billing
   - Review activity for suspicious patterns
   - Check Authentication logs for unknown users

3. **Update all instances**:
   - Re-run `flutterfire configure`
   - Update all developer machines
   - Rebuild and redeploy apps

4. **Enable additional security**:
   - Enable Firebase App Check
   - Add API key restrictions in Google Cloud Console
   - Enable 2FA on Firebase account

---

## 📋 Checklist for New Developers

- [ ] Install FlutterFire CLI
- [ ] Get Firebase project access from admin
- [ ] Run `flutterfire configure`
- [ ] Verify `google-services.json` is in `android/app/`
- [ ] Verify `GoogleService-Info.plist` is in `ios/Runner/`
- [ ] Verify files are in `.gitignore`
- [ ] Run app and check Firebase connection logs
- [ ] Verify Remote Config is working
- [ ] Test ML predictor feature flag toggle

---

## 🔗 Additional Resources

- [FlutterFire Documentation](https://firebase.flutter.dev/docs/overview)
- [Firebase Remote Config Guide](https://firebase.google.com/docs/remote-config)
- [Firebase Security Best Practices](https://firebase.google.com/docs/projects/api-keys)
- [Firebase App Check](https://firebase.google.com/docs/app-check)

---

## 💬 Support

If you encounter issues:

1. Check Firebase Console for errors
2. Review app logs for Firebase initialization errors
3. Verify project ID matches: `habitus-faith-app`
4. Ensure you have proper permissions in Firebase Console
5. Contact the team for assistance

---

**Last Updated**: February 11, 2026  
**Security Audit**: Completed  
**Status**: ✅ Hardcoded keys removed, Remote Config enabled
