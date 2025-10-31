import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';

/// Interface for rate limiting service (state-agnostic)
abstract class IRateLimitService {
  Future<bool> tryConsumeRequest();
  int getRemainingRequests();
}

/// Rate limiting service for Gemini API calls
/// Tracks monthly requests with automatic reset
class RateLimitService implements IRateLimitService {
  final SharedPreferences _prefs;
  final _lock = Lock();
  static const int maxRequests = 10;
  static const _countKey = 'gemini_request_count';
  static const _resetKey = 'gemini_last_reset';

  RateLimitService(this._prefs);

  /// Atomically check and consume a request slot
  /// Returns true if request can proceed, false if limit reached
  @override
  Future<bool> tryConsumeRequest() async {
    return await _lock.synchronized(() async {
      await _checkMonthlyReset();
      final count = _prefs.getInt(_countKey) ?? 0;

      if (count >= maxRequests) return false;

      await _prefs.setInt(_countKey, count + 1);
      return true;
    });
  }

  @override
  int getRemainingRequests() {
    final count = _prefs.getInt(_countKey) ?? 0;
    return (maxRequests - count).clamp(0, maxRequests);
  }

  Future<void> _checkMonthlyReset() async {
    final lastResetStr = _prefs.getString(_resetKey);
    final now = DateTime.now();

    if (lastResetStr == null) {
      await _prefs.setString(_resetKey, now.toIso8601String());
      return;
    }

    final lastReset = DateTime.parse(lastResetStr);

    // Reset if different month/year
    if (now.month != lastReset.month || now.year != lastReset.year) {
      await _prefs.setInt(_countKey, 0);
      await _prefs.setString(_resetKey, now.toIso8601String());
    }
  }
}
