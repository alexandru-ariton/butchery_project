import 'package:flutter/material.dart';

class OrderItems extends StatelessWidget {
  final List<dynamic> orderItems;

  const OrderItems({super.key, required this.orderItems});

  @override
  Widget build(BuildContext context) {
    if (orderItems.isEmpty) {
      return Text('No items found.', style: TextStyle(fontSize: 16));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: orderItems.map((item) {
        var productData = item['product'] ?? {};
        var productName = productData['title'] ?? 'Unknown Product';
        var quantity = item['quantity'] ?? 'Unknown Quantity';
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text('$productName x $quantity', style: TextStyle(fontSize: 16)),
        );
      }).toList(),
    );
  }
}
