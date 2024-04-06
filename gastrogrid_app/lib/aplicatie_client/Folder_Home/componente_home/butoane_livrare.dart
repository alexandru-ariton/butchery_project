// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, library_private_types_in_public_api, use_key_in_widget_constructors, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DeliveryInfo with ChangeNotifier {
  bool _isDelivery = true;
  double _deliveryFee = 5.0;
  String? _selectedAddress;

  bool get isDelivery => _isDelivery;
  double get deliveryFee => _deliveryFee;
  String? get selectedAddress => _selectedAddress; 

  void toggleDelivery(bool isDelivery) {
    _isDelivery = isDelivery;
    notifyListeners();
  }

   void setSelectedAddress(String? address) async {
  _selectedAddress = address;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('selectedAddress', address ?? '');
  notifyListeners();
}


}


class DeliveryToggleButtons extends StatefulWidget {
  @override
  _DeliveryToggleButtonsState createState() => _DeliveryToggleButtonsState();
}

class _DeliveryToggleButtonsState extends State<DeliveryToggleButtons> {
  @override
  Widget build(BuildContext context) {
    final deliveryInfo = Provider.of<DeliveryInfo>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildDeliveryButton(deliveryInfo.isDelivery),
              _buildPickupButton(!deliveryInfo.isDelivery),
            ],
          ),
        ),
        SizedBox(height: 10),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: deliveryInfo.isDelivery ? 
            [Icon(Icons.timelapse_outlined, size: 12), Text('60 min',style:TextStyle(fontSize: 12)),SizedBox(width: 8,), Icon(Icons.delivery_dining_outlined, size: 15), Text('${deliveryInfo.deliveryFee} lei',style:TextStyle(fontSize: 12))] : 
            [Icon(Icons.timelapse_outlined, size: 12), Text('20 min',style:TextStyle(fontSize: 12),)],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryButton(bool isDeliverySelected) {
    return _buildToggleButton('Livrare', isDeliverySelected, () {
      Provider.of<DeliveryInfo>(context, listen: false).toggleDelivery(true);
    });
  }

  Widget _buildPickupButton(bool isPickupSelected) {
    return _buildToggleButton('Ridicare', isPickupSelected, () {
      Provider.of<DeliveryInfo>(context, listen: false).toggleDelivery(false);
    });
  }

  Widget _buildToggleButton(String text, bool isSelected, VoidCallback onTap) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
