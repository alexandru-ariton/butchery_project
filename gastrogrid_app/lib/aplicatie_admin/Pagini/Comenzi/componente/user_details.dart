import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetails extends StatelessWidget {
  final String userId;

  const UserDetails({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text('Incarca detaliile client-ului...', style: TextStyle(fontSize: 16));
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>?;
        if (userData == null) {
          return Text('Detaliile clientului nu au putut fi gasite.', style: TextStyle(fontSize: 16));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderDetailRow('Nume:', userData['username'] ?? '-'),
            _buildOrderDetailRow('Email:', userData['email'] ?? '-'),
            _buildOrderDetailRow('Telefon:', userData['phoneNumber'] ?? '-'),
            _buildOrderDetailRow('Adresa:', userData['address'] ?? '-'),
          ],
        );
      },
    );
  }

  Widget _buildOrderDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text('$label ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: TextStyle(fontSize: 18))),
        ],
      ),
    );
  }
}
