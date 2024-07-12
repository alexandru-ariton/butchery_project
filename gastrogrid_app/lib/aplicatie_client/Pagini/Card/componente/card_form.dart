import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'encryption_utils.dart';
import 'firebase_utils.dart';

class CardForm extends StatefulWidget {
  final Map<String, dynamic>? cardData;
  final String? cardId;

  const CardForm({Key? key, this.cardData, this.cardId}) : super(key: key);

  @override
  _CardFormState createState() => _CardFormState();
}

class _CardFormState extends State<CardForm> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.cardData != null) {
      final decryptedCardNumber = decrypt(widget.cardData!['cardNumber'], widget.cardData!['iv']);
      final decryptedExpiryDate = decrypt(widget.cardData!['expiryDate'], widget.cardData!['iv']);
      final decryptedCVV = decrypt(widget.cardData!['cvv'], widget.cardData!['iv']);
      
      _cardNumberController.text = decryptedCardNumber;
      _expiryDateController.text = decryptedExpiryDate;
      _cvvController.text = decryptedCVV;
    }
  }

  void _saveCardDetails() async {
    if (_formKey.currentState?.validate() ?? false) {
      final encryptionResult = encryptCardDetails(
        _cardNumberController.text,
        _expiryDateController.text,
        _cvvController.text,
      );

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userId = user.uid;
        Map<String, dynamic> cardData = {
          'userId': userId,
          'cardNumber': encryptionResult.encryptedCardNumber,
          'expiryDate': encryptionResult.encryptedExpiryDate,
          'cvv': encryptionResult.encryptedCVV,
          'iv': encryptionResult.iv,
          'timestamp': FieldValue.serverTimestamp(),
        };

        try {
          if (widget.cardId != null) {
            // Update existing card
            await FirebaseFirestore.instance.collection('cards').doc(widget.cardId).update(cardData);
          } else {
            // Add new card
            DocumentReference cardRef = await saveCardDetailsToFirestore(cardData);
            Navigator.of(context).pop({
              'cardId': cardRef.id,
              'last4': _cardNumberController.text.substring(_cardNumberController.text.length - 4),
              'cardNumber': encryptionResult.encryptedCardNumber,
              'expiryDate': encryptionResult.encryptedExpiryDate,
              'cvv': encryptionResult.encryptedCVV,
              'iv': encryptionResult.iv,
            });
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Salvarea datelor a eșuat: $e")),
          );
        }
      }
    }
  }

  String decrypt(String encryptedData, String iv) {
    final encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1'), mode: encrypt.AESMode.cbc));
    final decryptedData = encrypter.decrypt64(encryptedData, iv: encrypt.IV.fromBase64(iv));
    return decryptedData;
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _expiryDateController.text = '${picked.month.toString().padLeft(2, '0')}/${picked.year.toString().substring(2)}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
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
              if (value.length != 16 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
                return 'Numărul cardului trebuie să aibă exact 16 cifre';
              }
              return null;
            },
          ),
          _buildExpiryDateField(
            context: context,
            controller: _expiryDateController,
            labelText: 'Data expirării (MM/YY)',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Introduceți data expirării';
              }
              final parts = value.split('/');
              if (parts.length != 2) {
                return 'Data expirării trebuie să fie în formatul MM/YY';
              }
              final month = int.tryParse(parts[0]);
              final year = int.tryParse('20${parts[1]}');
              if (month == null || year == null || month < 1 || month > 12) {
                return 'Data expirării este invalidă';
              }
              final now = DateTime.now();
              final expiryDate = DateTime(year, month);
              if (expiryDate.isBefore(now)) {
                return 'Data expirării trebuie să fie în viitor';
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
                return 'Introduceți CVV-ul';
              }
              if (value.length != 3 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
                return 'CVV-ul trebuie să aibă exact 3 cifre';
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
              children: const [
                Icon(Icons.save),
                SizedBox(width: 10),
                Text('Salvează detaliile cardului'),
              ],
            ),
          ),
        ],
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
          fillColor: Theme.of(context).colorScheme.surface,
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

  Widget _buildExpiryDateField({
    required BuildContext context,
    required TextEditingController controller,
    required String labelText,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: () => _selectExpiryDate(context),
        child: AbsorbPointer(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: labelText,
              labelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            keyboardType: TextInputType.datetime,
            validator: validator,
          ),
        ),
      ),
    );
  }
}
