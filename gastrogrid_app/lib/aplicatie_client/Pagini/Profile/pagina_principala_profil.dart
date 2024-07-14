// Importă pachetul Firestore pentru interacțiunea cu baza de date Firebase.
import 'package:cloud_firestore/cloud_firestore.dart';

// Importă pachetul principal pentru construirea interfeței de utilizator în Flutter.
import 'package:flutter/material.dart';

// Importă pachetul Firebase Auth pentru autentificarea utilizatorilor.
import 'package:firebase_auth/firebase_auth.dart';

// Importă pagina de selecție a cardurilor.
import 'package:gastrogrid_app/aplicatie_client/Pagini/Card/Select%20Card/pagina_select_card.dart';

// Importă pagina de gestionare a adreselor salvate.
import 'package:gastrogrid_app/aplicatie_client/Pagini/Profile/pagini/Adrese/pagina_adrese.dart';

// Importă pagina de editare a profilului.
import 'package:gastrogrid_app/aplicatie_client/Pagini/Profile/pagini/Editare%20Profil/pagina_editare_profil.dart';

// Importă pagina de setări.
import 'package:gastrogrid_app/aplicatie_client/Pagini/Profile/pagini/pagina_setari.dart';

// Importă componentele personalizate pentru profil.
import 'package:gastrogrid_app/aplicatie_client/Pagini/Profile/componente/profil.dart';

// Importă provider-ul de autentificare personalizat.
import 'package:gastrogrid_app/providers/provider_autentificare.dart' as customAuth;

// Importă provider-ul pentru gestionarea temelor.
import 'package:gastrogrid_app/providers/provider_themes.dart';

// Importă provider-ul pentru gestionarea stării.
import 'package:provider/provider.dart';

// Declarația unei clase Flutter pentru widget-ul ProfilePage, care controlează afișarea paginii de profil.
class ProfilePage extends StatefulWidget {
  // Constructorul widgetului ProfilePage.
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

// Declarația unei clase de stare pentru widget-ul ProfilePage.
class _ProfilePageState extends State<ProfilePage> {
  // Declarație pentru URL-ul pozei de profil.
  String? _photoUrl;

  // Declarație pentru ID-ul utilizatorului.
  String? _userId;

  // Declarație pentru numele de utilizator.
  String? _username;

  // Metodă care inițializează starea widgetului. Se apelează când widgetul este creat.
  @override
  void initState() {
    super.initState();
    _loadProfileInfo(); // Încarcă informațiile de profil.
  }

  // Metodă asincronă pentru încărcarea informațiilor de profil ale utilizatorului.
  Future<void> _loadProfileInfo() async {
    // Obține utilizatorul curent autentificat.
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;

      // Obține documentul utilizatorului din Firestore.
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(_userId).get();
      setState(() {
        // Verifică dacă documentul utilizatorului există și are date.
        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data() as Map<String, dynamic>;
          // Setează numele de utilizator și URL-ul pozei de profil.
          _username = data['username'] ?? 'Nume utilizator';
          _photoUrl = data['photoUrl']; // Actualizăm _photoUrl din Firestore
        } else {
          // Setează valori implicite dacă documentul nu există.
          _username = 'Nume utilizator';
          _photoUrl = user.photoURL; // Dacă nu există în Firestore, încercăm din Firebase Auth
        }
      });
    }
  }

  // Metodă care construiește interfața de utilizator a widgetului.
  @override
  Widget build(BuildContext context) {
    // Obține instanța provider-ului de teme.
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      // Setează culoarea de fundal a paginii.
      backgroundColor: themeProvider.themeData.colorScheme.surface,
      // Widget pentru a asigura că conținutul este afișat în zona sigură a ecranului.
      body: SafeArea(
        child: Column(
          children: [
            // Adaugă spațiu vertical.
            SizedBox(height: 20),
            // Widget pentru afișarea pozei de profil.
            CircleAvatar(
              radius: 50,
              backgroundColor: themeProvider.themeData.colorScheme.primary.withOpacity(0.2),
              // Setează imaginea de fundal a pozei de profil.
              backgroundImage: _photoUrl != null ? NetworkImage(_photoUrl!) : null,
              // Afișează o pictogramă implicită dacă nu există o poză de profil.
              child: _photoUrl == null
                  ? Icon(Icons.person, size: 50, color: themeProvider.themeData.colorScheme.primary)
                  : null,
            ),
            // Adaugă spațiu vertical.
            SizedBox(height: 10),
            // Text pentru afișarea numelui de utilizator.
            Text(
              _username ?? 'Nume utilizator',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeProvider.themeData.colorScheme.onSurface,
              ),
            ),
            // Adaugă spațiu vertical.
            SizedBox(height: 20),
            // Expanded pentru a umple restul ecranului.
            Expanded(
              // ListView pentru a afișa opțiunile de profil.
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Opțiune de profil pentru editarea profilului.
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
                          content: Text('User ID nu a putut fi gasit'),
                        ));
                      }
                    },
                  ),
                  // Opțiune de profil pentru gestionarea adreselor.
                  ProfileOption(
                    icon: Icons.location_on,
                    text: 'Adresele mele',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SavedAddressesPage(source: 'Profile'),
                        ),
                      );
                    },
                  ),
                  // Opțiune de profil pentru setări.
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
                  // Opțiune de profil pentru gestionarea cardurilor.
                  ProfileOption(
                    icon: Icons.payment_rounded,
                    text: 'Carduri',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectCardPage(),
                        ),
                      );
                    },
                  ),
                  // Opțiune de profil pentru deconectare.
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
