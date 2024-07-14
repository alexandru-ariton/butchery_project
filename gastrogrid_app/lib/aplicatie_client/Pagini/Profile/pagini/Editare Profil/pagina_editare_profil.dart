// Importă biblioteca Dart pentru funcționalități legate de sistemul de fișiere.
import 'dart:io';

// Importă pachetul principal pentru construirea interfeței de utilizator în Flutter.
import 'package:flutter/material.dart';

// Importă pachetul Firestore pentru interacțiunea cu baza de date Firebase.
import 'package:cloud_firestore/cloud_firestore.dart';

// Importă pachetul Scheduler pentru a gestiona sarcinile planificate.
import 'package:flutter/scheduler.dart';

// Importă componentele personalizate pentru încărcarea imaginii, acțiunile profilului și formularul profilului.
import 'package:gastrogrid_app/aplicatie_client/Pagini/Profile/pagini/Editare%20Profil/componente%20profil/image_picker_widget.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Profile/pagini/Editare%20Profil/componente%20profil/profile_actions.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Profile/pagini/Editare%20Profil/componente%20profil/profile_form.dart';

// Importă biblioteca ImagePicker pentru a selecta imagini.
import 'package:image_picker/image_picker.dart';

// Importă pagina de adrese salvate.
import '../Adrese/pagina_adrese.dart';

// Declarația unei clase Flutter pentru widget-ul EditProfilePage, care controlează afișarea paginii de editare a profilului.
class EditProfilePage extends StatefulWidget {
  // Declarația unui câmp pentru ID-ul utilizatorului.
  final String userId;

  // Constructorul widgetului EditProfilePage.
  const EditProfilePage({super.key, required this.userId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

// Declarația unei clase de stare pentru widget-ul EditProfilePage.
class _EditProfilePageState extends State<EditProfilePage> {
  // Declarația unei chei pentru formularul de profil.
  final _formKey = GlobalKey<FormState>();

  // Declarația controlerelor pentru câmpurile de text.
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  late TextEditingController _passwordController;

  // Declarația variabilelor pentru gen, prefixul selectat, imaginea și URL-ul pozei de profil.
  String? _gender;
  String _selectedPrefix = '+40';
  File? _image;
  String? _photoUrl;

  // Instanța pentru selectarea imaginii.
  final picker = ImagePicker();

  // Metodă care inițializează starea widgetului. Se apelează când widgetul este creat.
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _dobController = TextEditingController();
    _passwordController = TextEditingController();
    _loadUserProfile(); // Încarcă informațiile de profil ale utilizatorului.
  }

  // Metodă care eliberează resursele controlerelor când widgetul este distrus.
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Metodă asincronă pentru încărcarea informațiilor de profil ale utilizatorului din Firestore.
  Future<void> _loadUserProfile() async {
    try {
      // Obține documentul utilizatorului din Firestore.
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      if (userDoc.exists) {
        setState(() {
          // Setează valorile controlerelor și variabilelor cu datele din document.
          _nameController.text = (userDoc.data() as Map<String, dynamic>)['username'] ?? 'Nume utilizator';
          _phoneController.text = (userDoc.data() as Map<String, dynamic>)['phoneNumber'] ?? '';
          _dobController.text = (userDoc.data() as Map<String, dynamic>)['dateOfBirth'] ?? '';
          _passwordController.text = (userDoc.data() as Map<String, dynamic>)['password'] ?? '';
          _gender = (userDoc.data() as Map<String, dynamic>)['gender'];
          _photoUrl = (userDoc.data() as Map<String, dynamic>)['photoUrl'];

          // Extrage prefixul și numărul de telefon.
          if (_phoneController.text.isNotEmpty) {
            var phoneParts = _phoneController.text.split(' ');
            if (phoneParts.length > 1) {
              _selectedPrefix = phoneParts[0];
              _phoneController.text = phoneParts.sublist(1).join(' ');
            }
          }
        });
      }
    } catch (e) {
      // Afișează un mesaj de eroare dacă încărcarea profilului eșuează.
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
      });
    }
  }

  // Metodă care construiește interfața de utilizator a widgetului.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar pentru afișarea titlului paginii.
      appBar: AppBar(
        title: Text('Editeaza profil'),
      ),
      // Padding pentru adăugarea spațiului în jurul formularului.
      body: Padding(
        padding: EdgeInsets.all(16.0),
        // Form pentru gestionarea validării și salvării datelor.
        child: Form(
          key: _formKey,
          // ListView pentru afișarea câmpurilor formularului.
          child: ListView(
            children: [
              // Widget personalizat pentru încărcarea imaginii.
              ImagePickerWidget(
                image: _image,
                photoUrl: _photoUrl,
                onImagePicked: (pickedFile) {
                  setState(() {
                    if (pickedFile != null) {
                      _image = File(pickedFile.path);
                    }
                  });
                },
              ),
              // Widget personalizat pentru formularul de profil.
              ProfileForm(
                nameController: _nameController,
                phoneController: _phoneController,
                dobController: _dobController,
                passwordController: _passwordController,
                gender: _gender,
                selectedPrefix: _selectedPrefix,
                onGenderChanged: (newGender) {
                  setState(() {
                    _gender = newGender;
                  });
                },
                onPrefixChanged: (newPrefix) {
                  setState(() {
                    _selectedPrefix = newPrefix!;
                  });
                },
                onSelectDate: () => _selectDate(context),
              ),
              SizedBox(height: 24),
              // Buton pentru salvarea profilului.
              ElevatedButton(
                onPressed: () => saveProfile(
                  context,
                  _formKey,
                  widget.userId,
                  _nameController,
                  _phoneController,
                  _dobController,
                  _passwordController,
                  _gender,
                  _selectedPrefix,
                  _image,
                  _photoUrl,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Salveaza'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Metodă asincronă pentru selectarea datei de naștere.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }
}
