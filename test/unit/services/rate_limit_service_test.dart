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
      expect(await service.canMakeRequest(), isTrue);
      expect(service.getRemainingRequests(), equals(10));
    });

    test('tracks request count correctly', () async {
      await service.incrementCounter();
      expect(service.getRemainingRequests(), equals(9));

      await service.incrementCounter();
      expect(service.getRemainingRequests(), equals(8));
    });

    test('blocks requests when limit reached', () async {
      // Use up all requests
      for (int i = 0; i < 10; i++) {
        await service.incrementCounter();
      }

      expect(await service.canMakeRequest(), isFalse);
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
      expect(await service.canMakeRequest(), isTrue);
      expect(service.getRemainingRequests(), equals(10));
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
  });
}
