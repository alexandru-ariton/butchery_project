import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';
import 'pagina_adrese.dart';

class EditProfilePage extends StatefulWidget {
  final String userId;

  EditProfilePage({required this.userId});

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
      SchedulerBinding.instance?.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<String?> _uploadImage() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw FirebaseAuthException(code: 'ERROR_NO_SIGNED_IN_USER', message: 'No user is signed in.');
      }

      if (_image != null) {
        final storageReference = FirebaseStorage.instance
            .ref()
            .child('profile_images/${user.uid}');
        await storageReference.putFile(_image!);
        return await storageReference.getDownloadURL();
      }
      return _photoUrl;
    } catch (e) {
      SchedulerBinding.instance?.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
      });
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw FirebaseAuthException(code: 'ERROR_NO_SIGNED_IN_USER', message: 'No user is signed in.');
        }

        String? photoUrl = await _uploadImage();
        if (photoUrl != null) {
          await user.updatePhotoURL(photoUrl);
          setState(() {
            _photoUrl = photoUrl;
          });
        }

        await FirebaseFirestore.instance.collection('users').doc(widget.userId).set({
          'username': _nameController.text,
          'phoneNumber': _phoneController.text,
          'address': _addressController.text,
          'dateOfBirth': _dobController.text,
          'gender': _gender,
          'photoUrl': photoUrl,
        }, SetOptions(merge: true));

        SchedulerBinding.instance?.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully!')));
        });

        Navigator.pop(context, true);
      } catch (e) {
        SchedulerBinding.instance?.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now())
      setState(() {
        _dobController.text = "${picked.toLocal()}".split(' ')[0];
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.blueGrey[900],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_image != null)
                Image.file(_image!)
              else if (_photoUrl != null)
                Image.network(_photoUrl!, errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.error);
                })
              else
                Icon(Icons.person, size: 100),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Change Image'),
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person)),
                validator: (value) => value!.isEmpty ? 'Please enter the name' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone)),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Please enter the phone number' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.home)),
                readOnly: true,
                onTap: () => _selectAddress(context),
                validator: (value) => value!.isEmpty ? 'Please select an address' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _dobController,
                decoration: InputDecoration(labelText: 'Date of Birth', prefixIcon: Icon(Icons.calendar_today)),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) => value!.isEmpty ? 'Please select your date of birth' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: InputDecoration(labelText: 'Gender', prefixIcon: Icon(Icons.person_outline)),
                items: ['Male', 'Female', 'Other'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _gender = newValue;
                  });
                },
                validator: (value) => value == null ? 'Please select your gender' : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveProfile,
                child: Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
