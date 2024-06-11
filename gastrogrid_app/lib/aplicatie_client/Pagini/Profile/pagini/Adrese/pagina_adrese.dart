import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Profile/pagini/Adrese/pagina_editare_adrese.dart';
import 'package:gastrogrid_app/providers/provider_livrare.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';

class SavedAddressesPage extends StatefulWidget {
  const SavedAddressesPage({super.key});

  @override
  _SavedAddressesPageState createState() => _SavedAddressesPageState();
}

class _SavedAddressesPageState extends State<SavedAddressesPage> {
  List<Map<String, dynamic>> savedAddresses = [];
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
      loadSavedAddresses();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Utilizatorul nu este autentificat')),
      );
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

  void _handleAddressTap1(String address) async {
    LatLng? location = await _getLocationFromAddress(address);
    Provider.of<DeliveryProvider>(context, listen: false).setSelectedAddress(address, location);
    Navigator.pop(context, address); 
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
          savedAddresses = querySnapshot.docs.map((doc) {
            String address = doc['address'] as String;
            return {
              'addressId': doc.id,
              'address': address,
            };
          }).toList();
        });
      }).catchError((error) {
        print("Failed to load addresses: $error");
      });
    }
  }

  void _handleAddressTap(String addressId, String address) async {
    List<String> parts = address.split(',');
    String street = parts.isNotEmpty ? parts[0].trim() : '';
    String city = parts.length > 1 ? parts[1].trim() : '';
    String stateZip = parts.length > 2 ? parts[2].trim() : '';
    String state = '';
    String zipCode = '';
    if (stateZip.isNotEmpty) {
      List<String> stateZipParts = stateZip.split(' ');
      if (stateZipParts.isNotEmpty) state = stateZipParts[0].trim();
      if (stateZipParts.length > 1) zipCode = stateZipParts[1].trim();
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAddressPage(
          addressId: addressId,
          street: street,
          city: city,
          state: state,
          zipCode: zipCode,
        ),
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> addressData) {
    return GestureDetector(
      onTap: () => _handleAddressTap1(addressData['address']!),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 4,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          title: Text(
            addressData['address'],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: IconButton(
            icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
            onPressed: () => _handleAddressTap(addressData['addressId'], addressData['address']),
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
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor), toolbarTextStyle: TextTheme(
          titleLarge: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ).bodyMedium, titleTextStyle: TextTheme(
          titleLarge: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ).titleLarge,
      ),
      body: savedAddresses.isEmpty
          ? Center(
              child: Text(
                'Nu ai adrese salvate',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: savedAddresses.length,
              itemBuilder: (context, index) {
                return _buildAddressCard(savedAddresses[index]);
              },
            ),
    );
  }
}
