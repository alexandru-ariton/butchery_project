// Importă pachetul pentru interacțiunea cu baza de date Firestore.
import 'package:cloud_firestore/cloud_firestore.dart';
// Importă pachetul pentru autentificare Firebase.
import 'package:firebase_auth/firebase_auth.dart';
// Importă pachetul principal pentru construirea UI-ului în Flutter.
import 'package:flutter/material.dart';
// Importă pagina de login a aplicației.
import 'package:gastrogrid_app/Autentificare/pagini/pagina_login.dart';

// Clasă care gestionează autentificarea utilizatorilor și notifică ascultătorii când există schimbări.
class AuthProvider with ChangeNotifier {
  // Instanță a autentificării Firebase.
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Instanță a Firestore.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getter pentru obținerea utilizatorului curent autentificat.
  User? get currentUser => _auth.currentUser;

  // Metodă pentru înregistrarea unui utilizator nou.
  Future<void> signUp(String email, String password) async {
    try {
      // Crează un utilizator nou cu email și parolă.
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      // Salvează detaliile utilizatorului în colecția 'users' din Firestore.
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'isLoggedIn': false,
        'parola': password,
      });
      notifyListeners(); // Notifică ascultătorii despre schimbare.
    } on FirebaseAuthException catch (e) {
      throw e.message!; // Aruncă mesajul de eroare în caz de eșec.
    }
  }

  // Metodă pentru autentificarea unui utilizator existent.
  Future<void> login(String email, String password) async {
    try {
      // Verifică dacă utilizatorul există în colecțiile 'users' sau 'admin_users'.
      bool userExists = await isUserInCollection(email, 'users');
      bool adminExists = await isUserInCollection(email, 'admin_users');

      if (!userExists && !adminExists) {
        throw 'Utilizatorul nu exista.';
      }

      String collection = userExists ? 'users' : 'admin_users';

      // Asigură că câmpul 'isLoggedIn' există pentru utilizator.
      await ensureIsLoggedInFieldExists(email, collection);

      // Verifică dacă utilizatorul este deja autentificat.
      bool isLoggedIn = await isUserLoggedIn(email, collection);

      if (isLoggedIn && collection == 'users') {
        throw 'Utilizatorul este deja autentificat pe alt dispozitiv.';
      }

      // Autentifică utilizatorul cu email și parolă.
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Actualizează câmpul 'isLoggedIn' în Firestore.
      await _firestore.collection(collection).doc(userCredential.user!.uid).update({
        'isLoggedIn': true,
      });

      notifyListeners(); // Notifică ascultătorii despre schimbare.
    } on FirebaseAuthException catch (e) {
      throw e.message!; // Aruncă mesajul de eroare în caz de eșec.
    }
  }

  // Metodă pentru deautentificarea utilizatorului.
  Future<void> logout(BuildContext context) async {
    if (currentUser != null) {
      String email = currentUser!.email!;
      // Verifică dacă utilizatorul există în colecția 'users'.
      bool userExists = await isUserInCollection(email, 'users');
      String collection = userExists ? 'users' : 'admin_users';

      // Obține documentul utilizatorului din Firestore.
      DocumentSnapshot docSnapshot = await _firestore.collection(collection).doc(currentUser!.uid).get();
      if (docSnapshot.exists) {
        // Actualizează câmpul 'isLoggedIn' la false.
        await _firestore.collection(collection).doc(currentUser!.uid).update({
          'isLoggedIn': false,
        });
      } else {
        print('Document not found. Cannot update non-existent document.');
      }
    }

    await _auth.signOut(); // Deautentifică utilizatorul.
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => PaginaLogin()), // Navighează la pagina de login.
      (route) => false,
    );
  }

  // Metodă pentru verificarea existenței unui utilizator într-o colecție specifică.
  Future<bool> isUserInCollection(String email, String collection) async {
    final querySnapshot = await _firestore
        .collection(collection)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty; // Returnează true dacă utilizatorul există.
  }

  // Metodă pentru verificarea stării de autentificare a unui utilizator.
  Future<bool> isUserLoggedIn(String email, String collection) async {
    final querySnapshot = await _firestore
        .collection(collection)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.get('isLoggedIn') ?? false; // Returnează starea de autentificare.
    }

    return false; // Returnează false dacă utilizatorul nu este autentificat.
  }

  // Metodă pentru verificarea stării de autentificare curente.
  Future<bool> isLoggedIn() async {
    if (currentUser != null) {
      String email = currentUser!.email!;
      bool userExists = await isUserInCollection(email, 'users');
      bool adminExists = await isUserInCollection(email, 'admin_users');
      String collection = userExists ? 'users' : (adminExists ? 'admin_users' : '');

      if (collection.isNotEmpty) {
        return await isUserLoggedIn(email, collection); // Returnează starea de autentificare.
      }
    }
    return false; // Returnează false dacă utilizatorul nu este autentificat.
  }

  // Metodă pentru asigurarea existenței câmpului 'isLoggedIn' într-un document.
  Future<void> ensureIsLoggedInFieldExists(String email, String collection) async {
    final querySnapshot = await _firestore
        .collection(collection)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      if (!doc.data().containsKey('isLoggedIn')) {
        await doc.reference.update({'isLoggedIn': false}); // Adaugă câmpul 'isLoggedIn' dacă nu există.
      }
    }
  }
}
