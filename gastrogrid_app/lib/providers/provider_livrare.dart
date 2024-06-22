import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class DeliveryProvider with ChangeNotifier {
  bool _isDelivery = true;
  double _deliveryFee = 5.0;
  final String _defaultAddress = "Adresa Default";
  final LatLng _defaultLocation = LatLng(44.416686, 26.101286); 
  String? _selectedAddress;
  LatLng? _selectedLocation;
  int _deliveryTime = 60; 
  final int _pickupTime = 20; 

  bool get isDelivery => _isDelivery;
  double get deliveryFee => _deliveryFee;
  String? get selectedAddress => _selectedAddress;
  LatLng get defaultLocation => _defaultLocation;
  LatLng? get selectedLocation => _selectedLocation;
  int get deliveryTime => _deliveryTime;
  int get pickupTime => _pickupTime;

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
    if (_selectedAddress == _defaultAddress || _selectedAddress == null || _selectedLocation == null) {
      _deliveryFee = 5.0;
      _deliveryTime = 60; 
    } else {
      double distance = await _calculateDistance(_defaultLocation, _selectedLocation!);
      _deliveryFee = double.parse((5.0 + distance * 0.5).toStringAsFixed(2)) ; 
      _deliveryTime = (distance / 10 * 60).round(); 
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
    notifyListeners();
  }
}
