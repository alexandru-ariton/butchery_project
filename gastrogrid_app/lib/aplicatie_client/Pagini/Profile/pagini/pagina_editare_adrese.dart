import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditAddressPage extends StatefulWidget {
  final String address;

  EditAddressPage({required this.address});

  @override
  _EditAddressPageState createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  late TextEditingController _addressController;
  String? userId;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.address);
    userId = FirebaseAuth.instance.currentUser?.uid;
  }

  void _saveAddress() async {
    if (userId != null) {
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .doc();
      await docRef.set({'address': _addressController.text});
      Navigator.pop(context, true); // Go back and indicate that the address was updated
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editează Adresa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Adresa'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveAddress,
              child: Text('Salvează'),
            ),
          ],
        ),
      ),
    );
  }
}
