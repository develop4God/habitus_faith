# Firebase Options Template

This is a template file for `firebase_options.dart`. The actual `firebase_options.dart` file is not tracked in Git for security reasons.

## Setup Instructions

To configure Firebase for this project, run:

```bash
# Install FlutterFire CLI if not already installed
dart pub global activate flutterfire_cli

# Configure Firebase (this will create firebase_options.dart)
flutterfire configure
```

This will:
1. Prompt you to select the Firebase project
2. Generate `firebase_options.dart` with the correct configuration
3. Download platform-specific config files:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
   - `macos/Runner/GoogleService-Info.plist`

## Project Details

- **Project ID**: `habitus-faith-app`
- **Bundle ID (iOS/macOS)**: `com.develop4God.habitusFaith`
- **Package Name (Android)**: `com.develop4God.habitusFaith`

## Manual Configuration (Alternative)

If you cannot use FlutterFire CLI, you can manually configure Firebase:

1. Download config files from [Firebase Console](https://console.firebase.google.com/)
2. Place files in the correct locations (see above)
3. Copy this template to `lib/firebase_options.dart`
4. Replace placeholder values with actual values from Firebase Console

## Security Notes

⚠️ **NEVER commit the actual `firebase_options.dart` file to Git!**

The following files are already in `.gitignore`:
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `macos/Runner/GoogleService-Info.plist`

For more information, see [Firebase Setup Guide](./FIREBASE_SETUP_GUIDE.md).

