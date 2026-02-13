import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/providers/habit_predictor_provider.dart';
import 'package:habitus_faith/core/providers/ml_providers.dart';
import 'package:habitus_faith/core/providers/clock_provider.dart';
import 'package:habitus_faith/core/providers/shared_preferences_provider.dart';
import 'package:habitus_faith/core/services/ml/abandonment_predictor.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:habitus_faith/features/habits/domain/models/risk_level.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/habit_predictor_mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('ML Predictor → Notification Integration Tests', () {
    late MockHabitsRepository mockRepo;
    late MockNotificationService mockNotificationService;
    late MockRemoteConfigService mockRemoteConfig;
    late ProviderContainer container;

    setUpAll(() {
      registerFallbackValue(Habit(
        id: 'fallback',
        userId: 'user',
        name: 'Fallback',
        category: HabitCategory.spiritual,
        createdAt: DateTime.now(),
      ));
    });

    setUp(() {
      mockRepo = MockHabitsRepository();
      mockNotificationService = MockNotificationService();
      mockRemoteConfig = MockRemoteConfigService();
      SharedPreferences.setMockInitialValues({});

      when(() => mockRemoteConfig.isMLPredictorEnabled).thenReturn(true);
    });

    tearDown(() {
      container.dispose();
    });

    test('ML predictor initializes before making predictions', () async {
      container = ProviderContainer();

      final predictor = await container.read(abandonmentPredictorInitializedProvider.future);

      expect(predictor, isA<AbandonmentPredictor>());
    });

    test('habitPredictorInitializedProvider ensures ML model is ready', () async {
      // Skip: TensorFlow Lite not available in CI, causes initialization errors
      // TODO: Mock TFLite or test in environment with proper setup
      return;
    }, skip: true);

    test('Risk threshold validation', () {
      expect(RiskThresholds.requiresIntervention(0.64), isFalse);
      expect(RiskThresholds.requiresIntervention(0.65), isTrue);
      expect(RiskThresholds.requiresIntervention(0.75), isTrue);
      expect(RiskThresholds.requiresIntervention(1.0), isTrue);
      
      expect(RiskThresholds.highRiskThreshold, equals(0.65));
      expect(RiskThresholds.mediumRiskThreshold, equals(0.3));
    });

    test('High-risk prediction triggers intervention', () async {
      final prefs = await SharedPreferences.getInstance();
      
      final highRiskHabit = Habit(
        id: 'high-risk-1',
        userId: 'user1',
        name: 'Morning Prayer',
        category: HabitCategory.spiritual,
        createdAt: DateTime.now().subtract(Duration(days: 30)),
        targetMinutes: 30,
        difficultyLevel: 4,
        currentStreak: 2,
        completionHistory: [
          DateTime.now().subtract(Duration(days: 10)),
          DateTime.now().subtract(Duration(days: 8)),
        ],
        lastCompletedAt: DateTime.now().subtract(Duration(days: 8)),
        completedToday: false,
        isArchived: false,
      );

      when(() => mockRepo.getHabits()).thenAnswer((_) async => [highRiskHabit]);
      when(() => mockRepo.updateHabitInstance(any())).thenAnswer((_) async => null);
      when(() => mockNotificationService.showImmediateNotification(
        any(), any(), 
        payload: any(named: 'payload'), 
        id: any(named: 'id')
      )).thenAnswer((_) async {});

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      final clock = container.read(clockProvider);
      final realPredictor = container.read(abandonmentPredictorProvider);
      await realPredictor.initialize();
      
      final service = HabitPredictorService(
        habitsRepository: mockRepo,
        predictor: realPredictor,
        clock: clock,
        remoteConfigFuture: AsyncValue.data(mockRemoteConfig),
        notificationService: mockNotificationService,
      );

      await service.runDailyPredictions();

      verify(() => mockRepo.getHabits()).called(1);
      verify(() => mockRepo.updateHabitInstance(any())).called(greaterThanOrEqualTo(1));
    });
  });
}
