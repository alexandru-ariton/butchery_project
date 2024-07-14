// Importă pachetul principal pentru construirea UI-ului în Flutter.
import 'package:flutter/material.dart';

// Clasă care gestionează starea comenzilor și notifică ascultătorii când există schimbări.
class OrderStatusProvider with ChangeNotifier {
  // Variabilă privată care indică dacă o comandă a fost finalizată.
  bool _orderFinalized = false;

  // Getter pentru a verifica dacă o comandă a fost finalizată.
  bool get orderFinalized => _orderFinalized;

  // Setter pentru a seta starea finalizării comenzii.
  set orderFinalized(bool value) {
    _orderFinalized = value; // Actualizează variabila privată.
    notifyListeners(); // Notifică ascultătorii despre schimbare.
  }
}
