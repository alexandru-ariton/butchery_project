import 'dart:typed_data';
import 'package:GastroGrid/aplicatie_admin/Pagini/Materii%20Prime/componente/image_picker_widget.dart';
import 'package:GastroGrid/aplicatie_admin/Pagini/Materii%20Prime/componente/raw_material_actions.dart';
import 'package:GastroGrid/aplicatie_admin/Pagini/Materii%20Prime/componente/raw_material_form.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
            _imageData = base64StringToUint8List(result.split(',').last);
          });
        }
      });
    });
  }

  void _saveRawMaterial() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String imageUrl = await uploadImage(widget.rawMaterialId ?? '', _imageData, widget.currentImageUrl);

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
                    RawMaterialForm(
                      nameController: _nameController,
                      quantityController: _quantityController,
                      selectedUnit: _selectedUnit,
                      onUnitChanged: (newValue) {
                        setState(() {
                          _selectedUnit = newValue!;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    ImagePickerWidget(
                      imageData: _imageData,
                      imageUrl: widget.currentImageUrl,
                      onImagePicked: _pickImage,
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
