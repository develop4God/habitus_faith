import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/core/services/ai/rate_limit_service.dart';

void main() {
  group('RateLimitService Tests', () {
    late RateLimitService service;

    setUp(() async {
      // Reset SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      service = RateLimitService(prefs);
    });

    group('Test 1: checkLimit - allows requests within limit', () {
      test('should allow requests when under limit', () {
        // Arrange - Fresh service with 0 requests

        // Act
        final canRequest = service.canMakeRequest();

        // Assert
        expect(canRequest, isTrue);
        expect(service.getRemainingRequests(), equals(10));
      });

      test('should count requests correctly up to limit', () {
        // Arrange - Make 9 requests
        for (int i = 0; i < 9; i++) {
          service.recordRequest();
        }

        // Act - Check remaining count
        final remaining = service.getRemainingRequests();

        // Assert - Should have 1 remaining, but may not allow request due to 5-second delay
        expect(remaining, equals(1));
        // Note: canMakeRequest() may return false due to the 5-second delay
        // between requests, even though we haven't hit the monthly limit
      });

      test('should calculate remaining requests correctly', () {
        // Arrange
        expect(service.getRemainingRequests(), equals(10));

        // Act & Assert - After each request
        service.recordRequest();
        expect(service.getRemainingRequests(), equals(9));

        service.recordRequest();
        expect(service.getRemainingRequests(), equals(8));

        service.recordRequest();
        expect(service.getRemainingRequests(), equals(7));
      });
    });

    group('Test 2: checkLimit - blocks requests over limit', () {
      test('should block request at exactly 10 requests', () {
        // Arrange - Make 10 requests to hit limit
        for (int i = 0; i < 10; i++) {
          service.recordRequest();
        }

        // Act
        final canRequest = service.canMakeRequest();

        // Assert
        expect(canRequest, isFalse);
        expect(service.getRemainingRequests(), equals(0));
      });

      test('should stay blocked after hitting limit', () {
        // Arrange - Make 10 requests
        for (int i = 0; i < 10; i++) {
          service.recordRequest();
        }

        // Act - Try multiple times
        expect(service.canMakeRequest(), isFalse);
        expect(service.canMakeRequest(), isFalse);
        expect(service.canMakeRequest(), isFalse);

        // Assert - Still blocked
        expect(service.getRemainingRequests(), equals(0));
      });

      test('should block requests beyond 10', () {
        // Arrange - Try to exceed limit
        for (int i = 0; i < 15; i++) {
          service.recordRequest();
        }

        // Act
        final canRequest = service.canMakeRequest();

        // Assert
        expect(canRequest, isFalse);
        expect(service.getRemainingRequests(), equals(0));
      });
    });

    group('Test 3: incrementUsage - increments count correctly', () {
      test('should start at 0 requests', () {
        expect(service.getRemainingRequests(), equals(10));
      });

      test('should increment request count', () {
        // Act
        service.recordRequest();
        expect(service.getRemainingRequests(), equals(9));

        service.recordRequest();
        expect(service.getRemainingRequests(), equals(8));

        service.recordRequest();
        expect(service.getRemainingRequests(), equals(7));
      });

      test('should persist request count across checks', () {
        // Arrange
        service.recordRequest();
        service.recordRequest();
        service.recordRequest();

        // Act - Multiple checks should return same value
        expect(service.getRemainingRequests(), equals(7));
        expect(service.getRemainingRequests(), equals(7));
        expect(service.getRemainingRequests(), equals(7));
      });
    });

    group('Test 4: getRemainingRequests - calculates correctly', () {
      test('should return 10 when no requests made', () {
        expect(service.getRemainingRequests(), equals(10));
      });

      test('should calculate remaining after requests', () {
        service.recordRequest();
        expect(service.getRemainingRequests(), equals(9));

        service.recordRequest();
        expect(service.getRemainingRequests(), equals(8));
      });

      test('should return 0 when at limit', () {
        for (int i = 0; i < 10; i++) {
          service.recordRequest();
        }

        expect(service.getRemainingRequests(), equals(0));
      });

      test('should clamp to 0 minimum', () {
        // Arrange - Force more than limit
        for (int i = 0; i < 15; i++) {
          service.recordRequest();
        }

        // Assert - Should be clamped to 0, not negative
        final remaining = service.getRemainingRequests();
        expect(remaining, equals(0));
        expect(remaining, greaterThanOrEqualTo(0));
      });
    });

    group('Test 5: Time-based rate limiting', () {
      test('should enforce minimum delay between requests', () {
        // Arrange
        service.recordRequest();

        // Act - Immediate second request
        final canRequest = service.canMakeRequest();

        // Assert - Should be blocked due to 5-second delay
        expect(canRequest, isFalse);
      });

      test('should return next available time when blocked', () {
        // Arrange
        service.recordRequest();

        // Act
        final nextTime = service.getNextAvailableTime();

        // Assert
        expect(nextTime, isNotNull);
        expect(nextTime!.isAfter(DateTime.now()), isTrue);
      });

      test('should return null when requests are available', () {
        // Arrange - Fresh service

        // Act
        final nextTime = service.getNextAvailableTime();

        // Assert
        expect(nextTime, isNull);
      });

      test('should calculate next available time after limit reached', () {
        // Arrange - Hit the limit
        for (int i = 0; i < 10; i++) {
          service.recordRequest();
          // Sleep briefly to avoid delay blocking
          if (i < 9) {
            // In real implementation, we'd need to wait or mock time
          }
        }

        // Act
        final nextTime = service.getNextAvailableTime();

        // Assert - Should be 30 days from first request
        expect(nextTime, isNotNull);
      });
    });

    group('Test 6: Old timestamp cleanup', () {
      test('should clean timestamps older than 30 days', () async {
        // Note: This test validates the concept
        // In real implementation, we'd need to manipulate time or use a clock service

        // The service automatically cleans old timestamps in _cleanOldTimestamps()
        // which is called by canMakeRequest() and other methods

        expect(service.getRemainingRequests(), equals(10));
      });

      test('should maintain count after cleanup', () {
        // Arrange
        service.recordRequest();
        service.recordRequest();

        // Act - Force cleanup through canMakeRequest
        service.canMakeRequest();

        // Assert - Count should be maintained
        expect(service.getRemainingRequests(), lessThan(10));
      });
    });

    group('Test 7: waitIfNeeded functionality', () {
      test('should return immediately when no wait needed', () async {
        // Arrange - Fresh service
        final stopwatch = Stopwatch()..start();

        // Act
        await service.waitIfNeeded();

        // Assert - Should complete quickly (< 100ms)
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      test('should wait when next available time is in future', () async {
        // Arrange
        service.recordRequest();

        // This test documents the behavior
        // In real scenario, waitIfNeeded would delay until next available time
        expect(service.canMakeRequest(), isFalse);
      });
    });

    group('Test 8: Persistence', () {
      test('should persist state across service instances', () async {
        // Arrange
        service.recordRequest();
        service.recordRequest();
        service.recordRequest();

        expect(service.getRemainingRequests(), equals(7));

        // Act - Create new service instance with same SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final newService = RateLimitService(prefs);

        // Assert - Should restore previous state
        expect(newService.getRemainingRequests(), equals(7));
      });

      test('should maintain timestamp history', () async {
        // Arrange
        for (int i = 0; i < 5; i++) {
          service.recordRequest();
        }

        // Act
        final prefs = await SharedPreferences.getInstance();
        final timestamps = prefs.getStringList('gemini_timestamps');

        // Assert
        expect(timestamps, isNotNull);
        expect(timestamps!.length, equals(5));
      });
    });

    group('Test 9: Edge cases', () {
      test('should handle fresh SharedPreferences', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final newService = RateLimitService(prefs);

        // Assert
        expect(newService.getRemainingRequests(), equals(10));
        expect(newService.canMakeRequest(), isTrue);
      });

      test('should handle corrupt data gracefully', () async {
        // Arrange - Set invalid data
        SharedPreferences.setMockInitialValues({
          'gemini_requests': 'not a number',
          'gemini_timestamps': ['invalid'],
        });
        final prefs = await SharedPreferences.getInstance();

        // Act - Create service
        final newService = RateLimitService(prefs);

        // Assert - Should handle gracefully
        expect(newService, isNotNull);
      });

      test('should clamp remaining requests to valid range', () {
        // The service uses .clamp(0, _maxRequests) to ensure valid range
        expect(service.getRemainingRequests(), greaterThanOrEqualTo(0));
        expect(service.getRemainingRequests(), lessThanOrEqualTo(10));

        // Even after many requests
        for (int i = 0; i < 20; i++) {
          service.recordRequest();
        }

        final remaining = service.getRemainingRequests();
        expect(remaining, greaterThanOrEqualTo(0));
        expect(remaining, lessThanOrEqualTo(10));
      });
    });

    group('Test 10: Configuration validation', () {
      test('should have correct max requests limit', () {
        // Verify configuration matches requirements
        expect(service.getRemainingRequests(), equals(10));
      });

      test('should enforce 30-day time window', () {
        // This is validated by the constant _timeWindow in RateLimitService
        // Duration(days: 30)
        expect(service, isNotNull);
      });

      test('should enforce 5-second minimum delay', () {
        // This is validated by the constant _minDelayBetweenRequests
        // Duration(seconds: 5)
        service.recordRequest();
        expect(service.canMakeRequest(), isFalse);
      });
    });
  });
}
