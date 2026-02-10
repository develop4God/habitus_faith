import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/faith_point.dart';

/// Repository for managing faith points with JSON storage
class FaithPointsRepository {
  final SharedPreferences _prefs;
  static const String _pointsKey = 'faith_points';
  static const String _totalPointsKey = 'total_faith_points';

  FaithPointsRepository(this._prefs);

  /// Get all faith points for a user
  Future<List<FaithPoint>> getPoints(String userId) async {
    final jsonString = _prefs.getString(_pointsKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    final allPoints = jsonList
        .map((json) => FaithPoint.fromJson(json as Map<String, dynamic>))
        .toList();

    return allPoints.where((p) => p.userId == userId).toList();
  }

  /// Add a new faith point record
  Future<void> addPoint(FaithPoint point) async {
    final points = await getPoints(point.userId);
    points.add(point);

    final allJsonList = points.map((p) => p.toJson()).toList();
    await _prefs.setString(_pointsKey, json.encode(allJsonList));

    // Update total
    final currentTotal = await getTotalPoints(point.userId);
    await _prefs.setInt(
      '${_totalPointsKey}_${point.userId}',
      currentTotal + point.points,
    );
  }

  /// Get total points for a user
  Future<int> getTotalPoints(String userId) async {
    return _prefs.getInt('${_totalPointsKey}_$userId') ?? 0;
  }

  /// Get points earned in a specific time period
  Future<List<FaithPoint>> getPointsInPeriod(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final allPoints = await getPoints(userId);
    return allPoints.where((p) {
      return p.earnedAt.isAfter(start) && p.earnedAt.isBefore(end);
    }).toList();
  }

  /// Clear all points (for testing)
  Future<void> clearAll() async {
    await _prefs.remove(_pointsKey);
    // Clear all total points keys
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_totalPointsKey)) {
        await _prefs.remove(key);
      }
    }
  }
}
