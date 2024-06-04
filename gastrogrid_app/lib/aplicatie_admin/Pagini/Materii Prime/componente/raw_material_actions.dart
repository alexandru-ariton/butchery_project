import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<String> uploadImage(String rawMaterialId, Uint8List? imageData, String? currentImageUrl) async {
  if (imageData != null) {
    final storageReference = FirebaseStorage.instance
        .ref()
        .child('rawMaterial_images/$rawMaterialId');
    await storageReference.putData(imageData);
    return await storageReference.getDownloadURL();
  }
  return currentImageUrl ?? '';
}

Uint8List base64StringToUint8List(String base64String) {
  return Uint8List.fromList(base64.decode(base64String));
}
