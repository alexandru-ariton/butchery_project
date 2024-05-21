import 'package:flutter/material.dart';
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
    _parseAddress();
  }

  void _parseAddress() {
    // Assuming the address format: "Street Name, Number, City, Country, Other Details"
    List<String> parts = widget.address.split(', ').map((e) => e.trim()).toList();
    _streetController = TextEditingController(text: parts.length > 0 ? parts[0] : '');
    _numberController = TextEditingController(text: parts.length > 1 ? parts[1] : '');
    _cityController = TextEditingController(text: parts.length > 1 ? parts[2] : '');
    _blockController = TextEditingController(text: parts.length > 3 ? parts[3] : '');  
    _otherDetailsController = TextEditingController(text: parts.length > 4 ? parts.sublist(4).join(', ') : '');
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
      String fullAddress = '${_streetController.text}, ${_numberController.text}, ${_cityController.text}, ${_blockController.text}, ${_otherDetailsController.text}';
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
      Navigator.pop(context, fullAddress);
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
                  labelText: 'Street',
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
                  labelText: 'Number',
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
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'City',
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
                controller: _blockController,
                decoration: InputDecoration(
                  labelText: 'Block, Scara, Apartment',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.apartment),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _otherDetailsController,
                decoration: InputDecoration(
                  labelText: 'Other details',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveAddress,
                child: Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _deleteAddress,
                child: Text('Delete Address'),
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
