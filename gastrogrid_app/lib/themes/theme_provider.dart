import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dark_mode.dart';
import 'light_mode.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightMode;
  String _selectedLanguage = 'English';

  ThemeProvider() {
    _loadSettings();
  }

  ThemeData get themeData => _themeData;
  String get selectedLanguage => _selectedLanguage;

  bool get isDarkMode => _themeData == darkMode;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
    _saveSettings();
  }

  Future<void> changeLanguage(String language) async {
    _selectedLanguage = language;
    notifyListeners();
    _saveSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _themeData = prefs.getBool('isDarkMode') ?? false ? darkMode : lightMode;
    _selectedLanguage = prefs.getString('selectedLanguage') ?? 'English';
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _themeData == darkMode);
    await prefs.setString('selectedLanguage', _selectedLanguage);
  }
}
