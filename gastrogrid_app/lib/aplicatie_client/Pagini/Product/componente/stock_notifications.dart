import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:gastrogrid_app/clase/clasa_produs.dart';
import 'package:gastrogrid_app/providers/provider_notificareStoc.dart';

Future<void> notifyLowStock(BuildContext context, Product product) async {
  try {
    // Fetch supplier information from subcollection
    QuerySnapshot supplierSnapshot = await FirebaseFirestore.instance
        .collection('products')
        .doc(product.id)
        .collection('suppliers')
        .get();

    if (supplierSnapshot.docs.isNotEmpty) {
      var supplierData = supplierSnapshot.docs.first.data() as Map<String, dynamic>;
      String supplierEmail = supplierData['email'] ?? '';

      // Debug statement
      print('Supplier email: $supplierEmail');

      if (supplierEmail.isNotEmpty) {
        Provider.of<NotificationProviderStoc>(context, listen: false).addNotification(
          'Stoc redus pentru ${product.title}',
          product.id,
          supplierEmail,
          product.title,
        );
      } else {
        print('Supplier email is empty');
      }
    } else {
      print('Supplier subcollection is empty');
    }
  } catch (e) {
    print('Failed to fetch supplier email: $e');
  }
}

Future<void> notifyOutOfStock(BuildContext context, Product product) async {
  try {
    // Fetch supplier information from subcollection
    QuerySnapshot supplierSnapshot = await FirebaseFirestore.instance
        .collection('products')
        .doc(product.id)
        .collection('suppliers')
        .get();

    if (supplierSnapshot.docs.isNotEmpty) {
      var supplierData = supplierSnapshot.docs.first.data() as Map<String, dynamic>;
      String supplierEmail = supplierData['email'] ?? '';

      // Debug statement
      print('Supplier email: $supplierEmail');

      if (supplierEmail.isNotEmpty) {
        Provider.of<NotificationProviderStoc>(context, listen: false).addNotification(
          'Stoc Epuizat pentru ${product.title}',
          product.id,
          supplierEmail,
          product.title,
        );
      } else {
        print('Supplier email is empty');
      }
    } else {
      print('Supplier subcollection is empty');
    }
  } catch (e) {
    print('Failed to fetch supplier email: $e');
  }
}

