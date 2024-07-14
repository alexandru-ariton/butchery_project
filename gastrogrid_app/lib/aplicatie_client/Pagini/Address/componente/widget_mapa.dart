// Importă pachetul necesar pentru widget-ul Google Maps.
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Definirea unui widget Stateless pentru widget-ul de hartă.
class MapWidget extends StatelessWidget {
  final Function(GoogleMapController) onMapCreated; // Funcție apelată când harta este creată.
  final Function(LatLng) onMapTapped; // Funcție apelată când harta este apăsată.
  final LatLng? selectedLocation; // Locația selectată pe hartă.

  // Constructor pentru widget-ul MapWidget.
  const MapWidget({
    super.key,
    required this.onMapCreated,
    required this.onMapTapped,
    required this.selectedLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0), // Marginile pentru container.
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0), // Colțurile rotunjite ale containerului.
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Culoarea și opacitatea umbrei.
            spreadRadius: 3, // Răspândirea umbrei.
            blurRadius: 7, // Estomparea umbrei.
            offset: Offset(0, 3), // Offset-ul umbrei.
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0), // Colțurile rotunjite ale widget-ului de hartă.
        child: GoogleMap(
          onMapCreated: onMapCreated, // Asociază funcția apelată când harta este creată.
          initialCameraPosition: CameraPosition(
            target: LatLng(40.7128, -74.0060), // Poziția inițială a camerei.
            zoom: 14.0, // Nivelul de zoom inițial.
          ),
          markers: {
            if (selectedLocation != null)
              Marker(
                markerId: MarkerId("selectedLocation"), // ID-ul marker-ului.
                position: selectedLocation!, // Poziția marker-ului.
                draggable: true, // Marker-ul poate fi mutat.
                onDragEnd: onMapTapped, // Asociază funcția apelată când marker-ul este mutat.
              )
          },
          onTap: onMapTapped, // Asociază funcția apelată când harta este apăsată.
        ),
      ),
    );
  }
}
