import 'package:gastrogrid_app/aplicatie_client/Pagini/Orders/componente/order_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class PaginaOrder extends StatelessWidget {
  const PaginaOrder({super.key});

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
                  return OrderCard(order: order);
                },
              );
            },
          );
        },
      ),
    );
  }
}
