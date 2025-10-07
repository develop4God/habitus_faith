# Architecture Diagram

## 🏗️ New Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                         MyApp                                │
│                    (ConsumerWidget)                          │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              ProviderScope                            │  │
│  │                                                       │  │
│  │  ┌─────────────────────────────────────────────┐    │  │
│  │  │         Firebase Initialization              │    │  │
│  │  │     (authInitProvider - Anonymous)          │    │  │
│  │  └─────────────────────────────────────────────┘    │  │
│  │                                                       │  │
│  │  ┌─────────────────────────────────────────────┐    │  │
│  │  │            HomePage                          │    │  │
│  │  │        (Bottom Navigation)                   │    │  │
│  │  │                                              │    │  │
│  │  │  ┌──────┬──────┬──────────┬──────────┐     │    │  │
│  │  │  │Habits│Bible │Statistics│ Settings │     │    │  │
│  │  │  └──────┴──────┴──────────┴──────────┘     │    │  │
│  │  └─────────────────────────────────────────────┘    │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## 📊 Data Flow - Habits Feature

```
┌────────────────────────────────────────────────────────────────┐
│                        UI Layer                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              HabitsPage (ConsumerWidget)                 │  │
│  │                                                           │  │
│  │  - FAB → Add Habit Dialog                               │  │
│  │  - Checkbox → Complete Habit                            │  │
│  │  - Delete → Remove Habit                                │  │
│  │  - Display Streaks                                      │  │
│  └──────────────────────────────────────────────────────────┘  │
│                            ↓ ref.watch / ref.read               │
└────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────┐
│                      Provider Layer                             │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │        habitsProvider (StreamProvider)                   │  │
│  │        - Watches: userIdProvider, firestoreProvider     │  │
│  │        - Returns: Stream<List<HabitModel>>              │  │
│  │        - Filters by userId and !isArchived              │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │        habitsActionsProvider (Provider)                  │  │
│  │        - addHabit(name, description, category)          │  │
│  │        - completeHabit(habit)                           │  │
│  │        - deleteHabit(habitId)                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │        userIdProvider (Provider)                         │  │
│  │        - Watches: currentUserProvider                   │  │
│  │        - Returns: String? (user.uid)                    │  │
│  └──────────────────────────────────────────────────────────┘  │
│                            ↓                                    │
└────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────┐
│                      Core Layer                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │        currentUserProvider (StreamProvider)              │  │
│  │        - Watches: firebaseAuthProvider                  │  │
│  │        - Returns: Stream<User?>                         │  │
│  │        - Source: auth.authStateChanges()                │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │        firebaseAuthProvider (Provider)                   │  │
│  │        - Returns: FirebaseAuth.instance                 │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │        firestoreProvider (Provider)                      │  │
│  │        - Returns: FirebaseFirestore.instance            │  │
│  └──────────────────────────────────────────────────────────┘  │
│                            ↓                                    │
└────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────┐
│                    Firebase Services                            │
│  ┌──────────────────────┐  ┌─────────────────────────────────┐ │
│  │   Firebase Auth      │  │    Cloud Firestore              │ │
│  │                      │  │                                 │ │
│  │  - Anonymous login   │  │  Collection: habits             │ │
│  │  - User streams      │  │  - userId (index)              │ │
│  │                      │  │  - isArchived (index)          │ │
│  │                      │  │  - createdAt (orderBy)         │ │
│  └──────────────────────┘  └─────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────┘
```

## 🔄 Streak Calculation Flow

```
User Taps Checkbox
        ↓
HabitsPage calls habitsActions.completeHabit(habit)
        ↓
HabitModel.completeToday() business logic:
        ↓
    ┌───────────────────────────────────────┐
    │ Check if already completed today      │
    │  → If yes: return unchanged          │
    └───────────────────────────────────────┘
        ↓
    ┌───────────────────────────────────────┐
    │ Calculate streak:                     │
    │  • First time: streak = 1            │
    │  • Consecutive: streak++             │
    │  • Gap >1 day: streak = 1            │
    └───────────────────────────────────────┘
        ↓
    ┌───────────────────────────────────────┐
    │ Update longestStreak if needed        │
    └───────────────────────────────────────┘
        ↓
    ┌───────────────────────────────────────┐
    │ Add to completionHistory              │
    └───────────────────────────────────────┘
        ↓
Update Firestore document
        ↓
StreamProvider emits new data
        ↓
UI updates automatically
```

