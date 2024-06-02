import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailsPage extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> orderData;

  OrderDetailsPage({required this.orderId, required this.orderData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order Details')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Order ID: $orderId', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Status: ${orderData['status'] ?? 'Unknown'}'),
            SizedBox(height: 8),
            Text('Total: ${orderData['total'] ?? 'Unknown'} lei'),
            SizedBox(height: 16),
            Text('Items:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            _buildOrderItems(orderData['items'] ?? []),
            SizedBox(height: 16),
            Text('Address: ${orderData['address'] ?? 'No address provided'}'),
            SizedBox(height: 16),
            Text('Payment Method: ${orderData['paymentMethod'] ?? 'Unknown'}'),
            SizedBox(height: 16),
            Text('User Details:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            _buildUserDetails(orderData['userId']),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems(List<dynamic> items) {
    if (items.isEmpty) {
      return Text('No items found.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        var productData = item['product'] ?? {};
        var productName = productData['title'] ?? 'Unknown Product';
        var quantity = item['quantity'] ?? 'Unknown Quantity';
        return Text('$productName x $quantity');
      }).toList(),
    );
  }

  Widget _buildCardDetails(dynamic cardDetails) {
    if (cardDetails == null || cardDetails is! List) {
      return Text('No card details available.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cardDetails.map<Widget>((cardDetail) {
        var last4 = cardDetail['last4'] ?? 'XXXX';
        return Text('Card ending in $last4');
      }).toList(),
    );
  }

  Widget _buildUserDetails(String userId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text('Loading user details...');
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>?;
        if (userData == null) {
          return Text('No user details available.');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${userData['username'] ?? 'Unknown'}'),
            Text('Email: ${userData['email'] ?? 'Unknown'}'),
            // Adăugați mai multe detalii despre utilizator aici, dacă este necesar
          ],
        );
      },
    );
  }
}
