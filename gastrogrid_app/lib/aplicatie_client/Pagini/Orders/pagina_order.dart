import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gastrogrid_app/aplicatie_client/clase/cart.dart';
import 'package:provider/provider.dart';
import 'package:gastrogrid_app/aplicatie_client/clase/produs.dart';
import 'package:gastrogrid_app/providers/provider_cart.dart';

class PaginaOrder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comenzile mele'),
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
                  return Card(
                    margin: EdgeInsets.all(8),
                    child: ListTile(
                      title: Text('Order ${order.id}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status: ${order['status'] ?? 'Unknown'}'),
                          Text('Total: ${order['total'] ?? 'Unknown'} lei'),
                          ..._buildOrderItems(order['items']),
                          Padding(
                             padding: const EdgeInsets.only(left:220.0),
                            child: ElevatedButton(
                              onPressed: () {
                                _reloadOrder(context, order['items']);
                              },
                              child: Text('Reload Order'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _buildOrderItems(List<dynamic> items) {
    return items.map<Widget>((item) {
      var productData = item['product'];
      if (productData == null) {
        return Text('Unknown product');
      }
      var product = Product.fromMap(productData, productData['id'] ?? 'unknown');
      return Text('${product.title} x ${item['quantity']}');
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
      SnackBar(content: Text('Order items added to cart')),
    );
  }
}
