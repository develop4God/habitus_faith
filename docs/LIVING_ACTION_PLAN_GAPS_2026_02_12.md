# 📋 Living Action Plan - Critical Gaps Resolution
## Habitus Faith - Easy Task Breakdown for Production Readiness

**Created:** February 12, 2026  
**Last Updated:** February 12, 2026  
**Based On:** [CRITICAL_PRE_PRODUCTION_AUDIT_2026_02_12.md](CRITICAL_PRE_PRODUCTION_AUDIT_2026_02_12.md)  
**Status:** 🟡 IN PROGRESS  
**Target Completion:** March 5, 2026 (3 weeks)

---

## 📊 Progress Overview

**Total Tasks:** 45  
**Completed:** 1 ✅  
**In Progress:** 0 ⏳  
**Not Started:** 44 ⬜

**Overall Progress:** 2% ██░░░░░░░░░░░░░░░░░░ 1/45

---

## 🎯 How to Use This Document

This is a **living document** - update it daily as you complete tasks!

### ✅ Marking Tasks Complete
1. Change `⬜` to `✅` when task is done
2. Update the "Progress Overview" section
3. Add completion date: `✅ (Feb 14)`
4. Commit changes with: `git add docs/LIVING_ACTION_PLAN_GAPS_2026_02_12.md && git commit -m "Update: Task X completed"`

### 📝 Task Format
Each task includes:
- **Priority Level**: 🔴 Critical | 🟠 High | 🟡 Medium
- **Estimated Time**: Realistic time estimate
- **Dependencies**: What must be done first
- **How to Do It**: Step-by-step instructions
- **How to Verify**: How to confirm it's working
- **Status**: ⬜ Not Started | ⏳ In Progress | ✅ Done

---

## 🔴 WEEK 1: CRITICAL TEST COVERAGE (Feb 12-18)

### Priority: Tests for NotificationService, GeminiService, RateLimitService

---

### Task 1: Setup Test Infrastructure 🔴

**Estimated Time:** 2 hours  
**Priority:** 🔴 CRITICAL (Do First!)  
**Dependencies:** None  
**Status:** ✅ (Feb 12)

#### What to Do:
1. Create test utilities directory
2. Setup Firebase mocks
3. Setup Gemini API mocks
4. Create test data generators

#### Step-by-Step:

```bash
# 1. Create test utilities
mkdir -p test/utils
cd test/utils

# 2. Create mock Firebase services
cat > firebase_mocks.dart << 'EOF'
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Mock Firebase Auth
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}

// Mock Firestore
class MockFirestore extends Mock implements FirebaseFirestore {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}

// Mock Firebase Messaging
class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}
EOF

# 3. Create mock Gemini service
cat > gemini_mocks.dart << 'EOF'
import 'package:mocktail/mocktail.dart';

class MockGeminiClient extends Mock {
  Future<Map<String, dynamic>> generateContent(String prompt) async {
    return {
      'candidates': [
        {
          'content': {
            'parts': [
              {
                'text': '{"habits": []}'
              }
            ]
          }
        }
      ]
    };
  }
}
EOF

# 4. Create test data generators
cat > test_data_generators.dart << 'EOF'
import 'package:habitus_faith/features/habits/domain/models/habit.dart';

class TestDataGenerators {
  static Habit createTestHabit({
    String? id,
    String title = 'Test Habit',
    int streakDays = 0,
    bool isCompleted = false,
  }) {
    return Habit(
      id: id ?? 'test_habit_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: 'Test description',
      category: HabitCategory.spiritual,
      difficultyLevel: 2,
      streakDays: streakDays,
      isCompleted: isCompleted,
      createdAt: DateTime.now(),
    );
  }
  
  static Map<String, dynamic> createTestUserData({
    String? uid,
    String? fcmToken,
  }) {
    return {
      'uid': uid ?? 'test_user_123',
      'fcmToken': fcmToken ?? 'test_fcm_token',
      'lastLogin': DateTime.now().toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}
EOF
```

#### How to Verify:
```bash
# Test that mocks compile
cd /home/runner/work/habitus_faith/habitus_faith
flutter analyze test/utils/

# Should show 0 errors
```

