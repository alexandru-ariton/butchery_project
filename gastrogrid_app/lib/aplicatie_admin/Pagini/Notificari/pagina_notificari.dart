import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gastrogrid_app/providers/provider_livrare.dart';


class LowStockNotificationPage extends StatelessWidget {
  const LowStockNotificationPage({Key? key}) : super(key: key);

  Future<void> _markAsChecked(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .delete();
      print('Notification marked as checked: $notificationId');
    } catch (e) {
      print('Error marking as checked: $e');
    }
  }

  Future<void> _updateProductQuantity(String productId, int newQuantity, String notificationId) async {
    try {
      await FirebaseFirestore.instance.collection('products').doc(productId).update({
        'quantity': newQuantity,
      });
      await _markAsChecked(notificationId);
      print('Product quantity updated: $productId');
    } catch (e) {
      print('Error updating product quantity: $e');
    }
  }

  void _openEmailClient(List<String> recipients, String subject, String body, String notificationId) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: recipients.join(','),
      query: 'subject=$subject&body=$body',
    );

    if (await canLaunch(emailUri.toString())) {
      await launch(emailUri.toString());
      await _markAsChecked(notificationId);
      print('Email client launched for notification: $notificationId');
    } else {
      print('Could not launch email client.');
    }
  }

  Future<List<String>> _getSupplierEmails(String productId) async {
    try {
      var suppliersSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .collection('suppliers')
          .get();

      List<String> emailList = [];
      for (var doc in suppliersSnapshot.docs) {
        var supplierData = await FirebaseFirestore.instance
            .collection('suppliers')
            .doc(doc.id)
            .get();
        if (supplierData.exists && supplierData.data() != null && supplierData['email'] != null) {
          emailList.add(supplierData['email']);
        }
      }
      print('Supplier emails fetched for product: $productId');
      return emailList;
    } catch (e) {
      print('Error fetching supplier emails: $e');
      return [];
    }
  }

  String _buildEmailBody(String productName, String timestamp, String storeName, String storeAddress) {
    return '''
    Stimate furnizor,

    Dorim să vă informăm că stocul pentru produsul $productName este scăzut sau a expirat. Vă rugăm să refaceți stocul cât mai curând posibil pentru a evita lipsurile în magazinul nostru.

    Detalii produs:
    - Nume produs: $productName
    - Data notificării: $timestamp

    Informații magazin:
    - Nume magazin: $storeName
    - Adresă: Calea Serban Voda 133, Bucuresti, Romania

    Vă mulțumim pentru colaborare.

    Cu stimă,
    Echipa $storeName
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DeliveryProvider>(
        builder: (context, deliveryInfo, child) {
          return StreamBuilder<QuerySnapshot>(
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
                var type = data['type'] ?? 'unknown';

                print('Notification data: $data');

                String? storeName = 'GastroGrid';
                String? storeAddress = deliveryInfo.defaultAddress;
                print('Adresa default: $storeAddress');

                return FutureBuilder<List<String>>(
                  future: _getSupplierEmails(productId),
                  builder: (context, supplierSnapshot) {
                    if (supplierSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (supplierSnapshot.hasError) {
                      return Center(child: Text('Error fetching suppliers: ${supplierSnapshot.error}'));
                    }

                    List<String> emailList = supplierSnapshot.data ?? [];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      elevation: 5,
                      child: ListTile(
                        title: Text(
                          message,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Date: $timestamp\nSupplier: $emailList\nProduct: $productName\nType: $type',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.email),
                              onPressed: () async {
                                if (emailList.isNotEmpty) {
                                  String subject = 'Notificare pentru $productName';
                                  String body = _buildEmailBody(productName, timestamp, storeName, storeAddress);
                                  _openEmailClient(emailList, subject, body, doc.id);
                                } else {
                                  print('No email addresses available.');
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () async {
                                await _markAsChecked(doc.id);
                              },
                            ),
                          ],
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      ),
                    );
                  },
                );
              }).toList();

              return ListView(children: notifications);
            },
          );
        },
      ),
    );
  }
}
