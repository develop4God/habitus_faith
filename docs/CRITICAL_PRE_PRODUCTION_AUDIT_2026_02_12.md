# 🚨 CRITICAL PRE-PRODUCTION AUDIT - February 12, 2026
## Habitus Faith - SOLID Violations, Coverage Gaps & Production Risks

**Audit Date:** February 12, 2026  
**Target Launch:** ~2 weeks (Feb 26, 2026)  
**Auditor:** Senior Software Architect  
**Severity Levels:** 🔴 Critical | 🟠 High | 🟡 Medium | 🟢 Low

---

## 📋 EXECUTIVE SUMMARY

### Overall Risk Assessment: 🟠 HIGH

**Critical Blockers Found:** 3  
**High-Priority Issues:** 7  
**Medium-Priority Issues:** 5  
**Total Issues:** 15

### Must-Fix Before Production (2 weeks):
1. ✅ **0% test coverage on critical services** (NotificationService, GeminiService, Auth)
2. ✅ **SOLID violations in large files** (1,104+ line files violating SRP)
3. ⚠️ **No integration tests for AI/ML pipeline**
4. ⚠️ **Production-critical services untested**

---

## 🔴 PART 1: FILES >700 LINES - SOLID RESPONSIBILITY AUDIT

### Critical Violations (Require Immediate Refactoring)

#### 1. 🔴 NotificationService.dart (1,104 lines) - **CRITICAL BLOCKER**

**File:** `lib/core/services/notifications/notification_service.dart`  
**Lines:** 1,104  
**Test Coverage:** 0%  
**Severity:** 🔴 **CRITICAL**

**SOLID Violations:**

**❌ Single Responsibility Principle (SRP) - SEVERE**
This class has **at least 8 distinct responsibilities**:

1. **Local Notifications** (Flutter Local Notifications setup)
2. **Remote Notifications** (FCM token management)
3. **Permission Management** (Requesting notification permissions)
4. **Firestore Integration** (User document creation, FCM token storage)
5. **Authentication Integration** (lastLogin updates)
6. **Scheduling Logic** (Daily reminders, habit-specific notifications)
7. **Nudge Notifications** (ML-driven nudges)
8. **SharedPreferences Management** (Settings persistence)

**Impact:**
- Impossible to test in isolation
- Changes to one feature break others
- Cannot mock dependencies properly
- High coupling with Firebase, SharedPreferences, Permissions

**Recommended Refactoring:**
```dart
// Split into focused services:
1. LocalNotificationManager - Local notification operations
2. RemoteNotificationManager - FCM token & remote config
3. NotificationPermissionService - Permission handling
4. NotificationScheduler - Scheduling logic
5. NotificationPreferencesService - Settings persistence
6. FirestoreNotificationSync - Firestore integration

// Main NotificationService becomes a facade:
class NotificationService {
  final LocalNotificationManager _local;
  final RemoteNotificationManager _remote;
  final NotificationScheduler _scheduler;
  // ... coordinate between services
}
```

**Estimated Refactoring Time:** 16 hours  
**Priority:** 🔴 CRITICAL - Do before production

---

#### 2. 🟠 UnifiedHabitCard.dart (1,077 lines) - **HIGH PRIORITY**

**File:** `lib/widgets/unified_habit_card.dart`  
**Lines:** 1,077  
**Test Coverage:** N/A (Widget)  
**Severity:** 🟠 HIGH

**SOLID Violations:**

**❌ Single Responsibility Principle (SRP) - SEVERE**
This widget has **at least 6 distinct responsibilities**:

1. **Habit Display Logic** (Rendering habit data)
2. **Completion Handling** (onComplete/onUncheck)
3. **Animation Management** (Timer pulse, expansion animations)
4. **Subtask Management** (Subtask UI and logic)
5. **Notification Configuration** (Notification dialog)
6. **State Management** (Expanded/collapsed, loading states)

**❌ Open/Closed Principle (OCP)**
- Adding new habit types requires modifying this widget
- No extension points for custom habit displays

**Impact:**
- Difficult to maintain and test
- UI and business logic tightly coupled
- Cannot reuse components
- High risk of regression bugs

