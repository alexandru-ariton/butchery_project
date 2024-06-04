import 'package:flutter/material.dart';
import 'package:GastroGrid/clase/clasa_produs.dart';

class OrderItems extends StatelessWidget {
  final List<dynamic> items;

  OrderItems({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map<Widget>((item) {
        var productData = item['product'];
        if (productData == null) {
          return Text('Unknown product');
        }
        var product = Product.fromMap(productData, productData['id'] ?? 'unknown');
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${product.title} x ${item['quantity']}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                '${(product.price * item['quantity']).toStringAsFixed(2)} lei',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
