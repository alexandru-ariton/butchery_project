import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  String _selectedLanguage = 'English';
  double _textSize = 16.0;
  bool _notificationsEnabled = true;

  ThemeProvider() {
    _loadPreferences();
  }

  ThemeData get themeData => _isDarkMode ? ThemeData.dark() : ThemeData.light();

  bool get isDarkMode => _isDarkMode;
  String get selectedLanguage => _selectedLanguage;
  double get textSize => _textSize;
  bool get notificationsEnabled => _notificationsEnabled;

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _savePreferences();
  }

  void changeLanguage(String language) async {
    _selectedLanguage = language;
    notifyListeners();
    await _savePreferences();
  }

  void changeTextSize(double size) async {
    _textSize = size;
    notifyListeners();
    await _savePreferences();
  }

  void toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
    await _savePreferences();
  }

  Future<void> _savePreferences() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'isDarkMode': _isDarkMode,
        'selectedLanguage': _selectedLanguage,
        'textSize': _textSize,
        'notificationsEnabled': _notificationsEnabled,
      }, SetOptions(merge: true));
    }
  }

  Future<void> _loadPreferences() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>;
        _isDarkMode = data['isDarkMode'] ?? _isDarkMode;
        _selectedLanguage = data['selectedLanguage'] ?? _selectedLanguage;
        _textSize = data['textSize'] ?? _textSize;
        _notificationsEnabled = data['notificationsEnabled'] ?? _notificationsEnabled;
        notifyListeners();
      }
    }
  }
}