**Recommended Refactoring:**
```dart
// Split into smaller widgets:
1. HabitCardHeader - Title, emoji, category
2. HabitCardCompletionButton - Checkbox/completion logic
3. HabitCardExpandedContent - Details when expanded
4. HabitSubtasksList - Subtask management
5. HabitCardAnimations - Animation controller wrapper
6. HabitCardActions - Edit, delete, notification buttons

// Use composition:
class UnifiedHabitCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HabitCardContainer(
      header: HabitCardHeader(habit),
      completionButton: HabitCardCompletionButton(habit),
      expandedContent: HabitCardExpandedContent(habit),
      actions: HabitCardActions(habit),
    );
  }
}
```

**Estimated Refactoring Time:** 12 hours  
**Priority:** 🟠 HIGH - Should do before production

---

#### 3. 🟠 AddHabitDialog.dart (1,047 lines) - **HIGH PRIORITY**

**File:** `lib/widgets/add_habit_dialog.dart`  
**Lines:** 1,047  
**Test Coverage:** N/A (Widget)  
**Severity:** 🟠 HIGH

**SOLID Violations:**

**❌ Single Responsibility Principle (SRP) - SEVERE**
This widget has **at least 7 distinct responsibilities**:

1. **Custom Habit Creation Flow** (Multi-step wizard)
2. **Template Habit Selection** (Browsing predefined habits)
3. **Flash Task Creation** (Quick task entry)
4. **Form Validation** (Input validation logic)
5. **Tab Management** (3 different tabs)
6. **Animation Control** (Gradient animations)
7. **State Coordination** (Step tracking, form state)

**Impact:**
- Monolithic dialog difficult to test
- Cannot reuse creation flows
- High complexity makes bugs likely
- Poor user experience if any part fails

**Recommended Refactoring:**
```dart
// Split into separate dialogs/wizards:
1. CustomHabitWizard - Multi-step custom habit creation
2. TemplateHabitBrowser - Template selection UI
3. FlashTaskDialog - Quick task creation
4. HabitFormValidator - Validation logic
5. HabitCreationService - Business logic layer

// Use separate dialogs:
showDialog(
  context: context,
  builder: (_) => CustomHabitWizard(),  // One focused dialog
);

showDialog(
  context: context,
  builder: (_) => TemplateHabitBrowser(),  // Another focused dialog
);
```

**Estimated Refactoring Time:** 10 hours  
**Priority:** 🟠 HIGH - Should do before production

---

#### 4. 🟡 GeminiService.dart (904 lines) - **MEDIUM PRIORITY**

**File:** `lib/core/services/ai/gemini_service.dart`  
**Lines:** 904  
**Test Coverage:** 0%  
**Severity:** 🟡 MEDIUM (Size) + 🔴 CRITICAL (Coverage)

**SOLID Violations:**

**❌ Single Responsibility Principle (SRP) - MODERATE**
This class has **4 distinct responsibilities**:

1. **AI API Communication** (Gemini API calls)
2. **Prompt Engineering** (Building prompts)
3. **Response Parsing** (JSON parsing)
4. **Bible Verse Enrichment** (Looking up verses)

**⚠️ Dependency Inversion Principle (DIP) - MINOR**
- Directly depends on concrete BibleDbService
- Should depend on abstraction

**Impact:**
- Moderate coupling
- Difficult to test without mocking multiple dependencies
- Some business logic mixed with API calls

**Recommended Refactoring:**
```dart
// Split into focused services:
1. GeminiApiClient - Raw API communication
2. PromptBuilder - Prompt construction
3. ResponseParser - JSON parsing and validation
4. BibleVerseEnricher - Verse lookup (separate service)

class GeminiService {
  final GeminiApiClient _client;
  final PromptBuilder _promptBuilder;
  final ResponseParser _parser;
  final BibleVerseEnricher _enricher;
  
  Future<List<MicroHabit>> generateHabits(GenerationRequest request) async {
    final prompt = _promptBuilder.build(request);
    final response = await _client.generate(prompt);
    final habits = _parser.parse(response);
    return _enricher.enrichWithVerses(habits);
  }
}
```

