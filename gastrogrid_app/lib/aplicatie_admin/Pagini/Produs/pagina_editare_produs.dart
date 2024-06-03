import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gastrogrid_app/providers/provider_notificareStoc.dart';
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

  Future<List<Map<String, dynamic>>> _fetchRawMaterials() async {
    final rawMaterialsSnapshot = await FirebaseFirestore.instance.collection('rawMaterials').get();
    return rawMaterialsSnapshot.docs.map((doc) => {'id': doc.id, 'name': doc['name'], 'quantity': doc['quantity']}).toList();
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate() && _selectedRawMaterials.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      // Verifică dacă există suficiente materii prime
      bool insufficientMaterials = false;
      for (final entry in _selectedRawMaterials.entries) {
        final rawMaterialDoc = await FirebaseFirestore.instance.collection('rawMaterials').doc(entry.key).get();
        if (entry.value > rawMaterialDoc['quantity']) {
          insufficientMaterials = true;
          break;
        }
      }

      if (insufficientMaterials) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Insufficient raw materials')));
        return;
      }

      String imageUrl = await _uploadImage(widget.productId ?? '');

      int newQuantity = int.parse(_quantityController.text);

      DocumentReference productRef;
      DocumentSnapshot productSnapshot;

      if (widget.productId == null) {
        // Add new product
        productRef = await FirebaseFirestore.instance.collection('products').add({
          'title': _titleController.text,
          'price': double.parse(_priceController.text),
          'description': _descriptionController.text,
          'imageUrl': imageUrl,
          'quantity': newQuantity,
        });
      } else {
        // Get existing product
        productRef = FirebaseFirestore.instance.collection('products').doc(widget.productId!);
        productSnapshot = await productRef.get();
        int currentQuantity = productSnapshot['quantity'];

        // Update existing product with new quantity added to current quantity
        await productRef.update({
          'title': _titleController.text,
          'price': double.parse(_priceController.text),
          'description': _descriptionController.text,
          'imageUrl': imageUrl,
          'quantity': currentQuantity + newQuantity,
        });

        // Șterge notificările dacă stocul este suficient
        if (currentQuantity + newQuantity > 0) {
          Provider.of<NotificationProviderStoc>(context, listen: false).removeNotification(widget.productId!);
        }
      }

      // Adaugă materii prime pentru produs și actualizează cantitatea acestora
      for (final entry in _selectedRawMaterials.entries) {
        await productRef.collection('rawMaterials').add({
          'rawMaterialId': entry.key,
          'quantity': entry.value,
        });
        await FirebaseFirestore.instance.collection('rawMaterials').doc(entry.key).update({
          'quantity': FieldValue.increment(-entry.value),
        });
      }

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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.blueGrey[900],
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
                    FutureBuilder(
                      future: _fetchRawMaterials(),
                      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                        return Column(
                          children: snapshot.data!.map((rawMaterial) {
                            final controller = _rawMaterialControllers.putIfAbsent(
                              rawMaterial['id'],
                              () => TextEditingController(),
                            );
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      rawMaterial['name'],
                                      style: TextStyle(fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: TextFormField(
                                      controller: controller,
                                      decoration: InputDecoration(labelText: 'Quantity'),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        final quantity = int.tryParse(value);
                                        if (quantity != null) {
                                          _selectedRawMaterials[rawMaterial['id']] = quantity;
                                        } else {
                                          _selectedRawMaterials.remove(rawMaterial['id']);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
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
