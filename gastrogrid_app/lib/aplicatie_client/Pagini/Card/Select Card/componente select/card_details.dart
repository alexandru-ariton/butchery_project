// Importă pachetele necesare.
import 'package:flutter/material.dart'; // Importă pachetul Flutter Material pentru UI.
import 'package:encrypt/encrypt.dart' as encrypt; // Importă pachetul Encrypt pentru criptare/decriptare.

// Funcția pentru decriptarea detaliilor cardului.
void decryptCardDetails(
  BuildContext context, // Contextul build pentru interacțiuni UI.
  Map<String, dynamic> cardData, // Datele cardului care trebuie decriptate.
  encrypt.Key encryptionKey, // Cheia de criptare.
  String? selectedCardId, // ID-ul cardului selectat.
) {
  // Verifică dacă datele cardului conțin cheia 'iv'.
  if (cardData.containsKey('iv')) {
    try {
      // Creează un obiect Encrypter pentru decriptarea AES cu mod CBC.
      final encrypter = encrypt.Encrypter(encrypt.AES(encryptionKey, mode: encrypt.AESMode.cbc));
      // Obține IV-ul din datele cardului.
      final iv = encrypt.IV.fromBase64(cardData['iv']);
      // Decriptează numărul cardului.
      final decryptedCardNumber = encrypter.decrypt64(cardData['cardNumber'], iv: iv);
      // Navighează înapoi și returnează datele decriptate ale cardului.
      Navigator.of(context).pop({
        'cardId': selectedCardId,
        'last4': decryptedCardNumber.substring(decryptedCardNumber.length - 4), // Ultimele 4 cifre ale cardului.
        'cardNumber': cardData['cardNumber'], // Numărul cardului criptat.
        'expiryDate': cardData['expiryDate'], // Data expirării cardului.
        'cvv': cardData['cvv'], // CVV-ul cardului.
        'iv': cardData['iv'], // IV-ul folosit pentru decriptare.
      });
    } catch (e) {
      // Afișează un mesaj de eroare dacă decriptarea eșuează.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to decrypt card details: $e")),
      );
    }
  } else {
    // Afișează un mesaj de eroare dacă IV-ul nu este găsit.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("IV not found for the selected card")),
    );
  }
}
