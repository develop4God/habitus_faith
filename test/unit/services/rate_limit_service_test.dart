import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/core/services/ai/rate_limit_service.dart';

void main() {
  group('RateLimitService', () {
    late SharedPreferences prefs;
    late RateLimitService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      service = RateLimitService(prefs);
    });

    test('allows requests when under limit', () async {
      expect(await service.tryConsumeRequest(), isTrue);
      expect(service.getRemainingRequests(), equals(9));
    });

    test('tracks request count correctly with atomic operation', () async {
      await service.tryConsumeRequest();
      expect(service.getRemainingRequests(), equals(9));

      await service.tryConsumeRequest();
      expect(service.getRemainingRequests(), equals(8));
    });

    test('blocks requests when limit reached', () async {
      // Use up all requests
      for (int i = 0; i < 10; i++) {
        expect(await service.tryConsumeRequest(), isTrue);
      }

      expect(await service.tryConsumeRequest(), isFalse);
      expect(service.getRemainingRequests(), equals(0));
    });

    test('resets counter on new month', () async {
      // Set last reset to previous month
      final lastMonth = DateTime.now().subtract(const Duration(days: 32));
      await prefs.setString('gemini_last_reset', lastMonth.toIso8601String());
      await prefs.setInt('gemini_request_count', 10);

      // Create new service instance to trigger reset check
      service = RateLimitService(prefs);

      // Should allow request (new month = reset)
      expect(await service.tryConsumeRequest(), isTrue);
      expect(service.getRemainingRequests(), equals(9));
    });

    test('does not reset counter in same month', () async {
      final now = DateTime.now();
      await prefs.setString('gemini_last_reset', now.toIso8601String());
      await prefs.setInt('gemini_request_count', 5);

      service = RateLimitService(prefs);

      expect(service.getRemainingRequests(), equals(5));
    });

    test('remaining requests never goes negative', () async {
      // Manually set count beyond limit (edge case)
      await prefs.setInt('gemini_request_count', 15);
      service = RateLimitService(prefs);

      expect(service.getRemainingRequests(), equals(0));
    });

    test('handles concurrent requests atomically', () async {
      // Test concurrent access doesn't cause race conditions
      final futures = List.generate(
        15,
        (_) => service.tryConsumeRequest(),
      );

      final results = await Future.wait(futures);

      // Exactly 10 should succeed, 5 should fail
      final successCount = results.where((r) => r).length;
      expect(successCount, equals(10));
      expect(service.getRemainingRequests(), equals(0));
    });
  });
}
