import 'package:flutter/material.dart';

class ProductForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController priceController;
  final TextEditingController descriptionController;
  final TextEditingController quantityController;

  const ProductForm({super.key, 
    required this.titleController,
    required this.priceController,
    required this.descriptionController,
    required this.quantityController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: titleController,
          decoration: InputDecoration(
            labelText: 'Denumire Produs',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[200],
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Introdu denumirea produsului';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: priceController,
          decoration: InputDecoration(
            labelText: 'Pret',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[200],
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Introdu pretul';
            }
            if (double.tryParse(value) == null) {
              return 'Valoare invalida';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: descriptionController,
          decoration: InputDecoration(
            labelText: 'Descriere',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[200],
          ),
          maxLines: 4,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Introdu o descriere';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: quantityController,
          decoration: InputDecoration(
            labelText: 'Cantitate',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[200],
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Introdu cantitatea';
            }
            if (int.tryParse(value) == null) {
              return 'Valoare invalida';
            }
            return null;
          },
        ),
      ],
    );
  }
}
