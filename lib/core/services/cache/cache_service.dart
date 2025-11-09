import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../features/habits/domain/models/micro_habit.dart';

/// Interface for cache service (state-agnostic)
abstract class ICacheService {
  Future<T?> get<T>(String key);
  Future<void> set<T>(String key, T value, {Duration? ttl});
  Future<void> delete(String key);
  Future<void> clear();
}

/// SharedPreferences-based cache implementation
/// Works with any state management pattern
class CacheService implements ICacheService {
  final SharedPreferences _prefs;
  static const _prefix = 'cache_';
  static const _expiryPrefix = 'cache_expiry_';

  CacheService(this._prefs);

  @override
  Future<T?> get<T>(String key) async {
    final fullKey = '$_prefix$key';
    final expiryKey = '$_expiryPrefix$key';

    // Check expiry
    final expiryStr = _prefs.getString(expiryKey);
    if (expiryStr != null) {
      final expiry = DateTime.parse(expiryStr);
      if (DateTime.now().isAfter(expiry)) {
        await delete(key);
        return null;
      }
    }

    final jsonStr = _prefs.getString(fullKey);
    if (jsonStr == null) return null;

    // Type-safe deserialization
    if (T == List<MicroHabit>) {
      final List<dynamic> json = jsonDecode(jsonStr);
      return json.map((e) => MicroHabit.fromJson(e)).toList() as T;
    }

    return jsonDecode(jsonStr) as T;
  }

  @override
  Future<void> set<T>(String key, T value, {Duration? ttl}) async {
    final fullKey = '$_prefix$key';

    String jsonStr;
    if (value is List<MicroHabit>) {
      jsonStr = jsonEncode(value.map((h) => h.toJson()).toList());
    } else {
      jsonStr = jsonEncode(value);
    }

    await _prefs.setString(fullKey, jsonStr);

    if (ttl != null) {
      final expiry = DateTime.now().add(ttl);
      await _prefs.setString('$_expiryPrefix$key', expiry.toIso8601String());
    }
  }

  @override
  Future<void> delete(String key) async {
    final fullKey = '$_prefix$key';
    final expiryKey = '$_expiryPrefix$key';

    await _prefs.remove(fullKey);
    await _prefs.remove(expiryKey);
  }

  @override
  Future<void> clear() async {
    final keys = _prefs.getKeys();
    final cacheKeys = keys.where(
      (k) => k.startsWith(_prefix) || k.startsWith(_expiryPrefix),
    );

    for (final key in cacheKeys) {
      await _prefs.remove(key);
    }
  }
}
