import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/journey_level.dart';

/// Repository for managing journey level progression
class JourneyLevelRepository {
  final SharedPreferences _prefs;
  static const String _levelKey = 'journey_level';

  JourneyLevelRepository(this._prefs);

  /// Get current journey level for a user
  Future<JourneyLevel?> getLevel(String userId) async {
    final jsonString = _prefs.getString('${_levelKey}_$userId');
    if (jsonString == null) return null;

    final jsonData = json.decode(jsonString) as Map<String, dynamic>;
    return JourneyLevel.fromJson(jsonData);
  }

  /// Save journey level
  Future<void> saveLevel(JourneyLevel level) async {
    final jsonString = json.encode(level.toJson());
    await _prefs.setString('${_levelKey}_${level.userId}', jsonString);
  }

  /// Initialize a new user's journey
  Future<JourneyLevel> initializeForUser(String userId) async {
    final level = JourneyLevel.initial(userId);
    await saveLevel(level);
    return level;
  }

  /// Clear level data (for testing)
  Future<void> clearAll() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_levelKey)) {
        await _prefs.remove(key);
      }
    }
  }
}