## 🧪 Testing Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Test Layer                              │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │           Test Helpers                                │  │
│  │                                                       │  │
│  │  createTestContainer(firestore, auth)                │  │
│  │    → Overrides providers with mocks                  │  │
│  │                                                       │  │
│  │  TestFixtures                                        │  │
│  │    → habitOracion()                                  │  │
│  │    → habitLectura()                                  │  │
│  │    → habitConRacha(days)                            │  │
│  │    → listaHabitos(count)                            │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │           Unit Tests (7 tests)                       │  │
│  │                                                       │  │
│  │  Test HabitModel business logic:                    │  │
│  │    - Streak calculations                            │  │
│  │    - Serialization                                  │  │
│  │    - Edge cases                                     │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │       Integration Tests (5 tests)                    │  │
│  │                                                       │  │
│  │  Test Providers with Firestore:                     │  │
│  │    - CRUD operations                                │  │
│  │    - Data filtering                                 │  │
│  │    - Real Firestore mocks                          │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         Widget Tests (6 tests)                       │  │
│  │                                                       │  │
│  │  Test UI interactions:                               │  │
│  │    - User flows                                      │  │
│  │    - Firestore integration                          │  │
│  │    - State updates                                  │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Mocks Used                              │  │
│  │                                                       │  │
│  │  FakeFirebaseFirestore                              │  │
│  │  MockFirebaseAuth                                   │  │
│  │  ProviderContainer (with overrides)                 │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## 📦 Dependency Graph

```
┌─────────────────────────────────────────────────────────────┐
│                    Application                               │
│                                                              │
│  MyApp (ConsumerWidget)                                      │
│    ↓ watches                                                │
│  authInitProvider                                           │
│    ↓ depends on                                             │
│  firebaseAuthProvider                                       │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                  Habits Feature                              │
│                                                              │
│  HabitsPage (ConsumerWidget)                                 │
│    ↓ watches                                                │
│  habitsProvider (StreamProvider)                            │
│    ↓ depends on                                             │
│  ┌─────────────────┐    ┌───────────────────┐             │
│  │ userIdProvider  │    │ firestoreProvider │             │
│  └─────────────────┘    └───────────────────┘             │
│           ↓                                                 │
│  currentUserProvider                                        │
│           ↓                                                 │
│  firebaseAuthProvider                                       │
│                                                              │
│  habitsActionsProvider                                      │
│    ↓ depends on                                             │
│  ┌─────────────────┐    ┌───────────────────┐             │
│  │ userIdProvider  │    │ firestoreProvider │             │
│  └─────────────────┘    └───────────────────┘             │
└─────────────────────────────────────────────────────────────┘
```

## 🎯 Key Design Decisions

### 1. **Provider Hierarchy**
- Core providers (auth, firestore) at the root
- Feature providers derive from core providers
- No circular dependencies

### 2. **State Management**
- StreamProvider for real-time Firestore data
- FutureProvider for one-time async operations
- Provider for synchronous dependencies

### 3. **Testing Strategy**
- Mock at the provider level (not Firebase directly)
- Use FakeFirebaseFirestore for realistic tests
- Test helpers centralize mock creation

### 4. **Code Organization**
```
lib/
├── core/           # Shared providers and utilities
├── features/       # Feature-specific code
│   └── habits/
│       ├── models/
│       └── providers/
└── pages/          # UI layer
```

### 5. **Separation of Concerns**
- **Model**: Pure Dart, business logic
- **Provider**: Data management, Firebase interaction
- **UI**: Display and user interaction only

## 📈 Benefits

✅ **Testable**: All dependencies injectable
✅ **Maintainable**: Clear separation of concerns
✅ **Scalable**: Easy to add new features
✅ **Type-safe**: Full Dart type safety
✅ **Real-time**: Firestore streams auto-update UI
✅ **Offline**: Firebase handles offline persistence

---

This architecture provides a solid foundation for enterprise-level Flutter development with full testability and clean code organization.
