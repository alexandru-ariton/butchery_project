import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationProviderStoc with ChangeNotifier {
  void addNotification(String message, String productId) {
    FirebaseFirestore.instance.collection('notifications').add({
      'message': message,
      'productId': productId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
