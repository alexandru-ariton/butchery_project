import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:GastroGrid/providers/provider_notificareStoc.dart';
import 'package:provider/provider.dart';

Future<bool> checkRawMaterials(Map<String, int> selectedRawMaterials) async {
  for (final entry in selectedRawMaterials.entries) {
    final rawMaterialDoc = await FirebaseFirestore.instance.collection('rawMaterials').doc(entry.key).get();
    if (entry.value > rawMaterialDoc['quantity']) {
      return true;
    }
  }
  return false;
}

Future<String> uploadImage(String productId, Uint8List? imageData, String? currentImageUrl) async {
  if (imageData != null) {
    final storageReference = FirebaseStorage.instance
        .ref()
        .child('product_images/$productId');
    await storageReference.putData(imageData);
    return await storageReference.getDownloadURL();
  }
  return currentImageUrl ?? '';
}

Future<DocumentReference> saveOrUpdateProduct(
  String? productId,
  String title,
  double price,
  String description,
  String imageUrl,
  int quantity,
  BuildContext context,
) async {
  DocumentReference productRef;
  if (productId == null) {
    productRef = await FirebaseFirestore.instance.collection('products').add({
      'title': title,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'quantity': quantity,
    });
  } else {
    productRef = FirebaseFirestore.instance.collection('products').doc(productId);
    DocumentSnapshot productSnapshot = await productRef.get();
    int currentQuantity = productSnapshot['quantity'];
    await productRef.update({
      'title': title,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'quantity': currentQuantity + quantity,
    });

    if (currentQuantity + quantity > 0) {
      Provider.of<NotificationProviderStoc>(context, listen: false).removeNotification(productId);
    }
  }
  return productRef;
}

Future<void> saveRawMaterials(DocumentReference productRef, Map<String, int> selectedRawMaterials) async {
  for (final entry in selectedRawMaterials.entries) {
    await productRef.collection('rawMaterials').add({
      'rawMaterialId': entry.key,
      'quantity': entry.value,
    });
    await FirebaseFirestore.instance.collection('rawMaterials').doc(entry.key).update({
      'quantity': FieldValue.increment(-entry.value),
    });
  }
}
