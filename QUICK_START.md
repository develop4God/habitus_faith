# Quick Start Guide 🚀

## What Changed?

### Before (Provider)
```dart
// Old way - in-memory, no persistence
class HabitService with ChangeNotifier {
  final List<Habit> _habits = [...];
  
  void toggleHabit(Habit habit) {
    habit.completed = !habit.completed;
    notifyListeners();
  }
}
```

### After (Riverpod + Firebase)
```dart
// New way - cloud-based, persistent, testable
final habitsProvider = StreamProvider<List<HabitModel>>((ref) {
  final userId = ref.watch(userIdProvider);
  return firestore
    .collection('habits')
    .where('userId', isEqualTo: userId)
    .snapshots()
    .map((snapshot) => snapshot.docs.map(HabitModel.fromFirestore).toList());
});
```

## Setup in 3 Steps

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Configure Firebase
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select project: **habitus-faith-app**
3. Enable **Authentication** → Anonymous
4. Enable **Firestore Database** → Test mode

### 3. Run Tests
```bash
flutter test
```

Expected: **19 tests passing** ✅

## Run the App

```bash
flutter run
```

## File Changes Summary

### New Files Created (15 files)
```
lib/
├── core/providers/
│   ├── auth_provider.dart          ← Firebase Auth with anonymous sign-in
│   └── firestore_provider.dart     ← Firestore instance provider
│
├── features/habits/
│   ├── models/
│   │   └── habit_model.dart        ← Full habit model with streak logic
│   └── providers/
│       └── habits_provider.dart    ← Riverpod providers for habits
│
└── firebase_options.dart            ← Cross-platform Firebase config

android/
└── app/
    └── google-services.json         ← Firebase Android config

test/
├── helpers/
│   ├── fixtures.dart                ← Test data factory
│   └── test_providers.dart          ← Mock providers for tests
│
├── unit/models/
│   └── habit_model_test.dart        ← 7 unit tests
│
├── integration/
│   └── habits_provider_test.dart    ← 5 integration tests
│
└── widget/
    └── habits_page_test.dart        ← 6 widget tests
```

### Modified Files (6 files)
```
lib/
├── main.dart                        ← Added Firebase init + ProviderScope
├── pages/
│   ├── habits_page.dart             ← Migrated to ConsumerWidget
│   └── home_page.dart               ← Added bottom navigation

android/
├── build.gradle.kts                 ← Added Firebase plugin
└── app/
    └── build.gradle.kts             ← Added google-services plugin

pubspec.yaml                         ← Added 11 new dependencies
```

## Key Features

### ✨ Habit Streak Tracking
```dart
// Automatic streak calculation
habit.completeToday()
  → First time: streak = 1
  → Consecutive: streak++
  → Gap >1 day: streak = 1 (keeps longestStreak)
  → Same day: no change
```

### 🔒 User Authentication
```dart
// Auto sign-in on app start
final authInitProvider = FutureProvider<User?>((ref) async {
  final auth = ref.watch(firebaseAuthProvider);
  if (auth.currentUser != null) return auth.currentUser;
  final userCredential = await auth.signInAnonymously();
  return userCredential.user;
});
```

### 💾 Cloud Persistence
```dart
// Habits saved to Firestore
await firestore
  .collection('habits')
  .doc(habit.id)
  .set(habit.toFirestore());
```

### 🧪 Full Test Coverage
- **Unit Tests**: Business logic (streak calculations)
- **Integration Tests**: Firebase operations with mocks
- **Widget Tests**: UI interactions with Firestore verification

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze

# Run app
flutter run

# Validate migration (custom script)
./validate.sh
```

## Test Keys for Automation

All interactive widgets have test keys:

```dart
// FAB to add habit
find.byKey(const Key('add_habit_fab'))

// Checkbox to complete habit
find.byKey(Key('habit_checkbox_${habitId}'))

// Delete button
find.byKey(Key('habit_delete_${habitId}'))

// Form inputs
find.byKey(const Key('habit_name_input'))
find.byKey(const Key('habit_description_input'))
```

## Bottom Navigation Tabs

1. **Hábitos** → HabitsPage (new Riverpod version)
2. **Biblia** → BibleReaderPage (existing)
3. **Progreso** → StatisticsPage (existing)
4. **Ajustes** → SettingsPage (existing)

## Troubleshooting

### Tests fail?
```bash
flutter clean
flutter pub get
flutter test
```

### App won't build?
1. Check Firebase Console settings
2. Verify `google-services.json` exists
3. Enable Anonymous Auth in Firebase
4. Create Firestore database

### Coverage report?
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## What's Next?

1. ✅ **Run tests** - Verify 19 tests pass
2. ✅ **Configure Firebase** - Enable Auth + Firestore
3. ✅ **Run app** - Test on device/emulator
4. ⏭️ **Production** - Update Firestore security rules
5. ⏭️ **Deploy** - Build release APK/IPA

## Resources

- 📚 [MIGRATION_COMPLETE.md](./MIGRATION_COMPLETE.md) - Full migration details
- 🧪 [TESTING.md](./TESTING.md) - Testing guide
- 🔧 [validate.sh](./validate.sh) - Validation script

## Success Criteria

✅ 19 tests passing  
✅ Coverage >70%  
✅ No analyzer errors  
✅ App runs on device  
✅ Habits persist to Firestore  
✅ Streaks calculated correctly  

---

**Status**: ✅ READY FOR TESTING

Run `./validate.sh` to verify everything is set up correctly!
