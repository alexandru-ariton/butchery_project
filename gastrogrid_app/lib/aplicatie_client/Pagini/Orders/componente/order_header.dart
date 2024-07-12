import 'package:flutter/material.dart';

class OrderHeader extends StatelessWidget {
  final String orderId;
  final String preparationStatus;
  final String paymentStatus;
  final double total;

  const OrderHeader({
    super.key, 
    required this.orderId, 
    required this.preparationStatus, 
    required this.paymentStatus, 
    required this.total
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comanda #$orderId',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
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
        Row(
          children: [
            Icon(Icons.payment, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              'Status plată: $paymentStatus',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
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
