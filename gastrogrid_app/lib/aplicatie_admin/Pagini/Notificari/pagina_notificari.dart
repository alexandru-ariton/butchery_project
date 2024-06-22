import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class LowStockNotificationPage extends StatelessWidget {
  const LowStockNotificationPage({super.key});

  Future<void> _sendEmail(List<String> emails, String productName) async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: emails.join(','),
      query: 'subject=Restock Request&body=Please restock the product: $productName', 
    );

    var url = params.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _showEmailDialog(BuildContext context, List<Map<String, dynamic>> suppliers, String productName) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Select Suppliers'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: suppliers.map((supplier) {
                    return CheckboxListTile(
                      title: Text(supplier['email']),
                      value: supplier['selected'],
                      onChanged: (bool? value) {
                        setState(() {
                          supplier['selected'] = value ?? false;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Send Email'),
                  onPressed: () async {
                    List<String> selectedEmails = suppliers
                        .where((supplier) => supplier['selected'])
                        .map<String>((supplier) => supplier['email'] as String)
                        .toList();
                    if (selectedEmails.isNotEmpty) {
                      await _sendEmail(selectedEmails, productName);
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificări Stoc Scăzut și Produse Expirate'),
      ),
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
            var message = data['message'] ?? 'No message';
            var productName = data['productName'] ?? 'Unknown product';
            var productId = data['productId'] ?? 'Unknown productId';
            var supplierEmails = data['supplierEmail'] ?? 'No email available';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              elevation: 5,
              child: ListTile(
                title: Text(
                  message,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Date: $timestamp\nSupplier: $supplierEmails\nProduct: $productName',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                trailing: supplierEmails != 'No email available'
                    ? IconButton(
                        icon: const Icon(Icons.email),
                        onPressed: () async {
                          
                          QuerySnapshot supplierSnapshot = await FirebaseFirestore.instance
                              .collection('products')
                              .doc(productId)
                              .collection('suppliers')
                              .get();

                          List<Map<String, dynamic>> suppliers = supplierSnapshot.docs.map((doc) {
                            var supplierData = doc.data() as Map<String, dynamic>;
                            return {
                              'email': supplierData['email'] ?? 'No email available',
                              'selected': false,
                            };
                          }).toList();

                          
                          await _showEmailDialog(context, suppliers, productName);
                        },
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
