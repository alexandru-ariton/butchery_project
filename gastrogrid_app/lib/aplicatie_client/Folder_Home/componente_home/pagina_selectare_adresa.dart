import 'package:flutter/material.dart';
import 'package:gastrogrid_app/themes/theme_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:provider/provider.dart';
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
  List<AutocompletePrediction> predictions = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    googlePlace = GooglePlace('AIzaSyBPKl6hVOD0zauA38oy1RQ3KXW8SM6pwZQ'); // Use your actual API key here
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setInitialLocation();
    });
  }

  @override
  void dispose() {
    mapController?.dispose();
    searchController.dispose();
    super.dispose();
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
      });
    }
    setState(() {
      loading = false;
    });
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }

  void saveAddress(String address) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedAddresses = prefs.getStringList('savedAddresses') ?? [];
    if (!savedAddresses.contains(address)) {
      savedAddresses.add(address);
      await prefs.setStringList('savedAddresses', savedAddresses);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Address saved successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Address already saved")),
      );
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Address'),
        backgroundColor: themeProvider.themeData.colorScheme.background,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              if (searchController.text.isNotEmpty) {
                saveAddress(searchController.text);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please enter an address")),
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
            child: Column(
              children: [
                TextFormField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by street, city, or state',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    suffixIcon: loading ? CircularProgressIndicator() : null,
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      autoCompleteSearch(value);
                    } else {
                      setState(() {
                        predictions = [];
                      });
                    }
                  },
                ),
                SizedBox(height: 8.0),
                predictions.isNotEmpty ? Container(
                  constraints: BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: predictions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        textColor: themeProvider.themeData.colorScheme.primary,
                        title: Text(predictions[index].description ?? ''),
                        onTap: () async {
                          var placeId = predictions[index].placeId!;
                          var details = await googlePlace.details.get(placeId);
                          if (details != null && details.result != null) {
                            var location = details.result!.geometry!.location!;
                            setSelectedLocation(LatLng(location.lat!, location.lng!));
                            fetchAddressFromCoordinates(LatLng(location.lat!, location.lng!));
                            setState(() {
                              searchController.text = predictions[index].description ?? '';
                              predictions = [];
                            });
                          }
                        },
                      );
                    },
                  ),
                ) : Container(),
              ],
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
