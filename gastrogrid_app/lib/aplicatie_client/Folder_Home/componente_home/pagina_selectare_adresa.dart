import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressSelector extends StatefulWidget {
  @override
  _AddressSelectorState createState() => _AddressSelectorState();
}

class _AddressSelectorState extends State<AddressSelector> {
  late GooglePlace googlePlace;
  TextEditingController searchController = TextEditingController();
  GoogleMapController? mapController;
  LatLng? selectedLocation;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    googlePlace = GooglePlace('AIzaSyBPKl6hVOD0zauA38oy1RQ3KXW8SM6pwZQ'); // Use your actual API key here
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setInitialLocation();
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _setInitialLocation() async {
    LatLng initialLocation = LatLng(40.7128, -74.0060); // Default to New York City
    mapController?.animateCamera(CameraUpdate.newLatLngZoom(initialLocation, 14.0));
  }

  void _onMapTapped(LatLng position) async {
    setSelectedLocation(position);
    fetchAddressFromCoordinates(position);
  }

  void setSelectedLocation(LatLng position) {
    setState(() {
      selectedLocation = position;
    });
    if (mapController != null) {
  mapController!.animateCamera(CameraUpdate.newLatLng(position));
}

  }

  Future<void> fetchAddressFromCoordinates(LatLng coordinates) async {
  setState(() {
    loading = true;
  });
  var result = await googlePlace.search.getNearBySearch(
    Location(lat: coordinates.latitude, lng: coordinates.longitude), 500);
  if (result != null && result.results != null && result.results!.isNotEmpty && result.results!.first.formattedAddress != null) {
    setState(() {
      searchController.text = result.results!.first.formattedAddress!;
      loading = false;
    });
  } else {
    setState(() {
      searchController.text = 'No address found';
      loading = false;
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
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              if (searchController.text.isNotEmpty) {
                saveAddress(searchController.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Address saved successfully"))
                );
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextFormField(
              controller: searchController,
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
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(40.7128, -74.0060), // Default coordinates
                zoom: 14.0,
              ),
              markers: {
                if (selectedLocation != null)
                  Marker(
                    markerId: MarkerId("selectedLocation"),
                    position: selectedLocation!,
                    draggable: true,
                    onDragEnd: (newPosition) {
  // ignore: unnecessary_null_comparison
  if (newPosition != null) {
    setSelectedLocation(newPosition);
    fetchAddressFromCoordinates(newPosition);
  }
},

                  )
              },
              onTap: _onMapTapped,
            ),
          ),
        ],
      ),
    );
  }
}