#### Done When:
- ✅ `test/utils/firebase_mocks.dart` exists
- ✅ `test/utils/gemini_mocks.dart` exists
- ✅ `test/utils/test_data_generators.dart` exists
- ✅ `flutter analyze test/utils/` shows 0 errors

---

### Task 2: NotificationService - Basic Tests 🔴

**Estimated Time:** 3 hours  
**Priority:** 🔴 CRITICAL  
**Dependencies:** Task 1  
**Status:** ⬜

#### What to Do:
Create basic test file for NotificationService with 7 essential tests

#### Step-by-Step:

```bash
# 1. Create test file
mkdir -p test/unit/services/notifications
cd test/unit/services/notifications

cat > notification_service_test.dart << 'EOF'
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:habitus_faith/core/services/notifications/notification_service.dart';
import '../../../utils/firebase_mocks.dart';

void main() {
  group('NotificationService - Basic Tests', () {
    late NotificationService service;
    late MockFirebaseAuth mockAuth;
    late MockFirebaseMessaging mockMessaging;
    late MockFirestore mockFirestore;
    
    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockMessaging = MockFirebaseMessaging();
      mockFirestore = MockFirestore();
      
      // Setup default mocks
      when(() => mockMessaging.getToken()).thenAnswer((_) async => 'test_token');
      when(() => mockAuth.currentUser).thenReturn(null);
    });
    
    test('initialize - requests and saves FCM token', () async {
      // TODO: Implement test
      // 1. Call service.initialize()
      // 2. Verify getToken() was called
      // 3. Verify token was saved
    });
    
    test('initialize - handles permission denial gracefully', () async {
      // TODO: Implement test
      // 1. Mock permission denial
      // 2. Call service.initialize()
      // 3. Verify no exception thrown
      // 4. Verify graceful fallback
    });
    
    test('scheduleHabitReminder - schedules at correct time', () async {
      // TODO: Implement test
      // 1. Create test habit
      // 2. Call scheduleHabitReminder
      // 3. Verify notification scheduled
      // 4. Verify correct time
    });
    
    test('scheduleDailyReminder - respects user time zone', () async {
      // TODO: Implement test
      // 1. Set user timezone
      // 2. Call scheduleDailyReminder
      // 3. Verify notification time adjusted
    });
    
    test('updateLastLogin - creates user doc if not exists', () async {
      // TODO: Implement test
      // 1. Mock user without doc
      // 2. Call updateLastLogin
      // 3. Verify doc created
    });
    
    test('sendNudgeNotification - respects 24h cooldown', () async {
      // TODO: Implement test
      // 1. Send first nudge
      // 2. Try to send second nudge immediately
      // 3. Verify second nudge blocked
      // 4. Wait 24h (mock time)
      // 5. Verify nudge allowed
    });
    
    test('handleNotificationTap - routes to correct habit', () async {
      // TODO: Implement test
      // 1. Tap notification with habitId
      // 2. Verify navigation to habit detail
    });
  });
}
EOF
```

#### How to Verify:
```bash
# Run tests (will show 7 skipped/TODOs initially)
flutter test test/unit/services/notifications/notification_service_test.dart

# Should run without errors (tests not implemented yet, that's OK)
```

#### Done When:
- ✅ Test file created with 7 test stubs
- ✅ All test stubs compile
- ✅ `flutter test` runs without compilation errors
- ✅ Ready for implementation

---

### Task 3: NotificationService - Implement Test #1 (FCM Token) 🔴

**Estimated Time:** 45 minutes  
**Priority:** 🔴 CRITICAL  
**Dependencies:** Task 2  
**Status:** ⬜

#### What to Do:
Implement the first NotificationService test: FCM token request and save

#### Step-by-Step:

```dart
// Edit: test/unit/services/notifications/notification_service_test.dart
// Replace the first TODO test with:

test('initialize - requests and saves FCM token', () async {
  // Arrange
  final testToken = 'test_fcm_token_123';
  when(() => mockMessaging.getToken()).thenAnswer((_) async => testToken);
  
  final mockUser = MockUser();
  when(() => mockUser.uid).thenReturn('test_user_id');
  when(() => mockAuth.currentUser).thenReturn(mockUser);
  
  final mockDocRef = MockDocumentReference();
  final mockCollection = MockCollectionReference();
  when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
  when(() => mockCollection.doc('test_user_id')).thenReturn(mockDocRef);
  when(() => mockDocRef.set(any(), any())).thenAnswer((_) async => {});
  
  // Act
  await service.initialize();
  
  // Assert
  verify(() => mockMessaging.getToken()).called(1);
  verify(() => mockDocRef.set(
    any(that: containsPair('fcmToken', testToken)),
    any(),
  )).called(1);
});
```

