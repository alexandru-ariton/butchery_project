// ignore_for_file: unnecessary_new

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:location/location.dart' as loc;

class AddressSelector extends StatefulWidget {
  @override
  _AddressSelectorState createState() => _AddressSelectorState();
}

class _AddressSelectorState extends State<AddressSelector> {
  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  TextEditingController searchController = TextEditingController();
  GoogleMapController? mapController;
  LatLng? selectedLocation;

  @override
  void initState() {
    super.initState();
    googlePlace = GooglePlace("AIzaSyBPKl6hVOD0zauA38oy1RQ3KXW8SM6pwZQ");
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void selectPrediction(AutocompletePrediction prediction) async {
    var detail = await googlePlace.details.get(prediction.placeId!);
    if (detail != null && detail.result != null && mounted) {
      final location = detail.result!.geometry!.location!;
      final position = LatLng(location.lat!, location.lng!);
      mapController?.animateCamera(CameraUpdate.newLatLng(position));
      setState(() {
        selectedLocation = position;
        predictions.clear();
        searchController.text = detail.result!.formattedAddress!;
      });
    }
  }

  void determineLocationAutomatically() async {
    loc.Location location = new loc.Location();
    bool _serviceEnabled;
    loc.PermissionStatus _permissionGranted;
    loc.LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    setState(() {
      selectedLocation = LatLng(_locationData.latitude!, _locationData.longitude!);
    });

    mapController?.animateCamera(CameraUpdate.newLatLng(selectedLocation!));
  }

  void addAddressManually() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adaugă Adresa Manual'),
          content: TextField(
            onSubmitted: (value) {
              Navigator.of(context).pop();
              // Do something with the user input
            },
            decoration: InputDecoration(
              hintText: 'Introdu adresa',
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adaugă adresă'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextFormField(
              controller: searchController,
              onChanged: autoCompleteSearch,
              decoration: InputDecoration(
                hintText: 'Caută stradă, localitate, județ',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: predictions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.location_on),
                  title: Text(predictions[index].description!),
                  onTap: () {
                    selectPrediction(predictions[index]);
                  },
                );
              },
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: selectedLocation ?? LatLng(45.4215, -75.6972),
                zoom: 14.0,
              ),
              markers: selectedLocation != null
                  ? {
                      Marker(
                        markerId: MarkerId("selected-location"),
                        position: selectedLocation!,
                      ),
                    }
                  : {},
              onTap: (position) {
                setState(() {
                  selectedLocation = position;
                });
                mapController?.animateCamera(CameraUpdate.newLatLng(position));
              },
            ),
          ),
          ElevatedButton(
            onPressed: determineLocationAutomatically,
            child: Text('Determină locația automat'),
          ),
          ElevatedButton(
            onPressed: addAddressManually,
            child: Text('Adaugă adresă manual'),
          ),
        ],
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: AddressSelector()));
