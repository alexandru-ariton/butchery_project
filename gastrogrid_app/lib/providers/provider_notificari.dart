import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  bool _showBanner = false;
  String _notificationMessage = '';
  String _notificationOrderId = '';
  bool _hasNewNotifications = false;

  bool get showBanner => _showBanner;
  String get notificationMessage => _notificationMessage;
  String get notificationOrderId => _notificationOrderId;
  bool get hasNewNotifications => _hasNewNotifications;

  NotificationProvider() {
    _checkForNotifications();
  }

  void _checkForNotifications() {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    FirebaseFirestore.instance.collection('notifications').where('userId', isEqualTo: userId).snapshots().listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var notification = snapshot.docs.first;
        _showBanner = true;
        _notificationMessage = notification['message'];
        _notificationOrderId = notification['orderId'];
        _hasNewNotifications = true;
        notifyListeners();

        // Optionally delete the notification after showing it
        FirebaseFirestore.instance.collection('notifications').doc(notification.id).delete();
      } else {
        _hasNewNotifications = false;
        notifyListeners();
      }
    });
  }

  void dismissBanner() {
    _showBanner = false;
    _notificationMessage = '';
    _notificationOrderId = '';
    _hasNewNotifications = false;
    notifyListeners();
  }
}
