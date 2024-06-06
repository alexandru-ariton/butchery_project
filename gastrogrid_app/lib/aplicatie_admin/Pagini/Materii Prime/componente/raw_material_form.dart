import 'package:flutter/material.dart';

class RawMaterialForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final String? selectedUnit;
  final ValueChanged<String?> onUnitChanged;

  const RawMaterialForm({
    super.key,
    required this.nameController,
    required this.quantityController,
    required this.selectedUnit,
    required this.onUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Denumire',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[200],
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Introdu denumirea';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
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
                  if (double.tryParse(value) == null) {
                    return 'Numarul nu este valid';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedUnit,
                decoration: InputDecoration(
                  labelText: 'Unitate de Masura',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                items: <String>['kg', 'l'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: onUnitChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
