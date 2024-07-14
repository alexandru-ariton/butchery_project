// Importă pachetele necesare pentru autentificarea Firebase, baza de date Firestore și Google Place.
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_place/google_place.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Funcție asincronă care obține adresa de la coordonatele date folosind Google Place API.
Future<void> fetchAddressFromCoordinates(
  GooglePlace googlePlace,
  LatLng coordinates,
  TextEditingController searchController,
  Function(bool) setLoading,
) async {
  setLoading(true); // Setează starea de încărcare la adevărat.
  try {
    var result = await googlePlace.search.getNearBySearch(
      Location(lat: coordinates.latitude, lng: coordinates.longitude),
      500, // Raza de căutare în metri.
    );
    if (result != null &&
        result.results != null &&
        result.results!.isNotEmpty &&
        result.results!.first.formattedAddress != null) {
      var address = result.results!.first.formattedAddress!;
      searchController.text = address; // Actualizează controller-ul de căutare cu adresa obținută.
    }
  } catch (e) {
    debugPrint('Error fetching address: $e'); // Afișează eroarea în consola de debug.
  } finally {
    setLoading(false); // Setează starea de încărcare la fals.
  }
}

// Funcție asincronă care salvează adresa în Firestore.
Future<void> saveAddress(String address, BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser; // Obține utilizatorul curent autentificat.
  if (user != null) {
    final userId = user.uid; // Obține ID-ul utilizatorului.

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .add({
        'address': address, // Adresa introdusă de utilizator.
        'timestamp': FieldValue.serverTimestamp(), // Timestamp-ul serverului.
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Adresa a fost salvată cu succes')), // Afișează un mesaj de succes.
      );

      Navigator.of(context).pop(); // Închide pagina curentă.
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eroare la salvarea adresei: $e')), // Afișează un mesaj de eroare.
      );
    }
  }
}
