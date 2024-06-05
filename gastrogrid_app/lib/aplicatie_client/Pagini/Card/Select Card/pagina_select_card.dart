import 'package:GastroGrid/aplicatie_client/Pagini/Card/Select%20Card/componente%20select/card_details.dart';
import 'package:GastroGrid/aplicatie_client/Pagini/Card/Select%20Card/componente%20select/card_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../pagina_card.dart'; // Asigurați-vă că ați creat această pagină pentru introducerea datelor cardului

class SelectCardPage extends StatefulWidget {
  const SelectCardPage({super.key});

  @override
  _SelectCardPageState createState() => _SelectCardPageState();
}

class _SelectCardPageState extends State<SelectCardPage> {
  List<DocumentSnapshot> _cards = [];
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
        _cards = querySnapshot.docs;
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

  void _confirmSelection() {
    if (_selectedCardId != null) {
      DocumentSnapshot selectedCard = _cards.firstWhere((card) => card.id == _selectedCardId);
      final Map<String, dynamic> cardData = selectedCard.data() as Map<String, dynamic>;
      decryptCardDetails(
        context,
        cardData,
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
        title: Text('Selectați un card'),
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
                  Text('Adăugați un card nou'),
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
