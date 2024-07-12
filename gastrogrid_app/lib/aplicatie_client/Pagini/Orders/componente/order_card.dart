import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_header.dart';
import 'order_items.dart';

class OrderCard extends StatelessWidget {
  final DocumentSnapshot order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    var orderData = order.data() as Map<String, dynamic>;
    String preparationStatus = orderData['preparationStatus'] ?? 'Receptionata';
    String paymentStatus = orderData['paymentStatus'] ?? 'Neplatit';
    
    return Card(
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OrderHeader(
              orderId: order.id, 
              preparationStatus: preparationStatus, 
              paymentStatus: paymentStatus, 
              total: orderData['total']
            ),
            Divider(),
            OrderItems(items: orderData['items']),

          ],
        ),
      ),
    );
  }
}
