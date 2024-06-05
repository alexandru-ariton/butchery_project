import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:GastroGrid/Autentificare/pagini/pagina_login.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<void> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'isLoggedIn': false, // Initialize the isLoggedIn field
      });
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw e.message!;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      // Check if the user is already logged in on another device
      bool isLoggedIn = await isUserLoggedIn(email);
      if (isLoggedIn) {
        throw 'Utilizatorul este deja autentificat pe alt dispozitiv.';
      }

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Update the isLoggedIn field to true
      await _firestore.collection('users').doc(userCredential.user!.uid).update({
        'isLoggedIn': true,
      });

      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw e.message!;
    }
  }

  Future<void> logout(BuildContext context) async {
    // Update the isLoggedIn field to false before signing out
    if (currentUser != null) {
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'isLoggedIn': false,
      });
    }

    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => PaginaLogin()),
      (route) => false,
    );
  }

  Future<bool> isUserLoggedIn(String email) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.get('isLoggedIn') ?? false;
    }

    return false;
  }
}
