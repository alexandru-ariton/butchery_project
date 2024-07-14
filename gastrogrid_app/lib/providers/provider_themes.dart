// Importă pachetul principal pentru construirea UI-ului în Flutter.
import 'package:flutter/material.dart';
// Importă pachetul pentru interacțiunea cu baza de date Firestore.
import 'package:cloud_firestore/cloud_firestore.dart';
// Importă pachetul pentru autentificare Firebase.
import 'package:firebase_auth/firebase_auth.dart';

// Clasă care gestionează tema aplicației și notifică ascultătorii când tema se schimbă.
class ThemeProvider with ChangeNotifier {
  // Variabilă privată care indică dacă modul întunecat este activat.
  bool _isDarkMode = false;

  // Constructor care încarcă preferințele utilizatorului la inițializare.
  ThemeProvider() {
    _loadPreferences();
  }

  // Getter pentru obținerea temei curente. Returnează ThemeData.dark() dacă este activat modul întunecat, altfel ThemeData.light().
  ThemeData get themeData => _isDarkMode ? ThemeData.dark() : ThemeData.light();

  // Getter pentru obținerea stării modului întunecat.
  bool get isDarkMode => _isDarkMode;

  // Metodă pentru comutarea între modul întunecat și modul luminos.
  void toggleTheme() async {
    _isDarkMode = !_isDarkMode; // Comută starea modului întunecat.
    notifyListeners(); // Notifică ascultătorii despre schimbare.
    await _savePreferences(); // Salvează preferințele utilizatorului.
  }

  // Metodă privată pentru salvarea preferințelor utilizatorului în Firestore.
  Future<void> _savePreferences() async {
    User? user = FirebaseAuth.instance.currentUser; // Obține utilizatorul curent autentificat.
    if (user != null) {
      // Salvează starea modului întunecat în documentul utilizatorului din Firestore.
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'isDarkMode': _isDarkMode,
      }, SetOptions(merge: true)); // SetOptions(merge: true) pentru a evita suprascrierea altor date.
    }
  }

  // Metodă privată pentru încărcarea preferințelor utilizatorului din Firestore.
  Future<void> _loadPreferences() async {
    User? user = FirebaseAuth.instance.currentUser; // Obține utilizatorul curent autentificat.
    if (user != null) {
      // Obține documentul utilizatorului din Firestore.
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        // Dacă documentul există, încarcă datele și actualizează starea modului întunecat.
        var data = userDoc.data() as Map<String, dynamic>;
        _isDarkMode = data['isDarkMode'] ?? _isDarkMode;
        notifyListeners(); // Notifică ascultătorii despre schimbare.
      }
    }
  }
}
