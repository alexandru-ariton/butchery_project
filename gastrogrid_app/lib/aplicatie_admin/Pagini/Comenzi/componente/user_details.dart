import 'package:flutter/material.dart'; // Importă biblioteca principală Flutter pentru utilizarea widget-urilor.
import 'package:cloud_firestore/cloud_firestore.dart'; // Importă biblioteca Cloud Firestore pentru accesul la baza de date Firestore.

class UserDetails extends StatelessWidget {
  final String userId; // ID-ul utilizatorului.

  const UserDetails({super.key, required this.userId}); // Constructorul clasei, care primește ID-ul utilizatorului.

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(), // Obține documentul utilizatorului din colecția 'users' folosind ID-ul.
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text('Incarca detaliile client-ului...', style: TextStyle(fontSize: 16)); // Afișează un mesaj de încărcare dacă nu sunt date disponibile.
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>?; // Obține datele utilizatorului.
        if (userData == null) {
          return Text('Detaliile clientului nu au putut fi gasite.', style: TextStyle(fontSize: 16)); // Afișează un mesaj dacă datele utilizatorului nu au fost găsite.
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderDetailRow('Nume:', userData['username'] ?? '-'), // Afișează numele utilizatorului.
            _buildOrderDetailRow('Email:', userData['email'] ?? '-'), // Afișează email-ul utilizatorului.
            _buildOrderDetailRow('Telefon:', userData['phoneNumber'] ?? '-'), // Afișează numărul de telefon al utilizatorului.
          ],
        );
      },
    );
  }

  Widget _buildOrderDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Adaugă padding vertical de 8 pixeli.
      child: Row(
        children: [
          Text('$label ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Setează stilul textului pentru etichetă.
          Expanded(child: Text(value, style: TextStyle(fontSize: 18))), // Setează stilul textului pentru valoare și extinde pe toată lățimea disponibilă.
        ],
      ),
    );
  }
}
