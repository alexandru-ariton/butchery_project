import 'package:flutter/material.dart';

class RawMaterialForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final String? selectedUnit;
  final ValueChanged<String?> onUnitChanged;

  const RawMaterialForm({super.key, 
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
            labelText: 'Raw Material Name',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[200],
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a raw material name';
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
                  labelText: 'Raw Material Quantity',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a raw material quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 16),
            DropdownButton<String>(
              value: selectedUnit,
              items: <String>['kg', 'litrii'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: onUnitChanged,
            ),
          ],
        ),
      ],
    );
  }
}
