// Importă pachetul principal pentru construirea UI-ului în Flutter.
import 'package:flutter/material.dart';

// Clasă care gestionează opțiunile selectate și notifică ascultătorii când există schimbări.
class SelectedOptionsProvider extends ChangeNotifier {
  // Variabilă privată pentru adresa selectată.
  String? _selectedAddress;
  // Variabilă privată pentru metoda de plată selectată.
  String? _selectedPaymentMethod;
  // Variabilă privată pentru detaliile cardului selectat.
  Map<String, dynamic>? _selectedCardDetails;

  // Getter pentru adresa selectată.
  String? get selectedAddress => _selectedAddress;
  // Getter pentru metoda de plată selectată.
  String? get selectedPaymentMethod => _selectedPaymentMethod;
  // Getter pentru detaliile cardului selectat.
  Map<String, dynamic>? get selectedCardDetails => _selectedCardDetails;

  // Metodă pentru setarea adresei selectate.
  void setSelectedAddress(String address) {
    _selectedAddress = address;
    notifyListeners(); // Notifică ascultătorii despre schimbare.
  }

  // Metodă pentru setarea metodei de plată selectate.
  void setSelectedPaymentMethod(String paymentMethod, [Map<String, dynamic>? cardDetails]) {
    _selectedPaymentMethod = paymentMethod;
    _selectedCardDetails = cardDetails;
    notifyListeners(); // Notifică ascultătorii despre schimbare.
  }

  // Metodă pentru resetarea tuturor opțiunilor selectate.
  void clear() {
    _selectedAddress = null;
    _selectedPaymentMethod = null;
    _selectedCardDetails = null;
    notifyListeners(); // Notifică ascultătorii despre schimbare.
  }
}
