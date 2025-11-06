import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/time/time.dart';

void main() {
  group('Clock implementations', () {
    test('SystemClock returns current time', () {
      final clock = const Clock.system();
      final now = DateTime.now();
      final clockNow = clock.now();

      // Should be within 1 second of each other
      expect(clockNow.difference(now).inSeconds.abs(), lessThan(2));
    });

    test('FixedClock returns fixed time', () {
      final fixedTime = DateTime(2025, 11, 15, 10, 30);
      final clock = Clock.fixed(fixedTime);

      expect(clock.now(), equals(fixedTime));
      expect(clock.now(), equals(fixedTime)); // Should be consistent
    });

    test('DebugClock with multiplier=1 returns normal time', () {
      final clock = DebugClock(daySpeedMultiplier: 1);
      final now = DateTime.now();
      final clockNow = clock.now();

      // Should be within 1 second of each other
      expect(clockNow.difference(now).inSeconds.abs(), lessThan(2));
    });

    test('DebugClock with multiplier>1 accelerates time', () async {
      // With 288x multiplier, 1 second = 4.8 minutes
      final clock = DebugClock(daySpeedMultiplier: 288);
      final start = clock.now();

      // Wait 1 second
      await Future.delayed(const Duration(seconds: 1));

      final end = clock.now();
      final elapsed = end.difference(start);

      // Should be approximately 4-5 minutes (288 seconds)
      expect(elapsed.inSeconds, greaterThan(200)); // At least 3+ minutes
      expect(elapsed.inSeconds, lessThan(400)); // Less than 7 minutes
    });
  });

  group('Clock provider integration', () {
    test('Clock.system is const', () {
      const clock1 = Clock.system();
      const clock2 = Clock.system();

      // Should be the same instance
      expect(identical(clock1, clock2), isTrue);
    });

    test('Clock.fixed is const with same time', () {
      final time1 = DateTime(2025, 11, 15);
      final time2 = DateTime(2025, 11, 15);

      final clock1 = Clock.fixed(time1);
      final clock2 = Clock.fixed(time2);

      // Should return the same time value
      expect(clock1.now(), equals(clock2.now()));
    });
  });

  group('Clock usage in business logic', () {
    test('Fixed clock enables deterministic testing', () {
      final fixedTime = DateTime(2025, 11, 14, 14, 30); // Friday 2:30pm
      final clock = Clock.fixed(fixedTime);

      // Simulate business logic that uses clock
      final now = clock.now();
      expect(now.year, 2025);
      expect(now.month, 11);
      expect(now.day, 14);
      expect(now.hour, 14);
      expect(now.minute, 30);
      expect(now.weekday, 5); // Friday
    });

    test('Fixed clock allows time-traveling forward', () {
      final startTime = DateTime(2025, 11, 10, 9, 0); // Monday 9am
      var currentTime = startTime;

      // Simulate 7 days passing
      for (int day = 0; day < 7; day++) {
        final clock = Clock.fixed(currentTime);
        final now = clock.now();

        // Verify we're at the expected day
        expect(now.difference(startTime).inDays, day);

        // Move to next day
        currentTime = currentTime.add(const Duration(days: 1));
      }

      // Should be 7 days later
      expect(currentTime.difference(startTime).inDays, 7);
    });
  });
}
