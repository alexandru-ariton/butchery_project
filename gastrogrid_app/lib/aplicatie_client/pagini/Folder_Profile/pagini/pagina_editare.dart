// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, use_build_context_synchronously, prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  final String username;
  final String phoneNumber;
  final String email;

  EditProfilePage({
    required this.username,
    required this.phoneNumber,
    required this.email,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.username);
    _phoneController = TextEditingController(text: widget.phoneNumber);
    _emailController = TextEditingController(text: widget.email);
  }

  _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _nameController.text);
    await prefs.setString('phoneNumber', _phoneController.text);
    await prefs.setString('email', _emailController.text);
    Navigator.pop(context, true); // Return true when saved
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editează Profilul'),
        elevation: 0,
        backgroundColor: Colors.blueGrey[900], // A more modern color
        foregroundColor: Colors.white, // Ensures the title is white
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nume',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Număr de telefon',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.green, minimumSize: Size(double.infinity, 50), // foreground (text) color
              ),
              child: Text('Salvează Modificările'),
              onPressed: _saveProfile,
            ),
          ],
        ),
      ),
    );
  }
}
