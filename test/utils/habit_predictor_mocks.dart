import 'package:habitus_faith/core/services/ml/abandonment_predictor.dart';
import 'package:habitus_faith/core/services/notifications/notification_service.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:mocktail/mocktail.dart';

class MockHabitsRepository extends Mock {
  Future<List<Habit>> getHabits();
  Future<dynamic> updateHabitInstance(Habit habit);
}

class MockAbandonmentPredictor extends Mock implements AbandonmentPredictor {}

class MockNotificationService extends Mock implements NotificationService {}

class MockRemoteConfigService extends Mock {
  bool get isMLPredictorEnabled;
}
