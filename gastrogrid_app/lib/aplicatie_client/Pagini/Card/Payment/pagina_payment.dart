// Importă pachetele necesare.
import 'package:gastrogrid_app/aplicatie_client/Pagini/Card/Payment/componente_payment/payment_button.dart'; // Importă componenta PaymentButton.
import 'package:flutter/material.dart'; // Importă pachetul Flutter Material pentru UI.

// Definirea unei clase StatelessWidget pentru pagina de plată.
class PaymentPage extends StatelessWidget {
  final Map<String, dynamic> cardDetails; // Detaliile cardului.
  final double amount; // Suma de plată.
  final String orderId; // ID-ul comenzii.

  // Constructorul clasei PaymentPage.
  const PaymentPage({super.key, required this.cardDetails, required this.amount, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Scaffold oferă o structură de bază pentru pagină.
      appBar: AppBar( // Bara de aplicație de sus.
        title: Text('Plata'), // Titlul barei de aplicație.
        automaticallyImplyLeading: true,
      ),
      body: Padding( // Padding adaugă spațiu în jurul conținutului.
        padding: const EdgeInsets.all(16.0),
        child: Center( // Center aliniază conținutul la mijlocul paginii.
          child: Card( // Card creează o zonă ridicată pentru conținut.
            elevation: 4, // Setează umbra cardului.
            shape: RoundedRectangleBorder( // Setează forma cardului.
              borderRadius: BorderRadius.circular(15), // Setează colțurile rotunjite ale cardului.
            ),
            child: Padding( // Padding adaugă spațiu în jurul conținutului cardului.
              padding: const EdgeInsets.all(20.0),
              child: Column( // Column aranjează widget-urile pe verticală.
                mainAxisSize: MainAxisSize.min, // Setează dimensiunea coloanei să fie minimă.
                children: <Widget>[
                  Text(
                    'Plateste ${amount.toStringAsFixed(2)} lei cu cardul', // Afișează suma de plată.
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20), // Adaugă un spațiu vertical de 20 de pixeli.
                  Text(
                    'Card: **** **** **** ${cardDetails['last4']}', // Afișează ultimele 4 cifre ale cardului.
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 40), // Adaugă un spațiu vertical de 40 de pixeli.
                  PaymentButton( // Adaugă butonul de plată.
                    amount: amount, // Transmite suma de plată către buton.
                    orderId: orderId, // Transmite ID-ul comenzii către buton.
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
