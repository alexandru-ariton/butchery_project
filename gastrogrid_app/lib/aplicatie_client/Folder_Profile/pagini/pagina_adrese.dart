// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_Home/componente_home/butoane_livrare.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedAddressesPage extends StatefulWidget {
  @override
  _SavedAddressesPageState createState() => _SavedAddressesPageState();
}

class _SavedAddressesPageState extends State<SavedAddressesPage> {
  List<String> savedAddresses = [];

  @override
  void initState() {
    super.initState();
    loadSavedAddresses();
  }

  void loadSavedAddresses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      savedAddresses = prefs.getStringList('savedAddresses') ?? [];
    });
  }
 void _handleAddressTap(String address) {
  Provider.of<DeliveryInfo>(context, listen: false).setSelectedAddress(address);
  Navigator.pop(context); // Go back
}


  Widget _buildAddressCard(String address) {
    return GestureDetector(
      onTap: () => _handleAddressTap(address),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 4,
        shadowColor: Colors.grey.withOpacity(0.5),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          title: Text(
            address,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: IconButton(
            icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
            onPressed: () {
              // Implement edit address logic
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adresele mele'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView.builder(
        itemCount: savedAddresses.length,
        itemBuilder: (context, index) {
          return _buildAddressCard(savedAddresses[index]);
        },
      ),
    );
  }
}
