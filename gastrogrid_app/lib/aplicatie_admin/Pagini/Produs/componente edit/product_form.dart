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
            labelText: 'Product Title',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[200],
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a product title';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: priceController,
          decoration: InputDecoration(
            labelText: 'Product Price',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[200],
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a product price';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: descriptionController,
          decoration: InputDecoration(
            labelText: 'Product Description',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[200],
          ),
          maxLines: 4,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a product description';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: quantityController,
          decoration: InputDecoration(
            labelText: 'Product Quantity',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[200],
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a product quantity';
            }
            if (int.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
      ],
    );
  }
}
