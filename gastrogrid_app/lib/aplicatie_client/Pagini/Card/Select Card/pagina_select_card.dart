import 'package:gastrogrid_app/aplicatie_client/Pagini/Card/Select%20Card/componente%20select/card_details.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Card/Select%20Card/componente%20select/card_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:gastrogrid_app/aplicatie_client/Pagini/Card/pagina_card.dart';

class SelectCardPage extends StatefulWidget {
  const SelectCardPage({Key? key}) : super(key: key);

  @override
  _SelectCardPageState createState() => _SelectCardPageState();
}

class _SelectCardPageState extends State<SelectCardPage> {
  List<Map<String, dynamic>> _cards = [];
  String? _selectedCardId;
  final _encryptionKey = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  void _loadCards() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('cards')
          .where('userId', isEqualTo: userId)
          .get();
      setState(() {
        _cards = querySnapshot.docs.map((doc) {
          Map<String, dynamic> cardData = doc.data() as Map<String, dynamic>;
          if (cardData.containsKey('iv')) {
            try {
              final encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey, mode: encrypt.AESMode.cbc));
              final iv = encrypt.IV.fromBase64(cardData['iv']);
              final decryptedCardNumber = encrypter.decrypt64(cardData['cardNumber'], iv: iv);
              cardData['last4'] = decryptedCardNumber.substring(decryptedCardNumber.length - 4);
              print('Decrypted card number: $decryptedCardNumber');
            } catch (e) {
              // Handle decryption error, but continue
              print('Error decrypting card number: $e');
              cardData['last4'] = 'XXXX';
            }
          }
          cardData['id'] = doc.id;
          return cardData;
        }).toList();
      });
    }
  }

  void _selectCard(String? cardId) {
    setState(() {
      _selectedCardId = cardId;
    });
  }

  void _addNewCard() async {
    final cardDetails = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CardDetailsPage(),
      ),
    );

    if (cardDetails != null && cardDetails['cardId'] != null) {
      setState(() {
        _selectedCardId = cardDetails['cardId'];
        _loadCards();
      });
    }
  }

  void _editCard(Map<String, dynamic> card) async {
    final cardDetails = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CardDetailsPage(
          cardData: card,
          cardId: card['id'],
        ),
      ),
    );

    if (cardDetails != null && cardDetails['cardId'] != null) {
      setState(() {
        _loadCards();
      });
    }
  }

  void _confirmSelection() {
    if (_selectedCardId != null) {
      Map<String, dynamic> selectedCard = _cards.firstWhere((card) => card['id'] == _selectedCardId);
      decryptCardDetails(
        context,
        selectedCard,
        _encryptionKey,
        _selectedCardId,
      );
    } else {
      Navigator.of(context).pop(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selectează un card'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: CardList(
                cards: _cards,
                encryptionKey: _encryptionKey,
                selectedCardId: _selectedCardId,
                onSelectCard: _selectCard,
                onEditCard: _editCard,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addNewCard,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add),
                  SizedBox(width: 10),
                  Text('Adaugă un card nou'),
                ],
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _confirmSelection,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check),
                  SizedBox(width: 10),
                  Text('Confirmă selecția'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
