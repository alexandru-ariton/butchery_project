// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GastroGrid/clase/clasa_cart.dart';
import 'package:GastroGrid/providers/provider_cart.dart';
import 'package:GastroGrid/providers/provider_themes.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem item;

  CartItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            if (item.product.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  item.product.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.image, size: 50, color: Colors.grey[400]),
              ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.product.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: themeProvider.themeData.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Price: ${item.product.price.toStringAsFixed(2)} lei',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Quantity: ${item.quantity}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            _buildQuantityControls(context, item),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControls(BuildContext context, CartItem item) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.remove),
          color: themeProvider.themeData.colorScheme.primary,
          onPressed: () {
            if (item.quantity > 1) {
              Provider.of<CartProvider>(context, listen: false).updateProductQuantity(item, item.quantity - 1);
            } else {
              Provider.of<CartProvider>(context, listen: false).removeProduct(item);
            }
          },
        ),
        Text(
          item.quantity.toString(),
          style: TextStyle(
            fontSize: 16,
            color: themeProvider.themeData.colorScheme.onSurface,
          ),
        ),
        IconButton(
          icon: Icon(Icons.add),
          color: themeProvider.themeData.colorScheme.primary,
          onPressed: () {
            Provider.of<CartProvider>(context, listen: false).updateProductQuantity(item, item.quantity + 1);
          },
        ),
      ],
    );
  }
}
