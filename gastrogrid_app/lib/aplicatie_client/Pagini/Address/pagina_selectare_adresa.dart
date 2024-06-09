import 'dart:async';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Address/componente/utils.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Address/componente/widget_mapa.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Address/componente/widget_search.dart';
import 'package:gastrogrid_app/providers/provider_themes.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:provider/provider.dart';

class AddressSelector extends StatefulWidget {
  const AddressSelector({super.key});

  @override
  _AddressSelectorState createState() => _AddressSelectorState();
}

class _AddressSelectorState extends State<AddressSelector> {
  late GooglePlace googlePlace;
  TextEditingController searchController = TextEditingController();
  TextEditingController manualAddressController = TextEditingController();
  GoogleMapController? mapController;
  LatLng? selectedLocation;
  List<AutocompletePrediction> predictions = [];
  bool loading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    googlePlace = GooglePlace('AIzaSyBPKl6hVOD0zauA38oy1RQ3KXW8SM6pwZQ');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setInitialLocation();
    });
  }

  @override
  void dispose() {
    mapController?.dispose();
    searchController.dispose();
    manualAddressController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    if (mapController != null) {
      mapController!.dispose();
    }
    mapController = controller;
  }

  Future<void> _setInitialLocation() async {
    LatLng initialLocation = LatLng(40.7128, -74.0060);
    await Future.delayed(Duration(milliseconds: 300));
    if (mapController != null) {
      mapController!.animateCamera(CameraUpdate.newLatLngZoom(initialLocation, 14.0));
    }
  }

  void _onMapTapped(LatLng position) async {
    setSelectedLocation(position);
    await fetchAddressFromCoordinates(
      googlePlace,
      position,
      searchController,
      (value) {
        setState(() {
          loading = value;
        });
      }
    );
  }

  void setSelectedLocation(LatLng position) {
    setState(() {
      selectedLocation = position;
    });
    if (mapController != null) {
      mapController!.animateCamera(CameraUpdate.newLatLng(position));
    }
  }

  void autoCompleteSearch(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: 300), () async {
      if (value.isEmpty) {
        setState(() {
          predictions = [];
        });
        return;
      }
      setState(() {
        loading = true;
      });
      try {
        var result = await googlePlace.autocomplete.get(value);
        if (result != null && result.predictions != null) {
          setState(() {
            predictions = result.predictions!;
          });
        } else {
          setState(() {
            predictions = [];
          });
        }
      } catch (e) {
        debugPrint('Error fetching predictions: $e');
        setState(() {
          predictions = [];
        });
      } finally {
        setState(() {
          loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Alege Adresa'),
        backgroundColor: themeProvider.themeData.colorScheme.surface,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              if (searchController.text.isNotEmpty) {
                saveAddress(searchController.text, context);
              } else if (manualAddressController.text.isNotEmpty) {
                saveAddress(manualAddressController.text, context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Introdu adresa")),
                );
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          SearchWidget(
            googlePlace: googlePlace,
            searchController: searchController,
            manualAddressController: manualAddressController,
            predictions: predictions,
            loading: loading,
            onSearchChanged: autoCompleteSearch,
            onPredictionSelected: (LatLng location, String description) async {
              setSelectedLocation(location);
              await fetchAddressFromCoordinates(
                googlePlace,
                location,
                searchController,
                (value) {
                  setState(() {
                    loading = value;
                  });
                }
              );
              setState(() {
                searchController.text = description;
                predictions = [];
              });
            },
          ),
          Expanded(
            child: MapWidget(
              onMapCreated: _onMapCreated,
              onMapTapped: _onMapTapped,
              selectedLocation: selectedLocation,
            ),
          ),
        ],
      ),
    );
  }
}
