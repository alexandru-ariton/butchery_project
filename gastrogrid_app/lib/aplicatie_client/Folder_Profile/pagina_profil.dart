import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_Profile/pagini/pagina_adrese.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_Profile/pagini/pagina_editare.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_Profile/pagini/pagina_informatii.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_Profile/pagini/pagina_setari.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_Profile/profil.dart';
import 'package:gastrogrid_app/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _username = "Utilizator Nou";
  String _phoneNumber = "0712345678";
  String _email = "utilizatornou@example.com";
  String? _photoUrl;

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
      _photoUrl = FirebaseAuth.instance.currentUser?.photoURL;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.themeData.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue[100],
              backgroundImage: _photoUrl != null ? NetworkImage(_photoUrl!) : null,
              child: _photoUrl == null
                  ? Icon(Icons.person, size: 50, color: Colors.blue[800])
                  : null,
            ),
            SizedBox(height: 10),
            Text(
              _username,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            Text(
              _phoneNumber,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
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
                          ),
                        ),
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
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SavedAddressesPage(),
                        ),
                      );
                    },
                  ),
                  ProfileOption(
                    icon: Icons.settings,
                    text: 'Setări aplicație',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaginaSetari(),
                        ),
                      );
                    },
                  ),
                  ProfileOption(
                    icon: Icons.info,
                    text: 'Informații aplicație',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaginaInformatii(),
                        ),
                      );
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