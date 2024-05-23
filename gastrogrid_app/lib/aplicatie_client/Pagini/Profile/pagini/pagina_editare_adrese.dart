import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditAddressPage extends StatefulWidget {
  final String address;
  final String addressId;

  EditAddressPage({required this.address, required this.addressId});

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
    _initializeUser();
  }

  void _initializeUser() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    setState(() {
      userId = user.uid;
    });
    print('User ID in Edit Page: $userId'); 
  } else {
    print('User is not logged in');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Utilizatorul nu este autentificat')),
    );
  }
}


  void _saveAddress() async {
    if (userId != null && widget.addressId.isNotEmpty) {
      try {
        DocumentReference docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('addresses')
            .doc(widget.addressId);
        await docRef.set({'address': _addressController.text});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Adresa a fost salvată cu succes!')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        print('Eroare la salvarea adresei: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eroare la salvarea adresei: $e')),
        );
      }
    } else {
      print('User ID sau Address ID lipsește');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ID sau Address ID lipsește')),
      );
    }
  }

  void _removeAddress() async {
    if (userId != null && widget.addressId.isNotEmpty) {
      try {
        DocumentReference docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('addresses')
            .doc(widget.addressId);
        await docRef.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Adresa a fost ștearsă cu succes!')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        print('Eroare la ștergerea adresei: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eroare la ștergerea adresei: $e')),
        );
      }
    } else {
      print('User ID sau Address ID lipsește');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ID sau Address ID lipsește')),
      );
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _saveAddress,
                  child: Text('Salvează'),
                ),
                ElevatedButton(
                  onPressed: _removeAddress,
                  child: Text('Șterge'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