**Estimated Refactoring Time:** 8 hours  
**Priority:** 🟡 MEDIUM (size) but 🔴 CRITICAL (must add tests)

---

#### 5. 🟡 JsonHabitsRepository.dart (790 lines) - **MEDIUM PRIORITY**

**File:** `lib/features/habits/data/storage/json_habits_repository.dart`  
**Lines:** 790  
**Test Coverage:** Unknown  
**Severity:** 🟡 MEDIUM

**SOLID Violations:**

**❌ Single Responsibility Principle (SRP) - MODERATE**
This class has **4 distinct responsibilities**:

1. **JSON Serialization** (Converting habits to/from JSON)
2. **File I/O** (Reading/writing to storage)
3. **Data Migration** (Handling schema changes)
4. **Caching Logic** (In-memory caching)

**Impact:**
- Mixing persistence concerns with serialization
- Migration logic makes the class complex
- Difficult to swap storage backends

**Recommended Refactoring:**
```dart
// Split into focused classes:
1. HabitJsonSerializer - JSON serialization only
2. FileStorageManager - File I/O operations
3. HabitMigrationService - Schema migrations
4. HabitCacheManager - In-memory caching

class JsonHabitsRepository implements HabitsRepository {
  final HabitJsonSerializer _serializer;
  final FileStorageManager _storage;
  final HabitMigrationService _migrator;
  
  @override
  Future<List<Habit>> getHabits() async {
    final json = await _storage.read();
    final migrated = await _migrator.migrate(json);
    return _serializer.deserialize(migrated);
  }
}
```

**Estimated Refactoring Time:** 6 hours  
**Priority:** 🟡 MEDIUM - Consider for post-production

---

### Summary: Files >700 Lines

| File | Lines | Coverage | SOLID Issues | Priority | Refactor Time |
|------|-------|----------|--------------|----------|---------------|
| NotificationService | 1,104 | 0% | SRP (8 responsibilities) | 🔴 Critical | 16h |
| UnifiedHabitCard | 1,077 | N/A | SRP (6), OCP | 🟠 High | 12h |
| AddHabitDialog | 1,047 | N/A | SRP (7) | 🟠 High | 10h |
| GeminiService | 904 | 0% | SRP (4), DIP | 🟡 Medium | 8h |
| JsonHabitsRepository | 790 | ? | SRP (4) | 🟡 Medium | 6h |
| **TOTAL** | **4,922** | **~0%** | **29 violations** | - | **52 hours** |

**Recommendation for 2-week deadline:**
- **Must do:** NotificationService refactoring + tests (16h + 8h = 24h)
- **Should do:** Add tests to GeminiService without refactoring (8h)
- **Post-production:** UI widgets refactoring (can work with current code)

---

## 🔴 PART 2: TEST COVERAGE CRITICAL GAPS

### Test Results Summary
- **Total Tests Run:** 300+ (exact count from test execution)
- **Tests Passed:** All tests passed ✅
- **Coverage Generated:** Yes (`coverage/lcov.info`)
- **Overall Coverage:** ~85% (from previous evaluation)

### TOP 10 CRITICAL COVERAGE GAPS

#### Priority 1 - Production Blockers (0% Coverage)

##### 1. 🔴 NotificationService (0% coverage) - **BLOCKER**

**File:** `lib/core/services/notifications/notification_service.dart`  
**Lines Untested:** 273 / 273  
**Impact:** Complete notification system failure in production

**Critical Scenarios NOT Tested:**
- ❌ FCM token registration fails
- ❌ Notification permissions denied
- ❌ Scheduled notifications not triggered
- ❌ Firebase user document creation fails
- ❌ Nudge notifications sent multiple times (cooldown not tested)

**Required Tests (Minimum):**
```dart
test('initialize - requests and saves FCM token', () async {});
test('initialize - handles permission denial gracefully', () async {});
test('scheduleHabitReminder - schedules at correct time', () async {});
test('scheduleDailyReminder - respects user time zone', () async {});
test('updateLastLogin - creates user doc if not exists', () async {});
test('sendNudgeNotification - respects 24h cooldown', () async {});
test('handleNotificationTap - routes to correct habit', () async {});
```

