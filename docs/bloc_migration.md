# BLoC Migration Guide for Gemini AI Service

This document explains how to adapt the state-agnostic Gemini AI micro-habits generator to use the BLoC pattern instead of Riverpod.

## Overview

The core services (`GeminiService`, `CacheService`, `RateLimitService`) are intentionally designed with **zero state management dependencies**. They use pure Dart interfaces and constructor injection, making them compatible with any dependency injection framework.

## Key Principles

1. **Services are state-agnostic** - No Riverpod or BLoC dependencies in service layer
2. **Use interfaces** - All services implement abstract interfaces for testability
3. **Constructor injection** - Dependencies are injected through constructors, not providers

## Migration Steps

### 1. Add BLoC Dependencies

```yaml
# pubspec.yaml
dependencies:
  flutter_bloc: ^8.1.0
  get_it: ^7.6.0  # or your preferred DI solution
```

### 2. Setup Dependency Injection (get_it example)

```dart
// lib/core/di/service_locator.dart
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // Core dependencies
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // Cache service
  getIt.registerLazySingleton<ICacheService>(
    () => CacheService(getIt<SharedPreferences>()),
  );

  // Rate limit service
  getIt.registerLazySingleton<IRateLimitService>(
    () => RateLimitService(getIt<SharedPreferences>()),
  );

  // Gemini service
  getIt.registerLazySingleton<IGeminiService>(
    () => GeminiService(
      apiKey: EnvConfig.geminiApiKey,
      modelName: EnvConfig.geminiModel,
      cache: getIt<ICacheService>(),
      rateLimit: getIt<IRateLimitService>(),
    ),
  );
}
```

### 3. Create BLoC Events

```dart
// lib/features/habits/presentation/bloc/micro_habit_generator_event.dart
abstract class MicroHabitGeneratorEvent {}

class GenerateMicroHabitsRequested extends MicroHabitGeneratorEvent {
  final GenerationRequest request;
  
  GenerateMicroHabitsRequested(this.request);
}

class RemainingRequestsChecked extends MicroHabitGeneratorEvent {}
```

### 4. Create BLoC States

```dart
// lib/features/habits/presentation/bloc/micro_habit_generator_state.dart
abstract class MicroHabitGeneratorState {}

class MicroHabitGeneratorInitial extends MicroHabitGeneratorState {}

class MicroHabitGeneratorLoading extends MicroHabitGeneratorState {}

class MicroHabitGeneratorSuccess extends MicroHabitGeneratorState {
  final List<MicroHabit> habits;
  final int remainingRequests;
  
  MicroHabitGeneratorSuccess(this.habits, this.remainingRequests);
}

class MicroHabitGeneratorError extends MicroHabitGeneratorState {
  final String message;
  final bool isRateLimit;
  
  MicroHabitGeneratorError(this.message, {this.isRateLimit = false});
}
```

### 5. Create BLoC Implementation

```dart
// lib/features/habits/presentation/bloc/micro_habit_generator_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

class MicroHabitGeneratorBloc 
    extends Bloc<MicroHabitGeneratorEvent, MicroHabitGeneratorState> {
  final IGeminiService _geminiService;

  MicroHabitGeneratorBloc(this._geminiService) 
      : super(MicroHabitGeneratorInitial()) {
    on<GenerateMicroHabitsRequested>(_onGenerateRequested);
    on<RemainingRequestsChecked>(_onRemainingChecked);
  }

  Future<void> _onGenerateRequested(
    GenerateMicroHabitsRequested event,
    Emitter<MicroHabitGeneratorState> emit,
  ) async {
    emit(MicroHabitGeneratorLoading());

    try {
      final habits = await _geminiService.generateMicroHabits(event.request);
      final remaining = _geminiService.getRemainingRequests();
      
      emit(MicroHabitGeneratorSuccess(habits, remaining));
    } on RateLimitExceededException catch (e) {
      emit(MicroHabitGeneratorError(e.message, isRateLimit: true));
    } on GeminiException catch (e) {
      emit(MicroHabitGeneratorError(e.message));
    } catch (e) {
      emit(MicroHabitGeneratorError('An unexpected error occurred: $e'));
    }
  }

  void _onRemainingChecked(
    RemainingRequestsChecked event,
    Emitter<MicroHabitGeneratorState> emit,
  ) {
    final remaining = _geminiService.getRemainingRequests();
    
    if (state is MicroHabitGeneratorSuccess) {
      final current = state as MicroHabitGeneratorSuccess;
      emit(MicroHabitGeneratorSuccess(current.habits, remaining));
    }
  }
}
```

