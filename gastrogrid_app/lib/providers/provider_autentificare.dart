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
    // Check if the user exists in the users or admin_users collection
    bool userExists = await isUserInCollection(email, 'users');
    bool adminExists = await isUserInCollection(email, 'admin_users');
    
    if (!userExists && !adminExists) {
      throw 'Utilizatorul nu există.';
    }

    String collection = userExists ? 'users' : 'admin_users';

    // Ensure the document has the 'isLoggedIn' field
    await ensureIsLoggedInFieldExists(email, collection);

    // Check if the user is already logged in on another device
    bool isLoggedIn = await isUserLoggedIn(email, collection);
    if (isLoggedIn) {
      throw 'Utilizatorul este deja autentificat pe alt dispozitiv.';
    }

    UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);

    // Check if the document exists before updating
    DocumentSnapshot docSnapshot = await _firestore.collection(collection).doc(userCredential.user!.uid).get();
    if (!docSnapshot.exists) {
      // If the document does not exist, create it first
      await _firestore.collection(collection).doc(userCredential.user!.uid).set({
        'email': email,
        'isLoggedIn': true,
      });
    } else {
      // Update the isLoggedIn field to true
      await _firestore.collection(collection).doc(userCredential.user!.uid).update({
        'isLoggedIn': true,
      });
    }

    notifyListeners();
  } on FirebaseAuthException catch (e) {
    throw e.message!;
  }
}

Future<void> logout(BuildContext context) async {
  // Update the isLoggedIn field to false before signing out
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
      // Handle the case where the document does not exist, which shouldn't happen in normal flow
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
