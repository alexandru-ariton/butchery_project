import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationProviderStoc with ChangeNotifier {
  void addNotification(String message, String productId) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'message': message,
        'productId': productId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Notification added: $message for product $productId'); // Debugging line
    } catch (e) {
      print('Error adding notification: $e'); // Debugging line
    }
  }

  void removeNotification(String productId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('productId', isEqualTo: productId)
          .get();

      for (var doc in snapshot.docs) {
        await FirebaseFirestore.instance.collection('notifications').doc(doc.id).delete();
        print('Notification removed for product $productId'); // Debugging line
      }
    } catch (e) {
      print('Error removing notification: $e'); // Debugging line
    }
  }
}
