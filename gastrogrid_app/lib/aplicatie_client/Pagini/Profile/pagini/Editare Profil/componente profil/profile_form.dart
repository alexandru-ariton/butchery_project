// Importă pachetul principal pentru construirea interfeței de utilizator în Flutter.
import 'package:flutter/material.dart';

// Definirea unei clase stateless pentru formularul de profil.
class ProfileForm extends StatelessWidget {
  // Declarația controlerelor pentru câmpurile de text.
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController dobController;
  final TextEditingController passwordController;
  
  // Declarația unei variabile pentru gen.
  final String? gender;

  // Declarația funcțiilor de callback pentru schimbarea genului, selectarea datei și schimbarea prefixului.
  final Function(String?) onGenderChanged;
  final VoidCallback onSelectDate;
  final Function(String?) onPrefixChanged;

  // Declarația unui prefix selectat.
  final String selectedPrefix;

  // Constructorul clasei ProfileForm.
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

  // Metodă care construiește interfața de utilizator a widgetului.
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Câmp de text pentru nume.
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Nume', 
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) => value!.isEmpty ? 'Introdu numele' : null,
        ),
        SizedBox(height: 16),

        // Row pentru câmpul de text pentru telefon și dropdown pentru prefix.
        Row(
          children: [
            // Dropdown pentru selectarea prefixului de telefon.
            Expanded(
              flex: 2,
              child: InputDecorator(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.phone),
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedPrefix,
                    onChanged: onPrefixChanged,
                    items: <String>['+40', '+1', '+44', '+49'].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              flex: 5,
              // Câmp de text pentru numărul de telefon.
              child: TextFormField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Telefon',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Introdu numarul de telefon';
                  }
                  String pattern = r'^\+?[0-9]{10,15}$';
                  RegExp regExp = RegExp(pattern);
                  if (!regExp.hasMatch('$selectedPrefix${value.trim()}')) {
                    return 'Numar de telefon invalid';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        // Câmp de text pentru data nașterii.
        TextFormField(
          controller: dobController,
          decoration: InputDecoration(
            labelText: 'Data nasterii', 
            prefixIcon: Icon(Icons.calendar_today),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
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

        // Dropdown pentru selectarea genului.
        DropdownButtonFormField<String>(
          value: gender != null && ['Masculin', 'Feminin', 'Neutru'].contains(gender) ? gender : null,
          decoration: InputDecoration(
            labelText: 'Gen', 
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
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

        // Câmp de text pentru parolă.
        TextFormField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: 'Parola', 
            prefixIcon: Icon(Icons.lock),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          obscureText: true,
        ),
      ],
    );
  }
}
