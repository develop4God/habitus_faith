import 'package:shared_preferences/shared_preferences.dart';

/// Interface for key-value preferences used by AbandonmentPredictor.
///
/// Abstracts away [SharedPreferences.getInstance] so the predictor
/// can be tested without a platform channel.
abstract class IPreferencesService {
  int? getInt(String key);
  Future<bool> setInt(String key, int value);
  String? getString(String key);
  Future<bool> setString(String key, String value);
}

/// Production implementation wrapping a [SharedPreferences] instance.
class SharedPreferencesService implements IPreferencesService {
  final SharedPreferences _prefs;

  SharedPreferencesService(this._prefs);

  @override
  int? getInt(String key) => _prefs.getInt(key);

  @override
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);
}
