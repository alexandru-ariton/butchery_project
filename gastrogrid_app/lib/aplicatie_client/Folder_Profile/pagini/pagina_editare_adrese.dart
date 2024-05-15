// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, prefer_is_empty, use_build_context_synchronously, prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_Home/componente_home/butoane_livrare.dart';
import 'package:gastrogrid_app/aplicatie_client/clase/info_livrare.dart';
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
    _cityController = TextEditingController(text: addressParts.length > 3 ? addressParts[3] : '');
    _otherDetailsController = TextEditingController(text: addressParts.length > 4 ? addressParts[4] : '');
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

  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String fullAddress = '${_streetController.text}, ${_numberController.text}, ${_blockController.text}, ${_cityController.text}, ${_otherDetailsController.text}';
      List<String> savedAddresses = prefs.getStringList('savedAddresses') ?? [];
      if (!savedAddresses.contains(fullAddress)) {
        savedAddresses.add(fullAddress);
        await prefs.setStringList('savedAddresses', savedAddresses);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Address saved successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Address already exists')),
        );
      }
      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedAddresses = prefs.getStringList('savedAddresses') ?? [];
    savedAddresses.remove(widget.address);
    await prefs.setStringList('savedAddresses', savedAddresses);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Address'),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _streetController,
                decoration: InputDecoration(
                  labelText: 'Strada',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
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
                decoration: InputDecoration(
                  labelText: 'Număr',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.format_list_numbered),
                ),
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
                decoration: InputDecoration(
                  labelText: 'Bloc, Scara, Apartament',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.apartment),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the block, scara, and apartment.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'Oraș',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the city.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _otherDetailsController,
                decoration: InputDecoration(
                  labelText: 'Detalii suplimentare',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveAddress,
                child: Text('Finalizat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _deleteAddress,
                child: Text('Șterge Adresa'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
