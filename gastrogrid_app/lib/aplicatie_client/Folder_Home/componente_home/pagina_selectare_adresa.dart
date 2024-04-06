import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
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
  bool loading = false;

  @override
  void initState() {
    super.initState();
    googlePlace = GooglePlace('AIzaSyBPKl6hVOD0zauA38oy1RQ3KXW8SM6pwZQ');
  }

  void autoCompleteSearch(String value) async {
    if (value.isNotEmpty) {
      setState(() => loading = true);
      var result = await googlePlace.autocomplete.get(value);
      if (result != null && result.predictions != null && mounted) {
        setState(() {
          predictions = result.predictions!;
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } else {
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
        predictions = [];
        searchController.text = detail.result!.formattedAddress!;
      });
    }
  }

  void saveAddress(String address) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedAddresses = prefs.getStringList('savedAddresses') ?? [];
    if (!savedAddresses.contains(address)) {
      savedAddresses.add(address);
      await prefs.setStringList('savedAddresses', savedAddresses);
    }
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
                suffixIcon: loading ? CircularProgressIndicator() : null,
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
          if (selectedLocation != null)
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
          if (selectedLocation != null)
            ElevatedButton(
              onPressed: () {
                if (selectedLocation != null && searchController.text.isNotEmpty) {
                  saveAddress(searchController.text);
                }
                 Navigator.pop(context);
              },
              child: Text('Save Address'),
            ),
        ],
      ),
    );
  }
}
