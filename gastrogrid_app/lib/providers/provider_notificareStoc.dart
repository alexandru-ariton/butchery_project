import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationProviderStoc with ChangeNotifier {
  void addNotification(String message, String productId, String supplierEmail, String productName) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'message': message,
      'productId': productId,
      'supplierEmail': supplierEmail,
      'productName': productName,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void removeNotification(String productId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('productId', isEqualTo: productId)
        .get();

    for (var doc in snapshot.docs) {
      await FirebaseFirestore.instance.collection('notifications').doc(doc.id).delete();
    }
  }
}
