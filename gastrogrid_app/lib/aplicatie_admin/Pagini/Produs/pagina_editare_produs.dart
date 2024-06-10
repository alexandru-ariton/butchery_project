import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gastrogrid_app/aplicatie_admin/Pagini/Produs/componente%20edit/lista_furnizori.dart';
import 'package:gastrogrid_app/providers/provider_notificareStoc.dart';
import 'package:universal_html/html.dart' as html;
import 'package:gastrogrid_app/aplicatie_admin/Pagini/Produs/componente%20edit/image_picker_widget.dart';
import 'package:gastrogrid_app/aplicatie_admin/Pagini/Produs/componente%20edit/product_form.dart';

class EditProductPage extends StatefulWidget {
  final String? productId;
  final String? currentTitle;
  final String? currentPrice;
  final String? currentDescription;
  final String? currentImageUrl;
  final String? currentQuantity;

  const EditProductPage({
    super.key,
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
  final Map<String, Map<String, dynamic>> _selectedSuppliers = {}; // Map pentru furnizori
  final Map<String, TextEditingController> _supplierControllers = {}; // Controllere pentru furnizori

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
    _loadSelectedSuppliers();
  }

  Future<void> _loadSelectedSuppliers() async {
    if (widget.productId != null) {
      var suppliersSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .collection('suppliers')
          .get();

      for (var doc in suppliersSnapshot.docs) {
        _selectedSuppliers[doc.id] = doc.data();
        _supplierControllers[doc.id] = TextEditingController(text: doc.data()['controller']);
      }
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

 Future<String> uploadImage(String productId, Uint8List? imageData, String? currentImageUrl) async {
  if (imageData == null) {
    return currentImageUrl ?? '';
  }
  
  // Create a reference to the location you want to upload the image to
  final storageRef = FirebaseStorage.instance.ref().child('product_images/$productId.jpg');

  // Upload the file to Firebase Storage
  UploadTask uploadTask = storageRef.putData(imageData);

  // Wait for the upload to complete
  TaskSnapshot snapshot = await uploadTask;

  // Get the download URL of the uploaded image
  String downloadUrl = await snapshot.ref.getDownloadURL();

  return downloadUrl;
}

 Future<DocumentReference> saveOrUpdateProduct(String? productId, String title, double price, String description, String imageUrl, int quantity, BuildContext context) async {
  if (productId == null) {
    // Add a new product
    DocumentReference newProductRef = await FirebaseFirestore.instance.collection('products').add({
      'title': title,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'quantity': quantity,
    });
    return newProductRef;
  } else {
    // Update the existing product
    DocumentReference productRef = FirebaseFirestore.instance.collection('products').doc(productId);

    // Get the current quantity from Firestore
    DocumentSnapshot productSnapshot = await productRef.get();
    int currentQuantity = productSnapshot['quantity'];

    // Add the new quantity to the existing one
    int newQuantity = currentQuantity + quantity;

    await productRef.update({
      'title': title,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'quantity': newQuantity,
    });
    return productRef;
  }
}


  Future<void> _saveSuppliers(DocumentReference productRef, Map<String, Map<String, dynamic>> selectedSuppliers) async {
    for (String supplierId in selectedSuppliers.keys) {
      await productRef.collection('suppliers').doc(supplierId).set(selectedSuppliers[supplierId]!);
    }
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate() && _selectedSuppliers.isNotEmpty) { // Verifică dacă sunt selectați furnizori
      setState(() {
        _isLoading = true;
      });

      String imageUrl = await uploadImage(widget.productId ?? '', _imageData, widget.currentImageUrl);

      int newQuantity = int.parse(_quantityController.text); // Setăm cantitatea nouă
      DocumentReference productRef = await saveOrUpdateProduct(
        widget.productId,
        _titleController.text,
        double.parse(_priceController.text),
        _descriptionController.text,
        imageUrl,
        newQuantity, // Transmitem cantitatea nouă care trebuie adăugată la cea existentă
        context,
      );

      await _saveSuppliers(productRef, _selectedSuppliers); // Salvează furnizorii selectați

      if (newQuantity < 4) {
        var supplierData = _selectedSuppliers.values.first; // Presupunem că există cel puțin un furnizor selectat
        NotificationProviderStoc().addNotification(
          'Produsul ${_titleController.text} este sub pragul minim de stoc!',
          productRef.id,
          supplierData['email'],
          _titleController.text,
        );
      } else {
        NotificationProviderStoc().removeNotification(productRef.id);
      }

      setState(() {
        _isLoading = false;
      });

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select at least one supplier')));
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
                    SupplierList(
                      supplierControllers: _supplierControllers,
                      selectedSuppliers: _selectedSuppliers,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saveProduct,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.green,
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
