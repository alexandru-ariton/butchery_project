import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
class Product {
  String id;
  String title;
  double price;
  String description;
  String imageUrl;

  Product({
    required this.id,
    required this.title,
    required this.price,
    this.description = '',
    this.imageUrl = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}



class ManageProductsPage extends StatefulWidget {
  @override
  _ManageProductsPageState createState() => _ManageProductsPageState();
}

class _ManageProductsPageState extends State<ManageProductsPage> {
   // Function to delete a product
       void _deleteProduct(String id) async {
    try {
      await FirebaseFirestore.instance.collection('products').doc(id).delete();
      // Optionally show a snackbar or some UI feedback that the product has been deleted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product deleted successfully')),
      );
    } catch (e) {
      // If there's an error, handle it here. For example, show a snackbar with the error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting product: $e')),
      );
    }
    // You may want to refresh the product list after deletion
  }

  // Navigate to product form and pass product details for editing
  void _editProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductFormPage(product: product),
      ),
    ).then((_) => setState(() {})); // Refresh the list after editing
  }

  // Navigate to product form for adding new product
  void _addNewProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductFormPage(product: null),
      ),
    ).then((_) => setState(() {})); // Refresh the list after adding
  }
  final CollectionReference _productsRef = FirebaseFirestore.instance.collection('products');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _productsRef.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Something went wrong"));
          }

          List<Product> products = snapshot.data?.docs.map((doc) {
            return Product(
              id: doc.id,
              title: doc['title'],
              price: doc['price'],
              description: doc['description'] ?? '',
              imageUrl: doc['imageUrl'] ?? 'https://via.placeholder.com/350',
            );
          }).toList() ?? [];

          int crossAxisCount = MediaQuery.of(context).size.width ~/ 200;
          return CustomScrollView(
    slivers: [
      SliverPadding(
        padding: EdgeInsets.all(16),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1 / 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              // Pass 'products[index]' instead of 'context' to '_buildProductItem'
              return _buildProductItem(products[index]);
            },
            childCount: products.length,
          ),
        ),
      ),
    ],
  );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewProduct,
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildProductItem(Product product) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned.fill(
            child: Image.network(
  "https://via.placeholder.com/350",
  fit: BoxFit.cover,
  height: 300,
  width: double.infinity,
  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
    // Log the error or handle it in a way suitable for your app
    print('Failed to load the image: $exception');

    // Returning a placeholder widget or an error icon
    return Center(
      child: Icon(Icons.error, color: Colors.red),
    );
  },
),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                  ),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.white),
                  onPressed: () => _editProduct(product),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.white),
                  onPressed: () => _deleteProduct(product.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddNewProductButton() {
    return FloatingActionButton(
      onPressed: _addNewProduct,
      child: Icon(
        Icons.add_circle_outline,
        color: Theme.of(context).primaryColor, // Adjust the color to fit your design
        size: 60, // Adjust the size to fit your design
      ),
    );
  }
}







class ProductFormPage extends StatefulWidget {
  final Product? product;

  ProductFormPage({this.product});

  @override
  _ProductFormPageState createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  String _imageUrl = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product?.title ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _imageUrl = widget.product?.imageUrl ?? '';
  }

 // Method to select and upload image
Future<void> _selectAndUploadImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    final File file = File(pickedFile.path);
    // Define the path in Firebase Storage
    final ref = FirebaseStorage.instance
        .ref()
        .child('product_images/${DateTime.now().toIso8601String()}.png');

    // Upload file
    await ref.putFile(file);
    // Retrieve download URL
    final url = await ref.getDownloadURL();

    // Update state with new image URL
    setState(() {
      _imageUrl = url;
    });
  } else {
    print('No image selected.');
  }
}

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final newProduct = Product(
        id: widget.product?.id ?? DateTime.now().toString(),
        title: _titleController.text,
        price: double.parse(_priceController.text),
        description: _descriptionController.text,
        imageUrl: _imageUrl,
      );

      final collection = FirebaseFirestore.instance.collection('products');
      if (widget.product != null) {
        await collection.doc(widget.product!.id).update(newProduct.toMap());
      } else {
        await collection.add(newProduct.toMap());
      }

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product != null ? 'Edit Product' : 'Add Product'),
        actions: [
          IconButton(
            icon: Icon(Icons.photo_camera),
            onPressed: _selectAndUploadImage,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide a title.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number.';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Please enter a number greater than zero.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                keyboardType: TextInputType.multiline,
                maxLines: 3,
              ),
              if (_imageUrl.isNotEmpty)
                Image.network(_imageUrl, height: 200, fit: BoxFit.cover),
              ElevatedButton(
                child: Text('Save'),
                onPressed: _saveForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}