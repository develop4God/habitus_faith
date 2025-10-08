# Running Tests

This project includes comprehensive tests for the Habitus Faith app migration.

## Prerequisites

```bash
flutter pub get
```

## Run All Tests

```bash
flutter test
```

Expected output: **18+ tests passing** ✅

## Run Tests with Coverage

```bash
flutter test --coverage
```

This generates a coverage report in `coverage/lcov.info`

## View Coverage Report (HTML)

```bash
# Install lcov if not already installed
# macOS: brew install lcov
# Linux: sudo apt-get install lcov

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open in browser
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
```

## Run Specific Test Files

```bash
# Unit tests only
flutter test test/unit/

# Integration tests only
flutter test test/integration/

# Widget tests only
flutter test test/widget/

# Specific test file
flutter test test/unit/models/habit_model_test.dart
```

## Run Tests in Watch Mode

```bash
flutter test --watch
```

## Test Categories

### Unit Tests (7 tests)
- `test/unit/models/habit_model_test.dart`
- Tests habit model business logic
- Tests streak calculations
- Tests serialization/deserialization

### Integration Tests (5 tests)
- `test/integration/habits_provider_test.dart`
- Tests Riverpod providers with Firestore
- Tests CRUD operations
- Tests data filtering

### Widget Tests (6 tests)
- `test/widget/habits_page_test.dart`
- Tests UI interactions
- Tests user flows
- Tests Firestore integration in UI

## Expected Results

All tests should pass with:
- ✅ 18+ tests passing
- ✅ 0 failures
- ✅ Coverage >70% on new code
- ✅ No analyzer warnings

## Troubleshooting

### If tests fail:

1. **Missing dependencies**
   ```bash
   flutter pub get
   ```

2. **Stale build cache**
   ```bash
   flutter clean
   flutter pub get
   flutter test
   ```

3. **Platform-specific issues**
   - Ensure you're using Flutter 3.0.0 or later
   - Check that all test dependencies are installed

### Common Issues

**Issue**: Cannot find package imports
**Solution**: Run `flutter pub get`

**Issue**: Test timeout
**Solution**: Some tests use `pumpAndSettle()` - ensure your system isn't overloaded

**Issue**: Firestore mock errors
**Solution**: Verify `fake_cloud_firestore` version is compatible

## Test Helper Files

- `test/helpers/test_providers.dart` - Creates test containers with mocked Firebase
- `test/helpers/fixtures.dart` - Provides test data fixtures

## CI/CD Integration

Add to your CI/CD pipeline:

```yaml
# GitHub Actions example
- name: Run tests
  run: flutter test
  
- name: Generate coverage
  run: flutter test --coverage
  
- name: Upload coverage
  uses: codecov/codecov-action@v2
  with:
    files: coverage/lcov.info
```

## Writing New Tests

Follow the AAA pattern:

```dart
test('description', () {
  // Arrange - Set up test data
  final habit = TestFixtures.habitOracion();
  
  // Act - Execute the action
  final result = habit.completeToday();
  
  // Assert - Verify the result
  expect(result.currentStreak, 1);
});
```

Use test keys for widget tests:

```dart
await tester.tap(find.byKey(const Key('add_habit_fab')));
```
