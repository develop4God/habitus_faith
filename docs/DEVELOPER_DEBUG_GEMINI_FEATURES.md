# Developer Debug Page - Gemini AI Testing Features

## Overview
Added comprehensive testing tools for Gemini AI Coach and Micro Habits Generator to the Developer Debug Page for easy QA and validation.

## New Features Added

### 1. Test Gemini Micro Habits Generator
**Location**: Developer Debug Page → "AI & Gemini Features" section

**What it does**:
- Generates AI-powered micro-habits using Gemini API
- Uses test request:
  - Goal: "Orar más consistentemente" (Pray more consistently)
  - Failure Pattern: "Olvido en las mañanas ocupadas" (Forget in busy mornings)
  - Faith Context: "Cristiano" (Christian)
  - Language: Spanish

**Usage**:
1. Tap "Test Gemini Micro Habits Generator"
2. Wait for generation (shows loading state)
3. See success/error message with habit count

**Logs**:
- `GEMINI 🤖 Starting micro-habits generation test...`
- `GEMINI 🤖 ✅ Generated X micro-habits successfully`
- `GEMINI 🤖 ❌ Error: [error message]`

### 2. Gemini API Status Card
**Location**: Developer Debug Page → Below test button

**Displays**:
- **Remaining requests**: Shows X/month (max 10 by default)
- **Last generation**: Number of habits generated
- **Status**: Current state (Generating... / error / success)

**Real-time updates**: Card automatically updates when you generate habits

### 3. Open Gemini Coach UI
**Location**: Developer Debug Page → "AI & Gemini Features" section

**What it does**:
- Direct navigation to the full Micro Habit Generator page
- Opens the complete UI for manual testing
- Allows custom goal, failure pattern, and language input

**Usage**:
1. Tap "Open Gemini Coach UI"
2. Enter your own goal and failure pattern
3. Generate and review AI-suggested habits
4. Select habits to save

## Testing Workflows

### Quick API Test (1 tap)
```
1. Open Developer Debug Page
2. Tap "Test Gemini Micro Habits Generator"
3. Check logs for GEMINI 🤖 messages
4. Verify success message and habit count
```

### Full UI Test
```
1. Open Developer Debug Page
2. Tap "Open Gemini Coach UI"
3. Enter custom goal (e.g., "Leer la Biblia diariamente")
4. Optional: Add failure pattern
5. Tap "Generate Habits"
6. Review AI-generated habits
7. Select habits to save
```

### API Limit Test
```
1. Note remaining requests in status card
2. Generate habits multiple times
3. Verify request count decreases
4. Test behavior when limit reached (10/month)
```

## Code Integration

### Dependencies Added
- `ai_providers.dart` - Provides `microHabitGeneratorProvider`
- `generation_request.dart` - Model for generation requests
- `micro_habit_generator_page.dart` - Full UI for Gemini Coach

### Provider Usage
```dart
// Access the generator notifier
final generatorNotifier = ref.read(microHabitGeneratorProvider.notifier);

// Check remaining requests
final remaining = generatorNotifier.remainingRequests;

// Generate habits
await generatorNotifier.generate(
  GenerationRequest(
    userGoal: 'Your goal here',
    failurePattern: 'Optional pattern',
    faithContext: 'Cristiano',
    languageCode: 'es',
  ),
);

// Watch generation state
ref.watch(microHabitGeneratorProvider).when(
  data: (habits) => /* success */,
  loading: () => /* loading */,
  error: (error, stack) => /* error */,
);
```

## Features Overview

### Gemini API Capabilities
- **AI-Powered**: Uses Google's Gemini 1.5 Flash API
- **Personalized**: Generates habits based on user goals and patterns
- **Biblical**: Includes relevant Bible verses with full text
- **Localized**: Supports multiple languages (es, en, fr, pt, zh)
- **Smart Caching**: 7-day cache to minimize API calls
- **Rate Limited**: 10 requests/month with automatic reset

### Error Handling
- **RateLimitExceededException**: Shows when monthly limit reached
- **GeminiParseException**: Invalid API response
- **ApiKeyMissingException**: Missing GEMINI_API_KEY
- **Timeout**: 30-second timeout protection

## Logs Reference

All Gemini-related logs use `GEMINI 🤖` emoji:

```
GEMINI 🤖 Starting micro-habits generation test...
GEMINI 🤖 ✅ Generated 3 micro-habits successfully
GEMINI 🤖 ❌ Error: Rate limit exceeded
GEMINI 🤖 ⏳ Loading...
```

## Testing Checklist

- [ ] Test quick generation (1 tap)
- [ ] Verify remaining requests display
- [ ] Test with custom goal in full UI
- [ ] Verify Bible verses are enriched
- [ ] Test error handling (simulate no API key)
- [ ] Test rate limit behavior
- [ ] Verify localization (change language)
- [ ] Test habit selection and save
- [ ] Check logs for proper emoji tags

## Known Limitations

1. **API Key Required**: Must have valid GEMINI_API_KEY in .env
2. **Rate Limit**: 10 requests/month (resets monthly)
3. **Internet Required**: API calls need active connection
4. **Language**: Test defaults to Spanish (can be changed)

## Future Enhancements

- [ ] Add custom test parameters in UI (goal, pattern, language)
- [ ] Add response time metrics
- [ ] Add cache hit/miss statistics
- [ ] Add export generated habits as JSON
- [ ] Add A/B testing for different prompts
- [ ] Add analytics for generation success rate

## Files Modified

- `lib/features/developer/developer_debug_page.dart`
  - Added AI & Gemini Features section
  - Added test generation button
  - Added API status card
  - Added navigation to full UI
  - Added imports for ai_providers and generation_request

## Related Documentation

- `/docs/AI_FEATURES.md` - Complete Gemini AI documentation
- `/docs/AI_COACH_REVIEW.md` - Architecture review and best practices
- `/lib/core/providers/ai_providers.dart` - Provider implementation
- `/lib/features/habits/presentation/ai_generator/` - UI components
