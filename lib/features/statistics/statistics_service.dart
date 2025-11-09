import 'package:shared_preferences/shared_preferences.dart';
import 'statistics_model.dart';
import 'dart:convert';

class StatisticsService {
  static const String statsKey = 'user_statistics';

  Future<void> saveStatistics(StatisticsModel stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(statsKey, jsonEncode(stats.toJson()));
  }

  Future<StatisticsModel> loadStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(statsKey);
    if (jsonString == null) return StatisticsModel.empty();
    return StatisticsModel.fromJson(jsonDecode(jsonString));
  }

  Future<void> clearStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(statsKey);
  }
}
