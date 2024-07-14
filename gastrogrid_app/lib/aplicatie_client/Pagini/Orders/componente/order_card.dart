// Importă biblioteca principală Flutter pentru a crea interfețe de utilizator.
import 'package:flutter/material.dart';

// Importă pachetul Firestore pentru interacțiunea cu baza de date Firebase.
import 'package:cloud_firestore/cloud_firestore.dart';

// Importă componentele pentru afișarea antetului comenzii și a elementelor comenzii.
import 'order_header.dart';
import 'order_items.dart';

// Declarația unei clase stateless pentru afișarea unui card de comandă.
class OrderCard extends StatelessWidget {
  // Declarația câmpului pentru documentul comenzii.
  final DocumentSnapshot order;

  // Constructorul clasei OrderCard.
  const OrderCard({super.key, required this.order});

  // Metodă care construiește interfața de utilizator a widgetului.
  @override
  Widget build(BuildContext context) {
    // Extrage datele comenzii din document.
    var orderData = order.data() as Map<String, dynamic>;
    // Extrage statusul preparării din datele comenzii, cu valoare implicită "Receptionata".
    String preparationStatus = orderData['preparationStatus'] ?? 'Receptionata';
    // Extrage statusul plății din datele comenzii, cu valoare implicită "Neplatit".
    String paymentStatus = orderData['paymentStatus'] ?? 'Neplatit';
    
    return Card(
      // Setează marginea cardului.
      margin: EdgeInsets.all(8),
      // Setează forma cardului.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      // Setează elevarea cardului.
      elevation: 4,
      // Setează padding-ul cardului.
      child: Padding(
        padding: EdgeInsets.all(16),
        // Construiește conținutul cardului.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Afișează antetul comenzii folosind widgetul OrderHeader.
            OrderHeader(
              orderId: order.id, 
              preparationStatus: preparationStatus, 
              paymentStatus: paymentStatus, 
              total: orderData['total']
            ),
            // Afișează un separator.
            Divider(),
            // Afișează elementele comenzii folosind widgetul OrderItems.
            OrderItems(items: orderData['items']),
          ],
        ),
      ),
    );
  }
}
