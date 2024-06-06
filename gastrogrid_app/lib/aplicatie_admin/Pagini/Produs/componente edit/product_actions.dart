import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';



const unitConversion = {
  'kg_to_g': 1000,
  'g_to_kg': 0.001,
  'ml_to_l': 0.001,
  'l_to_ml': 1000,
  // Add more conversions as needed
};





double convertToBaseUnit(double quantity, String unit) {
  switch (unit) {
    case 'kg':
      return quantity * 1000; // kilograms to grams
    case 'l':
      return quantity * 1000; // liters to milliliters
    case 'ml':
    case 'g':
    default:
      return quantity; // base units
  }
}

double convertFromBaseUnit(double quantity, String unit) {
  switch (unit) {
    case 'kg':
      return quantity / 1000; // grams to kilograms
    case 'l':
      return quantity / 1000; // milliliters to liters
    case 'ml':
    case 'g':
    default:
      return quantity; // base units
  }
}



Future<bool> checkRawMaterials(BuildContext context, Map<String, Map<String, dynamic>> selectedRawMaterials) async {
  try {
    for (var entry in selectedRawMaterials.entries) {
      DocumentSnapshot rawMaterialSnapshot = await FirebaseFirestore.instance.collection('rawMaterials').doc(entry.key).get();

      if (!rawMaterialSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Materia prima ${entry.key} nu exista')));
        return true;
      }

      double availableQuantity = rawMaterialSnapshot.get('quantity').toDouble();
      String availableUnit = rawMaterialSnapshot.get('unit');
      double requiredQuantity = entry.value['quantity'].toDouble();
      String requiredUnit = entry.value['unit'];

      if (availableUnit != requiredUnit) {
        requiredQuantity = convertToBaseUnit(requiredQuantity, requiredUnit);
        requiredQuantity = convertFromBaseUnit(requiredQuantity, availableUnit);
      }

      if (availableQuantity < requiredQuantity) {
        return true; // Insufficient raw materials
      }
    }
    return false; // Sufficient raw materials
  } catch (e) {
    print('Eroare la verificarea: $e');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Eroare la verificarea: $e')));
    return true;
  }
}



  int convertQuantity(int quantity, String fromUnit, String toUnit) {
    String conversionKey = '${fromUnit}_to_${toUnit}';
    if (unitConversion.containsKey(conversionKey)) {
      return (quantity * unitConversion[conversionKey]!).toInt();
    } else {
      throw Exception('Conversia de la $fromUnit la $toUnit nu e definita');
    }
  }





Map<String, Map<String, dynamic>> convertRawMaterialsToInt(Map<String, Map<String, dynamic>> rawMaterials) {
    Map<String, Map<String, dynamic>> convertedRawMaterials = {};
    rawMaterials.forEach((key, value) {
      int quantity = value['quantity'];
      convertedRawMaterials[key] = {'quantity': quantity, 'unit': value['unit']};
    });
    return convertedRawMaterials;
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

Future<DocumentReference> saveOrUpdateProduct(String? productId, String title, double price, String description, String imageUrl, int newQuantity, BuildContext context) async {
  if (productId == null) {
    // Add new product
    return await FirebaseFirestore.instance.collection('products').add({
      'title': title,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'quantity': newQuantity,
    });
  } else {
    // Retrieve the existing product
    DocumentSnapshot productSnapshot = await FirebaseFirestore.instance.collection('products').doc(productId).get();

    if (!productSnapshot.exists) {
      // Handle the case where the product does not exist
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('-')));
      throw Exception('-');
    }

    int existingQuantity = productSnapshot['quantity'];
    int updatedQuantity = existingQuantity + newQuantity;

    // Update existing product
    await FirebaseFirestore.instance.collection('products').doc(productId).update({
      'title': title,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'quantity': updatedQuantity,
    });
    return FirebaseFirestore.instance.collection('products').doc(productId);
  }
}



  Future<void> saveRawMaterials(DocumentReference productRef, Map<String, Map<String, dynamic>> selectedRawMaterials) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (var entry in selectedRawMaterials.entries) {
      DocumentReference rawMaterialUsageRef = productRef.collection('rawMaterials').doc(entry.key);
      batch.set(rawMaterialUsageRef, {
        'quantity': entry.value['quantity'],
        'unit': entry.value['unit'],
      });
    }
    await batch.commit();
  }

Future<void> updateRawMaterials(Map<String, Map<String, dynamic>> selectedRawMaterials) async {
  for (var entry in selectedRawMaterials.entries) {
    DocumentReference rawMaterialRef = FirebaseFirestore.instance.collection('rawMaterials').doc(entry.key);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot rawMaterialSnapshot = await transaction.get(rawMaterialRef);
      double currentQuantity = rawMaterialSnapshot.get('quantity').toDouble();
      String currentUnit = rawMaterialSnapshot.get('unit');
      double usedQuantity = entry.value['quantity'].toDouble();
      String usedUnit = entry.value['unit'];

      if (currentUnit != usedUnit) {
        usedQuantity = convertToBaseUnit(usedQuantity, usedUnit);
        usedQuantity = convertFromBaseUnit(usedQuantity, currentUnit);
      }

      double newQuantity = currentQuantity - usedQuantity;
      if (newQuantity < 0) {
        newQuantity = 0; // Ensure quantity doesn't go negative
      }

      transaction.update(rawMaterialRef, {'quantity': newQuantity});
    });
  }
}









