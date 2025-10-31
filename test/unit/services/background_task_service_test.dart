import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/background_task_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BackgroundTaskService', () {
    late BackgroundTaskService service;

    setUp(() {
      service = BackgroundTaskService();
      SharedPreferences.setMockInitialValues({});
    });

    test('initializes successfully', () async {
      // Act
      await service.initialize();

      // Assert: Should complete without throwing
      expect(true, true); // Initialization should not throw
    });

    test('arePredictionsEnabled returns true by default', () async {
      // Act
      final enabled = await service.arePredictionsEnabled();

      // Assert
      expect(enabled, true);
    });

    test('setPredictionsEnabled updates preference', () async {
      // Arrange
      await service.initialize();

      // Act: Disable predictions
      await service.setPredictionsEnabled(false);
      final enabled = await service.arePredictionsEnabled();

      // Assert
      expect(enabled, false);
    });

    test('setPredictionsEnabled re-enables predictions', () async {
      // Arrange
      await service.initialize();
      await service.setPredictionsEnabled(false);

      // Act: Re-enable predictions
      await service.setPredictionsEnabled(true);
      final enabled = await service.arePredictionsEnabled();

      // Assert
      expect(enabled, true);
    });

    test('scheduleDailyPrediction does not throw when initialized', () async {
      // Arrange
      await service.initialize();

      // Act & Assert: Should complete without throwing
      expect(
        () => service.scheduleDailyPrediction(),
        returnsNormally,
      );
    });

    test('cancelDailyPrediction does not throw when initialized', () async {
      // Arrange
      await service.initialize();

      // Act & Assert: Should complete without throwing
      expect(
        () => service.cancelDailyPrediction(),
        returnsNormally,
      );
    });

    test('cancelAll does not throw when initialized', () async {
      // Arrange
      await service.initialize();

      // Act & Assert: Should complete without throwing
      expect(
        () => service.cancelAll(),
        returnsNormally,
      );
    });

    test('handles multiple initializations gracefully', () async {
      // Act: Initialize multiple times
      await service.initialize();
      await service.initialize();
      await service.initialize();

      // Assert: Should not throw
      expect(true, true);
    });
  });
}
