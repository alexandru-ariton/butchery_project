// Importă componentele necesare pentru a crea carduri de comandă.
import 'package:gastrogrid_app/aplicatie_client/Pagini/Orders/componente/order_card.dart';

// Importă biblioteca principală Flutter pentru a crea interfețe de utilizator.
import 'package:flutter/material.dart';

// Importă pachetul Firestore pentru interacțiunea cu baza de date Firebase.
import 'package:cloud_firestore/cloud_firestore.dart';

// Importă pachetul Firebase Auth pentru autentificare.
import 'package:firebase_auth/firebase_auth.dart';

// Declarația unei clase stateless pentru pagina de comenzi.
class PaginaOrder extends StatelessWidget {
  // Constructorul clasei PaginaOrder.
  const PaginaOrder({super.key});

  // Metodă care construiește interfața de utilizator a widgetului.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Creează un AppBar cu titlul centrat.
      appBar: AppBar(
        title: Center(child: Text('Comenzile mele')),
      ),
      // Folosește un StreamBuilder pentru a asculta modificările stării de autentificare a utilizatorului.
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, userSnapshot) {
          // Dacă datele utilizatorului nu sunt încă disponibile, afișează un indicator de încărcare.
          if (!userSnapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          // Obține utilizatorul curent din snapshot.
          final user = userSnapshot.data;

          // Folosește un alt StreamBuilder pentru a asculta modificările colecției de comenzi din Firestore.
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .where('userId', isEqualTo: user!.uid)
                .snapshots(),
            builder: (context, orderSnapshot) {
              // Dacă datele comenzilor nu sunt încă disponibile, afișează un indicator de încărcare.
              if (!orderSnapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              // Obține documentele comenzilor din snapshot.
              var orders = orderSnapshot.data!.docs;

              // Construiește o listă de carduri de comenzi folosind ListView.builder.
              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  var order = orders[index];
                  return OrderCard(order: order);
                },
              );
            },
          );
        },
      ),
    );
  }
}
