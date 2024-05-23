import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Profile/pagini/pagina_editare_adrese.dart';
import 'package:gastrogrid_app/providers/provider_livrare.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';

class SavedAddressesPage extends StatefulWidget {
  @override
  _SavedAddressesPageState createState() => _SavedAddressesPageState();
}

class _SavedAddressesPageState extends State<SavedAddressesPage> {
  List<Map<String, String>> savedAddresses = [];
  String? userId;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  void _initializeUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      print('User ID: $userId'); 
      loadSavedAddresses();
    } else {
      print("User is not logged in");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Utilizatorul nu este autentificat')),
      );
    }
  }

  void loadSavedAddresses() async {
    if (userId != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .get()
          .then((QuerySnapshot querySnapshot) {
        setState(() {
          savedAddresses = querySnapshot.docs.map((doc) => {
            'addressId': doc.id,
            'address': doc['address'] as String,
          }).toList();
        });
      }).catchError((error) {
        print("Failed to load addresses: $error");
      });
    }
  }

  Future<LatLng?> _getLocationFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
    } catch (e) {
      print("Error getting location from address: $e");
    }
    return null;
  }

  void _handleAddressTap(String address) async {
    LatLng? location = await _getLocationFromAddress(address);
    Provider.of<DeliveryProvider>(context, listen: false).setSelectedAddress(address, location);
    Navigator.pop(context, address); // Go back
  }

  Widget _buildAddressCard(Map<String, String> addressData) {
    return GestureDetector(
      onTap: () => _handleAddressTap(addressData['address']!),
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
            addressData['address']!,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: IconButton(
            icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditAddressPage(
                    address: addressData['address']!,
                    addressId: addressData['addressId']!,
                  ),
                ),
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
    );
  }
}
