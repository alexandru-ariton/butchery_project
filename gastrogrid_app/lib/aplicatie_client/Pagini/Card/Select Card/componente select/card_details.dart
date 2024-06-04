import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

void decryptCardDetails(
  BuildContext context,
  Map<String, dynamic> cardData,
  encrypt.Key encryptionKey,
  String? selectedCardId,
) {
  if (cardData.containsKey('iv')) {
    try {
      final encrypter = encrypt.Encrypter(encrypt.AES(encryptionKey, mode: encrypt.AESMode.cbc));
      final iv = encrypt.IV.fromBase64(cardData['iv']);
      final decryptedCardNumber = encrypter.decrypt64(cardData['cardNumber'], iv: iv);
      Navigator.of(context).pop({
        'cardId': selectedCardId,
        'last4': decryptedCardNumber.substring(decryptedCardNumber.length - 4),
        'cardNumber': cardData['cardNumber'],
        'expiryDate': cardData['expiryDate'],
        'cvv': cardData['cvv'],
        'iv': cardData['iv'],
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
}
