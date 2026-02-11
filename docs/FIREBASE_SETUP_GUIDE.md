# Firebase Setup Guide

This guide explains how to properly configure Firebase for the Habitus Faith app across all platforms.

## Overview

Firebase configuration uses platform-specific files that should **NOT** be committed to version control:
- **Android**: `google-services.json`
- **iOS/macOS**: `GoogleService-Info.plist`
- **All platforms**: `firebase_options.dart` (generated)

## Prerequisites

1. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Ensure you have access to the Firebase Console:
   - Project: `habitus-faith-app`
   - URL: https://console.firebase.google.com/

## Configuration Steps

### Option 1: Using FlutterFire CLI (Recommended)

The easiest way to configure Firebase for all platforms:

```bash
# Navigate to project root
cd /path/to/habitus_faith

# Run FlutterFire configuration
flutterfire configure
```

This will:
1. Prompt you to select the Firebase project (`habitus-faith-app`)
2. Select platforms to configure (Android, iOS, macOS, Web)
3. Automatically download and place config files:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
   - `macos/Runner/GoogleService-Info.plist`
4. Generate `lib/firebase_options.dart` with correct API keys

### Option 2: Manual Configuration

If you prefer manual setup or FlutterFire CLI is unavailable:

#### Android

1. Go to Firebase Console → Project Settings → Your Apps
2. Select the Android app or create a new one
3. Download `google-services.json`
4. Place it in `android/app/google-services.json`

#### iOS/macOS

1. Go to Firebase Console → Project Settings → Your Apps
2. Select the iOS app or create a new one
3. Download `GoogleService-Info.plist`
4. Place it in:
   - `ios/Runner/GoogleService-Info.plist`
   - `macos/Runner/GoogleService-Info.plist`

#### Web

Web requires API keys in `firebase_options.dart`. Get values from:
- Firebase Console → Project Settings → Your Apps → Web App

Update `lib/firebase_options.dart`:
```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_WEB_API_KEY',
  appId: 'YOUR_WEB_APP_ID',
  messagingSenderId: '512385927943',
  projectId: 'habitus-faith-app',
  authDomain: 'habitus-faith-app.firebaseapp.com',
  storageBucket: 'habitus-faith-app.firebasestorage.app',
);
```

## Security Best Practices

### Development Environment

1. **Never commit config files to Git**
   - `.gitignore` already excludes:
     - `google-services.json`
     - `GoogleService-Info.plist`
     - `firebase_options.dart`

2. **Store files securely**
   - Use a password manager or secure cloud storage
   - Share with team members through encrypted channels

### Production/CI/CD

1. **Store config files as encrypted secrets**
   - GitHub Secrets
   - GitLab CI/CD Variables
   - Bitrise Secret Environment Variables

2. **Example: GitHub Actions**
   ```yaml
   - name: Decode google-services.json
     run: |
       echo "${{ secrets.GOOGLE_SERVICES_JSON }}" | base64 --decode > android/app/google-services.json
   
   - name: Decode GoogleService-Info.plist
     run: |
       echo "${{ secrets.GOOGLE_SERVICE_INFO_PLIST }}" | base64 --decode > ios/Runner/GoogleService-Info.plist
   ```

3. **Create base64 encoded secrets**
   ```bash
   # Android
   base64 -i android/app/google-services.json | pbcopy
   
   # iOS/macOS
   base64 -i ios/Runner/GoogleService-Info.plist | pbcopy
   ```

## Troubleshooting

### "DefaultFirebaseOptions have not been configured"

**Solution**: Run `flutterfire configure` to regenerate config files.

### "google-services.json is missing"

**Causes**:
- File not downloaded from Firebase Console
- File in wrong directory (should be `android/app/`)
- File excluded by `.gitignore` (this is intentional)

**Solution**: Download from Firebase Console and place in correct location.

### "API key restrictions"

Firebase API keys can be restricted by:
- HTTP referrers (Web)
- Android app bundle ID
- iOS bundle ID

**Check restrictions**:
1. Go to Google Cloud Console
2. Navigate to APIs & Services → Credentials
3. Find your API keys
4. Verify restrictions match your app configuration

### Testing Configuration

After setup, verify Firebase is working:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  print('Firebase initialized successfully!');
  
  runApp(MyApp());
}
```

## Environment-Specific Configuration

For multiple environments (dev, staging, production):

### Option 1: Multiple Firebase Projects

Create separate Firebase projects:
- `habitus-faith-dev`
- `habitus-faith-staging`
- `habitus-faith-app` (production)

Switch between them:
```bash
flutterfire configure --project=habitus-faith-dev
```

### Option 2: Build Flavors

Use Flutter build flavors with different config files:

```
android/app/src/
  ├── dev/google-services.json
  ├── staging/google-services.json
  └── production/google-services.json
```

## Additional Resources

- [Firebase Flutter Setup](https://firebase.google.com/docs/flutter/setup)
- [FlutterFire CLI Documentation](https://firebase.flutter.dev/docs/cli/)
- [Firebase Security Best Practices](https://firebase.google.com/support/guides/security-checklist)

## Summary

✅ **DO**:
- Use FlutterFire CLI for configuration
- Store config files securely
- Use encrypted secrets in CI/CD
- Keep config files out of version control

❌ **DON'T**:
- Commit `google-services.json` to Git
- Commit `GoogleService-Info.plist` to Git
- Commit `firebase_options.dart` with real API keys
- Share config files in plain text

---

**Last Updated**: February 11, 2026

