import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Profile/pagini/pagina_editare_adrese.dart';
import 'package:gastrogrid_app/providers/provider_livrare.dart';
import 'package:provider/provider.dart';

class SavedAddressesPage extends StatefulWidget {
  @override
  _SavedAddressesPageState createState() => _SavedAddressesPageState();
}

class _SavedAddressesPageState extends State<SavedAddressesPage> {
  List<String> savedAddresses = [];
  String? userId;

  @override
  void initState() {
    super.initState();
    loadSavedAddresses();
  }

  void loadSavedAddresses() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .get()
          .then((QuerySnapshot querySnapshot) {
        setState(() {
          savedAddresses = querySnapshot.docs.map((doc) => doc['address'] as String).toList();
        });
      });
    }
  }

  void _handleAddressTap(String address) {
    Provider.of<DeliveryProvider>(context, listen: false).setSelectedAddress(address);
    Navigator.pop(context, address); // Go back
  }

  void _addNewAddress(String newAddress) async {
    if (userId != null) {
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .doc();
      await docRef.set({'address': newAddress});
      loadSavedAddresses();
    }
  }

  Widget _buildAddressCard(String address) {
    return GestureDetector(
      onTap: () => _handleAddressTap(address),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 4,
        shadowColor: Colors.grey.withOpacity(0.5),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          title: Text(
            address,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: IconButton(
            icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditAddressPage(address: address)),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adresele mele'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView.builder(
        itemCount: savedAddresses.length,
        itemBuilder: (context, index) {
          return _buildAddressCard(savedAddresses[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Adaugă logica pentru a adăuga o nouă adresă
          _addNewAddress('Noua Adresă');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
