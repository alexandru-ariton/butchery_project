import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pagina_card.dart'; // Asigurați-vă că ați creat această pagină pentru introducerea datelor cardului
import 'package:encrypt/encrypt.dart' as encrypt;

class SelectCardPage extends StatefulWidget {
  @override
  _SelectCardPageState createState() => _SelectCardPageState();
}

class _SelectCardPageState extends State<SelectCardPage> {
  List<DocumentSnapshot> _cards = [];
  String? _selectedCardId;
  final _encryptionKey = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1'); // Cheie de criptare

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
      if (cardData.containsKey('iv')) {
        try {
          final encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey, mode: encrypt.AESMode.cbc));
          final iv = encrypt.IV.fromBase64(cardData['iv']); // Folosim IV-ul stocat pentru decriptare
          print('IV used for decryption: ${iv.base64}'); // Debug: print IV
          final decryptedCardNumber = encrypter.decrypt64(cardData['cardNumber'], iv: iv);
          Navigator.of(context).pop({
            'cardId': _selectedCardId,
            'last4': decryptedCardNumber.substring(decryptedCardNumber.length - 4),
            'cardNumber': cardData['cardNumber'],
            'expiryDate': cardData['expiryDate'],
            'cvv': cardData['cvv'],
            'iv': cardData['iv'], // Returnăm și IV-ul pentru a-l folosi ulterior
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to decrypt card details: $e")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("IV not found for the selected card")),
        );
      }
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
              child: _cards.isEmpty
                  ? Center(child: Text('Nu aveți carduri adăugate.'))
                  : ListView.builder(
                      itemCount: _cards.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot card = _cards[index];
                        String last4 = 'XXXX'; // Default value
                        final Map<String, dynamic> cardData = card.data() as Map<String, dynamic>;
                        if (cardData.containsKey('iv')) {
                          try {
                            final encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey, mode: encrypt.AESMode.cbc));
                            final iv = encrypt.IV.fromBase64(cardData['iv']);
                            print('IV used for decryption: ${iv.base64}'); // Debug: print IV
                            final decryptedCardNumber = encrypter.decrypt64(cardData['cardNumber'], iv: iv);
                            last4 = decryptedCardNumber.substring(decryptedCardNumber.length - 4);
                          } catch (e) {
                            // Handle decryption error, but continue
                          }
                        }
                        return Card(
                          elevation: 2,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text('Card ${index + 1}'),
                            subtitle: Text('Ultimele 4 cifre: $last4'),
                            trailing: Radio<String>(
                              value: card.id,
                              groupValue: _selectedCardId,
                              onChanged: _selectCard,
                            ),
                            onTap: () {
                              _selectCard(card.id);
                            },
                          ),
                        );
                      },
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
                children: [
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
                children: [
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
