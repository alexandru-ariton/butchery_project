import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:universal_html/html.dart' as html;

class EditRawMaterialPage extends StatefulWidget {
  final String? rawMaterialId;
  final String? currentName;
  final String? currentQuantity;
  final String? currentUnit;
  final String? currentImageUrl;

  EditRawMaterialPage({
    this.rawMaterialId,
    this.currentName,
    this.currentQuantity,
    this.currentUnit,
    this.currentImageUrl,
  });

  @override
  _EditRawMaterialPageState createState() => _EditRawMaterialPageState();
}

class _EditRawMaterialPageState extends State<EditRawMaterialPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  Uint8List? _imageData;
  String? _imageName;
  String? _selectedUnit;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.currentName != null) {
      _nameController.text = widget.currentName!;
    }
    if (widget.currentQuantity != null) {
      _quantityController.text = widget.currentQuantity!;
    }
    _selectedUnit = widget.currentUnit ?? 'kg'; // Default unit
  }

  Future<void> _pickImage() async {
    final html.FileUploadInputElement input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();
    input.onChange.listen((event) {
      final file = input.files!.first;
      final reader = html.FileReader();
      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((event) {
        if (reader.result is String) {
          setState(() {
            final result = reader.result as String;
            _imageData = _base64StringToUint8List(result.split(',').last);
            _imageName = file.name;
          });
        }
      });
    });
  }

  Uint8List _base64StringToUint8List(String base64String) {
    return Uint8List.fromList(base64.decode(base64String));
  }

  Future<String> _uploadImage(String rawMaterialId) async {
    if (_imageData != null) {
      final storageReference = FirebaseStorage.instance
          .ref()
          .child('rawMaterial_images/$rawMaterialId');
      await storageReference.putData(_imageData!);
      return await storageReference.getDownloadURL();
    }
    return widget.currentImageUrl ?? '';
  }

  void _saveRawMaterial() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String imageUrl = await _uploadImage(widget.rawMaterialId ?? '');

      int newQuantity = int.parse(_quantityController.text);

      if (widget.rawMaterialId == null) {
        // Add new raw material
        await FirebaseFirestore.instance.collection('rawMaterials').add({
          'name': _nameController.text,
          'quantity': newQuantity,
          'unit': _selectedUnit,
          'imageUrl': imageUrl,
        });
      } else {
        // Update existing raw material
        await FirebaseFirestore.instance.collection('rawMaterials').doc(widget.rawMaterialId).update({
          'name': _nameController.text,
          'quantity': newQuantity,
          'unit': _selectedUnit,
          'imageUrl': imageUrl,
        });
      }

      setState(() {
        _isLoading = false;
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Raw Material'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
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
                            controller: _quantityController,
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
                          value: _selectedUnit,
                          items: <String>['kg', 'litrii'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedUnit = newValue!;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    _imageData != null
                        ? Image.memory(_imageData!, height: 150)
                        : widget.currentImageUrl != null
                            ? Image.network(widget.currentImageUrl!, height: 150, errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 150,
                                  color: Colors.grey[200],
                                  child: Center(child: Text('Failed to load image')),
                                );
                              }, loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              })
                            : Container(
                                height: 150,
                                color: Colors.grey[200],
                                child: Center(child: Text('No Image')),
                              ),
                    SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(Icons.image),
                      label: Text('Change Image'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blueGrey[900],
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saveRawMaterial,
                      child: Text('Save Raw Material'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, 
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
