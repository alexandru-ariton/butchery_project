import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';

Future<void> saveProfile(
  BuildContext context,
  GlobalKey<FormState> formKey,
  String userId,
  TextEditingController nameController,
  TextEditingController phoneController,
  TextEditingController addressController,
  TextEditingController dobController,
  String? gender,
  File? image,
  String? photoUrl,
) async {
  if (formKey.currentState!.validate()) {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw FirebaseAuthException(code: 'ERROR_NO_SIGNED_IN_USER', message: 'No user is signed in.');
      }

      String? newPhotoUrl = await uploadImage(context, user.uid, image, photoUrl);
      if (newPhotoUrl != null) {
        await user.updatePhotoURL(newPhotoUrl);
        photoUrl = newPhotoUrl;
      }

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'username': nameController.text,
        'phoneNumber': phoneController.text,
        'address': addressController.text,
        'dateOfBirth': dobController.text,
        'gender': gender,
        'photoUrl': photoUrl,
      }, SetOptions(merge: true));

      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profil editat')));
      });

      Navigator.pop(context, true);
    } catch (e) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Eroare: $e')));
      });
    }
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
