# Quick Start: Firebase Configuration

## TL;DR

Run this command to set up Firebase:

```bash
flutterfire configure
```

Then verify the following files exist (but are NOT in Git):
- ✅ `android/app/google-services.json`
- ✅ `ios/Runner/GoogleService-Info.plist` (if building for iOS)
- ✅ `macos/Runner/GoogleService-Info.plist` (if building for macOS)
- ✅ `lib/firebase_options.dart`

## Why This Approach?

### ❌ Old Approach (Hardcoded Keys)
```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIzaSy...', // ❌ Hardcoded in source code
  // ...
);
```

**Problems**:
- API keys exposed in Git history
- Keys can be extracted from compiled app
- Difficult to rotate keys
- Security risk if repository is public

### ✅ New Approach (Config Files)

**Android** reads from `google-services.json`:
- File is platform-specific
- Not committed to Git
- Easy to update
- Follows Google's best practices

**iOS/macOS** reads from `GoogleService-Info.plist`:
- File is platform-specific
- Not committed to Git
- Easy to update
- Follows Apple's best practices

**Web** still needs keys in `firebase_options.dart`:
- Web API keys are public by nature
- Protected by Firebase Security Rules
- Can be restricted by HTTP referrer

## How Android/iOS Use Config Files

### Android Build Process

1. Gradle plugin reads `google-services.json`
2. Extracts Firebase configuration
3. Generates `com.google.android.gms.R` class
4. App accesses config at runtime

This happens automatically when you build:
```bash
flutter build apk
# or
flutter build appbundle
```

### iOS Build Process

1. Xcode reads `GoogleService-Info.plist`
2. Firebase SDK loads configuration at runtime
3. No manual code changes needed

This happens automatically when you build:
```bash
flutter build ios
```

## Firebase Initialization

Your app initializes Firebase like this:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(MyApp());
}
```

Behind the scenes:
- **Android**: Uses `google-services.json` + `firebase_options.dart` as fallback
- **iOS/macOS**: Uses `GoogleService-Info.plist` + `firebase_options.dart` as fallback
- **Web**: Uses `firebase_options.dart` only

## Security Checklist

- [x] `google-services.json` in `.gitignore`
- [x] `GoogleService-Info.plist` in `.gitignore`
- [x] `firebase_options.dart` in `.gitignore`
- [x] Config files stored securely (password manager/vault)
- [x] CI/CD uses encrypted secrets
- [ ] Firebase Security Rules configured (see `firestore.rules`, `storage.rules`)
- [ ] API key restrictions enabled in Google Cloud Console

## Common Issues

### "google-services.json is missing"

You're trying to build but the file doesn't exist locally.

**Fix**:
```bash
flutterfire configure
```

### "Firebase app not initialized"

You forgot to call `Firebase.initializeApp()` before using Firebase services.

**Fix**: Ensure initialization in `main()` function.

### "API key restrictions"

Firebase API keys might be restricted in Google Cloud Console.

**Check**: Google Cloud Console → APIs & Services → Credentials

## For Team Members

When you clone this repository:

1. **Install FlutterFire CLI**:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. **Configure Firebase**:
   ```bash
   flutterfire configure
   ```

3. **Select project**: `habitus-faith-app`

4. **Select platforms**: Android, iOS, macOS, Web

5. **Verify files created**:
   ```bash
   ls android/app/google-services.json
   ls ios/Runner/GoogleService-Info.plist
   ls lib/firebase_options.dart
   ```

6. **Run the app**:
   ```bash
   flutter run
   ```

## For CI/CD

Store config files as base64-encoded secrets:

```bash
# Encode files
base64 -i android/app/google-services.json > google-services.base64
base64 -i ios/Runner/GoogleService-Info.plist > GoogleService-Info.base64
```

Then in your CI/CD pipeline:

```yaml
# GitHub Actions example
- name: Setup Firebase configs
  run: |
    echo "${{ secrets.GOOGLE_SERVICES_JSON }}" | base64 --decode > android/app/google-services.json
    echo "${{ secrets.GOOGLE_SERVICE_INFO }}" | base64 --decode > ios/Runner/GoogleService-Info.plist
```

## Related Documentation

- [Firebase Setup Guide](./FIREBASE_SETUP_GUIDE.md) - Detailed setup instructions
- [Firebase Security Setup](./FIREBASE_SECURITY_SETUP.md) - Security configuration
- [Technical Due Diligence](../TECHNICAL_DUE_DILIGENCE.md) - Full technical review

---

**Last Updated**: February 11, 2026

