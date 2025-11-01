# Gemini AI Micro-Habits Generator

This module provides AI-powered micro-habit generation using Google's Gemini 1.5 Flash API. The implementation is designed to be **state-management agnostic**, allowing reuse across different Flutter state management patterns (Riverpod, BLoC, Provider, etc.).

## Architecture Overview

```
┌─────────────────────────────────────────┐
│         UI Layer (Riverpod)             │
│  - MicroHabitGeneratorProvider          │
│  - AsyncValue<List<MicroHabit>>         │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│      Service Layer (Pure Dart)          │
│  ┌─────────────────────────────────┐   │
│  │   IGeminiService                 │   │
│  │   - generateMicroHabits()        │   │
│  │   - canMakeRequest()             │   │
│  │   - getRemainingRequests()       │   │
│  └────────┬────────────┬─────────────┘   │
│           │            │                 │
│  ┌────────▼──────┐  ┌──▼───────────┐    │
│  │ ICacheService │  │ IRateLimit   │    │
│  │ (7-day TTL)   │  │ (10/month)   │    │
│  └───────────────┘  └──────────────┘    │
└─────────────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│       Gemini 1.5 Flash API              │
│  - Context-aware prompt generation      │
│  - JSON response parsing                │
│  - Timeout handling (30s)               │
└─────────────────────────────────────────┘
```

## Features

✅ **AI-Generated Habits**: Creates 3 personalized micro-habits based on user goals  
✅ **Biblical Integration**: Each habit includes relevant Bible verse with full text  
✅ **Smart Caching**: 7-day cache to minimize API calls and costs  
✅ **Rate Limiting**: 10 requests/month with automatic monthly reset  
✅ **Error Handling**: Graceful degradation with descriptive error messages  
✅ **State Agnostic**: Works with any state management (currently uses Riverpod)  
✅ **Testable**: 17 unit tests with >90% coverage  
✅ **Secure**: API keys loaded from `.env` with fallback to `--dart-define`  

## Setup

### 1. Get Gemini API Key

1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create a new API key for Gemini 1.5 Flash
3. Copy your API key

### 2. Configure Environment

Create a `.env` file in the project root:

```env
GEMINI_API_KEY=your_actual_api_key_here
GEMINI_MODEL=gemini-1.5-flash
```

**Important**: Never commit the `.env` file to git. It's already in `.gitignore`.

### 3. Alternative: CI/CD Configuration

For production builds, use `--dart-define`:

```bash
flutter build apk --dart-define=GEMINI_API_KEY=your_key
```

