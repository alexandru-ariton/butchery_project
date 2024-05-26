import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentPage extends StatelessWidget {
  final Map<String, dynamic> cardDetails;
  final double amount;
  final String orderId; // Adăugăm orderId

  PaymentPage({required this.cardDetails, required this.amount, required this.orderId}); // Modificăm constructorul

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plată'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Plătește ${amount.toStringAsFixed(2)} lei cu cardul'),
            SizedBox(height: 20),
            Text('Card: **** **** **** ${cardDetails['last4']}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Simulează procesul de plată
                _processPayment(context);
              },
              child: Text('Confirmă Plată'),
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment(BuildContext context) async {
    // Simulează un delay pentru procesarea plății
    await Future.delayed(Duration(seconds: 3));

    // Actualizează statusul plății în baza de date
    FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'paymentStatus': 'Paid'
    });

    // După confirmarea plății, întoarce-te și transmite un mesaj de succes
    Navigator.of(context).pop(true);
  }
}
