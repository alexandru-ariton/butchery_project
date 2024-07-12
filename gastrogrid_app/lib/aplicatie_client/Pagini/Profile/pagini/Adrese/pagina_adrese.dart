import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Profile/pagini/Adrese/pagina_editare_adrese.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:gastrogrid_app/providers/provider_livrare.dart';

class SavedAddressesPage extends StatefulWidget {
  final String source;

  const SavedAddressesPage({super.key, required this.source});

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

  void loadSavedAddresses() async {
    if (userId != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .orderBy('timestamp', descending: true)
          .get()
          .then((QuerySnapshot querySnapshot) {
        setState(() {
          savedAddresses = querySnapshot.docs.map((doc) {
            Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
            return {
              'addressId': doc.id,
              'address': data?['address'] ?? '',
              'city': data?['city'] ?? '',
              'country': data?['country'] ?? '',
              'zipCode': data?['zipCode'] ?? '',
              'timestamp': data?['timestamp'],
            };
          }).toList();
        });
      }).catchError((error) {
        print("Failed to load addresses: $error");
      });
    }
  }

  void _handleAddressTapForCart(String address) async {
    LatLng? location = await _getLocationFromAddress(address);
    Provider.of<DeliveryProvider>(context, listen: false).setSelectedAddress(address, location);
    Navigator.pop(context, address);
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

  void _handleAddressTapForProfile(Map<String, dynamic> addressData) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAddressPage(
          addressId: addressData['addressId'],
          street: addressData['address'],
          city: addressData['city'],
          country: addressData['country'],
          zipCode: addressData['zipCode'],
        ),
      ),
    );
  }

  void _handleAddressTap(Map<String, dynamic> addressData) {
    if (widget.source == 'Cart') {
      _handleAddressTapForCart('${addressData['address']}, ${addressData['city']}, ${addressData['country']}, ${addressData['zipCode']}');
    } else {
      _handleAddressTapForProfile(addressData);
    }
  }

  Widget _buildAddressCard(Map<String, dynamic> addressData) {
    return GestureDetector(
      onTap: () => _handleAddressTap(addressData),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 4,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          title: Text(
            '${addressData['address']}, ${addressData['city']}, ${addressData['country']}, ${addressData['zipCode']}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: IconButton(
            icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
            onPressed: () => _handleAddressTap(addressData),
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
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.secondary),
        toolbarTextStyle: TextTheme(
          titleLarge: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ).bodyMedium,
        titleTextStyle: TextTheme(
          titleLarge: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
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
