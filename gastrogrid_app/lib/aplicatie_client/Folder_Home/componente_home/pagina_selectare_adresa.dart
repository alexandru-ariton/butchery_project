// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_Profile/pagini/pagina_adrese.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:location/location.dart' as loc;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    // Initialize googlePlace with your API key
    googlePlace = GooglePlace("AIzaSyBPKl6hVOD0zauA38oy1RQ3KXW8SM6pwZQ");
  }

 void autoCompleteSearch(String value) async {
  // Check if the input is not empty
  if (value.isNotEmpty) {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  } else {
    // Clear predictions if the search input is cleared
    setState(() {
      predictions = [];
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
    // Save the address
    saveAddress(detail.result!.formattedAddress!);
  }
}

  void determineLocationAutomatically() async {
  var locationService = loc.Location();

  bool serviceEnabled;
  loc.PermissionStatus permissionGranted;
  loc.LocationData locationData;

  serviceEnabled = await locationService.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await locationService.requestService();
    if (!serviceEnabled) {
      return;
    }
  }

  permissionGranted = await locationService.hasPermission();
  if (permissionGranted == loc.PermissionStatus.denied) {
    permissionGranted = await locationService.requestPermission();
    if (permissionGranted != loc.PermissionStatus.granted) {
      return;
    }
  }

  locationData = await locationService.getLocation();
  LatLng currentLocation = LatLng(locationData.latitude!, locationData.longitude!);

  mapController?.animateCamera(CameraUpdate.newLatLngZoom(currentLocation, 14.0));
  
  setState(() {
    selectedLocation = currentLocation;
    // Assuming you want to clear the search bar when using automatic location
    searchController.clear();
    predictions.clear();
  });

}


  void addAddressManually() {
    // TODO: Add your logic to add the address manually
  }





void saveAddress(String address) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // Fetch the existing list of saved addresses or initialize an empty list
  List<String> savedAddresses = prefs.getStringList('savedAddresses') ?? [];
  // Add the new address to the list
  savedAddresses.add(address);
  // Save the updated list back to shared_preferences
  await prefs.setStringList('savedAddresses', savedAddresses);
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Address'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextFormField(
              controller: searchController,
              onChanged: autoCompleteSearch,
              decoration: InputDecoration(
                hintText: 'Search by street, city, or state',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
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
          if (selectedLocation != null) ...[
            Expanded(
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: selectedLocation!,
                  zoom: 14.0,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId("selectedLocation"),
                    position: selectedLocation!,
                  ),
                },
                onTap: (position) {
                  setState(() {
                    selectedLocation = position;
                  });
                },
              ),
            ),
            ElevatedButton(
             
              onPressed: () { saveAddress; },
              child: Text('Save Address'),
            ),
          ],
        ],
      ),
    );
  }
}