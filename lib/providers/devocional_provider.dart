import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DevocionalProvider extends ChangeNotifier {
  String _selectedLanguage = 'es';
  String _selectedVersion = 'RVR1960';

  String get selectedLanguage => _selectedLanguage;
  String get selectedVersion => _selectedVersion;

  DevocionalProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedLanguage = prefs.getString('selected_language') ?? 'es';
    _selectedVersion = prefs.getString('selected_version') ?? 'RVR1960';
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    _selectedLanguage = languageCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', languageCode);
    notifyListeners();
  }

  Future<void> setVersion(String versionCode) async {
    _selectedVersion = versionCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_version', versionCode);
    notifyListeners();
  }

  // Get last read position
  Future<Map<String, dynamic>?> getLastPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final versionCode = prefs.getString('last_version');
    final bookNumber = prefs.getInt('last_book_number');
    final chapter = prefs.getInt('last_chapter');

    if (versionCode != null && bookNumber != null && chapter != null) {
      return {
        'version': versionCode,
        'bookNumber': bookNumber,
        'chapter': chapter,
      };
    }
    return null;
  }

  // Save last read position
  Future<void> saveLastPosition(
      String versionCode, int bookNumber, int chapter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_version', versionCode);
    await prefs.setInt('last_book_number', bookNumber);
    await prefs.setInt('last_chapter', chapter);
  }
}
