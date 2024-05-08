import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeliveryInfo with ChangeNotifier {
  bool _isDelivery = true;
  double _deliveryFee = 5.0;
  String? _selectedAddress;

  bool get isDelivery => _isDelivery;
  double get deliveryFee => _deliveryFee;
  String? get selectedAddress => _selectedAddress; 

  void toggleDelivery(bool isDelivery) {
    _isDelivery = isDelivery;
    notifyListeners();
  }

   void setSelectedAddress(String? address) async {
  _selectedAddress = address;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('selectedAddress', address ?? '');
  notifyListeners();
}


}