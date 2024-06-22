import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gastrogrid_app/Autentificare/pagini/pagina_login.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<void> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'isLoggedIn': false, 
      });
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw e.message!;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      bool userExists = await isUserInCollection(email, 'users');
      bool adminExists = await isUserInCollection(email, 'admin_users');

      if (!userExists && !adminExists) {
        throw 'Utilizatorul nu exista.';
      }

      String collection = userExists ? 'users' : 'admin_users';

      await ensureIsLoggedInFieldExists(email, collection);

      bool isLoggedIn = await isUserLoggedIn(email, collection);

      if (isLoggedIn && collection == 'users') {
        throw 'Utilizatorul este deja autentificat pe alt dispozitiv.';
      }

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);

      await _firestore.collection(collection).doc(userCredential.user!.uid).update({
        'isLoggedIn': true,
      });

      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw e.message!;
    }
  }

  Future<void> logout(BuildContext context) async {
    if (currentUser != null) {
      String email = currentUser!.email!;
      bool userExists = await isUserInCollection(email, 'users');
      String collection = userExists ? 'users' : 'admin_users';

      DocumentSnapshot docSnapshot = await _firestore.collection(collection).doc(currentUser!.uid).get();
      if (docSnapshot.exists) {
        await _firestore.collection(collection).doc(currentUser!.uid).update({
          'isLoggedIn': false,
        });
      } else {
        print('Document not found. Cannot update non-existent document.');
      }
    }

    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => PaginaLogin()),
      (route) => false,
    );
  }

  Future<bool> isUserInCollection(String email, String collection) async {
    final querySnapshot = await _firestore
        .collection(collection)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<bool> isUserLoggedIn(String email, String collection) async {
    final querySnapshot = await _firestore
        .collection(collection)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.get('isLoggedIn') ?? false;
    }

    return false;
  }

  Future<bool> isLoggedIn() async {
    if (currentUser != null) {
      String email = currentUser!.email!;
      bool userExists = await isUserInCollection(email, 'users');
      bool adminExists = await isUserInCollection(email, 'admin_users');
      String collection = userExists ? 'users' : (adminExists ? 'admin_users' : '');

      if (collection.isNotEmpty) {
        return await isUserLoggedIn(email, collection);
      }
    }
    return false;
  }

  Future<void> ensureIsLoggedInFieldExists(String email, String collection) async {
    final querySnapshot = await _firestore
        .collection(collection)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      if (!doc.data().containsKey('isLoggedIn')) {
        await doc.reference.update({'isLoggedIn': false});
      }
    }
  }
}
