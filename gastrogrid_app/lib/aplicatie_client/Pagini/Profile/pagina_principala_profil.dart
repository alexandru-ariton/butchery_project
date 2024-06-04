import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:GastroGrid/aplicatie_client/Pagini/Card/pagina_card.dart';
import 'package:GastroGrid/aplicatie_client/Pagini/Card/pagina_select_card.dart';
import 'package:GastroGrid/aplicatie_client/Pagini/Profile/pagini/pagina_adrese.dart';
import 'package:GastroGrid/aplicatie_client/Pagini/Profile/pagini/pagina_editare_profil.dart';
import 'package:GastroGrid/aplicatie_client/Pagini/Profile/pagini/pagina_setari.dart';
import 'package:GastroGrid/aplicatie_client/clase/profil.dart';
import 'package:GastroGrid/providers/provider_autentificare.dart' as customAuth;
import 'package:GastroGrid/providers/provider_themes.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _photoUrl;
  String? _userId;
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadProfileInfo();
  }

  Future<void> _loadProfileInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
      _photoUrl = user.photoURL;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(_userId).get();
      setState(() {
        _username = userDoc['username'];
      });
    }
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
              backgroundColor: themeProvider.themeData.colorScheme.primary.withOpacity(0.2),
              backgroundImage: _photoUrl != null ? NetworkImage(_photoUrl!) : null,
              child: _photoUrl == null
                  ? Icon(Icons.person, size: 50, color: themeProvider.themeData.colorScheme.primary)
                  : null,
            ),
            SizedBox(height: 10),
            Text(
              _username ?? 'N/A',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeProvider.themeData.colorScheme.onBackground,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ProfileOption(
                    icon: Icons.edit,
                    text: 'Editeaza profil',
                    onTap: () async {
                      if (_userId != null) {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(userId: _userId!),
                          ),
                        );
                        if (updated != null && updated) {
                          _loadProfileInfo();
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('User ID not found'),
                        ));
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
                    text: 'Setari',
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
                    icon: Icons.logout,
                    text: 'Logout',
                    onTap: () {
                      Provider.of<customAuth.AuthProvider>(context, listen: false).logout(context);
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
