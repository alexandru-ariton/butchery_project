// ignore_for_file: unused_field

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gastrogrid_app/providers/pagina_notificare_stoc.dart';
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

  Future<String> _uploadImage(String productId) async {
    if (_imageData != null) {
      final storageReference = FirebaseStorage.instance
          .ref()
          .child('product_images/$productId');
      await storageReference.putData(_imageData!);
      return await storageReference.getDownloadURL();
    }
    return widget.currentImageUrl ?? '';
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String imageUrl = await _uploadImage(widget.productId ?? '');

      int newQuantity = int.parse(_quantityController.text);

      if (widget.productId == null) {
        // Add new product
        await FirebaseFirestore.instance.collection('products').add({
          'title': _titleController.text,
          'price': double.parse(_priceController.text),
          'description': _descriptionController.text,
          'imageUrl': imageUrl,
          'quantity': newQuantity,
        });
      } else {
        // Update existing product
        await FirebaseFirestore.instance.collection('products').doc(widget.productId).update({
          'title': _titleController.text,
          'price': double.parse(_priceController.text),
          'description': _descriptionController.text,
          'imageUrl': imageUrl,
          'quantity': newQuantity,
        });

        // Șterge notificările dacă stocul este suficient
        if (newQuantity > 0) {
          Provider.of<NotificationProviderStoc>(context, listen: false).removeNotification(widget.productId!);
        }
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
        title: Text('Edit Product'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Product Title',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a product title';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Product Price',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a product price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Product Description',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a product description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Product Quantity',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a product quantity';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    _imageData != null
                        ? Image.memory(_imageData!)
                        : widget.currentImageUrl != null
                            ? Image.network(widget.currentImageUrl!)
                            : Container(height: 200, color: Colors.grey[200], child: Center(child: Text('No Image'))),
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
