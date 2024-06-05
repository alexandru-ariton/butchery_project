import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class CardList extends StatelessWidget {
  final List<DocumentSnapshot> cards;
  final encrypt.Key encryptionKey;
  final String? selectedCardId;
  final Function(String?) onSelectCard;

  const CardList({super.key, 
    required this.cards,
    required this.encryptionKey,
    required this.selectedCardId,
    required this.onSelectCard,
  });

  @override
  Widget build(BuildContext context) {
    return cards.isEmpty
        ? Center(child: Text('Nu aveți carduri adăugate.'))
        : ListView.builder(
            itemCount: cards.length,
            itemBuilder: (context, index) {
              DocumentSnapshot card = cards[index];
              String last4 = 'XXXX';
              final Map<String, dynamic> cardData = card.data() as Map<String, dynamic>;
              if (cardData.containsKey('iv')) {
                try {
                  final encrypter = encrypt.Encrypter(encrypt.AES(encryptionKey, mode: encrypt.AESMode.cbc));
                  final iv = encrypt.IV.fromBase64(cardData['iv']);
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
                    groupValue: selectedCardId,
                    onChanged: onSelectCard,
                  ),
                  onTap: () {
                    onSelectCard(card.id);
                  },
                ),
              );
            },
          );
  }
}