## Usage (Riverpod)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitus_faith/core/providers/ai_providers.dart';
import 'package:habitus_faith/features/habits/domain/models/generation_request.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generatorNotifier = ref.read(microHabitGeneratorProvider.notifier);
    final generatorState = ref.watch(microHabitGeneratorProvider);
    final remainingRequests = generatorNotifier.remainingRequests;

    return Column(
      children: [
        Text('$remainingRequests requests remaining this month'),
        
        ElevatedButton(
          onPressed: () async {
            await generatorNotifier.generate(
              GenerationRequest(
                userGoal: 'Orar más consistentemente',
                failurePattern: 'Olvido en las mañanas ocupadas',
                faithContext: 'Cristiano',
                languageCode: 'es',
              ),
            );
          },
          child: Text('Generate Habits'),
        ),
        
        generatorState.when(
          data: (habits) => ListView.builder(
            itemCount: habits.length,
            itemBuilder: (ctx, i) => ListTile(
              title: Text(habits[i].action),
              subtitle: Text('${habits[i].verse} - ${habits[i].purpose}'),
            ),
          ),
          loading: () => CircularProgressIndicator(),
          error: (err, stack) => Text('Error: $err'),
        ),
      ],
    );
  }
}
```

## Domain Models

### MicroHabit

```dart
@freezed
class MicroHabit with _$MicroHabit {
  const factory MicroHabit({
    required String id,
    required String action,       // "Orar 3min al despertar"
    required String verse,         // "Salmos 5:3"
    String? verseText,             // "Oh Jehová, de mañana..."
    required String purpose,       // "Comenzar el día con Dios"
    @Default(5) int estimatedMinutes,
    DateTime? generatedAt,
  }) = _MicroHabit;
}
```

### GenerationRequest

```dart
@freezed
class GenerationRequest with _$GenerationRequest {
  const factory GenerationRequest({
    required String userGoal,     // User's spiritual goal
    String? failurePattern,        // Known obstacles
    @Default('Cristiano') String faithContext,
    @Default('es') String languageCode,
  }) = _GenerationRequest;
}
```

## API Limits

| Limit Type | Value | Behavior |
|------------|-------|----------|
| Monthly Requests | 10 | Hard limit, throws `RateLimitExceededException` |
| Cache Duration | 7 days | Automatic expiry, transparent to user |
| Request Timeout | 30 seconds | Throws `GeminiException` on timeout |
| Response Size | ~3 habits | Fixed at 3 micro-habits per request |

## Error Handling

### RateLimitExceededException

```dart
try {
  await service.generateMicroHabits(request);
} on RateLimitExceededException catch (e) {
  // User exceeded 10 requests/month
  // Show message: "Limit will reset next month"
}
```

### GeminiParseException

```dart
try {
  await service.generateMicroHabits(request);
} on GeminiParseException catch (e) {
  // API returned invalid JSON
  // Log: e.rawResponse
}
```

### ApiKeyMissingException

```dart
try {
  await EnvConfig.load();
  final key = EnvConfig.geminiApiKey;
} on ApiKeyMissingException catch (e) {
  // .env file missing or GEMINI_API_KEY not set
  // Show setup instructions
}
```

## Testing

Run all AI service tests:

```bash
flutter test test/unit/services/
```

Run specific test file:

```bash
flutter test test/unit/services/gemini_service_test.dart
```

### Test Coverage

- **Cache Service**: 6 tests (TTL, expiry, CRUD operations)
- **Rate Limit Service**: 6 tests (monthly reset, counter, limits)
- **Gemini Service**: 5 tests (mocked API, caching, delegation)

## Adapting to BLoC

See [docs/bloc_migration.md](./bloc_migration.md) for complete guide.

**Quick Summary**:
1. Services are already BLoC-compatible (no Riverpod dependencies)
2. Use `get_it` for dependency injection
3. Create BLoC events/states wrapping service calls
4. Inject `IGeminiService` via constructor

## Performance

### Cache Hit Rate

Expected >80% for repeated requests:
- Same goal + failure pattern = cache hit
- 7-day TTL ensures freshness

### API Call Optimization

```
Request Flow:
1. Check rate limit (SharedPreferences read) → <1ms
2. Check cache (SharedPreferences read) → <5ms
3. If cache hit: return immediately (no API call)
4. If cache miss: API call → 1-3 seconds
5. Save to cache (SharedPreferences write) → <10ms
6. Increment counter (SharedPreferences write) → <5ms
```

## Security Considerations

✅ API keys stored in `.env` (not committed)  
✅ Fallback to `--dart-define` for CI/CD  
✅ No sensitive data in error messages  
✅ Cache data encrypted by OS (SharedPreferences)  
✅ Rate limiting prevents abuse  

## Troubleshooting

### "GEMINI_API_KEY not configured"

**Solution**: Create `.env` file in project root with your API key

### "Monthly limit reached"

**Solution**: Wait until next month or implement paid tier

### "Request timed out"

**Solution**: Check internet connection, retry request

### Tests failing

**Solution**: Run `flutter pub get` and `flutter pub run build_runner build`

## Future Enhancements

- [ ] Implement paid tier with higher limits
- [ ] Add habit difficulty levels
- [ ] Support multiple faith contexts (Catholic, Protestant, etc.)
- [ ] Multilingual support beyond Spanish
- [ ] User feedback on generated habits
- [ ] Habit effectiveness tracking

## Contributing

When making changes to AI services:

1. Keep services state-agnostic (no Riverpod imports)
2. Use interfaces for all services
3. Add unit tests for new features
4. Update BLoC migration guide if needed
5. Run `dart analyze` and `dart format`

## License

Same as parent project (Habitus Faith)
