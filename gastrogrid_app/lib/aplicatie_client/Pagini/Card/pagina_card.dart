// Importă pachetele necesare.
import 'package:flutter/material.dart'; // Importă pachetul Flutter Material pentru UI.
import 'package:gastrogrid_app/aplicatie_client/Pagini/Card/componente/card_form.dart'; // Importă widget-ul CardForm.


// Declarația unui widget Stateful pentru gestionarea detaliilor cardului.
class CardDetailsPage extends StatefulWidget {
  final Map<String, dynamic>? cardData; // Variabilă finală pentru a stoca datele cardului (opțional).
  final String? cardId; // Variabilă finală pentru a stoca ID-ul cardului (opțional).

  // Constructorul widget-ului.
  const CardDetailsPage({Key? key, this.cardData, this.cardId}) : super(key: key);

  @override
  _CardDetailsPageState createState() => _CardDetailsPageState(); // Creează starea asociată widget-ului.
}

// Clasa de stare asociată widget-ului CardDetailsPage.
class _CardDetailsPageState extends State<CardDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cardId != null ? 'Editeaza card' : 'Adauga card'), // Titlul AppBar-ului este determinat în funcție de existența unui cardId.
      ),
      body: SingleChildScrollView( // Corpul paginii este scrollabil.
        padding: EdgeInsets.all(16.0), // Padding-ul interior al SingleChildScrollView.
        child: CardForm( // Include widget-ul CardForm în corpul paginii.
          cardData: widget.cardData, // Transmite datele cardului către CardForm.
          cardId: widget.cardId, // Transmite ID-ul cardului către CardForm.
        ),
      ),
    );
  }
}
