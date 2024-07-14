// Importă biblioteca Dart pentru funcționalități legate de sistemul de fișiere.
import 'dart:io';

// Importă pachetul principal pentru construirea interfeței de utilizator în Flutter.
import 'package:flutter/material.dart';

// Importă pachetul Firebase Auth pentru autentificarea utilizatorilor.
import 'package:firebase_auth/firebase_auth.dart';

// Importă pachetul Firebase Storage pentru gestionarea fișierelor stocate în Firebase.
import 'package:firebase_storage/firebase_storage.dart';

// Importă pachetul Firestore pentru interacțiunea cu baza de date Firebase.
import 'package:cloud_firestore/cloud_firestore.dart';

// Importă pachetul Scheduler pentru a gestiona sarcinile planificate.
import 'package:flutter/scheduler.dart';

// Importă biblioteca path pentru a gestiona căile fișierelor.
import 'package:path/path.dart' as path; 

// Funcție asincronă pentru salvarea profilului utilizatorului.
Future<void> saveProfile(
  BuildContext context,
  GlobalKey<FormState> formKey,
  String userId,
  TextEditingController nameController,
  TextEditingController phoneController,
  TextEditingController dobController,
  TextEditingController passwordController,
  String? gender,
  String selectedPrefix,
  File? image,
  String? photoUrl,
) async {
  // Verifică dacă formularul este valid.
  if (!formKey.currentState!.validate()) {
    return;
  }

  try {
    // Obține documentul utilizatorului din Firestore.
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final existingData = userDoc.data() as Map<String, dynamic>?;

    // Obține parola și adresa curentă din datele existente.
    String? currentPassword = existingData != null ? existingData['password'] : null;
    String? currentAddress = existingData != null ? existingData['address'] : null;

    // Setează noua parolă sau păstrează parola curentă.
    String newPassword = passwordController.text.isNotEmpty ? passwordController.text : currentPassword ?? '';
  
    // Creează un map cu datele actualizate.
    Map<String, dynamic> updatedData = {
      'username': nameController.text,
      'phoneNumber': '$selectedPrefix ${phoneController.text}',
      'dateOfBirth': dobController.text,
      'gender': gender,
      'password': newPassword,
    };

    // Logică pentru a încărca imaginea și a actualiza photoUrl.
    if (image != null) {
      // Obține numele fișierului.
      String fileName = path.basename(image.path);
      // Creează o referință în Firebase Storage.
      Reference storageRef = FirebaseStorage.instance.ref().child('profile_images/$userId/$fileName');
      // Încarcă fișierul în Firebase Storage.
      UploadTask uploadTask = storageRef.putFile(image);
      // Așteaptă să se finalizeze încărcarea.
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
      // Obține URL-ul fișierului încărcat.
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      // Adaugă URL-ul în datele actualizate.
      updatedData['photoUrl'] = downloadUrl;
    } else if (photoUrl != null) {
      updatedData['photoUrl'] = photoUrl;
    }

    // Actualizează documentul utilizatorului în Firestore.
    await FirebaseFirestore.instance.collection('users').doc(userId).update(updatedData);

    // Afișează un mesaj de succes.
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profilul a fost actualizat cu succes')));
    // Închide pagina și returnează true.
    Navigator.of(context).pop(true);
  } catch (e) {
    // Afișează un mesaj de eroare dacă actualizarea profilului eșuează.
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Eroare la actualizarea profilului: $e')));
  }
}

// Funcție asincronă pentru încărcarea imaginii de profil în Firebase Storage.
Future<String?> uploadImage(BuildContext context, String userId, File? image, String? existingPhotoUrl) async {
  try {
    if (image != null) {
      // Creează o referință în Firebase Storage.
      final storageReference = FirebaseStorage.instance
          .ref()
          .child('profile_images/$userId');
      // Încarcă fișierul în Firebase Storage.
      await storageReference.putFile(image);
      // Returnează URL-ul fișierului încărcat.
      return await storageReference.getDownloadURL();
    }
    // Returnează URL-ul existent dacă nu există o nouă imagine.
    return existingPhotoUrl;
  } catch (e) {
    // Afișează un mesaj de eroare dacă încărcarea imaginii eșuează.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Eroare imagine: $e')));
    });
    // Returnează null dacă încărcarea eșuează.
    return null;
  }
}
