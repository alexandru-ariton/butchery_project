// Importă pachetele necesare.
import 'package:flutter/material.dart'; // Importă pachetul Flutter Material pentru UI.
import 'package:encrypt/encrypt.dart' as encrypt; // Importă pachetul Encrypt pentru criptare/decriptare.

// Definirea unui widget stateless pentru afișarea listei de carduri.
class CardList extends StatelessWidget {
  final List<Map<String, dynamic>> cards; // Listă de carduri.
  final encrypt.Key encryptionKey; // Cheia de criptare.
  final String? selectedCardId; // ID-ul cardului selectat.
  final Function(String?) onSelectCard; // Funcție pentru selectarea cardului.
  final Function(Map<String, dynamic>) onEditCard; // Funcție pentru editarea cardului.

  const CardList({
    Key? key,
    required this.cards, // Cardurile sunt obligatorii.
    required this.encryptionKey, // Cheia de criptare este obligatorie.
    required this.selectedCardId, // ID-ul cardului selectat este obligatoriu.
    required this.onSelectCard, // Funcția pentru selectarea cardului este obligatorie.
    required this.onEditCard, // Funcția pentru editarea cardului este obligatorie.
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return cards.isEmpty // Verifică dacă lista de carduri este goală.
        ? Center(child: Text('Nu ai carduri adaugate.')) // Dacă lista este goală, afișează un mesaj.
        : ListView.builder( // Dacă lista nu este goală, construiește lista de carduri.
            itemCount: cards.length, // Numărul de elemente din listă.
            itemBuilder: (context, index) { // Construitor pentru fiecare element din listă.
              final card = cards[index]; // Obține cardul curent.
              String last4 = card['last4'] ?? 'XXXX'; // Obține ultimele 4 cifre ale cardului, sau 'XXXX' dacă nu există.

              return Card( // Construitor pentru un card UI.
                elevation: 2, // Setează elevația cardului.
                margin: EdgeInsets.symmetric(vertical: 8), // Marginile verticale ale cardului.
                child: ListTile( // Utilizează un ListTile pentru afișarea cardului.
                  title: Text('Card ${index + 1}'), // Titlul cardului, afișând numărul acestuia.
                  subtitle: Text('Ultimele 4 cifre: $last4'), // Subtitlul cardului, afișând ultimele 4 cifre.
                  trailing: Row( // Elementele din partea dreaptă a ListTile.
                    mainAxisSize: MainAxisSize.min, // Dimensiunea minimă a rândului.
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit), // Icon pentru butonul de editare.
                        onPressed: () => onEditCard(card), // Apelare funcției de editare când butonul este apăsat.
                      ),
                      Radio<String>(
                        value: card['id'], // Valoarea radio este ID-ul cardului.
                        groupValue: selectedCardId, // Valoarea grupului este ID-ul cardului selectat.
                        onChanged: onSelectCard, // Apelare funcției de selectare când radio-ul este apăsat.
                      ),
                    ],
                  ),
                  onTap: () {
                    onSelectCard(card['id']); // Apelare funcției de selectare când ListTile este apăsat.
                  },
                ),
              );
            },
          );
  }
}
