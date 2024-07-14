// Importă biblioteca principală Flutter pentru a crea interfețe de utilizator.
import 'package:flutter/material.dart';

// Importă pachetul Firebase Auth pentru autentificarea utilizatorilor.
import 'package:firebase_auth/firebase_auth.dart';

// Importă pachetul Firestore pentru interacțiunea cu baza de date Firebase.
import 'package:cloud_firestore/cloud_firestore.dart';

// Importă pagina pentru editarea adreselor.
import 'package:gastrogrid_app/aplicatie_client/Pagini/Profile/pagini/Adrese/pagina_editare_adrese.dart';

// Importă pachetul geocoding pentru a obține locația dintr-o adresă.
import 'package:geocoding/geocoding.dart';

// Importă pachetul Google Maps pentru a gestiona locațiile.
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Importă pachetul provider pentru gestionarea stării.
import 'package:provider/provider.dart';

// Importă providerul pentru livrare.
import 'package:gastrogrid_app/providers/provider_livrare.dart';

// Declarația unei clase StatefulWidget pentru pagina de adrese salvate.
class SavedAddressesPage extends StatefulWidget {
  // Declarația unui câmp pentru sursa paginii.
  final String source;

  // Constructorul clasei SavedAddressesPage.
  const SavedAddressesPage({super.key, required this.source});

  @override
  _SavedAddressesPageState createState() => _SavedAddressesPageState();
}

// Declarația unei clase de stare pentru widget-ul SavedAddressesPage.
class _SavedAddressesPageState extends State<SavedAddressesPage> {
  // Declarația unei liste pentru adresele salvate.
  List<Map<String, dynamic>> savedAddresses = [];

  // Declarația unei variabile pentru ID-ul utilizatorului.
  String? userId;

  // Metodă care inițializează starea widgetului. Se apelează când widgetul este creat.
  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  // Metodă asincronă pentru inițializarea utilizatorului.
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

  // Metodă pentru încărcarea adreselor salvate din Firestore.
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

  // Metodă pentru gestionarea selectării unei adrese pentru coșul de cumpărături.
  void _handleAddressTapForCart(String address) async {
    LatLng? location = await _getLocationFromAddress(address);
    Provider.of<DeliveryProvider>(context, listen: false).setSelectedAddress(address, location);
    Navigator.pop(context, address);
  }

  // Metodă pentru obținerea locației dintr-o adresă folosind geocoding.
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

  // Metodă pentru gestionarea selectării unei adrese pentru profil.
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

  // Metodă pentru gestionarea selectării unei adrese.
  void _handleAddressTap(Map<String, dynamic> addressData) {
    if (widget.source == 'Cart') {
      _handleAddressTapForCart('${addressData['address']}, ${addressData['city']}, ${addressData['country']}, ${addressData['zipCode']}');
    } else {
      _handleAddressTapForProfile(addressData);
    }
  }

  // Metodă pentru construirea unui card de adresă.
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

  // Metodă care construiește interfața de utilizator a widgetului.
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
