import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_place/google_place.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<void> fetchAddressFromCoordinates(
  GooglePlace googlePlace,
  LatLng coordinates,
  TextEditingController searchController,
  Function(bool) setLoading,
) async {
  setLoading(true);
  try {
    var result = await googlePlace.search.getNearBySearch(
      Location(lat: coordinates.latitude, lng: coordinates.longitude),
      500,
    );
    if (result != null &&
        result.results != null &&
        result.results!.isNotEmpty &&
        result.results!.first.formattedAddress != null) {
      var address = result.results!.first.formattedAddress!;
      searchController.text = address;
    }
  } catch (e) {
    debugPrint('Error fetching address: $e');
  } finally {
    setLoading(false);
  }
}

Future<void> saveAddress(String address, BuildContext context) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    String userId = user.uid;
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .doc();
    await docRef.set({'address': address});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Address saved successfully")),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("User not found")),
    );
  }
  Navigator.pop(context, true);
}
