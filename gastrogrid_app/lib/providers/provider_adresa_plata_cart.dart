import 'package:flutter/material.dart';

class SelectedOptionsProvider extends ChangeNotifier {
  String? _selectedAddress;
  String? _selectedPaymentMethod;
  Map<String, dynamic>? _selectedCardDetails;

  String? get selectedAddress => _selectedAddress;
  String? get selectedPaymentMethod => _selectedPaymentMethod;
  Map<String, dynamic>? get selectedCardDetails => _selectedCardDetails;

  void setSelectedAddress(String address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void setSelectedPaymentMethod(String paymentMethod, [Map<String, dynamic>? cardDetails]) {
    _selectedPaymentMethod = paymentMethod;
    _selectedCardDetails = cardDetails;
    notifyListeners();
  }

  void clear() {
    _selectedAddress = null;
    _selectedPaymentMethod = null;
    _selectedCardDetails = null;
    notifyListeners();
  }
}
