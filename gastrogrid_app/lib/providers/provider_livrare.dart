// Importă pachetul principal pentru construirea UI-ului în Flutter.
import 'package:flutter/material.dart';
// Importă pachetul pentru utilizarea Google Maps în Flutter.
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Importă pachetul pentru obținerea locației curente și calcularea distanțelor.
import 'package:geolocator/geolocator.dart';
// Importă pachetul pentru geocodificare (convertirea coordonatelor în adrese).
import 'package:geocoding/geocoding.dart';

// Clasă care gestionează informațiile de livrare și notifică ascultătorii când există schimbări.
class DeliveryProvider with ChangeNotifier {
  // Variabilă privată care indică dacă este activată livrarea.
  bool _isDelivery = true;
  // Variabilă privată pentru taxa de livrare.
  double _deliveryFee = 0.0;
  // Locația implicită (LatLng) setată la o locație specifică.
  final LatLng _defaultLocation = LatLng(44.416686, 26.101286);
  // Adresa implicită.
  String? _defaultAddress;
  // Adresa selectată de utilizator.
  String? _selectedAddress;
  // Locația selectată de utilizator.
  LatLng? _selectedLocation;
  // Timpul de livrare estimat în minute.
  int _deliveryTime = 0;
  // Timpul estimat pentru preluare în minute.
  int pickupTime = 0;

  // Getter pentru a verifica dacă este activată livrarea.
  bool get isDelivery => _isDelivery;
  // Getter pentru taxa de livrare, calculată pe baza timpului de livrare.
  double get deliveryFee => (_isDelivery && _deliveryTime <= 60) ? _deliveryFee : 0.0;
  // Getter pentru adresa implicită.
  String get defaultAddress => _defaultAddress ?? 'Adresa necunoscuta';
  // Getter pentru locația implicită.
  LatLng get defaultLocation => _defaultLocation;
  // Getter pentru adresa selectată.
  String? get selectedAddress => _selectedAddress;
  // Getter pentru locația selectată.
  LatLng? get selectedLocation => _selectedLocation;
  // Getter pentru timpul de livrare estimat.
   int get deliveryTime => _isDelivery ? (_deliveryTime) : pickupTime;

    void resetSelectedAddress() {
    _selectedAddress = null;
    _selectedLocation = null;
    _deliveryFee = 0.0;
    _deliveryTime = 0;
    pickupTime = 0;
    notifyListeners();
  }

  // Getter pentru timpul de livrare formatat ca text.
  Object get formattedDeliveryTime {
    int time = _isDelivery ? _deliveryTime : pickupTime;
    String mesaj= "In afara ariei de livrare";
    if(time>60)
    {
      return mesaj;
    }
    return _formatTime(time);
  }

  // Constructor care convertește locația implicită într-o adresă.
  DeliveryProvider() {
    _convertDefaultLocationToAddress();
  }

  // Metodă pentru comutarea între livrare și preluare.
  void toggleDelivery(bool isDelivery) {
    _isDelivery = isDelivery;
    notifyListeners(); // Notifică ascultătorii despre schimbare.
  }

  // Metodă pentru setarea adresei și locației selectate.
  void setSelectedAddress(String? address, LatLng? location) {
    _selectedAddress = address;
    _selectedLocation = location;
    calculateDeliveryDetails(); // Calculează detaliile livrării pe baza noii adrese.
    notifyListeners(); // Notifică ascultătorii despre schimbare.
  }

  // Metodă pentru calcularea detaliilor livrării (taxa și timpul).
  Future<void> calculateDeliveryDetails() async {
    if (_selectedAddress == null || _selectedLocation == null) {
      _deliveryFee = 0.0;
      _deliveryTime = 0;
      pickupTime = 0;
    } else {
      double distance = await _calculateDistance(_defaultLocation, _selectedLocation!);
      _deliveryFee = double.parse((5.0 + distance * 0.5).toStringAsFixed(2));
      _deliveryTime = (distance / 10 * 60).round();
      pickupTime = (distance / 20 * 20).round();
    }
    notifyListeners(); // Notifică ascultătorii despre schimbare.
  }

  // Metodă privată pentru calcularea distanței dintre două locații.
  Future<double> _calculateDistance(LatLng start, LatLng end) async {
    double distance = Geolocator.distanceBetween(start.latitude, start.longitude, end.latitude, end.longitude) / 1000;
    return distance; // Returnează distanța în kilometri.
  }

  // Metodă pentru resetarea informațiilor de livrare la valorile implicite.
  void resetDeliveryInfo() {
    _deliveryFee = 0.0;
    _deliveryTime = 0;
    pickupTime = 0;
    notifyListeners(); // Notifică ascultătorii despre schimbare.
  }

  // Metodă privată pentru convertirea locației implicite într-o adresă.
  Future<void> _convertDefaultLocationToAddress() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(_defaultLocation.latitude, _defaultLocation.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        _defaultAddress = '${place.street}, ${place.locality}, ${place.country}';
        print('Adresa default obținută: $_defaultAddress');
      } else {
        _defaultAddress = 'Adresa necunoscută';
        print('Nu s-a putut obține adresa default.');
      }
    } catch (e) {
      _defaultAddress = 'Eroare la obținerea adresei';
      print('Eroare la obținerea adresei: $e'); // Log de eroare pentru debugging
    }
    notifyListeners(); // Notifică ascultătorii despre schimbare.
  }

  // Metodă privată pentru formatarea timpului în minute, ore și zile.
  String _formatTime(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else if (minutes < 1440) {
      int hours = minutes ~/ 60;
      int remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}min';
    } else {
      int days = minutes ~/ 1440;
      int remainingHours = (minutes % 1440) ~/ 60;
      int remainingMinutes = minutes % 60;
      return '${days}z ${remainingHours}h ${remainingMinutes}min';
    }
  }

  // Metodă pentru obținerea locației (LatLng) pe baza unei adrese.
  Future<LatLng?> getLocationFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
    } catch (e) {
      print("Error getting location from address: $e");
    }
    return null; // Returnează null dacă locația nu poate fi obținută.
  }

   
}
