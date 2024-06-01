import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LowStockNotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Low Stock Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('notifications').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var notifications = snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            var timestamp = data['timestamp'] != null 
                ? (data['timestamp'] as Timestamp).toDate().toString() 
                : 'No timestamp';

            return ListTile(
              title: Text(data['message']),
              subtitle: Text(timestamp),
            );
          }).toList();

          if (notifications.isEmpty) {
            return Center(child: Text('No low stock notifications'));
          }

          return ListView(children: notifications);
        },
      ),
    );
  }
}
