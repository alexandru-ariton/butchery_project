// ignore_for_file: unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Card/pagina_card.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Card/pagina_select_card.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Profile/pagini/pagina_adrese.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Profile/pagini/pagina_editare.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Profile/pagini/pagina_informatii.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Profile/pagini/pagina_setari.dart';
import 'package:gastrogrid_app/aplicatie_client/clase/profil.dart';
import 'package:gastrogrid_app/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _photoUrl;
  String? _userId;
  String? _username;
  final user = FirebaseAuth.instance.currentUser;

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
              backgroundColor: Colors.blue[100],
              backgroundImage: _photoUrl != null ? NetworkImage(_photoUrl!) : null,
              child: _photoUrl == null
                  ? Icon(Icons.person, size: 50, color: Colors.blue[800])
                  : null,
            ),
            SizedBox(height: 10),
            Text(
              _username ?? 'N/A',
              style: TextStyle(
                fontSize: themeProvider.textSize,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
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
                 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}