import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'encryption_utils.dart';
import 'firebase_utils.dart';

class CardForm extends StatefulWidget {
  const CardForm({super.key});

  @override
  _CardFormState createState() => _CardFormState();
}

class _CardFormState extends State<CardForm> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();

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
          DocumentReference cardRef = await saveCardDetailsToFirestore(cardData);
          Navigator.of(context).pop({
            'cardId': cardRef.id,
            'last4': _cardNumberController.text.substring(_cardNumberController.text.length - 4),
            'cardNumber': encryptionResult.encryptedCardNumber,
            'expiryDate': encryptionResult.encryptedExpiryDate,
            'cvv': encryptionResult.encryptedCVV,
            'iv': encryptionResult.iv,
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
