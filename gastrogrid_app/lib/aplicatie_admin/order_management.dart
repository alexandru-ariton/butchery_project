import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderManagement extends StatelessWidget {
  void _deleteOrder(String id) async {
    await FirebaseFirestore.instance.collection('orders').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Management'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var order = snapshot.data!.docs[index];
              return ListTile(
                title: Text('Order ${order.id}'),
                subtitle: Text('Total: ${order['total']} lei'),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteOrder(order.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
