import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for storing and retrieving JSON data using SharedPreferences
class JsonStorageService {
  final SharedPreferences _prefs;

  JsonStorageService(this._prefs);

  /// Store a single JSON object
  Future<void> saveJson(String key, Map<String, dynamic> data) async {
    final jsonString = json.encode(data);
    await _prefs.setString(key, jsonString);
  }

  /// Retrieve a single JSON object
  Map<String, dynamic>? getJson(String key) {
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  /// Store a list of JSON objects
  Future<void> saveJsonList(String key, List<Map<String, dynamic>> data) async {
    final jsonString = json.encode(data);
    await _prefs.setString(key, jsonString);
  }

  /// Retrieve a list of JSON objects
  List<Map<String, dynamic>> getJsonList(String key) {
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return [];
    final decoded = json.decode(jsonString);
    return (decoded as List).cast<Map<String, dynamic>>();
  }

  /// Store a boolean flag
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  /// Get a boolean flag
  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  /// Store a string value
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  /// Get a string value
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// Delete a key
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  /// Clear all stored data
  Future<void> clear() async {
    await _prefs.clear();
  }

  /// Check if a key exists
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }
}
