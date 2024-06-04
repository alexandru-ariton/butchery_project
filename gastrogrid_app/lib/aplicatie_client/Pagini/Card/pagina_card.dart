import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class CardDetailsPage extends StatefulWidget {
  @override
  _CardDetailsPageState createState() => _CardDetailsPageState();
}

class _CardDetailsPageState extends State<CardDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();

  final _encryptionKey = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1'); // Cheie de criptare

  void _saveCardDetails() async {
    if (_formKey.currentState?.validate() ?? false) {
      final encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey, mode: encrypt.AESMode.cbc));
      final iv = encrypt.IV.fromLength(16);

      final encryptedCardNumber = encrypter.encrypt(_cardNumberController.text, iv: iv);
      final encryptedExpiryDate = encrypter.encrypt(_expiryDateController.text, iv: iv);
      final encryptedCVV = encrypter.encrypt(_cvvController.text, iv: iv);

      print('IV used for encryption: ${iv.base64}'); // Debug: print IV

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userId = user.uid;
        CollectionReference cards = FirebaseFirestore.instance.collection('cards');

        Map<String, dynamic> cardData = {
          'userId': userId,
          'cardNumber': encryptedCardNumber.base64,
          'expiryDate': encryptedExpiryDate.base64,
          'cvv': encryptedCVV.base64,
          'iv': iv.base64, // Stocăm și IV-ul
          'timestamp': FieldValue.serverTimestamp(),
        };

        try {
          DocumentReference cardRef = await cards.add(cardData);
          Navigator.of(context).pop({
            'cardId': cardRef.id,
            'last4': _cardNumberController.text.substring(_cardNumberController.text.length - 4),
            'cardNumber': encryptedCardNumber.base64,
            'expiryDate': encryptedExpiryDate.base64,
            'cvv': encryptedCVV.base64,
            'iv': iv.base64, // Returnăm și IV-ul pentru a-l folosi ulterior
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to save card details: $e")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalii card'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _cardNumberController,
                labelText: 'Numărul cardului',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Introduceți numărul cardului';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _expiryDateController,
                labelText: 'Data expirării (MM/YY)',
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Introduceți data expirării';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _cvvController,
                labelText: 'CVV',
                keyboardType: TextInputType.number,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Introduceți CVV';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveCardDetails,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save),
                    SizedBox(width: 10),
                    Text('Salvează detaliile cardului'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        keyboardType: keyboardType,
        validator: validator,
        obscureText: obscureText,
      ),
    );
  }
}
