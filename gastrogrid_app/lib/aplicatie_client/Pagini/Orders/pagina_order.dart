import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:GastroGrid/aplicatie_client/clase/cart.dart';
import 'package:provider/provider.dart';
import 'package:GastroGrid/aplicatie_client/clase/produs.dart';
import 'package:GastroGrid/providers/provider_cart.dart';

class PaginaOrder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Comenzile mele')),
        
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final user = userSnapshot.data;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .where('userId', isEqualTo: user!.uid)
                .snapshots(),
            builder: (context, orderSnapshot) {
              if (!orderSnapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              var orders = orderSnapshot.data!.docs;
              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  var order = orders[index];
                  return _buildOrderCard(context, order);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, DocumentSnapshot order) {
    var orderData = order.data() as Map<String, dynamic>;
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
            _buildOrderHeader(order.id, orderData['status'], orderData['total']),
            Divider(),
            ..._buildOrderItems(orderData['items']),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  _reloadOrder(context, orderData['items']);
                },
                icon: Icon(Icons.add_shopping_cart),
                label: Text('Adaugă în coș'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader(String orderId, String status, double total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comandă #$orderId',
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
              'Status: $status',
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

  List<Widget> _buildOrderItems(List<dynamic> items) {
    return items.map<Widget>((item) {
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
    }).toList();
  }

  void _reloadOrder(BuildContext context, List<dynamic> items) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    for (var item in items) {
      var productData = item['product'];
      if (productData != null) {
        var product = Product.fromMap(productData, productData['id'] ?? 'unknown');
        var cartItem = CartItem(
          product: product,
          quantity: item['quantity'],
        );
        cartProvider.addProductToCart(cartItem);
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Produsele au fost adăugate în coș')),
    );
  }
}
