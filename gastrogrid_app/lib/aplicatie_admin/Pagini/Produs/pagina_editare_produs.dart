import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gastrogrid_app/aplicatie_admin/Pagini/Produs/componente%20edit/image_picker_widget.dart';
import 'package:universal_html/html.dart' as html;
import 'package:intl/intl.dart';

class EditProductPage extends StatefulWidget {
  final String? productId;
  final String? currentTitle;
  final String? currentPrice;
  final String? currentDescription;
  final String? currentImageUrl;
  final String? currentQuantity;
  final String? currentUnit;
  final Timestamp? currentExpiryDate;
  final String? notificationId;

  const EditProductPage({
    Key? key,
    this.productId,
    this.currentTitle,
    this.currentPrice,
    this.currentDescription,
    this.currentImageUrl,
    this.currentQuantity,
    this.currentUnit,
    this.currentExpiryDate,
    this.notificationId,
  }) : super(key: key);

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  DateTime? _selectedExpiryDate;
  Uint8List? _imageData;
  bool _isLoading = false;
  final Map<String, Map<String, dynamic>> _selectedSuppliers = {};
  final Map<String, TextEditingController> _supplierControllers = {};
  String _selectedUnit = 'kg';
  final List<String> _units = ['gr', 'kg'];

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
    if (widget.currentExpiryDate != null) {
      _selectedExpiryDate = widget.currentExpiryDate!.toDate();
      _expiryDateController.text = DateFormat('yyyy-MM-dd').format(_selectedExpiryDate!);
    }
    if (widget.currentUnit != null) {
      _selectedUnit = widget.currentUnit!;
    }
    _loadAllSuppliers();
    _loadSelectedSuppliers();
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedExpiryDate) {
      setState(() {
        _selectedExpiryDate = pickedDate;
        _expiryDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _loadAllSuppliers() async {
    try {
      var suppliersSnapshot = await FirebaseFirestore.instance.collection('suppliers').get();
      for (var doc in suppliersSnapshot.docs) {
        _selectedSuppliers[doc.id] = {'name': doc.data()['name'], 'selected': false};
        _supplierControllers[doc.id] = TextEditingController(text: doc.data()['controller']);
      }
      setState(() {});
    } catch (e) {
      print('Error loading suppliers: $e');
    }
  }

  Future<void> _loadSelectedSuppliers() async {
    try {
      if (widget.productId != null) {
        var suppliersSnapshot = await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .collection('suppliers')
            .get();

        for (var doc in suppliersSnapshot.docs) {
          if (_selectedSuppliers.containsKey(doc.id)) {
            _selectedSuppliers[doc.id]!['selected'] = true;
          }
        }
        setState(() {});
      }
    } catch (e) {
      print('Error loading selected suppliers: $e');
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
        if (reader.readyState == html.FileReader.DONE) {
          setState(() {
            final result = reader.result as String;
            print('Image Data (Base64): ${result.substring(0, 100)}'); // Debug print
            _imageData = base64.decode(result.split(',').last);
          });
        }
      });
    });
  }

  Future<String> uploadImage(String productId, Uint8List? imageData, String? currentImageUrl) async {
    if (imageData == null) {
      return currentImageUrl ?? '';
    }

    final storageRef = FirebaseStorage.instance.ref().child('product_images/$productId.jpg');
    UploadTask uploadTask = storageRef.putData(imageData);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> _saveSuppliers(DocumentReference productRef, Map<String, Map<String, dynamic>> selectedSuppliers) async {
    try {
      for (String supplierId in selectedSuppliers.keys) {
        if (selectedSuppliers[supplierId]!['selected'] == true) {
          await productRef.collection('suppliers').doc(supplierId).set({'controller': supplierId});
        } else {
          await productRef.collection('suppliers').doc(supplierId).delete();
        }
      }
    } catch (e) {
      print('Error saving suppliers: $e');
    }
  }

  Future<DocumentReference> saveOrUpdateProduct(
      String? productId,
      String title,
      double price,
      String description,
      String imageUrl,
      double newQuantity,
      DateTime expiryDate,
      String unit,
      BuildContext context) async {
    try {
      if (productId == null) {
        DocumentReference newProductRef = await FirebaseFirestore.instance.collection('products').add({
          'title': title,
          'price': price,
          'description': description,
          'imageUrl': imageUrl,
          'quantity': newQuantity,
          'unit': unit,
          'expiryDate': expiryDate,
        });
        return newProductRef;
      } else {
        DocumentReference productRef = FirebaseFirestore.instance.collection('products').doc(productId);
        DocumentSnapshot productSnapshot = await productRef.get();
        double currentQuantity = productSnapshot['quantity'];
        double updatedQuantity = currentQuantity + (unit == 'gr' ? newQuantity / 1000 : newQuantity);

        await productRef.update({
          'title': title,
          'price': price,
          'description': description,
          'imageUrl': imageUrl,
          'quantity': updatedQuantity,
          'unit': unit,
          'expiryDate': expiryDate,
        });
        return productRef;
      }
    } catch (e) {
      print('Error saving/updating product: $e');
      throw e;
    }
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String imageUrl = await uploadImage(widget.productId ?? '', _imageData, widget.currentImageUrl);
        double newQuantity = double.parse(_quantityController.text);
        DateTime expiryDate = _selectedExpiryDate!;

        DocumentReference productRef = await saveOrUpdateProduct(
          widget.productId,
          _titleController.text,
          double.parse(_priceController.text),
          _descriptionController.text,
          imageUrl,
          newQuantity,
          expiryDate,
          _selectedUnit,
          context,
        );

        await _saveSuppliers(productRef, _selectedSuppliers);

        setState(() {
          _isLoading = false;
        });

        Navigator.pop(context);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Eroare la salvarea produsului: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selecteaza cel putin un furnizor')));
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
          : Padding(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Titlu',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Introduceti titlul';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Pret',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Introduceți pretul';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Descriere',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Introduceți descrierea';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Cantitate',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Introduceti cantitatea';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _expiryDateController,
                      decoration: InputDecoration(
                        labelText: 'Data expirare (YYYY-MM-DD)',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () => _selectExpiryDate(context),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Introduceti data de expirare';
                        }
                        return null;
                      },
                      readOnly: true,
                    ),
                    SizedBox(height: 16),
                    ImagePickerWidget(
                      imageData: _imageData,
                      imageUrl: widget.currentImageUrl,
                      onImagePicked: _pickImage,
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      items: _units.map((String unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedUnit = newValue!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Unitate',
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('Furnizori:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Column(
                      children: _selectedSuppliers.keys.map((supplierId) {
                        return CheckboxListTile(
                          title: Text(_selectedSuppliers[supplierId]!['name'] ?? 'No name'),
                          value: _selectedSuppliers[supplierId]!['selected'] ?? false,
                          onChanged: (bool? value) {
                            setState(() {
                              _selectedSuppliers[supplierId]!['selected'] = value ?? false;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saveProduct,
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
    );
  }
}
