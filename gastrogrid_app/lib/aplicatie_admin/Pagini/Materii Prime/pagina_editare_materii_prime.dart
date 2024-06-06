import 'dart:convert';
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

  const EditRawMaterialPage({
    super.key,
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

  Future<void> _saveRawMaterial() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      double newQuantity = double.parse(_quantityController.text);
      double updatedQuantity = newQuantity;

      if (widget.rawMaterialId != null) {
        // Fetch the existing raw material to get its current quantity
        DocumentSnapshot existingRawMaterial = await FirebaseFirestore.instance
            .collection('rawMaterials')
            .doc(widget.rawMaterialId)
            .get();
        if (existingRawMaterial.exists) {
          double currentQuantity = existingRawMaterial['quantity'];
          updatedQuantity += currentQuantity; // Add new quantity to the existing quantity
        }
      }

      String imageUrl = await uploadImage(widget.rawMaterialId ?? '', _imageData, widget.currentImageUrl);

      if (widget.rawMaterialId == null) {
        // Add new raw material
        await FirebaseFirestore.instance.collection('rawMaterials').add({
          'name': _nameController.text,
          'quantity': updatedQuantity,
          'unit': _selectedUnit,
        });
      } else {
        // Update existing raw material
        await FirebaseFirestore.instance.collection('rawMaterials').doc(widget.rawMaterialId).update({
          'name': _nameController.text,
          'quantity': updatedQuantity,
          'unit': _selectedUnit,
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
        title: Text('Editeaza'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(32.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Form(
                      key: _formKey,
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            ElevatedButton(
                              onPressed: _saveRawMaterial,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.green,
                                minimumSize: Size(double.infinity, 50),
                              ),
                              child: Text('Salveaza'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
