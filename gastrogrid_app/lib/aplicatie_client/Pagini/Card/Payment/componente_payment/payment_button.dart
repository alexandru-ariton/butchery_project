import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PaymentButton extends StatelessWidget {
  final double amount;
  final String orderId;

  const PaymentButton({super.key, required this.amount, required this.orderId});

  Future<void> _processPayment(BuildContext context, String orderId) async {
  // Simulează un delay pentru procesarea plății
  await Future.delayed(Duration(seconds: 3));

  // Actualizează statusul plății în baza de date
  await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
    'paymentStatus': 'Platit'
  });

  // După confirmarea plății, întoarce-te și transmite un mesaj de succes
  Navigator.of(context).pop(true);
}

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Simulează procesul de plată
        _processPayment(context, orderId);
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.payment),
          SizedBox(width: 10),
          Text('Confirma Plata'),
        ],
      ),
    );
  }
}
