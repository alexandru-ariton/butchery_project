import 'dart:convert';
import 'dart:typed_data';
import 'package:GastroGrid/aplicatie_admin/Pagini/Produs/componente%20edit/image_picker_widget.dart';
import 'package:GastroGrid/aplicatie_admin/Pagini/Produs/componente%20edit/product_actions.dart';
import 'package:GastroGrid/aplicatie_admin/Pagini/Produs/componente%20edit/product_form.dart';
import 'package:GastroGrid/aplicatie_admin/Pagini/Produs/componente%20edit/raw_material_list.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:GastroGrid/providers/provider_notificareStoc.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

class EditProductPage extends StatefulWidget {
  final String? productId;
  final String? currentTitle;
  final String? currentPrice;
  final String? currentDescription;
  final String? currentImageUrl;
  final String? currentQuantity;

  EditProductPage({
    this.productId,
    this.currentTitle,
    this.currentPrice,
    this.currentDescription,
    this.currentImageUrl,
    this.currentQuantity,
  });

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  Uint8List? _imageData;
  String? _imageName;
  bool _isLoading = false;
  final Map<String, int> _selectedRawMaterials = {};
  final Map<String, TextEditingController> _rawMaterialControllers = {};

  @override
  void initState() {
    super.initState();
    if (widget.currentTitle != null) {
      _titleController.text = widget.currentTitle!;
    }
    if (widget.currentPrice != null) {
      _priceController.text = widget.currentPrice!;
    }
    if (widget.currentDescription != null) {
      _descriptionController.text = widget.currentDescription!;
    }
    if (widget.currentQuantity != null) {
      _quantityController.text = widget.currentQuantity!;
    }
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
            _imageName = file.name;
          });
        }
      });
    });
  }

  Uint8List base64StringToUint8List(String base64String) {
    return Uint8List.fromList(base64.decode(base64String));
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate() && _selectedRawMaterials.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      bool insufficientMaterials = await checkRawMaterials(_selectedRawMaterials);
      if (insufficientMaterials) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Insufficient raw materials')));
        return;
      }

      String imageUrl = await uploadImage(widget.productId ?? '', _imageData, widget.currentImageUrl);

      int newQuantity = int.parse(_quantityController.text);
      DocumentReference productRef = await saveOrUpdateProduct(
        widget.productId,
        _titleController.text,
        double.parse(_priceController.text),
        _descriptionController.text,
        imageUrl,
        newQuantity,
        context,
      );

      await saveRawMaterials(productRef, _selectedRawMaterials);

      setState(() {
        _isLoading = false;
      });

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select at least one raw material')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    ProductForm(
                      titleController: _titleController,
                      priceController: _priceController,
                      descriptionController: _descriptionController,
                      quantityController: _quantityController,
                    ),
                    SizedBox(height: 16),
                    ImagePickerWidget(
                      imageData: _imageData,
                      imageUrl: widget.currentImageUrl,
                      onImagePicked: _pickImage,
                    ),
                    SizedBox(height: 16),
                    RawMaterialList(
                      rawMaterialControllers: _rawMaterialControllers,
                      selectedRawMaterials: _selectedRawMaterials,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saveProduct,
                      child: Text('Save Product'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.green,
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
