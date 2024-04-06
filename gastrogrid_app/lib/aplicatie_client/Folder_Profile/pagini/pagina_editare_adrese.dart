// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, prefer_is_empty, use_build_context_synchronously, prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_Home/componente_home/butoane_livrare.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditAddressPage extends StatefulWidget {
  final String address;

  EditAddressPage({required this.address});

  @override
  _EditAddressPageState createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
    final _formKey = GlobalKey<FormState>();
  late TextEditingController _streetController;
  late TextEditingController _numberController;
  late TextEditingController _blockController;
  late TextEditingController _cityController;
  late TextEditingController _otherDetailsController;

  @override
  void initState() {
    super.initState();
    // Assuming the address is structured with each part separated by a comma
    List<String> addressParts = widget.address.split(',');
    _streetController = TextEditingController(text: addressParts.length > 0 ? addressParts[0] : '');
    _numberController = TextEditingController(text: addressParts.length > 1 ? addressParts[1] : '');
    _blockController = TextEditingController(text: addressParts.length > 2 ? addressParts[2] : '');
    _cityController = TextEditingController(text: addressParts.length > 3 ? addressParts.sublist(3).join(', ') : '');
    _otherDetailsController = TextEditingController(text: addressParts.length > 4 ? addressParts.sublist(4).join(', ') : '');
  }

  @override
  void dispose() {
    _streetController.dispose();
    _numberController.dispose();
    _blockController.dispose();
    _cityController.dispose();
    _otherDetailsController.dispose();
    super.dispose();
  }

  void _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      String newAddress = "${_streetController.text},${_numberController.text},${_blockController.text},${_cityController.text}";
      List<String> allAddresses = prefs.getStringList('savedAddresses') ?? [];
      int index = allAddresses.indexOf(widget.address);
      if (index != -1) {
        allAddresses[index] = newAddress;
      } else {
        allAddresses.add(newAddress);
      }

      await prefs.setStringList('savedAddresses', allAddresses);
      Provider.of<DeliveryInfo>(context, listen: false).setSelectedAddress(newAddress);
      Navigator.pop(context);
    }
  }

  void _deleteAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> allAddresses = prefs.getStringList('savedAddresses') ?? [];
    allAddresses.remove(widget.address);
    await prefs.setStringList('savedAddresses', allAddresses);
    Provider.of<DeliveryInfo>(context, listen: false).setSelectedAddress(null);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Address'),
        leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context), // Close the page
          ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _streetController,
              decoration: InputDecoration(labelText: 'Strada', border: OutlineInputBorder()),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the street.';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _numberController,
              decoration: InputDecoration(labelText: 'Număr', border: OutlineInputBorder()),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the number.';
                }
                return null;
              },
            ),
             SizedBox(height: 16),
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(labelText: 'Bloc, scara, apartament, etaj', border: OutlineInputBorder()),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the number.';
                }
                return null;
              },
            ),
             SizedBox(height: 16),
            TextFormField(
              controller: _blockController,
              decoration: InputDecoration(labelText: 'Oras/Localitate', border: OutlineInputBorder()),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the number.';
                }
                return null;
              },
            ),
            // Repeat TextFormFields for city, county, and otherDetails
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveAddress,
              child: Text('FINALIZAT'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            ElevatedButton(
              onPressed: _deleteAddress,
              child: Text('ȘTERGE ADRESA'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
