import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionResult {
  final String encryptedCardNumber;
  final String encryptedExpiryDate;
  final String encryptedCVV;
  final String iv;

  EncryptionResult({
    required this.encryptedCardNumber,
    required this.encryptedExpiryDate,
    required this.encryptedCVV,
    required this.iv,
  });
}

EncryptionResult encryptCardDetails(String cardNumber, String expiryDate, String cvv) {
  final encryptionKey = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1'); // Cheie de criptare
  final encrypter = encrypt.Encrypter(encrypt.AES(encryptionKey, mode: encrypt.AESMode.cbc));
  final iv = encrypt.IV.fromLength(16);

  final encryptedCardNumber = encrypter.encrypt(cardNumber, iv: iv);
  final encryptedExpiryDate = encrypter.encrypt(expiryDate, iv: iv);
  final encryptedCVV = encrypter.encrypt(cvv, iv: iv);

  return EncryptionResult(
    encryptedCardNumber: encryptedCardNumber.base64,
    encryptedExpiryDate: encryptedExpiryDate.base64,
    encryptedCVV: encryptedCVV.base64,
    iv: iv.base64,
  );
}
