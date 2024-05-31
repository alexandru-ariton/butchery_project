import 'package:flutter/material.dart';

class OrderStatusProvider with ChangeNotifier {
  bool _orderFinalized = false;

  bool get orderFinalized => _orderFinalized;

  set orderFinalized(bool value) {
    _orderFinalized = value;
    notifyListeners();
  }
}