

// Importă pachetul principal pentru construirea interfeței de utilizator în Flutter.
import 'package:flutter/material.dart';

// Importă pachetul Firebase Auth pentru autentificarea utilizatorilor.
import 'package:firebase_auth/firebase_auth.dart';

// Importă pachetul Firestore pentru interacțiunea cu baza de date Firebase.
import 'package:cloud_firestore/cloud_firestore.dart';

// Declarația unei clase StatefulWidget pentru pagina de editare a adresei.
class EditAddressPage extends StatefulWidget {
  // Declarația câmpurilor pentru ID-ul adresei, strada, orașul, țara și codul poștal.
  final String addressId;
  final String street;
  final String city;
  final String country;
  final String zipCode;

  // Constructorul clasei EditAddressPage.
  const EditAddressPage({
    super.key,
    required this.addressId,
    required this.street,
    required this.city,
    required this.country,
    required this.zipCode,
  });

  @override
  _EditAddressPageState createState() => _EditAddressPageState();
}

// Declarația unei clase de stare pentru widget-ul EditAddressPage.
class _EditAddressPageState extends State<EditAddressPage> {
  // Declarația controlerelor pentru câmpurile de text.
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;
  late TextEditingController _zipCodeController;

  // Declarația unei variabile pentru ID-ul utilizatorului.
  String? userId;

  // Metodă care inițializează starea widgetului. Se apelează când widgetul este creat.
  @override
  void initState() {
    super.initState();
    // Inițializează controlerele cu valorile primite prin widget.
    _streetController = TextEditingController(text: widget.street);
    _cityController = TextEditingController(text: widget.city);
    _countryController = TextEditingController(text: widget.country);
    _zipCodeController = TextEditingController(text: widget.zipCode);
    // Inițializează utilizatorul.
    _initializeUser();
  }

  // Metodă asincronă pentru inițializarea utilizatorului.
  void _initializeUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    } else {
      // Afișează un mesaj de eroare dacă utilizatorul nu este autentificat.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Utilizatorul nu este autentificat')),
      );
    }
  }

  // Metodă pentru salvarea adresei în Firestore.
  void _saveAddress() async {
    if (userId != null && widget.addressId.isNotEmpty) {
      try {
        // Referință la documentul adresei în Firestore.
        DocumentReference docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('addresses')
            .doc(widget.addressId);
        // Actualizează documentul adresei cu noile valori.
        await docRef.update({
          'address': _streetController.text,
          'city': _cityController.text,
          'country': _countryController.text,
          'zipCode': _zipCodeController.text,
        });
        // Afișează un mesaj de succes.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Adresa a fost salvata')),
        );
        // Închide pagina și returnează true.
        Navigator.pop(context, true);
      } catch (e) {
        // Afișează un mesaj de eroare dacă salvarea adresei eșuează.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eroare la salvarea adresei: $e')),
        );
      }
    } else {
      // Afișează un mesaj de eroare dacă ID-ul utilizatorului sau adresei lipsește.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ID sau Address ID lipseste')),
      );
    }
  }

  // Metodă pentru ștergerea adresei din Firestore.
  void _removeAddress() async {
    if (userId != null && widget.addressId.isNotEmpty) {
      try {
        // Referință la documentul adresei în Firestore.
        DocumentReference docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('addresses')
            .doc(widget.addressId);
        // Șterge documentul adresei.
        await docRef.delete();
        // Afișează un mesaj de succes.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Adresa a fost stearsa')),
        );
        // Închide pagina și returnează true.
        Navigator.pop(context, true);
      } catch (e) {
        // Afișează un mesaj de eroare dacă ștergerea adresei eșuează.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eroare la stergerea adresei: $e')),
        );
      }
    } else {
      // Afișează un mesaj de eroare dacă ID-ul utilizatorului sau adresei lipsește.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ID sau Address ID lipseste')),
      );
    }
  }

  // Metodă care eliberează resursele controlerelor când widgetul este distrus.
  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  // Metodă care construiește interfața de utilizator a widgetului.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar pentru afișarea titlului paginii.
      appBar: AppBar(
        title: Text('Editează adresa'),
      ),
      // Padding pentru adăugarea spațiului în jurul formularului.
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Column pentru organizarea câmpurilor de text și a butoanelor.
        child: Column(
          children: [
            // Câmp de text pentru strada.
            TextField(
              controller: _streetController,
              decoration: InputDecoration(labelText: 'Strada'),
            ),
            SizedBox(height: 10),
            // Câmp de text pentru oraș.
            TextField(
              controller: _cityController,
              decoration: InputDecoration(labelText: 'Oras'),
            ),
            SizedBox(height: 10),
            // Câmp de text pentru țară.
            TextField(
              controller: _countryController,
              decoration: InputDecoration(labelText: 'Tara'),
            ),
            SizedBox(height: 10),
            // Câmp de text pentru cod poștal.
            TextField(
              controller: _zipCodeController,
              decoration: InputDecoration(labelText: 'Cod postal'),
            ),
            SizedBox(height: 20),
            // Row pentru organizarea butoanelor de salvare și ștergere.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Buton pentru salvarea adresei.
                ElevatedButton(
                  onPressed: _saveAddress,
                  child: Text('Salveaza'),
                ),
                // Buton pentru ștergerea adresei.
                ElevatedButton(
                  onPressed: _removeAddress,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text('Sterge'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
