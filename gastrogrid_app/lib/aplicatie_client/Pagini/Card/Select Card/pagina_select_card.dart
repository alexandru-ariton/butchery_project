// Importă pachetele necesare.
import 'package:gastrogrid_app/aplicatie_client/Pagini/Card/Select%20Card/componente%20select/card_details.dart'; // Importă widget-ul CardDetailsPage.
import 'package:gastrogrid_app/aplicatie_client/Pagini/Card/Select%20Card/componente%20select/card_list.dart'; // Importă widget-ul CardList.
import 'package:flutter/material.dart'; // Importă pachetul Flutter Material pentru UI.
import 'package:firebase_auth/firebase_auth.dart'; // Importă pachetul Firebase Auth pentru autentificare.
import 'package:cloud_firestore/cloud_firestore.dart'; // Importă pachetul Cloud Firestore pentru baze de date.
import 'package:encrypt/encrypt.dart' as encrypt; // Importă pachetul Encrypt pentru criptare/decriptare.
import 'package:gastrogrid_app/aplicatie_client/Pagini/Card/pagina_card.dart'; // Importă pagina Card pentru funcționalități suplimentare.

// Declarația unui widget Stateful pentru gestionarea selectării cardului.
class SelectCardPage extends StatefulWidget {
  const SelectCardPage({Key? key}) : super(key: key);

  @override
  _SelectCardPageState createState() => _SelectCardPageState(); // Creează starea asociată widget-ului.
}

// Clasa de stare asociată widget-ului SelectCardPage.
class _SelectCardPageState extends State<SelectCardPage> {
  List<Map<String, dynamic>> _cards = []; // Listă pentru stocarea cardurilor.
  String? _selectedCardId; // Variabilă pentru stocarea ID-ului cardului selectat.
  final _encryptionKey = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1'); // Cheia de criptare.

  @override
  void initState() {
    super.initState();
    _loadCards(); // Încarcă cardurile la inițializarea widget-ului.
  }

  // Funcția pentru încărcarea cardurilor din Firebase.
  void _loadCards() async {
    User? user = FirebaseAuth.instance.currentUser; // Obține utilizatorul curent.
    if (user != null) {
      String userId = user.uid;
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('cards')
          .where('userId', isEqualTo: userId)
          .get(); // Obține cardurile utilizatorului din Firestore.
      setState(() {
        _cards = querySnapshot.docs.map((doc) {
          Map<String, dynamic> cardData = doc.data() as Map<String, dynamic>;
          if (cardData.containsKey('iv')) {
            try {
              final encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey, mode: encrypt.AESMode.cbc));
              final iv = encrypt.IV.fromBase64(cardData['iv']);
              final decryptedCardNumber = encrypter.decrypt64(cardData['cardNumber'], iv: iv); // Decriptează numărul cardului.
              cardData['last4'] = decryptedCardNumber.substring(decryptedCardNumber.length - 4);
              print('Decrypted card number: $decryptedCardNumber');
            } catch (e) {
              // Gestionează eroarea de decriptare, dar continuă.
              print('Error decrypting card number: $e');
              cardData['last4'] = 'XXXX';
            }
          }
          cardData['id'] = doc.id; // Adaugă ID-ul documentului la datele cardului.
          return cardData;
        }).toList(); // Actualizează lista de carduri.
      });
    }
  }

  // Funcția pentru selectarea unui card.
  void _selectCard(String? cardId) {
    setState(() {
      _selectedCardId = cardId; // Actualizează ID-ul cardului selectat.
    });
  }

  // Funcția pentru adăugarea unui nou card.
  void _addNewCard() async {
    final cardDetails = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CardDetailsPage(), // Navighează la pagina de detalii card.
      ),
    );

    if (cardDetails != null && cardDetails['cardId'] != null) {
      setState(() {
        _selectedCardId = cardDetails['cardId']; // Actualizează ID-ul cardului selectat.
        _loadCards(); // Reîncarcă cardurile.
      });
    }
  }

  // Funcția pentru editarea unui card existent.
  void _editCard(Map<String, dynamic> card) async {
    final cardDetails = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CardDetailsPage(
          cardData: card, // Transmite datele cardului la pagina de detalii card.
          cardId: card['id'], // Transmite ID-ul cardului la pagina de detalii card.
        ),
      ),
    );

    if (cardDetails != null && cardDetails['cardId'] != null) {
      setState(() {
        _loadCards(); // Reîncarcă cardurile.
      });
    }
  }

  // Funcția pentru confirmarea selecției cardului.
  void _confirmSelection() {
    if (_selectedCardId != null) {
      Map<String, dynamic> selectedCard = _cards.firstWhere((card) => card['id'] == _selectedCardId);
      decryptCardDetails(
        context,
        selectedCard,
        _encryptionKey,
        _selectedCardId,
      ); // Decriptează detaliile cardului și le confirmă.
    } else {
      Navigator.of(context).pop(null); // Închide pagina fără a selecta un card.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecteaza un card'), // Setează titlul AppBar-ului.
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding pentru întregul corp.
        child: Column(
          children: [
            Expanded(
              child: CardList(
                cards: _cards, // Transmite lista de carduri la CardList.
                encryptionKey: _encryptionKey, // Transmite cheia de criptare la CardList.
                selectedCardId: _selectedCardId, // Transmite ID-ul cardului selectat la CardList.
                onSelectCard: _selectCard, // Transmite funcția pentru selectarea cardului la CardList.
                onEditCard: _editCard, // Transmite funcția pentru editarea cardului la CardList.
              ),
            ),
            SizedBox(height: 16), // Spațiu între elemente.
            ElevatedButton(
              onPressed: _addNewCard, // Funcția pentru adăugarea unui nou card.
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16), // Padding pentru buton.
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Colțuri rotunjite pentru buton.
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add),
                  SizedBox(width: 10), // Spațiu între icon și text.
                  Text('Adauga un card nou'), // Text pentru buton.
                ],
              ),
            ),
            SizedBox(height: 16), // Spațiu între elemente.
            ElevatedButton(
              onPressed: _confirmSelection, // Funcția pentru confirmarea selecției cardului.
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16), // Padding pentru buton.
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Colțuri rotunjite pentru buton.
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check),
                  SizedBox(width: 10), // Spațiu între icon și text.
                  Text('Confirma selectia'), // Text pentru buton.
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
