import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:GastroGrid/Autentificare/pagini/pagina_login.dart';
import 'package:GastroGrid/providers/provider_cart.dart';
import 'package:GastroGrid/providers/provider_livrare.dart';
import 'package:provider/provider.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<void> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
      });
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw e.message!;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw e.message!;
    }
  }

   Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => PaginaLogin()),
      (route) => false,
    );
  }

   void resetAppState(BuildContext context) {
    // Exemplu de resetare a coșului de cumpărături
    Provider.of<CartProvider>(context, listen: false).clear();

    // Exemplu de resetare a informațiilor de livrare
    Provider.of<DeliveryProvider>(context, listen: false).resetDeliveryInfo();

    // Adăugați aici alte resetări necesare
  }
}
