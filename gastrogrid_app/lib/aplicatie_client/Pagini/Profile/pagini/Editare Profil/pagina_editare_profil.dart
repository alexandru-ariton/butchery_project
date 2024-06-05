import 'dart:io';
import 'package:GastroGrid/aplicatie_client/Pagini/Profile/pagini/Editare%20Profil/componente%20profil/image_picker_widget.dart';
import 'package:GastroGrid/aplicatie_client/Pagini/Profile/pagini/Editare%20Profil/componente%20profil/profile_actions.dart';
import 'package:GastroGrid/aplicatie_client/Pagini/Profile/pagini/Editare%20Profil/componente%20profil/profile_form.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import '../Adrese/pagina_adrese.dart';


class EditProfilePage extends StatefulWidget {
  final String userId;

  const EditProfilePage({super.key, required this.userId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _dobController;
  String? _gender;
  File? _image;
  String? _photoUrl;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _dobController = TextEditingController();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      if (userDoc.exists) {
        setState(() {
          _nameController.text = userDoc['username'] ?? '';
          _phoneController.text = userDoc['phoneNumber'] ?? '';
          _addressController.text = userDoc['address'] ?? '';
          _dobController.text = userDoc['dateOfBirth'] ?? '';
          _gender = userDoc['gender'];
          _photoUrl = userDoc['photoUrl'];
        });
      }
    } catch (e) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ImagePickerWidget(
                image: _image,
                photoUrl: _photoUrl,
                onImagePicked: (pickedFile) {
                  setState(() {
                    if (pickedFile != null) {
                      _image = File(pickedFile.path);
                    }
                  });
                },
              ),
              ProfileForm(
                nameController: _nameController,
                phoneController: _phoneController,
                addressController: _addressController,
                dobController: _dobController,
                gender: _gender,
                onGenderChanged: (newGender) {
                  setState(() {
                    _gender = newGender;
                  });
                },
                onSelectAddress: () => _selectAddress(context),
                onSelectDate: () => _selectDate(context),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => saveProfile(
                  context,
                  _formKey,
                  widget.userId,
                  _nameController,
                  _phoneController,
                  _addressController,
                  _dobController,
                  _gender,
                  _image,
                  _photoUrl,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dobController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectAddress(BuildContext context) async {
    final selectedAddress = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SavedAddressesPage()),
    );
    if (selectedAddress != null) {
      setState(() {
        _addressController.text = selectedAddress;
      });
    }
  }
}
