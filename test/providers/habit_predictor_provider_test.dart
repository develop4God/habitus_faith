import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/providers/habit_predictor_provider.dart';
import 'package:habitus_faith/core/providers/clock_provider.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/habit_predictor_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(Habit(
      id: 'fallback',
      userId: 'user',
      name: 'Fallback',
      category: HabitCategory.spiritual,
      createdAt: DateTime.now(),
    ));
  });

  group('HabitPredictorProvider Tests', () {
    late MockHabitsRepository mockRepo;
    late MockAbandonmentPredictor mockPredictor;
    late MockNotificationService mockNotificationService;
    late MockRemoteConfigService mockRemoteConfig;
    late HabitPredictorService service;

    setUp(() {
      mockRepo = MockHabitsRepository();
      mockPredictor = MockAbandonmentPredictor();
      mockNotificationService = MockNotificationService();
      mockRemoteConfig = MockRemoteConfigService();
      SharedPreferences.setMockInitialValues({});

      when(() => mockRemoteConfig.isMLPredictorEnabled).thenReturn(true);

      final container = ProviderContainer();
      final clock = container.read(clockProvider);

      service = HabitPredictorService(
        habitsRepository: mockRepo,
        predictor: mockPredictor,
        clock: clock,
        remoteConfigFuture: AsyncValue.data(mockRemoteConfig),
        notificationService: mockNotificationService,
      );
    });

    test('processes all active habits', () async {
      final habit1 = Habit(
        id: '1',
        userId: 'user1',
        name: 'Prayer',
        category: HabitCategory.spiritual,
        createdAt: DateTime.now(),
        completedToday: false,
        isArchived: false,
      );
      final habit2 = Habit(
        id: '2',
        userId: 'user1',
        name: 'Exercise',
        category: HabitCategory.physical,
        createdAt: DateTime.now(),
        completedToday: false,
        isArchived: false,
      );

      when(() => mockRepo.getHabits())
          .thenAnswer((_) async => [habit1, habit2]);
      when(() => mockPredictor.predictRisk(any())).thenAnswer((_) async => 0.3);
      when(() => mockRepo.updateHabitInstance(any()))
          .thenAnswer((_) async => null);

      await service.runDailyPredictions();

      verify(() => mockRepo.getHabits()).called(1);
      verify(() => mockPredictor.predictRisk(any())).called(2);
    });

    test('skips completed habits', () async {
      final completedHabit = Habit(
        id: '1',
        userId: 'user1',
        name: 'Prayer',
        category: HabitCategory.spiritual,
        createdAt: DateTime.now(),
        completedToday: true,
      );

      when(() => mockRepo.getHabits())
          .thenAnswer((_) async => [completedHabit]);

      await service.runDailyPredictions();

      verify(() => mockRepo.getHabits()).called(1);
      verifyNever(() => mockPredictor.predictRisk(any()));
    });

    test('skips archived habits', () async {
      final archivedHabit = Habit(
        id: '1',
        userId: 'user1',
        name: 'Old Habit',
        category: HabitCategory.spiritual,
        createdAt: DateTime.now(),
        isArchived: true,
      );

      when(() => mockRepo.getHabits()).thenAnswer((_) async => [archivedHabit]);

      await service.runDailyPredictions();

      verify(() => mockRepo.getHabits()).called(1);
      verifyNever(() => mockPredictor.predictRisk(any()));
    });

    test('skips when ML predictor disabled', () async {
      when(() => mockRemoteConfig.isMLPredictorEnabled).thenReturn(false);

      await service.runDailyPredictions();

      verifyNever(() => mockRepo.getHabits());
    });

    test('handles ML errors gracefully', () async {
      final habit = Habit(
        id: '1',
        userId: 'user1',
        name: 'Prayer',
        category: HabitCategory.spiritual,
        createdAt: DateTime.now(),
        completedToday: false,
      );

      when(() => mockRepo.getHabits()).thenAnswer((_) async => [habit]);
      when(() => mockPredictor.predictRisk(any()))
          .thenThrow(Exception('ML error'));

      await service.runDailyPredictions();

      verify(() => mockRepo.getHabits()).called(1);
    });

    test('triggers intervention for high-risk', () async {
      await SharedPreferences.getInstance();
      final highRiskHabit = Habit(
        id: '1',
        userId: 'user1',
        name: 'Prayer',
        category: HabitCategory.spiritual,
        createdAt: DateTime.now(),
        completedToday: false,
        targetMinutes: 30,
      );

      when(() => mockRepo.getHabits()).thenAnswer((_) async => [highRiskHabit]);
      when(() => mockPredictor.predictRisk(any()))
          .thenAnswer((_) async => 0.75);
      when(() => mockRepo.updateHabitInstance(any()))
          .thenAnswer((_) async => null);
      when(() => mockNotificationService.showImmediateNotification(any(), any(),
          payload: any(named: 'payload'),
          id: any(named: 'id'))).thenAnswer((_) async {});

      await service.runDailyPredictions();

      verify(() => mockNotificationService.showImmediateNotification(
          any(), any(),
          payload: any(named: 'payload'), id: any(named: 'id'))).called(1);
    });

    test('no intervention for low-risk', () async {
      final lowRiskHabit = Habit(
        id: '1',
        userId: 'user1',
        name: 'Prayer',
        category: HabitCategory.spiritual,
        createdAt: DateTime.now(),
        completedToday: false,
      );

      when(() => mockRepo.getHabits()).thenAnswer((_) async => [lowRiskHabit]);
      when(() => mockPredictor.predictRisk(any())).thenAnswer((_) async => 0.4);
      when(() => mockRepo.updateHabitInstance(any()))
          .thenAnswer((_) async => null);

      await service.runDailyPredictions();

      verifyNever(() => mockNotificationService.showImmediateNotification(
          any(), any(),
          payload: any(named: 'payload'), id: any(named: 'id')));
    });

    test('respects cooldown', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nudge_sent_1',
          DateTime.now().subtract(const Duration(hours: 12)).toIso8601String());

      final habit = Habit(
        id: '1',
        userId: 'user1',
        name: 'Prayer',
        category: HabitCategory.spiritual,
        createdAt: DateTime.now(),
        completedToday: false,
        targetMinutes: 30,
      );

      when(() => mockRepo.getHabits()).thenAnswer((_) async => [habit]);
      when(() => mockPredictor.predictRisk(any()))
          .thenAnswer((_) async => 0.75);
      when(() => mockRepo.updateHabitInstance(any()))
          .thenAnswer((_) async => null);

      await service.runDailyPredictions();

      verifyNever(() => mockNotificationService.showImmediateNotification(
          any(), any(),
          payload: any(named: 'payload'), id: any(named: 'id')));
    });

    test('sends nudge after cooldown expires', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nudge_sent_1',
          DateTime.now().subtract(const Duration(hours: 25)).toIso8601String());

      final habit = Habit(
        id: '1',
        userId: 'user1',
        name: 'Prayer',
        category: HabitCategory.spiritual,
        createdAt: DateTime.now(),
        completedToday: false,
        targetMinutes: 30,
      );

      when(() => mockRepo.getHabits()).thenAnswer((_) async => [habit]);
      when(() => mockPredictor.predictRisk(any()))
          .thenAnswer((_) async => 0.75);
      when(() => mockRepo.updateHabitInstance(any()))
          .thenAnswer((_) async => null);
      when(() => mockNotificationService.showImmediateNotification(any(), any(),
          payload: any(named: 'payload'),
          id: any(named: 'id'))).thenAnswer((_) async {});

      await service.runDailyPredictions();

      verify(() => mockNotificationService.showImmediateNotification(
          any(), any(),
          payload: any(named: 'payload'), id: any(named: 'id'))).called(1);
    });
  });
}
