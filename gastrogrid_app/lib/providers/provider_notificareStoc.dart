import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationProviderStoc with ChangeNotifier {
  // Metodă pentru adăugarea unei notificări de expirare a unui produs.
  Future<void> addExpiryNotification(String productId, String supplierEmail, String productName) async {
    await addNotification(
      'Produsul $productName este expirat. Vă rugăm să înlocuiți stocul.',
      productId,
      supplierEmail,
      productName,
    );
  }

  // Metodă pentru adăugarea unei notificări generice în Firestore.
  Future<void> addNotification(String message, String productId, String supplierEmail, String productName) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'message': message,
        'productId': productId,
        'supplierEmail': supplierEmail,
        'productName': productName,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Notification added: $message');
    } catch (e) {
      print('Error adding notification: $e');
    }
  }


  // Metodă pentru eliminarea notificărilor asociate unui produs specific.
  Future<void> removeNotification(String productId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('productId', isEqualTo: productId)
        .get();

    for (var doc in snapshot.docs) {
      await FirebaseFirestore.instance.collection('notifications').doc(doc.id).delete();
    }
  }

 // Metodă pentru verificarea expirării produselor.
Future<void> checkForExpiredProducts() async {
  final now = DateTime.now();
  print('Verificare expirare produse la $now');

  try {
    QuerySnapshot productSnapshot = await FirebaseFirestore.instance
        .collection('products')
        .get();

    for (var productDoc in productSnapshot.docs) {
      var productData = productDoc.data() as Map<String, dynamic>;
      var expiryDate = (productData['expiryDate'] as Timestamp?)?.toDate();
      var productName = productData['title'] ?? 'Unknown product';
      print('Produs verificat: $productName, Expiry Date: $expiryDate');

      if (expiryDate != null && expiryDate.isBefore(now)) {
        print('Produs expirat găsit: $productName');
        String productId = productDoc.id;

        // Obține email-urile furnizorilor
        QuerySnapshot supplierSnapshot = await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .collection('suppliers')
            .get();

        for (var supplierDoc in supplierSnapshot.docs) {
          var supplierData = await FirebaseFirestore.instance
              .collection('suppliers')
              .doc(supplierDoc.id)
              .get();
          
          if (supplierData.exists && supplierData['email'] != null) {
            String supplierEmail = supplierData['email'];
            await addExpiryNotification(productId, supplierEmail, productName);
            print('Expiry notification added for product: $productName, Supplier: $supplierEmail');
          } else {
            print('Supplier data missing or email not found for supplier ID: ${supplierDoc.id}');
          }
        }
      }
    }
  } catch (e) {
    print('Eroare la verificarea produselor expirate: $e');
  }
}

}