**Estimated Testing Time:** 8 hours  
**Priority:** 🔴 CRITICAL BLOCKER

---

##### 2. 🔴 GeminiService (0% coverage) - **BLOCKER**

**File:** `lib/core/services/ai/gemini_service.dart`  
**Lines Untested:** 245 / 245  
**Impact:** AI features completely untested, API failures, cost overruns

**Critical Scenarios NOT Tested:**
- ❌ API rate limit exceeded
- ❌ Invalid JSON response from Gemini
- ❌ Network timeout/failure
- ❌ Prompt injection attempts
- ❌ Bible verse not found
- ❌ Empty or malformed user input

**Required Tests (Minimum):**
```dart
test('generateHabits - returns valid MicroHabits', () async {});
test('generateHabits - handles API errors gracefully', () async {});
test('generateHabits - enforces rate limiting', () async {});
test('generateHabits - sanitizes user input', () async {});
test('generateHabits - enriches with Bible verses', () async {});
test('generateHabits - handles malformed API response', () async {});
test('generateHabits - respects timeout', () async {});
```

**Estimated Testing Time:** 6 hours  
**Priority:** 🔴 CRITICAL BLOCKER

---

##### 3. 🔴 RateLimitService (0% coverage) - **BLOCKER**

**File:** `lib/core/services/ai/rate_limit_service.dart`  
**Lines Untested:** 56 / 56  
**Impact:** API quota exhaustion, unexpected costs ($$$)

**Critical Scenarios NOT Tested:**
- ❌ Rate limit enforcement (10 requests/month)
- ❌ Request counting accuracy
- ❌ Reset logic after 30 days
- ❌ Concurrent request handling
- ❌ Storage persistence

**Required Tests (Minimum):**
```dart
test('checkLimit - allows requests within limit', () async {});
test('checkLimit - blocks requests over limit', () async {});
test('incrementUsage - increments count correctly', () async {});
test('getRemainingRequests - calculates correctly', () async {});
test('resetMonthly - resets count on new month', () async {});
```

**Estimated Testing Time:** 4 hours  
**Priority:** 🔴 CRITICAL BLOCKER

---

##### 4. 🔴 HabitPredictorProvider (0% coverage) - **BLOCKER**

**File:** `lib/core/providers/habit_predictor_provider.dart`  
**Lines Untested:** 83 / 83  
**Impact:** ML predictions fail silently, gamification broken

**Critical Scenarios NOT Tested:**
- ❌ ML model loading failure
- ❌ Prediction with missing data
- ❌ Nudge notification trigger conditions
- ❌ High-risk vs low-risk thresholds

**Required Tests (Minimum):**
```dart
test('predictAbandonmentRisk - returns valid score 0-1', () async {});
test('predictAbandonmentRisk - handles ML model error', () async {});
test('shouldSendNudge - triggers for high-risk habits', () async {});
test('shouldSendNudge - respects cooldown period', () async {});
```

**Estimated Testing Time:** 6 hours  
**Priority:** 🔴 CRITICAL BLOCKER

---

##### 5. 🟠 AuthProvider (0% coverage) - **HIGH**

**File:** `lib/core/providers/auth_provider.dart`  
**Lines Untested:** 14 / 14  
**Impact:** Authentication flow untested, security risk

**Critical Scenarios NOT Tested:**
- ❌ Anonymous sign-in flow
- ❌ User session persistence
- ❌ Auth state changes
- ❌ Sign-out flow

**Required Tests (Minimum):**
```dart
test('authStateChanges - emits user on sign-in', () async {});
test('authStateChanges - emits null on sign-out', () async {});
test('signIn - creates anonymous user', () async {});
test('signOut - clears user session', () async {});
```

**Estimated Testing Time:** 3 hours  
**Priority:** 🟠 HIGH

---

#### Priority 2 - High Risk (Low Coverage)

