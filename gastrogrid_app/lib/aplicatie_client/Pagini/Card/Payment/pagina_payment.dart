import 'package:GastroGrid/aplicatie_client/Pagini/Card/Payment/componente_payment/payment_button.dart';
import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  final Map<String, dynamic> cardDetails;
  final double amount;
  final String orderId;

  const PaymentPage({super.key, required this.cardDetails, required this.amount, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plata'),
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
                    'Plateste ${amount.toStringAsFixed(2)} lei cu cardul',
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
                  PaymentButton(
                    amount: amount,
                    orderId: orderId,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