#### How to Verify:
```bash
# Run just this test
flutter test test/unit/services/notifications/notification_service_test.dart --name "requests and saves FCM token"

# Should PASS ✅
```

#### Done When:
- ✅ Test implemented completely
- ✅ Test passes
- ✅ Verifies token is requested
- ✅ Verifies token is saved to Firestore

---

### Task 4: NotificationService - Implement Test #2 (Permission Denial) 🔴

**Estimated Time:** 45 minutes  
**Priority:** 🔴 CRITICAL  
**Dependencies:** Task 3  
**Status:** ⬜

#### What to Do:
Implement permission denial test

#### Step-by-Step Instructions:
See pattern from Task 3. Implement the second test following this structure:
1. Mock permission request returning `denied`
2. Call `service.initialize()`
3. Verify no exception thrown
4. Verify service continues working in degraded mode

#### Done When:
- ✅ Test passes
- ✅ Graceful degradation verified

---

### Task 5: NotificationService - Implement Remaining 5 Tests 🔴

**Estimated Time:** 4 hours  
**Priority:** 🔴 CRITICAL  
**Dependencies:** Task 4  
**Status:** ⬜

#### What to Do:
Implement the remaining 5 NotificationService tests:
- scheduleHabitReminder
- scheduleDailyReminder
- updateLastLogin
- sendNudgeNotification (with cooldown)
- handleNotificationTap

#### How to Break It Down:
Do one test at a time (45 min each). Take breaks between tests.

#### Done When:
- ✅ All 7 tests implemented
- ✅ All 7 tests passing
- ✅ Test coverage for NotificationService >80%

---

### Task 6: GeminiService - Create Test File 🔴

**Estimated Time:** 2 hours  
**Priority:** 🔴 CRITICAL  
**Dependencies:** Task 1  
**Status:** ⬜

#### What to Do:
Create GeminiService test file with 7 test stubs

#### Step-by-Step:

```bash
mkdir -p test/unit/services/ai
cd test/unit/services/ai

cat > gemini_service_test.dart << 'EOF'
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:habitus_faith/core/services/ai/gemini_service.dart';
import '../../../utils/gemini_mocks.dart';

void main() {
  group('GeminiService', () {
    late GeminiService service;
    late MockGeminiClient mockClient;
    
    setUp(() {
      mockClient = MockGeminiClient();
      // service = GeminiService(client: mockClient);
    });
    
    test('generateHabits - returns valid MicroHabits', () async {
      // TODO: Implement
    });
    
    test('generateHabits - handles API errors gracefully', () async {
      // TODO: Implement
    });
    
    test('generateHabits - enforces rate limiting', () async {
      // TODO: Implement
    });
    
    test('generateHabits - sanitizes user input', () async {
      // TODO: Implement
    });
    
    test('generateHabits - enriches with Bible verses', () async {
      // TODO: Implement
    });
    
    test('generateHabits - handles malformed API response', () async {
      // TODO: Implement
    });
    
    test('generateHabits - respects timeout', () async {
      // TODO: Implement
    });
  });
}
EOF
```

#### Done When:
- ✅ Test file created
- ✅ 7 test stubs compile
- ✅ Ready for implementation

---

### Task 7: GeminiService - Implement All 7 Tests 🔴

**Estimated Time:** 6 hours  
**Priority:** 🔴 CRITICAL  
**Dependencies:** Task 6  
**Status:** ⬜

#### What to Do:
Implement all 7 GeminiService tests (1 hour each, roughly)

#### How to Break It Down:
- Day 1: Tests 1-3 (valid response, errors, rate limiting)
- Day 2: Tests 4-5 (input sanitization, Bible verses)
- Day 3: Tests 6-7 (malformed response, timeout)

