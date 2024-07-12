import 'package:flutter/material.dart';

class ProfileForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController dobController;
  final TextEditingController passwordController;
  final String? gender;
  final Function(String?) onGenderChanged;
  final VoidCallback onSelectDate;
  final String selectedPrefix;
  final Function(String?) onPrefixChanged;

  const ProfileForm({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.dobController,
    required this.passwordController,
    required this.gender,
    required this.onGenderChanged,
    required this.onSelectDate,
    required this.selectedPrefix,
    required this.onPrefixChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(labelText: 'Nume', prefixIcon: Icon(Icons.person)),
          validator: (value) => value!.isEmpty ? 'Introdu numele' : null,
        ),
        SizedBox(height: 16),
        Row(
          children: [
            DropdownButton<String>(
              value: selectedPrefix,
              onChanged: onPrefixChanged,
              items: <String>['+40', '+1', '+44', '+49'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Expanded(
              child: TextFormField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Telefon', prefixIcon: Icon(Icons.phone)),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Introdu numarul de telefon' : null,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: dobController,
          decoration: InputDecoration(labelText: 'Data nasterii', prefixIcon: Icon(Icons.calendar_today)),
          readOnly: true,
          onTap: onSelectDate,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Selecteaza data';
            }
            final selectedDate = DateTime.parse(value);
            final currentDate = DateTime.now();
            final minDate = DateTime(1900);
            if (selectedDate.isAfter(currentDate)) {
              return 'Data nu poate fi in viitor';
            }
            if (selectedDate.isBefore(minDate)) {
              return 'Data nu poate fi prea in trecut';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: gender != null && ['Masculin', 'Feminin', 'Neutru'].contains(gender) ? gender : null,
          decoration: InputDecoration(labelText: 'Gen', prefixIcon: Icon(Icons.person_outline)),
          items: ['Masculin', 'Feminin', 'Neutru'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onGenderChanged,
          validator: (value) => value == null ? 'Selecteaza un gen' : null,
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: passwordController,
          decoration: InputDecoration(labelText: 'Parola', prefixIcon: Icon(Icons.lock)),
          obscureText: true,
        ),
      ],
    );
  }
}
