import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/providers/notification_provider.dart';

void main() {
  group('NotificationProvider', () {
    test('should provide notification initialization future provider', () {
      // Verify that the initialization provider exists
      final initProvider = notificationInitProvider;
      expect(initProvider, isNotNull);
    });
    
    test('should provide notifications enabled future provider', () {
      // Verify that the enabled provider exists
      final enabledProvider = notificationsEnabledProvider;
      expect(enabledProvider, isNotNull);
    });
    
    test('should provide notification time future provider', () {
      // Verify that the time provider exists
      final timeProvider = notificationTimeProvider;
      expect(timeProvider, isNotNull);
    });
  });
}
