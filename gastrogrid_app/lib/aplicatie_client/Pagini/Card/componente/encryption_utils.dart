// Importă pachetul necesar pentru criptare.
import 'package:encrypt/encrypt.dart' as encrypt;

// Definirea unei clase pentru a ține rezultatele criptării.
class EncryptionResult {
  // Atributele clasei pentru a stoca detaliile criptate și IV-ul.
  final String encryptedCardNumber;
  final String encryptedExpiryDate;
  final String encryptedCVV;
  final String iv;

  // Constructor pentru a inițializa toate atributele clasei.
  EncryptionResult({
    required this.encryptedCardNumber,
    required this.encryptedExpiryDate,
    required this.encryptedCVV,
    required this.iv,
  });
}

// Funcție pentru criptarea detaliilor cardului.
EncryptionResult encryptCardDetails(String cardNumber, String expiryDate, String cvv) {
  // Cheia de criptare de 32 de caractere (256 biți).
  final encryptionKey = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1'); 
  
  // Inițializează encrypter-ul cu algoritmul AES și mod CBC.
  final encrypter = encrypt.Encrypter(encrypt.AES(encryptionKey, mode: encrypt.AESMode.cbc));
  
  // Vectorul de inițializare (IV) generat aleator cu lungimea de 16 octeți (128 biți).
  final iv = encrypt.IV.fromLength(16);

  // Criptează numărul cardului cu IV-ul generat.
  final encryptedCardNumber = encrypter.encrypt(cardNumber, iv: iv);
  
  // Criptează data de expirare a cardului cu același IV.
  final encryptedExpiryDate = encrypter.encrypt(expiryDate, iv: iv);
  
  // Criptează CVV-ul cardului cu același IV.
  final encryptedCVV = encrypter.encrypt(cvv, iv: iv);

  // Returnează un obiect EncryptionResult cu toate detaliile criptate și IV-ul în format Base64.
  return EncryptionResult(
    encryptedCardNumber: encryptedCardNumber.base64,
    encryptedExpiryDate: encryptedExpiryDate.base64,
    encryptedCVV: encryptedCVV.base64,
    iv: iv.base64,
  );
}
