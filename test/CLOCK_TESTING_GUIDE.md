# Clock Testing Patterns

This guide provides comprehensive examples and patterns for testing time-dependent logic in Habitus Faith using the Clock abstraction.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Testing Patterns](#testing-patterns)
3. [Common Scenarios](#common-scenarios)
4. [Best Practices](#best-practices)
5. [Troubleshooting](#troubleshooting)

---

## Quick Start

### Basic Fixed Clock Test

The simplest way to test time-dependent logic is using a fixed clock:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/time/time.dart';
import '../helpers/clock_test_helpers.dart';

test('habit completion with fixed time', () {
  // Arrange: Use fixed time for deterministic testing
  final fixedTime = DateTime(2025, 11, 15, 10, 30); // Friday 10:30 AM
  final clock = Clock.fixed(fixedTime);
  
  // Act: Complete habit
  final habit = Habit.create(
    id: 'test',
    userId: 'user1',
    name: 'Test Habit',
    description: 'Test',
    category: HabitCategory.spiritual,
    clock: clock,
  ).completeToday(clock: clock);
  
  // Assert: Verify completion time matches fixed time
  expect(habit.lastCompletedAt, fixedTime);
});
```

### Provider-Based Testing

When testing widgets or services that use Riverpod providers:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../helpers/clock_test_helpers.dart';

test('service with clock provider', () {
  // Arrange: Create container with fixed clock
  final fixedTime = DateTime(2025, 11, 15, 14, 30);
  final container = createContainerWithFixedClock(fixedTime);
  
  // Act: Read service from provider
  final predictor = container.read(abandonmentPredictorProvider);
  
  // Service automatically uses the fixed clock
  final risk = await predictor.predictRisk(habit);
  
  // Cleanup
  container.dispose();
});
```

---

## Testing Patterns

### Pattern 1: Single Point in Time

Use when you need to test logic at a specific moment:

```dart
test('weekend detection', () {
  // Test on a Saturday
  final saturday = createFixedTimeForWeekday(DateTime.saturday, hour: 14);
  final clock = Clock.fixed(saturday);
  
  final engine = BehavioralEngine(clock: clock);
  // ... test weekend-specific logic
});
```

### Pattern 2: Time Progression

Use when you need to test scenarios that span multiple time periods:

```dart
test('streak calculation over multiple days', () {
  // Arrange: Start on Monday
  final clock = AdvancingClock(DateTime(2025, 11, 10, 9, 0));
  var habit = Habit.create(/* ... */, clock: clock);
  
  // Day 1: Complete habit
  habit = habit.completeToday(clock: clock);
  expect(habit.currentStreak, 1);
  
  // Day 2: Advance time and complete again
  clock.advance(Duration(days: 1));
  habit = habit.completeToday(clock: clock);
  expect(habit.currentStreak, 2);
  
  // Day 3: Skip a day
  clock.advance(Duration(days: 2));
  
  // Day 5: Streak should reset
  habit = habit.completeToday(clock: clock);
  expect(habit.currentStreak, 1);
});
```

### Pattern 3: Historical Data Testing

Use when testing logic that analyzes past completion history:

```dart
test('7-day success rate calculation', () {
  final now = DateTime(2025, 11, 15, 10, 0);
  final clock = Clock.fixed(now);
  
  // Create habit with 5 completions in last 7 days
  final completions = [
    now.subtract(Duration(days: 1)),
    now.subtract(Duration(days: 2)),
    now.subtract(Duration(days: 3)),
    now.subtract(Duration(days: 5)),
    now.subtract(Duration(days: 6)),
  ];
  
  final habit = Habit(
    // ... other fields
    completionHistory: completions,
  ).completeToday(clock: clock);
  
  // 6 completions / 7 days = 0.857
  expect(habit.successRate7d, closeTo(6/7, 0.01));
});
```

### Pattern 4: Provider Override Testing

Use when testing components that inject clock via providers:

```dart
testWidgets('widget with time-dependent display', (tester) async {
  final fixedTime = DateTime(2025, 11, 15, 16, 30);
  
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        clockProvider.overrideWithValue(Clock.fixed(fixedTime)),
      ],
      child: MaterialApp(
        home: YourWidget(),
      ),
    ),
  );
  
  // Widget will use the fixed clock
  await tester.pumpAndSettle();
  
  // Assertions...
});
```

---

## Common Scenarios

### Scenario 1: Testing Weekend Gap Pattern

```dart
test('detects weekend failure pattern', () {
  final monday = DateTime(2025, 11, 10, 9, 0);
  final clock = AdvancingClock(monday);
  final engine = BehavioralEngine(clock: clock);
  
  // Create completions for weekdays only (2 weeks)
  final completions = createWeekdayOnlyDates(
    startMonday: monday,
    weeks: 2,
  );
  
  final habit = Habit(
    // ... other fields
    completionHistory: completions,
    consecutiveFailures: 3, // Simulating weekend failures
  );
  
  // Advance to Monday of week 3
  clock.setTime(monday.add(Duration(days: 14)));
  
  final pattern = engine.detectFailurePattern(habit);
  expect(pattern, FailurePattern.weekendGap);
});
```

### Scenario 2: Testing Streak Maintenance

```dart
test('maintains streak with consecutive completions', () {
  final clock = AdvancingClock(DateTime(2025, 11, 1, 10, 0));
  var habit = Habit.create(/* ... */, clock: clock);
  
  // Complete for 10 consecutive days
  for (int day = 0; day < 10; day++) {
    habit = habit.completeToday(clock: clock);
    expect(habit.currentStreak, day + 1);
    clock.advance(Duration(days: 1));
  }
  
  expect(habit.currentStreak, 10);
  expect(habit.longestStreak, 10);
});
```

### Scenario 3: Testing Time-of-Day Logic

```dart
test('optimal time detection', () {
  final baseTime = DateTime(2025, 11, 1, 7, 0); // 7 AM
  final engine = BehavioralEngine();
  
  // Create 5 completions all at 7 AM
  final completions = List.generate(
    5,
    (i) => baseTime.add(Duration(days: i)),
  );
  
  final habit = Habit(
    // ... other fields
    completionHistory: completions,
  );
  
  final optimalTime = engine.findOptimalTime(habit);
  expect(optimalTime, isNotNull);
  expect(optimalTime!.hour, 7);
});
```

### Scenario 4: Testing ML Predictions with Fixed Time

```dart
test('abandonment prediction uses fixed clock', () async {
  final fixedTime = DateTime(2025, 11, 15, 14, 30); // Friday 2:30 PM
  final predictor = AbandonmentPredictor(clock: Clock.fixed(fixedTime));
  
  await predictor.initialize();
  
  final habit = Habit(
    // ... fields
    lastCompletedAt: fixedTime.subtract(Duration(days: 1)),
  );
  
  final risk = await predictor.predictRisk(habit);
  
  // Risk calculation uses fixedTime for feature extraction
  expect(risk, greaterThanOrEqualTo(0.0));
  expect(risk, lessThanOrEqualTo(1.0));
  
  predictor.dispose();
});
```

### Scenario 5: Testing Month Boundaries

```dart
test('handles month boundary correctly', () {
  // Start near end of October
  final clock = AdvancingClock(DateTime(2025, 10, 28, 10, 0));
  var habit = Habit.create(/* ... */, clock: clock);
  
  // Complete across month boundary (Oct 28-31, Nov 1-3)
  for (int day = 0; day < 7; day++) {
    habit = habit.completeToday(clock: clock);
    clock.advance(Duration(days: 1));
  }
  
  expect(habit.currentStreak, 7);
  
  // Verify completions span two months
  final octCompletions = habit.completionHistory
      .where((d) => d.month == 10)
      .length;
  final novCompletions = habit.completionHistory
      .where((d) => d.month == 11)
      .length;
  
  expect(octCompletions, 4); // Oct 28-31
  expect(novCompletions, 3); // Nov 1-3
});
```

---

## Best Practices

### 1. Always Use Fixed Time for Deterministic Tests

❌ **Bad:**
```dart
test('completion timestamp', () {
  final habit = habit.completeToday(); // Uses system time - non-deterministic!
  // Test might fail at different times of day
});
```

✅ **Good:**
```dart
test('completion timestamp', () {
  final clock = Clock.fixed(DateTime(2025, 11, 15, 10, 30));
  final habit = habit.completeToday(clock: clock);
  expect(habit.lastCompletedAt, DateTime(2025, 11, 15, 10, 30));
});
```

### 2. Use Helper Functions for Common Scenarios

❌ **Bad:**
```dart
// Manually creating dates is error-prone
final completions = [
  DateTime(2025, 11, 10, 9, 0),
  DateTime(2025, 11, 11, 9, 0),
  DateTime(2025, 11, 12, 9, 0),
  // ... more dates
];
```

✅ **Good:**
```dart
final completions = createConsecutiveDates(
  start: DateTime(2025, 11, 10, 9, 0),
  count: 7,
);
```

### 3. Test Edge Cases with Specific Times

Always test boundary conditions:

```dart
test('completion at exact midnight', () {
  final midnight = DateTime(2025, 11, 15, 0, 0, 0);
  final clock = Clock.fixed(midnight);
  // ... test logic
});

test('completion at 11:59 PM', () {
  final almostMidnight = DateTime(2025, 11, 15, 23, 59, 59);
  final clock = Clock.fixed(almostMidnight);
  // ... test logic
});
```

### 4. Clean Up Provider Containers

Always dispose of containers to prevent memory leaks:

```dart
test('service test', () {
  final container = createContainerWithFixedClock(DateTime.now());
  
  try {
    // Test logic
  } finally {
    container.dispose();
  }
});
```

### 5. Use Descriptive Test Names with Time Context

✅ **Good:**
```dart
test('maintains 7-day streak when completing daily at 9 AM', () { /* ... */ });
test('resets streak when missing more than 24 hours', () { /* ... */ });
test('detects weekend gap with 2 weeks of weekday-only completions', () { /* ... */ });
```

---

## Troubleshooting

### Issue: Test Fails Intermittently

**Cause:** Test is using system clock instead of fixed clock.

**Solution:** Ensure all time-dependent code receives the test clock:
```dart
// Make sure to pass clock to all methods
habit = habit.completeToday(clock: clock); // ✅
habit = habit.completeToday(); // ❌ Uses system clock
```

### Issue: Provider Not Using Mocked Clock

**Cause:** Provider override not applied correctly.

**Solution:** Verify override is in place:
```dart
final container = ProviderContainer(
  overrides: [
    clockProvider.overrideWithValue(Clock.fixed(fixedTime)), // ✅
  ],
);
```

### Issue: Time Progression Tests Failing

**Cause:** Not advancing clock between operations.

**Solution:** Remember to advance the clock:
```dart
habit = habit.completeToday(clock: clock);
clock.advance(Duration(days: 1)); // ✅ Don't forget this!
habit = habit.completeToday(clock: clock);
```

### Issue: Weekday Logic Not Working

**Cause:** Using wrong day of week.

**Solution:** Use helper or verify weekday (Monday=1, Sunday=7):
```dart
final monday = createFixedTimeForWeekday(DateTime.monday, hour: 9);
expect(monday.weekday, DateTime.monday); // Verify it's actually Monday
```

---

## Additional Resources

- **Clock Implementation:** `lib/core/services/time/clock.dart`
- **Clock Provider:** `lib/core/providers/clock_provider.dart`
- **Test Helpers:** `test/helpers/clock_test_helpers.dart`
- **Example Tests:** `test/unit/services/time/clock_test.dart`
- **Integration Tests:** `test/integration/time_accelerated_habit_flow_test.dart`

---

## Running Tests with Time Acceleration

For manual testing and dogfooding, you can run the app with accelerated time:

```bash
flutter run --dart-define=FAST_TIME=true
```

This enables DebugClock with 288x speed:
- 1 real minute = 4.8 simulated hours
- 5 real minutes = 1 simulated day
- 35 real minutes = 1 simulated week

Use this to quickly validate multi-day patterns without waiting.
