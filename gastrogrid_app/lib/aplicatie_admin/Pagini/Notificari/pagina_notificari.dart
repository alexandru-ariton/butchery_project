import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gastrogrid_app/aplicatie_admin/Pagini/Produs/pagina_editare_produs.dart';


class LowStockNotificationPage extends StatelessWidget {
  const LowStockNotificationPage({Key? key}) : super(key: key);

  Future<void> _markAsChecked(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificări Stoc Scăzut și Produse Expirate'),
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
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProductPage(
                          productId: productId,
                          currentTitle: data['title'],
                          currentPrice: data['price'].toString(),
                          currentDescription: data['description'],
                          currentImageUrl: data['imageUrl'],
                          currentQuantity: data['quantity'].toString(),
                          currentUnit: data['unit'],
                          currentExpiryDate: data['expiryDate'],
                          notificationId: doc.id, // Adăugat notificationId
                        ),
                      ),
                    );
                    await _markAsChecked(doc.id);
                  },
                ),
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
