import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class DeliveryProvider with ChangeNotifier {
  bool _isDelivery = true;
  double _deliveryFee = 5.0;
  final LatLng _defaultLocation = LatLng(44.416686, 26.101286);
  String? _defaultAddress;
  String? _selectedAddress;
  LatLng? _selectedLocation;
  int _deliveryTime = 60;
  int pickupTime = 20;

  bool get isDelivery => _isDelivery;
  double get deliveryFee => (_isDelivery && _deliveryTime <= 60) ? _deliveryFee : 0.0;
  String get defaultAddress => _defaultAddress ?? 'Adresa necunoscută';
  LatLng get defaultLocation => _defaultLocation;
  String? get selectedAddress => _selectedAddress;
  LatLng? get selectedLocation => _selectedLocation;
  int get deliveryTime => _isDelivery ? _deliveryTime : pickupTime;
 
  

  String get formattedDeliveryTime {
    int time = _isDelivery ? _deliveryTime : pickupTime;
    if (time > 60) {
      return 'Locația este în afara ariei de livrare';
    } 
      return _formatTime(time);
    
  }

  DeliveryProvider() {
    _convertDefaultLocationToAddress();
  }

  void toggleDelivery(bool isDelivery) {
    _isDelivery = isDelivery;
    notifyListeners();
  }

  void setSelectedAddress(String? address, LatLng? location) {
    _selectedAddress = address;
    _selectedLocation = location;
    calculateDeliveryDetails();
    notifyListeners();
  }

  Future<void> calculateDeliveryDetails() async {
    if (_selectedAddress == null || _selectedLocation == null) {
      _deliveryFee = 5.0;
      _deliveryTime = 60;
      pickupTime = 20;
    } else {
      double distance = await _calculateDistance(_defaultLocation, _selectedLocation!);
      _deliveryFee = double.parse((5.0 + distance * 0.5).toStringAsFixed(2));
      _deliveryTime = (distance / 10 * 60).round();
      pickupTime = (distance / 20 * 20).round(); // Adjusted logic for pickup time
    }
    notifyListeners();
  }

  Future<double> _calculateDistance(LatLng start, LatLng end) async {
    double distance = Geolocator.distanceBetween(start.latitude, start.longitude, end.latitude, end.longitude) / 1000;
    return distance;
  }

  void resetDeliveryInfo() {
    _deliveryFee = 5.0;
    _deliveryTime = 60;
    pickupTime = 20;
    notifyListeners();
  }

  Future<void> _convertDefaultLocationToAddress() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(_defaultLocation.latitude, _defaultLocation.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        _defaultAddress = '${place.street}, ${place.locality}, ${place.country}';
      } else {
        _defaultAddress = 'Adresa necunoscută';
      }
    } catch (e) {
      _defaultAddress = 'Eroare la obținerea adresei';
      print('Eroare la obținerea adresei: $e'); // Log de eroare pentru debugging
    }
    notifyListeners();
  }

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

  Future<LatLng?> getLocationFromAddress(String address) async {
  try {
    List<Location> locations = await locationFromAddress(address);
    if (locations.isNotEmpty) {
      return LatLng(locations.first.latitude, locations.first.longitude);
    }
  } catch (e) {
    print("Error getting location from address: $e");
  }
  return null;
}

}
