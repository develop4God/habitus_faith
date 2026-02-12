# Next Steps - Tasks 6-8 (GeminiService & RateLimitService)

## Quick Start for February 13, 2026

### Morning Checklist
1. ✅ Review yesterday's progress: `docs/Production Readiness/DAILY_PROGRESS_2026_02_12.md`
2. ✅ Review living plan: `docs/Production Readiness/LIVING_ACTION_PLAN_GAPS_2026_02_12.md`
3. ✅ Run validation script: `./validate_architecture_fixes.sh`
4. ✅ Check no regressions: `flutter test`

---

## Task 6: GeminiService - Create Test File (2 hours)

### Step 1: Create Test Directory
```bash
mkdir -p test/unit/services/ai
cd test/unit/services/ai
```

### Step 2: Create Test File
```bash
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
      // TODO: Initialize service with mock client
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

### Step 3: Verify Compilation
```bash
cd /home/develop4god/Projects/habitus_faith
flutter analyze test/unit/services/ai/gemini_service_test.dart
```

### Step 4: Update Living Plan
Mark Task 6 as complete:
```bash
# Edit: docs/Production Readiness/LIVING_ACTION_PLAN_GAPS_2026_02_12.md
# Change Task 6 status from ⬜ to ✅ (Feb 13)
```

---

## Task 7: GeminiService - Implement Tests (6 hours)

### Test 1: Valid MicroHabits (1 hour)
```dart
test('generateHabits - returns valid MicroHabits', () async {
  // Arrange
  final mockResponse = {
    'candidates': [
      {
        'content': {
          'parts': [
            {
              'text': '''
              {
                "habits": [
                  {
                    "title": "Morning Prayer",
                    "description": "5 minutes of prayer",
                    "category": "spiritual",
                    "difficultyLevel": 2,
                    "bibleVerse": "Matthew 6:6"
                  }
                ]
              }
              '''
            }
          ]
        }
      }
    ]
  };
  
  when(() => mockClient.generateContent(any()))
      .thenAnswer((_) async => mockResponse);
  
  // Act
  final habits = await service.generateHabits(
    motivations: ['spiritual growth'],
    challenges: ['consistency'],
    experience: 'beginner',
  );
  
  // Assert
  expect(habits, isNotEmpty);
  expect(habits.first.title, 'Morning Prayer');
  expect(habits.first.category, HabitCategory.spiritual);
  verify(() => mockClient.generateContent(any())).called(1);
});
```

### Test 2: API Error Handling (1 hour)
```dart
test('generateHabits - handles API errors gracefully', () async {
  // Arrange
  when(() => mockClient.generateContent(any()))
      .thenThrow(Exception('API unavailable'));
  
  // Act & Assert
  expect(
    () => service.generateHabits(
      motivations: ['growth'],
      challenges: [],
      experience: 'beginner',
    ),
    throwsA(isA<GeminiServiceException>()),
  );
  
  // Should still have called API once
  verify(() => mockClient.generateContent(any())).called(1);
});
```

### Test 3: Rate Limiting (1 hour)
```dart
test('generateHabits - enforces rate limiting', () async {
  // Arrange
  final rateLimitService = MockRateLimitService();
  when(() => rateLimitService.checkLimit()).thenAnswer((_) async => false);
  
  // Inject rate limit service into GeminiService
  final serviceWithLimits = GeminiService(
    client: mockClient,
    rateLimitService: rateLimitService,
  );
  
  // Act & Assert
  expect(
    () => serviceWithLimits.generateHabits(
      motivations: ['growth'],
      challenges: [],
      experience: 'beginner',
    ),
    throwsA(isA<RateLimitExceededException>()),
  );
  
  // Should NOT have called API
  verifyNever(() => mockClient.generateContent(any()));
});
```

### Test 4: Input Sanitization (1 hour)
```dart
test('generateHabits - sanitizes user input', () async {
  // Arrange
  when(() => mockClient.generateContent(any()))
      .thenAnswer((_) async => validMockResponse);
  
  // Act
  await service.generateHabits(
    motivations: ['<script>alert("XSS")</script>'],
    challenges: ['SQL injection\'; DROP TABLE habits;--'],
    experience: 'beginner',
  );
  
  // Assert
  final captured = verify(() => mockClient.generateContent(captureAny())).captured;
  final prompt = captured.first as String;
  
  // Verify dangerous content was sanitized
  expect(prompt, isNot(contains('<script>')));
  expect(prompt, isNot(contains('DROP TABLE')));
  expect(prompt, isNot(contains("'")));
});
```

### Test 5: Bible Verse Enrichment (1 hour)
```dart
test('generateHabits - enriches with Bible verses', () async {
  // Arrange
  final mockResponseWithVerse = {
    'candidates': [
      {
        'content': {
          'parts': [
            {
              'text': '''
              {
                "habits": [
                  {
                    "title": "Prayer",
                    "bibleVerse": "Matthew 6:6"
                  }
                ]
              }
              '''
            }
          ]
        }
      }
    ]
  };
  
  when(() => mockClient.generateContent(any()))
      .thenAnswer((_) async => mockResponseWithVerse);
  
  // Act
  final habits = await service.generateHabits(
    motivations: ['prayer'],
    challenges: [],
    experience: 'beginner',
  );
  
  // Assert
  expect(habits.first.bibleVerse, isNotNull);
  expect(habits.first.bibleVerse, contains('Matthew'));
});
```

### Test 6: Malformed Response (30 min)
```dart
test('generateHabits - handles malformed API response', () async {
  // Arrange - Invalid JSON
  when(() => mockClient.generateContent(any()))
      .thenAnswer((_) async => {
        'candidates': [
          {'content': {'parts': [{'text': 'Not valid JSON!'}]}}
        ]
      });
  
  // Act & Assert
  expect(
    () => service.generateHabits(
      motivations: ['growth'],
      challenges: [],
      experience: 'beginner',
    ),
    throwsA(isA<MalformedResponseException>()),
  );
});
```

### Test 7: Timeout Handling (30 min)
```dart
test('generateHabits - respects timeout', () async {
  // Arrange - Simulate slow API
  when(() => mockClient.generateContent(any()))
      .thenAnswer((_) async {
        await Future.delayed(Duration(seconds: 31)); // Longer than timeout
        return validMockResponse;
      });
  
  // Act & Assert
  expect(
    () => service.generateHabits(
      motivations: ['growth'],
      challenges: [],
      experience: 'beginner',
    ),
    throwsA(isA<TimeoutException>()),
  );
}, timeout: Timeout(Duration(seconds: 35)));
```

### Verification After Each Test
```bash
# Run specific test
flutter test test/unit/services/ai/gemini_service_test.dart --name "returns valid MicroHabits"