### 6. Provide BLoC in Widget Tree

```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.load();
  await setupDependencyInjection();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (_) => MicroHabitGeneratorBloc(getIt<IGeminiService>()),
        child: MicroHabitGeneratorScreen(),
      ),
    );
  }
}
```

### 7. Use BLoC in UI

```dart
// lib/features/habits/presentation/screens/micro_habit_generator_screen.dart
class MicroHabitGeneratorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Generate Micro-Habits')),
      body: BlocBuilder<MicroHabitGeneratorBloc, MicroHabitGeneratorState>(
        builder: (context, state) {
          if (state is MicroHabitGeneratorLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (state is MicroHabitGeneratorError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(state.message),
                  if (state.isRateLimit)
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Limit will reset next month'),
                    ),
                ],
              ),
            );
          }
          
          if (state is MicroHabitGeneratorSuccess) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('${state.remainingRequests} requests remaining'),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.habits.length,
                    itemBuilder: (ctx, i) => MicroHabitCard(state.habits[i]),
                  ),
                ),
              ],
            );
          }
          
          return Center(
            child: ElevatedButton(
              onPressed: () => _showGenerateDialog(context),
              child: Text('Generate Habits'),
            ),
          );
        },
      ),
    );
  }

  void _showGenerateDialog(BuildContext context) {
    // Show dialog to collect user input
    // Then dispatch event:
    context.read<MicroHabitGeneratorBloc>().add(
      GenerateMicroHabitsRequested(
        GenerationRequest(userGoal: 'Your goal here'),
      ),
    );
  }
}
```

## Testing with BLoC

```dart
// test/bloc/micro_habit_generator_bloc_test.dart
void main() {
  group('MicroHabitGeneratorBloc', () {
    late MockGeminiService mockService;
    late MicroHabitGeneratorBloc bloc;

    setUp(() {
      mockService = MockGeminiService();
      bloc = MicroHabitGeneratorBloc(mockService);
    });

    blocTest<MicroHabitGeneratorBloc, MicroHabitGeneratorState>(
      'emits success when generation succeeds',
      build: () {
        when(() => mockService.generateMicroHabits(any()))
            .thenAnswer((_) async => [MicroHabit(...)]);
        when(() => mockService.getRemainingRequests()).thenReturn(9);
        return bloc;
      },
      act: (bloc) => bloc.add(
        GenerateMicroHabitsRequested(GenerationRequest(...)),
      ),
      expect: () => [
        MicroHabitGeneratorLoading(),
        isA<MicroHabitGeneratorSuccess>(),
      ],
    );
  });
}
```

## Key Differences from Riverpod

| Aspect | Riverpod | BLoC |
|--------|----------|------|
| State Container | AsyncValue<List<MicroHabit>> | MicroHabitGeneratorState |
| Dependency Injection | Providers | get_it / manual |
| State Updates | ref.read/watch | Events → Emitters |
| UI Consumption | Consumer/ConsumerWidget | BlocBuilder/BlocListener |
| Testing | ProviderContainer | blocTest |

## Advantages of This Architecture

1. **Reusable Services**: Same service code works in both apps
2. **Clear Separation**: State management is separate from business logic
3. **Easy Testing**: Mock interfaces, not state management frameworks
4. **Flexibility**: Switch state management without rewriting services
5. **Type Safety**: Compile-time errors, not runtime crashes

## Common Pitfalls

❌ **Don't** add Riverpod dependencies to services  
✅ **Do** keep services pure and inject dependencies

❌ **Don't** use providers inside service constructors  
✅ **Do** use constructor parameters

❌ **Don't** couple UI directly to services  
✅ **Do** use BLoC/Cubit as intermediary layer

## Additional Resources

- [BLoC Library Documentation](https://bloclibrary.dev)
- [get_it Package](https://pub.dev/packages/get_it)
- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)