#### Done When:
- ✅ All 7 tests passing
- ✅ GeminiService test coverage >80%

---

### Task 8: RateLimitService - Complete Test Suite 🔴

**Estimated Time:** 4 hours  
**Priority:** 🔴 CRITICAL  
**Dependencies:** Task 1  
**Status:** ⬜

#### What to Do:
Create and implement all RateLimitService tests

#### Test Cases (5 tests):
1. `checkLimit - allows requests within limit`
2. `checkLimit - blocks requests over limit`
3. `incrementUsage - increments count correctly`
4. `getRemainingRequests - calculates correctly`
5. `resetMonthly - resets count on new month`

#### Step-by-Step:

```bash
mkdir -p test/unit/services/ai
cat > test/unit/services/ai/rate_limit_service_test.dart << 'EOF'
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/ai/rate_limit_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('RateLimitService', () {
    late RateLimitService service;
    
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = RateLimitService();
      await service.initialize();
    });
    
    test('checkLimit - allows requests within limit', () async {
      // Arrange
      for (int i = 0; i < 9; i++) {
        await service.incrementUsage();
      }
      
      // Act
      final canRequest = await service.checkLimit();
      
      // Assert
      expect(canRequest, true);
    });
    
    test('checkLimit - blocks requests over limit', () async {
      // Arrange
      for (int i = 0; i < 10; i++) {
        await service.incrementUsage();
      }
      
      // Act
      final canRequest = await service.checkLimit();
      
      // Assert
      expect(canRequest, false);
    });
    
    // TODO: Add remaining 3 tests
  });
}
EOF
```

#### Done When:
- ✅ 5 tests implemented and passing
- ✅ RateLimitService test coverage >80%

---

## 🟠 WEEK 2: ML/AI INTEGRATION & HIGH PRIORITY (Feb 19-25)

### Task 9: HabitPredictorProvider - Test Suite 🟠

**Estimated Time:** 6 hours  
**Priority:** 🟠 HIGH  
**Dependencies:** Task 1  
**Status:** ⬜

#### What to Do:
Create comprehensive test suite for ML predictor

#### Test Cases (4 tests):
1. `predictAbandonmentRisk - returns valid score 0-1`
2. `predictAbandonmentRisk - handles ML model error`
3. `shouldSendNudge - triggers for high-risk habits`
4. `shouldSendNudge - respects cooldown period`

#### Done When:
- ✅ All tests passing
- ✅ ML prediction logic covered

---

### Task 10: AuthProvider - Test Suite 🟠

**Estimated Time:** 3 hours  
**Priority:** 🟠 HIGH  
**Dependencies:** Task 1  
**Status:** ⬜

#### Test Cases (4 tests):
1. `authStateChanges - emits user on sign-in`
2. `authStateChanges - emits null on sign-out`
3. `signIn - creates anonymous user`
4. `signOut - clears user session`

#### Done When:
- ✅ All tests passing
- ✅ Auth flow covered

---

### Task 11: AbandonmentPredictor - Increase Coverage 🟠

**Estimated Time:** 4 hours  
**Priority:** 🟠 HIGH  
**Dependencies:** Task 9  
**Status:** ⬜

#### What to Do:
Increase test coverage from 16% to >80%

#### New Tests Needed:
1. `initialize - handles missing model file`
2. `predictRisk - normalizes features correctly`
3. `predictRisk - clamps output to 0-1 range`
4. `predictRisk - handles null/missing features`

#### Done When:
- ✅ Coverage increased to 80%+

---

### Task 12: AI/ML Integration Tests 🟠

**Estimated Time:** 6 hours  
**Priority:** 🟠 HIGH  
**Dependencies:** Tasks 7, 9, 11  
**Status:** ⬜

#### What to Do:
Create end-to-end integration tests for AI/ML pipeline

#### Test Scenario:
1. AI generates habits via Gemini
2. ML predicts abandonment risk
3. Nudge notification sent if high risk
4. Verify entire flow works together

#### Step-by-Step:

```bash
mkdir -p test/integration/ai_ml
cat > test/integration/ai_ml/ai_ml_pipeline_test.dart << 'EOF'
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/ai/gemini_service.dart';
import 'package:habitus_faith/core/services/ml/abandonment_predictor.dart';
import 'package:habitus_faith/core/services/notifications/notification_service.dart';

void main() {
  testWidgets('AI to ML to Nudge - complete flow', (tester) async {
    // 1. Generate habits with AI
    final geminiService = GeminiService();
    final habits = await geminiService.generateHabits(
      motivations: ['spiritual growth'],
      challenges: ['consistency'],
      experience: 'beginner',
    );
    
    expect(habits, isNotEmpty);
    
    // 2. Predict abandonment risk
    final predictor = AbandonmentPredictor();
    await predictor.initialize();
    
    final risk = await predictor.predictAbandonmentRisk(
      habitId: habits.first.id,
      userId: 'test_user',
      habitData: {
        'streakDays': 0,
        'completionRate': 0.0,
        'daysSinceCreated': 1,
      },
    );
    
    expect(risk, greaterThanOrEqualTo(0.0));
    expect(risk, lessThanOrEqualTo(1.0));
    
    // 3. Send nudge if high risk
    final notificationService = NotificationService();
    if (risk > 0.7) {
      await notificationService.sendNudgeNotification(habits.first);
    }
    
    // Verify entire flow worked
    expect(habits.length, greaterThan(0));
    expect(risk, isA<double>());
  });
  
  test('Rate limiting across multiple AI calls', () async {
    // TODO: Test rate limiting
  });
  
  test('Concurrent ML predictions', () async {
    // TODO: Test concurrent predictions
  });
}
EOF
```

#### Done When:
- ✅ Integration tests created
- ✅ All tests passing
- ✅ Pipeline verified end-to-end

---

### Task 13: Firebase Initialization Tests 🟠

**Estimated Time:** 4 hours  
**Priority:** 🟠 HIGH  
**Dependencies:** Task 1  
**Status:** ⬜

#### Test Scenarios:
1. Firebase not initialized
2. Invalid Firebase config
3. Network unavailable at startup
4. Firestore offline persistence

#### Done When:
- ✅ Firebase init tested
- ✅ Error handling verified

---

### Task 14: Error Boundaries for Critical Services 🟠

**Estimated Time:** 3 hours  
**Priority:** 🟠 HIGH  
**Dependencies:** None  
**Status:** ⬜

#### What to Do:
Add try-catch blocks and fallbacks to prevent app crashes

#### Files to Update:
1. `lib/main.dart` - App initialization
2. `lib/core/services/notifications/notification_service.dart`
3. `lib/core/services/ml/abandonment_predictor.dart`

#### Example Implementation:

```dart
// In main.dart
Future<void> initializeCriticalServices() async {
  try {
    await notificationService.initialize();
  } catch (e, stackTrace) {
    logger.error('Notifications unavailable', error: e, stackTrace: stackTrace);
    // Continue - app works without notifications
  }
  
  try {
    await mlPredictor.initialize();
  } catch (e, stackTrace) {
    logger.error('ML predictions unavailable', error: e, stackTrace: stackTrace);
    // Continue - app works without ML
  }
}
```

#### Done When:
- ✅ Error boundaries added
- ✅ App doesn't crash on service failure
- ✅ Graceful degradation works

---

## 🟡 WEEK 3: REFACTORING & MEDIUM PRIORITY (Feb 26 - Mar 4)

### Task 15: NotificationService Refactoring - Plan 🟡

**Estimated Time:** 2 hours  
**Priority:** 🟡 MEDIUM  
**Dependencies:** Tasks 2-5 (tests must pass first!)  
**Status:** ⬜