##### 6. 🟠 AbandonmentPredictor (16% coverage) - **HIGH**

**File:** `lib/core/services/ml/abandonment_predictor.dart`  
**Lines Tested:** 23 / 142 (16%)  
**Impact:** Poor ML predictions harm user experience

**Critical Scenarios NOT Tested:**
- ❌ Model file not found
- ❌ TFLite interpreter initialization failure
- ❌ Feature normalization edge cases
- ❌ Prediction with extreme values

**Required Tests (Additional):**
```dart
test('initialize - handles missing model file', () async {});
test('predictRisk - normalizes features correctly', () async {});
test('predictRisk - clamps output to 0-1 range', () async {});
test('predictRisk - handles null/missing features', () async {});
```

**Estimated Testing Time:** 4 hours  
**Priority:** 🟠 HIGH

---

##### 7. 🟠 FirestoreHabitsRepository (38% coverage) - **HIGH**

**File:** `lib/features/habits/data/firestore_habits_repository.dart`  
**Lines Tested:** 37 / 97 (38%)  
**Impact:** Data persistence failures

**Critical Scenarios NOT Tested:**
- ❌ Network failure during sync
- ❌ Firestore permission denied
- ❌ Concurrent write conflicts
- ❌ Large dataset pagination

**Required Tests (Additional):**
```dart
test('saveHabit - handles network failure', () async {});
test('saveHabit - retries on conflict', () async {});
test('getHabits - handles permission errors', () async {});
test('deleteHabit - removes from Firestore', () async {});
```

**Estimated Testing Time:** 4 hours  
**Priority:** 🟠 HIGH

---

##### 8. 🟠 BibleDbService (0% coverage) - **HIGH**

**File:** `lib/bible_reader_core/src/bible_db_service.dart`  
**Lines Untested:** 61 / 61  
**Impact:** Bible content unavailable

**Critical Scenarios NOT Tested:**
- ❌ Database file not found
- ❌ Verse not found in database
- ❌ Query performance with large datasets
- ❌ Database corruption

**Required Tests (Minimum):**
```dart
test('getVerse - returns correct verse', () async {});
test('getVerse - handles verse not found', () async {});
test('searchVerses - returns matching results', () async {});
test('initialize - handles database error', () async {});
```

**Estimated Testing Time:** 3 hours  
**Priority:** 🟠 HIGH

---

### Coverage Summary by Risk Category

| Category | Files | Coverage | Tests Needed | Time | Priority |
|----------|-------|----------|--------------|------|----------|
| **Notifications** | 1 | 0% | 7 tests | 8h | 🔴 Critical |
| **AI Services** | 2 | 0% | 13 tests | 10h | 🔴 Critical |
| **ML Prediction** | 2 | 8% avg | 8 tests | 10h | 🔴 Critical |
| **Authentication** | 1 | 0% | 4 tests | 3h | 🟠 High |
| **Data Persistence** | 2 | 19% avg | 8 tests | 7h | 🟠 High |
| **Bible Services** | 1 | 0% | 4 tests | 3h | 🟠 High |
| **TOTAL** | **9** | **~5%** | **44 tests** | **41h** | - |

---

## 🔴 PART 3: PRODUCTION RISKS & GAPS

### Critical Risks

#### 1. 🔴 No Integration Tests for AI/ML Pipeline

**Risk:** AI and ML features work in isolation but fail when integrated

**Missing Test Scenarios:**
- ❌ AI habit generation → ML prediction → Nudge notification (end-to-end)
- ❌ Rate limiting across multiple AI calls
- ❌ Concurrent ML predictions
- ❌ AI cache invalidation

**Recommendation:**
```dart
// Add integration test:
testWidgets('AI to ML to Nudge - complete flow', (tester) async {
  // 1. Generate habits with AI
  final habits = await geminiService.generateHabits(request);
  
  // 2. Predict abandonment risk
  final risk = await predictor.predictRisk(habits.first);
  
  // 3. Send nudge if high risk
  if (risk > 0.7) {
    await notificationService.sendNudge(habits.first);
  }
  
  // Verify entire flow worked
  expect(habits, isNotEmpty);
  expect(risk, greaterThanOrEqualTo(0));
  // ... verify nudge sent
});
```

