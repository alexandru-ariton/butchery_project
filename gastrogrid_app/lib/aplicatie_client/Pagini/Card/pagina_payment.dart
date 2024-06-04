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
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Plătește ${amount.toStringAsFixed(2)} lei cu cardul',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Card: **** **** **** ${cardDetails['last4']}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      // Simulează procesul de plată
                      _processPayment(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.payment),
                        SizedBox(width: 10),
                        Text('Confirmă Plată'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
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
