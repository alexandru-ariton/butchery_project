// ignore_for_file: unused_field, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MultiAddressInputPage extends StatefulWidget {
  @override
  _MultiAddressInputPageState createState() => _MultiAddressInputPageState();
}

class _MultiAddressInputPageState extends State<MultiAddressInputPage> {
  final Set<Marker> _markers = {};
  late GoogleMapController _mapController;
  final LatLng _initialPosition = LatLng(45.4215, -75.6972); // Înlocuiește cu o locație inițială

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onAddMarkerButtonPressed(LatLng position) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(position.toString()),
          position: position,
          infoWindow: InfoWindow(
            title: 'Adresa selectată',
            snippet: 'Adaugă descrierea aici',
          ),
          icon: BitmapDescriptor.defaultMarker,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adaugă Adrese'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 12.0,
            ),
            markers: _markers,
            onTap: _onAddMarkerButtonPressed,
          ),
          // Adaugă aici widget-uri pentru căutarea adreselor și pentru a lista adresele adăugate
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Logica pentru a salva adresele sau pentru a merge mai departe
        },
        child: Icon(Icons.check),
      ),
    );
  }

}
