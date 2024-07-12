import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class CardList extends StatelessWidget {
  final List<Map<String, dynamic>> cards;
  final encrypt.Key encryptionKey;
  final String? selectedCardId;
  final Function(String?) onSelectCard;
  final Function(Map<String, dynamic>) onEditCard;

  const CardList({
    Key? key,
    required this.cards,
    required this.encryptionKey,
    required this.selectedCardId,
    required this.onSelectCard,
    required this.onEditCard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return cards.isEmpty
        ? Center(child: Text('Nu ai carduri adăugate.'))
        : ListView.builder(
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              String last4 = card['last4'] ?? 'XXXX';

              return Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text('Card ${index + 1}'),
                  subtitle: Text('Ultimele 4 cifre: $last4'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => onEditCard(card),
                      ),
                      Radio<String>(
                        value: card['id'],
                        groupValue: selectedCardId,
                        onChanged: onSelectCard,
                      ),
                    ],
                  ),
                  onTap: () {
                    onSelectCard(card['id']);
                  },
                ),
              );
            },
          );
  }
}