**Estimated Time:** 6 hours  
**Priority:** 🔴 CRITICAL

---

#### 2. 🟠 Firebase Initialization Not Tested in Production Mode

**Risk:** App crashes on startup in production

**Missing Test Scenarios:**
- ❌ Firebase not initialized
- ❌ Invalid Firebase config
- ❌ Network unavailable at startup
- ❌ Firestore offline persistence

**Recommendation:**
Add startup integration test with real Firebase (test environment)

**Estimated Time:** 4 hours  
**Priority:** 🟠 HIGH

---

#### 3. 🟠 No Error Boundary for Critical Services

**Risk:** Service failure crashes entire app

**Missing Error Handling:**
- ❌ NotificationService initialization failure
- ❌ ML model loading failure
- ❌ Firebase connection failure

**Recommendation:**
```dart
// Add error boundaries and fallbacks:
try {
  await notificationService.initialize();
} catch (e) {
  // Log error, continue with notifications disabled
  logger.error('Notifications unavailable', error: e);
  // Don't crash the app
}
```

**Estimated Time:** 3 hours  
**Priority:** 🟠 HIGH

---

#### 4. 🟡 No Performance Testing

**Risk:** App is slow on low-end devices

**Missing Metrics:**
- ❌ App startup time
- ❌ Habit list scroll performance (1000+ habits)
- ❌ ML prediction latency
- ❌ Database query performance

**Recommendation:**
Add performance benchmarks for critical paths

**Estimated Time:** 4 hours  
**Priority:** 🟡 MEDIUM

---

#### 5. 🟡 No Load Testing for Firebase

**Risk:** Firestore quotas exceeded, unexpected costs

**Missing Tests:**
- ❌ Concurrent user writes
- ❌ Large batch operations
- ❌ Read/write quota limits

**Recommendation:**
Use Firebase Emulator for load testing

**Estimated Time:** 4 hours  
**Priority:** 🟡 MEDIUM

---

## 📊 PRIORITY MATRIX FOR 2-WEEK DEADLINE

### Week 1 (Must Complete)

**Days 1-3: Critical Test Coverage (24 hours)**
- [ ] NotificationService tests (8h) - 🔴 BLOCKER
- [ ] GeminiService tests (6h) - 🔴 BLOCKER
- [ ] RateLimitService tests (4h) - 🔴 BLOCKER
- [ ] AI/ML integration tests (6h) - 🔴 BLOCKER

**Days 4-5: Critical Refactoring (16 hours)**
- [ ] NotificationService refactoring (16h) - 🔴 CRITICAL
  - Split into 6 focused services
  - Update tests for new architecture
  - Verify all functionality works

### Week 2 (High Priority)

**Days 6-8: High-Priority Tests (17 hours)**
- [ ] HabitPredictorProvider tests (6h) - 🔴 BLOCKER
- [ ] AuthProvider tests (3h) - 🟠 HIGH
- [ ] AbandonmentPredictor tests (4h) - 🟠 HIGH
- [ ] FirestoreHabitsRepository tests (4h) - 🟠 HIGH

**Days 9-10: Risk Mitigation (11 hours)**
- [ ] Error boundaries for critical services (3h)
- [ ] Firebase initialization tests (4h)
- [ ] BibleDbService tests (3h)
- [ ] Final integration testing (1h)

**Days 11-12: QA & Buffer**
- [ ] Full regression testing
- [ ] Performance testing
- [ ] Bug fixes
- [ ] Documentation updates

### Total Effort Required: **68 hours** (8.5 developer-days)

With 2 developers: **4.25 days** (doable in 2 weeks with buffer)

---

## ✅ ACCEPTANCE CRITERIA FOR PRODUCTION

### Must Have (Blockers)
- [ ] NotificationService test coverage >80%
- [ ] GeminiService test coverage >80%
- [ ] RateLimitService test coverage >80%
- [ ] HabitPredictorProvider test coverage >80%
- [ ] AuthProvider test coverage >80%
- [ ] All critical services have integration tests
- [ ] NotificationService refactored (SRP compliance)
- [ ] Error boundaries implemented
- [ ] Firebase initialization tested

