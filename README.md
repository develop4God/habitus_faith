# Habitus Faith 🙏

**Enterprise Flutter App for Spiritual Habit Tracking with Riverpod + Firebase**

[![Tests](https://img.shields.io/badge/tests-19%20passing-brightgreen)]()
[![Coverage](https://img.shields.io/badge/coverage-%3E70%25-brightgreen)]()
[![Flutter](https://img.shields.io/badge/flutter-3.0%2B-blue)]()
[![Riverpod](https://img.shields.io/badge/riverpod-2.5-blue)]()
[![Firebase](https://img.shields.io/badge/firebase-enabled-orange)]()

> **Haz de la fe tu mejor hábito diario** - Track your spiritual habits with intelligent streak monitoring and cloud sync.

---

## ✨ Features

- 📊 **Smart Habit Tracking** - Create and track spiritual habits
- 🔥 **Streak Monitoring** - Automatic calculation of consecutive days
- ☁️ **Cloud Sync** - Real-time sync across all devices
- 🔒 **Secure** - Anonymous authentication with user-specific data
- 📖 **Bible Reader** - Built-in Bible with multiple versions
- 📈 **Progress Stats** - Track your spiritual growth
- 🧪 **Fully Tested** - 19 comprehensive tests with >70% coverage

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.0+
- Firebase account (free)
- Android Studio or VS Code

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run Tests
```bash
flutter test
# Expected: ✅ 19 tests passing
```

### 3. Configure Firebase
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select project: `habitus-faith-app`
3. Enable Authentication → Anonymous
4. Create Firestore Database → Test mode

### 4. Run the App
```bash
flutter run
```

### 5. Validate Setup
```bash
./validate.sh
```

---

## 📚 Documentation

| Document | Description | Use When |
|----------|-------------|----------|
| **[SUMMARY.md](./SUMMARY.md)** | Complete migration summary | Want overview |
| **[QUICK_START.md](./QUICK_START.md)** | 5-minute quick start | Just starting |
| **[MIGRATION_COMPLETE.md](./MIGRATION_COMPLETE.md)** | Full migration details | Need deep dive |
| **[TESTING.md](./TESTING.md)** | Testing guide | Running tests |
| **[CHANGES.md](./CHANGES.md)** | What changed | Understanding changes |
| **[ARCHITECTURE.md](./ARCHITECTURE.md)** | Architecture & diagrams | Technical details |

---

## 🏗️ Architecture

### Tech Stack
- **State Management**: Riverpod 2.5
- **Backend**: Firebase (Auth + Firestore)
- **Database**: Cloud Firestore
- **Auth**: Firebase Anonymous Auth
- **Testing**: Flutter Test + Mocktail + Fake Firestore

### Project Structure
```
lib/
├── core/
│   └── providers/          # Firebase providers (DI)
├── features/
│   └── habits/
│       ├── models/         # HabitModel with business logic
│       └── providers/      # Riverpod providers
├── pages/                  # UI screens
└── main.dart              # App entry + Firebase init

test/
├── helpers/               # Test utilities
├── unit/                  # Business logic tests
├── integration/           # Provider tests
└── widget/               # UI tests
```

---

## 🎯 Key Features

### Habit Streak Tracking
- ✅ First completion → streak = 1
- ✅ Consecutive days → streak++
- ✅ Gap >1 day → streak resets to 1
- ✅ Same day prevention
- ✅ Longest streak maintained

### Firebase Integration
- ✅ Anonymous authentication (auto sign-in)
- ✅ Real-time Firestore sync
- ✅ User-specific data filtering
- ✅ Offline support (Firebase SDK)

### Testing
- ✅ 7 unit tests (business logic)
- ✅ 5 integration tests (Firestore)
- ✅ 6 widget tests (UI)
- ✅ Test helpers & fixtures
- ✅ >70% coverage

---

## 🧪 Testing

### Run All Tests
```bash
flutter test
```

### Run with Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Test Categories
- **Unit**: `test/unit/` - Business logic
- **Integration**: `test/integration/` - Providers + Firestore
- **Widget**: `test/widget/` - UI interactions

See **[TESTING.md](./TESTING.md)** for detailed testing guide.

---

## 📱 App Structure

### Bottom Navigation (4 Tabs)
1. **Hábitos** - Track spiritual habits
2. **Biblia** - Read Bible (4 versions)
3. **Progreso** - View statistics
4. **Ajustes** - App settings

### Habit Management
- Create habits with name, description, category
- Complete daily (with streak tracking)
- Delete with confirmation
- View current and longest streaks

---

## 🔧 Development

### Install Dependencies
```bash
flutter pub get
```

### Run Code Generation (if needed)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Analyze Code
```bash
flutter analyze
```

### Run App
```bash
flutter run
```

### Validate Everything
```bash
./validate.sh
```

---

## 🔥 Firebase Setup

### Required Services
1. **Authentication**
   - Provider: Anonymous
   - Auto sign-in on app start

2. **Firestore Database**
   - Mode: Test (development) / Production (with rules)
   - Collection: `habits`
   - Indexes: `userId`, `isArchived`, `createdAt`

### Security Rules (Production)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /habits/{habitId} {
      allow read, write: if request.auth != null && 
                         request.auth.uid == request.resource.data.userId;
    }
  }
}
```

---

## 📊 Project Statistics

- **Total Tests**: 19 (7 unit + 5 integration + 6 widget + 1 smoke)
- **Test Coverage**: >70%
- **Lines of Code**: ~2,500+
- **Files Created**: 15
- **Files Modified**: 6
- **Dependencies**: 11 production + 7 dev

---

## 🎨 Screenshots

> **Note**: Screenshots coming soon after UI testing

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new features
4. Ensure all tests pass
5. Submit a pull request

---

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Riverpod for excellent state management
- Firebase for backend services
- The open-source community

---

## 📞 Support

- 📧 Email: support@develop4god.com
- 📚 Documentation: See docs folder
- 🐛 Issues: GitHub Issues
- 💬 Discussions: GitHub Discussions

---

## 🎯 Roadmap

- [x] Basic habit tracking
- [x] Streak calculation
- [x] Firebase integration
- [x] Comprehensive testing
- [ ] Social features
- [ ] Notifications
- [ ] Analytics
- [ ] iOS support
- [ ] Web support

---

## ⚡ Quick Commands

```bash
# Setup
flutter pub get

# Test
flutter test

# Coverage
flutter test --coverage

# Analyze
flutter analyze

# Run
flutter run

# Validate
./validate.sh

# Clean
flutter clean && flutter pub get
```

---

## 📈 Status

**✅ PRODUCTION READY**

- ✅ All features implemented
- ✅ 19 tests passing
- ✅ >70% coverage
- ✅ Firebase integrated
- ✅ Documentation complete
- ✅ Ready for deployment

---

**Made with ❤️ by develop4God**

*Haz de la fe tu mejor hábito diario* 🙏

