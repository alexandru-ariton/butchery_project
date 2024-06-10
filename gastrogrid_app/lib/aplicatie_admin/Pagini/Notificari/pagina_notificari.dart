import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class LowStockNotificationPage extends StatelessWidget {
  const LowStockNotificationPage({super.key});

  Future<void> _sendEmail(String email, String productName) async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Restock Request&body=Please restock the product: $productName', // Customize as needed
    );

    var url = params.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('notifications').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No notifications', style: TextStyle(fontSize: 18)));
          }

          var notifications = snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            var timestamp = data['timestamp'] != null
                ? (data['timestamp'] as Timestamp).toDate().toString()
                : 'No timestamp';
            var productName = data['productName'] ?? 'Unknown product';
            var supplierEmail = data['supplierEmail'] ?? 'No email available';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              elevation: 5,
              child: ListTile(
                title: Text(
                  data['message'] ?? 'No message',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Date: $timestamp\nSupplier: $supplierEmail',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                trailing: supplierEmail != 'No email available'
                    ? IconButton(
                        icon: const Icon(Icons.email),
                        onPressed: () => _sendEmail(supplierEmail, productName),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              ),
            );
          }).toList();

          return ListView(children: notifications);
        },
      ),
    );
  }
}