### Should Have (High Priority)
- [ ] AbandonmentPredictor test coverage >80%
- [ ] FirestoreHabitsRepository test coverage >80%
- [ ] BibleDbService test coverage >50%
- [ ] Performance benchmarks established
- [ ] Load testing completed

### Nice to Have (Post-Production)
- [ ] UI widgets refactored (UnifiedHabitCard, AddHabitDialog)
- [ ] GeminiService refactored
- [ ] JsonHabitsRepository refactored
- [ ] Performance optimizations

---

## 🎯 RECOMMENDATIONS

### For 2-Week Timeline

**Week 1 Focus:** Test coverage for critical services (NotificationService, AI, ML)
- This is non-negotiable for production
- Catches bugs before users do
- Prevents catastrophic failures

**Week 2 Focus:** NotificationService refactoring + risk mitigation
- Reduces technical debt
- Makes future changes safer
- Improves maintainability

**Accept as Technical Debt:**
- UI widget refactoring (can work with current code)
- Performance optimizations (monitor in production)
- Non-critical service refactoring

### Alternative: Delayed Launch

If 2-week timeline is firm and resources are limited:
1. **Keep current architecture** (no refactoring)
2. **Add tests only** (41 hours = 5 days with 2 devs)
3. **Launch with monitoring** (Firebase Crashlytics, Analytics)
4. **Refactor post-launch** based on real issues

This reduces risk while meeting deadline.

---

## 📋 ACTION PLAN

### Immediate Actions (Today)

1. **Assign Resources**
   - Developer 1: NotificationService tests (Week 1)
   - Developer 2: AI/ML tests (Week 1)

2. **Set Up Test Infrastructure**
   - Mock Firebase services
   - Mock Gemini API
   - Test data generators

3. **Create Test Plan Document**
   - Detailed test scenarios
   - Expected coverage targets
   - Test data requirements

### Daily Standup Topics

- Test coverage progress (target: 80% by Week 1 end)
- Blockers (especially mock setup issues)
- Integration test failures
- Refactoring progress (Week 1 Days 4-5)

### Weekly Reviews

- **Week 1 End:** Review test coverage, decide if refactoring is feasible
- **Week 2 Mid:** Risk assessment, go/no-go decision
- **Week 2 End:** Final QA, production readiness review

---

## 🚨 ESCALATION PATH

### If Tests Reveal Critical Bugs

1. **Stop Feature Development**
2. **Triage Bugs** (Critical, High, Medium)
3. **Fix Critical Bugs** (delay launch if needed)
4. **Update Timeline** (communicate to stakeholders)

### If Timeline Slips

1. **Reduce Scope** (prioritize critical tests only)
2. **Skip Refactoring** (accept technical debt)
3. **Launch with Monitoring** (aggressive monitoring in production)
4. **Plan Post-Launch Fixes** (schedule refactoring)

---

## 📚 APPENDICES

### Appendix A: Test Coverage Command

```bash
# Generate coverage
flutter test --coverage

# View coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Check coverage percentage
lcov --summary coverage/lcov.info
```

### Appendix B: Refactoring Checklist

For each large file refactoring:
- [ ] Create new smaller classes
- [ ] Move tests to new classes
- [ ] Update dependency injection
- [ ] Update all imports
- [ ] Verify all tests still pass
- [ ] Update documentation

### Appendix C: SOLID Principles Quick Reference

- **S**ingle Responsibility: One class = one reason to change
- **O**pen/Closed: Open for extension, closed for modification
- **L**iskov Substitution: Subtypes must be substitutable
- **I**nterface Segregation: No client forced to depend on unused methods
- **D**ependency Inversion: Depend on abstractions, not concretions

---

**Document Version:** 1.0  
**Last Updated:** February 12, 2026  
**Next Review:** February 19, 2026 (Week 1 checkpoint)  
**Status:** 🔴 ACTIVE - IMMEDIATE ACTION REQUIRED
