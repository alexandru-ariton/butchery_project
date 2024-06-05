import 'package:flutter/material.dart';

class ProfileForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController dobController;
  final String? gender;
  final Function(String?) onGenderChanged;
  final VoidCallback onSelectAddress;
  final VoidCallback onSelectDate;

  const ProfileForm({super.key, 
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.dobController,
    required this.gender,
    required this.onGenderChanged,
    required this.onSelectAddress,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person)),
          validator: (value) => value!.isEmpty ? 'Please enter the name' : null,
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: phoneController,
          decoration: InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone)),
          keyboardType: TextInputType.phone,
          validator: (value) => value!.isEmpty ? 'Please enter the phone number' : null,
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: addressController,
          decoration: InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.home)),
          readOnly: true,
          onTap: onSelectAddress,
          validator: (value) => value!.isEmpty ? 'Please select an address' : null,
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: dobController,
          decoration: InputDecoration(labelText: 'Date of Birth', prefixIcon: Icon(Icons.calendar_today)),
          readOnly: true,
          onTap: onSelectDate,
          validator: (value) => value!.isEmpty ? 'Please select your date of birth' : null,
        ),
        SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: gender,
          decoration: InputDecoration(labelText: 'Gender', prefixIcon: Icon(Icons.person_outline)),
          items: ['Male', 'Female', 'Other'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onGenderChanged,
          validator: (value) => value == null ? 'Please select your gender' : null,
        ),
      ],
    );
  }
}
