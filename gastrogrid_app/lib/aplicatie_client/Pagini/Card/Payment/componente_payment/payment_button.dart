// Importă pachetele necesare pentru Cloud Firestore și Flutter Material.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Definește un widget StatelessWidget pentru butonul de plată.
class PaymentButton extends StatelessWidget {
  final double amount; // Suma de plată.
  final String orderId; // ID-ul comenzii.

  // Constructorul clasei PaymentButton.
  const PaymentButton({super.key, required this.amount, required this.orderId});

  // Funcție asincronă pentru procesarea plății.
  Future<void> _processPayment(BuildContext context, String orderId) async {
    // Simulează un delay pentru procesarea plății.
    await Future.delayed(Duration(seconds: 3));

    // Actualizează statusul plății în baza de date.
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'paymentStatus': 'Platit' // Setează statusul plății ca "Platit".
    });

    // După confirmarea plății, întoarce-te și transmite un mesaj de succes.
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Simulează procesul de plată.
        _processPayment(context, orderId);
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16), // Setează padding-ul vertical al butonului.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rotunjeste colțurile butonului.
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Aliniază conținutul pe centru.
        children: const [
          Icon(Icons.payment), // Adaugă o iconiță de plată.
          SizedBox(width: 10), // Adaugă un spațiu între iconiță și text.
          Text('Confirma plata'), // Textul butonului.
        ],
      ),
    );
  }
}
