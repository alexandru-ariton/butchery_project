import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;


  ThemeProvider() {
    _loadPreferences();
  }

  ThemeData get themeData => _isDarkMode ? ThemeData.dark() : ThemeData.light();

  bool get isDarkMode => _isDarkMode;
 

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _savePreferences();
  }


  Future<void> _savePreferences() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'isDarkMode': _isDarkMode,
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
        notifyListeners();
      }
    }
  }
}
