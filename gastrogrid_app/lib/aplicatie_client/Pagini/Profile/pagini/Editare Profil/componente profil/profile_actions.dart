import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';
import 'package:path/path.dart' as path; 



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
  if (!formKey.currentState!.validate()) {
    return;
  }

  try {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final existingData = userDoc.data() as Map<String, dynamic>?;

    String? currentPassword = existingData != null ? existingData['password'] : null;
    String? currentAddress = existingData != null ? existingData['address'] : null;

    String newPassword = passwordController.text.isNotEmpty ? passwordController.text : currentPassword ?? '';
  
    Map<String, dynamic> updatedData = {
      'username': nameController.text,
      'phoneNumber': '$selectedPrefix ${phoneController.text}',
      'dateOfBirth': dobController.text,
      'gender': gender,
      'password': newPassword,
    };

    // Logică pentru a încărca imaginea și a actualiza photoUrl
    if (image != null) {
      String fileName = path.basename(image.path);
      Reference storageRef = FirebaseStorage.instance.ref().child('profile_images/$userId/$fileName');
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      updatedData['photoUrl'] = downloadUrl;
    } else if (photoUrl != null) {
      updatedData['photoUrl'] = photoUrl;
    }


    await FirebaseFirestore.instance.collection('users').doc(userId).update(updatedData);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profilul a fost actualizat cu succes')));
    Navigator.of(context).pop(true);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Eroare la actualizarea profilului: $e')));
  }
}







Future<String?> uploadImage(BuildContext context, String userId, File? image, String? existingPhotoUrl) async {
  try {
    if (image != null) {
      final storageReference = FirebaseStorage.instance
          .ref()
          .child('profile_images/$userId');
      await storageReference.putFile(image);
      return await storageReference.getDownloadURL();
    }
    return existingPhotoUrl;
  } catch (e) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Eroare imagine: $e')));
    });
    return null;
  }
}
