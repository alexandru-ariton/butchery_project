// Importă biblioteca principală Flutter pentru a crea interfețe de utilizator.
import 'package:flutter/material.dart';

// Declarația unei clase stateless pentru afișarea antetului comenzii.
class OrderHeader extends StatelessWidget {
  // Declarația câmpurilor pentru detaliile comenzii.
  final String orderId;
  final String preparationStatus;
  final String paymentStatus;
  final double total;

  // Constructorul clasei OrderHeader.
  const OrderHeader({
    super.key, 
    required this.orderId, 
    required this.preparationStatus, 
    required this.paymentStatus, 
    required this.total
  });

  // Metodă care construiește interfața de utilizator a widgetului.
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Afișează ID-ul comenzii.
        Text(
          'Comanda #$orderId',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        // Afișează statusul preparării.
        Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              'Status preparare: $preparationStatus',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        // Afișează statusul plății.
        Row(
          children: [
            Icon(Icons.payment, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              'Status plata: $paymentStatus',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        // Afișează totalul comenzii.
        Row(
          children: [
            Icon(Icons.attach_money, color: Colors.green),
            SizedBox(width: 8),
            Text(
              'Total: ${total.toStringAsFixed(2)} lei',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
