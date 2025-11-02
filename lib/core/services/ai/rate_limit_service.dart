import 'package:shared_preferences/shared_preferences.dart';

abstract class IRateLimitService {
  bool canMakeRequest();
  void recordRequest();
  int getRemainingRequests();
  DateTime? getNextAvailableTime();
  Future<void> waitIfNeeded();
}

class RateLimitService implements IRateLimitService {
  static const int _maxRequests = 10;
  static const Duration _timeWindow = Duration(days: 30);
  static const Duration _minDelayBetweenRequests = Duration(seconds: 5);
  static const String _requestsKey = 'gemini_requests';
  static const String _timestampsKey = 'gemini_timestamps';
  static const String _lastRequestKey = 'gemini_last_request';

  final SharedPreferences _prefs;

  RateLimitService(this._prefs);

  List<int> _getRequestTimestamps() {
    final timestamps = _prefs.getStringList(_timestampsKey) ?? [];
    return timestamps.map((s) => int.parse(s)).toList();
  }

  void _saveRequestTimestamps(List<int> timestamps) {
    _prefs.setStringList(
      _timestampsKey,
      timestamps.map((t) => t.toString()).toList(),
    );
  }

  DateTime? _getLastRequestTime() {
    final timestamp = _prefs.getInt(_lastRequestKey);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  void _saveLastRequestTime(DateTime time) {
    _prefs.setInt(_lastRequestKey, time.millisecondsSinceEpoch);
  }

  void _cleanOldTimestamps() {
    final now = DateTime.now();
    final cutoff = now.subtract(_timeWindow);
    var timestamps = _getRequestTimestamps();

    timestamps = timestamps
        .where((ts) =>
        DateTime.fromMillisecondsSinceEpoch(ts).isAfter(cutoff))
        .toList();

    _saveRequestTimestamps(timestamps);
    _prefs.setInt(_requestsKey, timestamps.length);
  }

  @override
  bool canMakeRequest() {
    _cleanOldTimestamps();

    final count = _prefs.getInt(_requestsKey) ?? 0;
    if (count >= _maxRequests) return false;

    final lastRequest = _getLastRequestTime();
    if (lastRequest != null) {
      final timeSinceLastRequest = DateTime.now().difference(lastRequest);
      if (timeSinceLastRequest < _minDelayBetweenRequests) {
        return false;
      }
    }

    return true;
  }

  @override
  void recordRequest() {
    _cleanOldTimestamps();

    final now = DateTime.now();
    var timestamps = _getRequestTimestamps();
    timestamps.add(now.millisecondsSinceEpoch);

    _saveRequestTimestamps(timestamps);
    _saveLastRequestTime(now);
    _prefs.setInt(_requestsKey, timestamps.length);
  }

  @override
  int getRemainingRequests() {
    _cleanOldTimestamps();
    final count = _prefs.getInt(_requestsKey) ?? 0;
    return (_maxRequests - count).clamp(0, _maxRequests);
  }

  @override
  DateTime? getNextAvailableTime() {
    _cleanOldTimestamps();

    final count = _prefs.getInt(_requestsKey) ?? 0;
    if (count < _maxRequests) {
      final lastRequest = _getLastRequestTime();
      if (lastRequest != null) {
        final nextAvailable =
        lastRequest.add(_minDelayBetweenRequests);
        if (DateTime.now().isBefore(nextAvailable)) {
          return nextAvailable;
        }
      }
      return null;
    }

    final timestamps = _getRequestTimestamps();
    if (timestamps.isEmpty) return null;

    final oldestTimestamp =
    DateTime.fromMillisecondsSinceEpoch(timestamps.first);
    return oldestTimestamp.add(_timeWindow);
  }

  @override
  Future<void> waitIfNeeded() async {
    final nextAvailable = getNextAvailableTime();
    if (nextAvailable != null && DateTime.now().isBefore(nextAvailable)) {
      final waitDuration = nextAvailable.difference(DateTime.now());
      await Future.delayed(waitDuration);
    }
  }
}