// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_Profile/pagini/pagina_adrese.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_Profile/pagini/pagina_editare.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _username = "Utilizator Nou";
  String _phoneNumber = "0712345678";
  String _email = "utilizatornou@example.com";

  @override
  void initState() {
    super.initState();
    _loadProfileInfo();
  }

  Future<void> _loadProfileInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? "Utilizator Nou";
      _phoneNumber = prefs.getString('phoneNumber') ?? "0712345678";
      _email = prefs.getString('email') ?? "utilizatornou@example.com";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Schimbă culoarea de fundal
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue[100], // Schimbă culoarea de fundal a avatarului
              child: Icon(Icons.person, size: 50, color: Colors.blue[800]), // Schimbă culoarea iconiței
            ),
            SizedBox(height: 10),
            Text(
              _username,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800], // Schimbă culoarea textului
              ),
            ),
            Text(
              _phoneNumber,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800], // Schimbă culoarea textului
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  ProfileOption(
                    icon: Icons.edit,
                    text: 'Editează informații personale',
                    onTap: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditProfilePage(
                                  username: _username,
                                  phoneNumber: _phoneNumber,
                                  email: _email,
                                )),
                      );
                      if (updated != null && updated) {
                        _loadProfileInfo();
                      }
                    },
                  ),
                  ProfileOption(
                    icon: Icons.location_on,
                    text: 'Adresele mele',
                    onTap: () async {
              // Aici folosim Navigator pentru a deschide pagina de adrese
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SavedAddressesPage()),
              );
              // Reîncarcă informațiile din profil, dacă este necesar
            },
                  ),
                  ProfileOption(
                    icon: Icons.settings,
                    text: 'Setări aplicație',
                    onTap: () {
                      // Navighează către pagina de setări
                    },
                  ),
                  ProfileOption(
                    icon: Icons.info,
                    text: 'Informații aplicație',
                    onTap: () {
                      // Navighează către pagina de informații
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  ProfileOption({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue[800]),
        title: Text(text),
        trailing: Icon(Icons.chevron_right, color: Colors.blue[800]),
        onTap: onTap,
      ),
    );
  }
}
