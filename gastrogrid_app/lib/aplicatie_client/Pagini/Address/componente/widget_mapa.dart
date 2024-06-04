import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatelessWidget {
  final Function(GoogleMapController) onMapCreated;
  final Function(LatLng) onMapTapped;
  final LatLng? selectedLocation;

  MapWidget({
    required this.onMapCreated,
    required this.onMapTapped,
    required this.selectedLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: GoogleMap(
          onMapCreated: onMapCreated,
          initialCameraPosition: CameraPosition(
            target: LatLng(40.7128, -74.0060),
            zoom: 14.0,
          ),
          markers: {
            if (selectedLocation != null)
              Marker(
                markerId: MarkerId("selectedLocation"),
                position: selectedLocation!,
                draggable: true,
                onDragEnd: onMapTapped,
              )
          },
          onTap: onMapTapped,
        ),
      ),
    );
  }
}
