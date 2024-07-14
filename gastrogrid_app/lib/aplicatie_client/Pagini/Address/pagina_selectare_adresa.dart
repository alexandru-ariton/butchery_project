// Importă pachetele necesare pentru funcționalitatea aplicației.
import 'dart:async';  // Pentru gestionarea temporizatorilor.
import 'package:flutter/material.dart';  // Pachetul principal pentru Flutter.
import 'package:google_maps_flutter/google_maps_flutter.dart';  // Pentru integrarea Google Maps.
import 'package:google_place/google_place.dart';  // Pentru utilizarea API-ului Google Place.
import 'package:provider/provider.dart';  // Pentru gestionarea stării aplicației.
import 'package:gastrogrid_app/aplicatie_client/Pagini/Address/componente/utils.dart';  // Importă utilitare personalizate.
import 'package:gastrogrid_app/aplicatie_client/Pagini/Address/componente/widget_mapa.dart';  // Importă widget-ul personalizat pentru hartă.
import 'package:gastrogrid_app/aplicatie_client/Pagini/Address/componente/widget_search.dart';  // Importă widget-ul personalizat pentru căutare.
import 'package:gastrogrid_app/providers/provider_themes.dart';  // Importă furnizorul pentru temele aplicației.

// Definirea unui widget Stateful pentru selectorul de adrese.
class AddressSelector extends StatefulWidget {
  const AddressSelector({super.key});

  @override
  _AddressSelectorState createState() => _AddressSelectorState();
}

// Starea pentru widget-ul AddressSelector.
class _AddressSelectorState extends State<AddressSelector> {
  late GooglePlace googlePlace;  // Instanță pentru Google Place API.
  TextEditingController searchController = TextEditingController();  // Controler pentru câmpul de căutare.
  TextEditingController manualAddressController = TextEditingController();  // Controler pentru adresa manuală.
  GoogleMapController? mapController;  // Controler pentru Google Map.
  LatLng? selectedLocation;  // Coordonatele locației selectate.
  List<AutocompletePrediction> predictions = [];  // Lista predicțiilor autocomplete.
  bool loading = false;  // Stare de încărcare.
  Timer? _debounce;  // Temporizator pentru debouncing.

  @override
  void initState() {
    super.initState();
    // Inițializează Google Place cu cheia API.
    googlePlace = GooglePlace('AIzaSyBPKl6hVOD0zauA38oy1RQ3KXW8SM6pwZQ');
    // Setează locația inițială după ce widget-ul este construit.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setInitialLocation();
    });
  }

  // Funcție pentru configurarea hărții la crearea acesteia.
  void _onMapCreated(GoogleMapController controller) {
    if (mapController != null) {
      mapController!.dispose();
    }
    mapController = controller;
  }

  // Funcție pentru setarea locației inițiale pe hartă.
  Future<void> _setInitialLocation() async {
    LatLng initialLocation = LatLng(40.7128, -74.0060);  // Coordonate pentru New York City.
    await Future.delayed(Duration(milliseconds: 300));
    if (mapController != null) {
      mapController!.animateCamera(CameraUpdate.newLatLngZoom(initialLocation, 14.0));
    }
  }

  // Funcție apelată la tap pe hartă pentru a seta locația selectată.
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

  // Curăță resursele când widget-ul este eliminat.
  @override
  void dispose() {
    mapController?.dispose();
    searchController.dispose();
    manualAddressController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Setează locația selectată și animă camera hărții.
  void setSelectedLocation(LatLng position) {
    setState(() {
      selectedLocation = position;
    });
    if (mapController != null) {
      mapController!.animateCamera(CameraUpdate.newLatLng(position));
    }
  }

  // Funcție pentru căutarea automată utilizând debouncing.
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

  // Construirea UI pentru selectorul de adrese.
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Alege adresa'),
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
          // Widget pentru căutarea și selectarea adresei.
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
          // Widget pentru afișarea hărții.
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
