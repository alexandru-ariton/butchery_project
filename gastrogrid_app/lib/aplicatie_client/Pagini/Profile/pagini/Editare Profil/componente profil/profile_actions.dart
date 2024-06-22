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
  TextEditingController passwordController,
  String? gender,
  String selectedPrefix,
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

      String newPhoneNumber = '$selectedPrefix ${phoneController.text}';


      // Update password
      if (passwordController.text.isNotEmpty) {
        await user.updatePassword(passwordController.text);
      }

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'username': nameController.text,
        'phoneNumber': newPhoneNumber,
        'address': addressController.text,
        'dateOfBirth': dobController.text,
        'gender': gender,
        'photoUrl': photoUrl,
      }, SetOptions(merge: true));

      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
      });

      Navigator.pop(context, true);
    } catch (e) {
      String errorMessage;
      if (e is FirebaseAuthException && e.code == 'too-many-requests') {
        errorMessage = 'Too many requests. Please try again later.';
      } else if (e is FirebaseAuthException && e.code == 'operation-not-allowed') {
        errorMessage = 'Operation not allowed. Check your Firebase console settings.';
      } else {
        errorMessage = 'Error: $e';
      }

      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
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
