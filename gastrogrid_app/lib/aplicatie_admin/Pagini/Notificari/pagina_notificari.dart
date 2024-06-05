import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LowStockNotificationPage extends StatelessWidget {
  const LowStockNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
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

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              elevation: 5,
              child: ListTile(
                title: Text(
                  data['message'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  timestamp,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              ),
            );
          }).toList();

          if (notifications.isEmpty) {
            return Center(child: Text('No low stock notifications', style: TextStyle(fontSize: 18)));
          }

          return ListView(children: notifications);
        },
      ),
    );
  }
}