# Run all GeminiService tests
flutter test test/unit/services/ai/gemini_service_test.dart

# Check coverage
flutter test --coverage test/unit/services/ai/gemini_service_test.dart
```

---

## Task 8: RateLimitService - Complete Test Suite (4 hours)

### Create Test File
```bash
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
      expect(await service.getRemainingRequests(), 1);
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
      expect(await service.getRemainingRequests(), 0);
    });
    
    test('incrementUsage - increments count correctly', () async {
      // Arrange
      expect(await service.getCurrentUsage(), 0);
      
      // Act
      await service.incrementUsage();
      await service.incrementUsage();
      await service.incrementUsage();
      
      // Assert
      expect(await service.getCurrentUsage(), 3);
      expect(await service.getRemainingRequests(), 7);
    });
    
    test('getRemainingRequests - calculates correctly', () async {
      // Arrange
      await service.incrementUsage();
      await service.incrementUsage();
      
      // Act
      final remaining = await service.getRemainingRequests();
      
      // Assert
      expect(remaining, 8); // 10 - 2 = 8
    });
    
    test('resetMonthly - resets count on new month', () async {
      // Arrange
      for (int i = 0; i < 10; i++) {
        await service.incrementUsage();
      }
      expect(await service.checkLimit(), false);
      
      // Act
      await service.resetMonthly();
      
      // Assert
      expect(await service.checkLimit(), true);
      expect(await service.getCurrentUsage(), 0);
      expect(await service.getRemainingRequests(), 10);
    });
  });
}
EOF
```

### Run Tests
```bash
flutter test test/unit/services/ai/rate_limit_service_test.dart
```

---

## End of Day Checklist

1. ✅ Run full test suite: `flutter test`
2. ✅ Check coverage: `flutter test --coverage`
3. ✅ Run analysis: `flutter analyze`
4. ✅ Update Living Plan with completed tasks
5. ✅ Create daily progress report
6. ✅ Commit changes:
```bash
git add .
git commit -m "feat: Add GeminiService and RateLimitService test suites

- Implemented 7 comprehensive GeminiService tests
- Implemented 5 RateLimitService tests
- All tests use proper DI and mocking
- Coverage targets achieved

Tasks completed: 6, 7, 8
Week 1 progress: 8/8 tasks (100%)
"
git push
```

---

## Time Tracking

| Task | Estimated | Start Time | End Time | Actual |
|------|-----------|------------|----------|--------|
| Task 6 | 2h | | | |
| Task 7 | 6h | | | |
| Task 8 | 4h | | | |
| **Total** | **12h** | | | |

---

## Success Criteria

- ✅ All 12 new tests passing
- ✅ GeminiService coverage >80%
- ✅ RateLimitService coverage >80%
- ✅ No compilation errors
- ✅ No analysis warnings
- ✅ Week 1 complete (8/8 tasks)

---

**Good luck! Follow the step-by-step instructions and you'll complete Week 1!** 🚀