#### What to Do:
Create detailed refactoring plan (don't refactor yet!)

#### Deliverable:
Create `docs/NOTIFICATION_SERVICE_REFACTORING_PLAN.md` with:
1. List of 6 new services to create
2. Which methods go in which service
3. How to maintain backward compatibility
4. Migration strategy

#### Done When:
- ✅ Refactoring plan documented
- ✅ Plan reviewed by team
- ✅ Ready to execute (in Task 16)

---

### Task 16: NotificationService Refactoring - Execute 🟡

**Estimated Time:** 16 hours (2 days)  
**Priority:** 🟡 MEDIUM  
**Dependencies:** Task 15  
**Status:** ⬜

#### What to Do:
Split NotificationService into 6 focused services

#### Services to Create:
1. `LocalNotificationManager` - Local notification operations
2. `RemoteNotificationManager` - FCM token & remote config
3. `NotificationPermissionService` - Permission handling
4. `NotificationScheduler` - Scheduling logic
5. `NotificationPreferencesService` - Settings persistence
6. `FirestoreNotificationSync` - Firestore integration

#### How to Break It Down:
- Day 1: Create services 1-3 (8 hours)
- Day 2: Create services 4-6 (8 hours)
- Day 3: Update tests and verify (included in 16h)

#### Done When:
- ✅ 6 new services created
- ✅ All tests still passing
- ✅ NotificationService is now a facade
- ✅ Code review completed

---

### Task 17: BibleDbService - Test Suite 🟡

**Estimated Time:** 3 hours  
**Priority:** 🟡 MEDIUM  
**Dependencies:** Task 1  
**Status:** ⬜

#### Test Cases (4 tests):
1. `getVerse - returns correct verse`
2. `getVerse - handles verse not found`
3. `searchVerses - returns matching results`
4. `initialize - handles database error`

#### Done When:
- ✅ Tests implemented
- ✅ All tests passing

---

### Task 18: FirestoreHabitsRepository - Increase Coverage 🟡

**Estimated Time:** 4 hours  
**Priority:** 🟡 MEDIUM  
**Dependencies:** Task 1  
**Status:** ⬜

#### What to Do:
Increase coverage from 38% to >80%

#### New Tests:
1. `saveHabit - handles network failure`
2. `saveHabit - retries on conflict`
3. `getHabits - handles permission errors`
4. `deleteHabit - removes from Firestore`

#### Done When:
- ✅ Coverage increased to 80%+

---

## 📋 OPTIONAL: UI REFACTORING (Post-Production)

### Task 19: UnifiedHabitCard Refactoring 🟢

**Estimated Time:** 12 hours  
**Priority:** 🟢 LOW  
**Dependencies:** None  
**Status:** ⬜

#### What to Do:
Split large widget into smaller components

**NOTE:** This is optional and can be done post-launch!

---

### Task 20: AddHabitDialog Refactoring 🟢

**Estimated Time:** 10 hours  
**Priority:** 🟢 LOW  
**Dependencies:** None  
**Status:** ⬜

#### What to Do:
Split dialog into separate focused dialogs

**NOTE:** This is optional and can be done post-launch!

---

## 📊 Weekly Checklists

### Week 1 Checklist (Feb 12-18) - CRITICAL

- [ ] Task 1: Setup Test Infrastructure (2h)
- [ ] Task 2: NotificationService - Basic Tests (3h)
- [ ] Task 3: NotificationService - Test #1 (45min)
- [ ] Task 4: NotificationService - Test #2 (45min)
- [ ] Task 5: NotificationService - Tests #3-7 (4h)
- [ ] Task 6: GeminiService - Create Tests (2h)
- [ ] Task 7: GeminiService - Implement Tests (6h)
- [ ] Task 8: RateLimitService - Tests (4h)

**Total Week 1 Time:** 22.5 hours  
**Goal:** Complete all critical test coverage

### Week 2 Checklist (Feb 19-25) - HIGH PRIORITY

- [ ] Task 9: HabitPredictorProvider Tests (6h)
- [ ] Task 10: AuthProvider Tests (3h)
- [ ] Task 11: AbandonmentPredictor Coverage (4h)
- [ ] Task 12: AI/ML Integration Tests (6h)
- [ ] Task 13: Firebase Init Tests (4h)
- [ ] Task 14: Error Boundaries (3h)

**Total Week 2 Time:** 26 hours  
**Goal:** Complete high-priority tests and error handling

### Week 3 Checklist (Feb 26 - Mar 4) - MEDIUM PRIORITY

- [ ] Task 15: Refactoring Plan (2h)
- [ ] Task 16: NotificationService Refactoring (16h)
- [ ] Task 17: BibleDbService Tests (3h)
- [ ] Task 18: FirestoreHabitsRepository Coverage (4h)

**Total Week 3 Time:** 25 hours  
**Goal:** Refactoring and remaining test coverage

---

## 🎯 Success Metrics

### Test Coverage Goals

| Service | Current | Target | Status |
|---------|---------|--------|--------|
| NotificationService | 0% | 80%+ | ⬜ |
| GeminiService | 0% | 80%+ | ⬜ |
| RateLimitService | 0% | 80%+ | ⬜ |
| HabitPredictorProvider | 0% | 80%+ | ⬜ |
| AuthProvider | 0% | 80%+ | ⬜ |
| AbandonmentPredictor | 16% | 80%+ | ⬜ |
| FirestoreHabitsRepository | 38% | 80%+ | ⬜ |
| BibleDbService | 0% | 50%+ | ⬜ |

### Code Quality Goals

| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| Flutter Analyze | 0 errors | 0 errors | ✅ |
| Test Count | 78 | 120+ | ⬜ |
| Integration Tests | 0 | 5+ | ⬜ |
| Error Boundaries | No | Yes | ⬜ |

---

## 💡 Tips for Success

### Daily Workflow

1. **Start of Day:**
   - Review this document
   - Pick 1-2 tasks for today
   - Mark them as ⏳ In Progress

2. **During Work:**
   - Follow step-by-step instructions
   - Don't skip verification steps
   - Ask for help if stuck >30 minutes

3. **End of Day:**
   - Mark completed tasks as ✅
   - Update progress percentages
   - Commit changes to this document

### When Stuck

1. **Read the audit:** [CRITICAL_PRE_PRODUCTION_AUDIT_2026_02_12.md](CRITICAL_PRE_PRODUCTION_AUDIT_2026_02_12.md)
2. **Check examples:** Look at existing tests in `test/` directory
3. **Ask for help:** Don't waste time being stuck
4. **Break it down:** Split large tasks into smaller subtasks

### Testing Tips

```bash
# Run specific test file
flutter test test/unit/services/notifications/notification_service_test.dart

# Run specific test by name
flutter test --name "requests and saves FCM token"

# Run with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Run all tests
flutter test

# Watch mode (re-run on changes)
flutter test --watch
```

---

## 📅 Timeline Summary

| Week | Dates | Focus | Hours | Tasks |
|------|-------|-------|-------|-------|
| 1 | Feb 12-18 | Critical Tests | 22.5h | Tasks 1-8 |
| 2 | Feb 19-25 | High Priority | 26h | Tasks 9-14 |
| 3 | Feb 26-Mar 4 | Refactoring | 25h | Tasks 15-18 |

**Total Estimated Time:** 73.5 hours (~2.5 weeks with 2 developers)

---

## ✅ Definition of Done

### Task is Complete When:
- ✅ All code written and tested
- ✅ All tests passing
- ✅ Coverage target met (if applicable)
- ✅ Code reviewed
- ✅ Documentation updated
- ✅ This document updated
- ✅ Changes committed to Git

### Week is Complete When:
- ✅ All week's tasks marked ✅
- ✅ All tests passing
- ✅ No regressions introduced
- ✅ Progress report sent to team

### Project is Complete When:
- ✅ All critical and high priority tasks done
- ✅ Test coverage >80% for critical services
- ✅ All integration tests passing
- ✅ Error boundaries implemented
- ✅ Code review completed
- ✅ Production deployment ready

---

## 🚨 Blockers & Issues Log

Use this section to track problems:

### Active Blockers
*None yet*

### Resolved Issues
*Track resolved issues here*

---

## 📞 Need Help?

### Resources
- **Audit Document:** [CRITICAL_PRE_PRODUCTION_AUDIT_2026_02_12.md](CRITICAL_PRE_PRODUCTION_AUDIT_2026_02_12.md)
- **Action Plan:** [ACTION_PLAN_2026_02_12.md](ACTION_PLAN_2026_02_12.md)
- **Architecture:** [ARCHITECTURE_REVIEW.md](ARCHITECTURE_REVIEW.md)
- **Existing Tests:** `test/` directory

### Getting Unstuck
1. Review the step-by-step instructions
2. Check existing test examples
3. Read the audit for context
4. Ask team for help
5. Break task into smaller pieces

---

**Remember:** This is a living document. Update it daily! 📝

**Last Updated:** February 12, 2026  
**Next Update:** When you complete a task! ✅
