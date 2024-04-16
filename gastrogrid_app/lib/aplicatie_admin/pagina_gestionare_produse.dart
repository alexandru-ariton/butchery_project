import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Product {
  final String id;
  String title;
  double price;

  Product({required this.id, required this.title, required this.price});
}

List<Product> products = [
  Product(id: 'p1', title: 'Red Shirt', price: 29.99),
  Product(id: 'p2', title: 'Blue Carpet', price: 59.99),
  // Add more products here
];

class ManageProductsPage extends StatefulWidget {
  @override
  _ManageProductsPageState createState() => _ManageProductsPageState();
}

class _ManageProductsPageState extends State<ManageProductsPage> {
   // Function to delete a product
  void _deleteProduct(String id) {
    setState(() {
      products.removeWhere((prod) => prod.id == id);
    });
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
  @override
  Widget build(BuildContext context) {
    int crossAxisCount = MediaQuery.of(context).size.width ~/ 200;
    return Scaffold(
      body: CustomScrollView(
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
                  if (index < products.length) {
                    return _buildProductItem(products[index]);
                  } else {
                    return _buildAddNewProductButton();
                  }
                },
                childCount: products.length + 1, // Add one for the "add new" button
              ),
            ),
          ),
        ],
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
              'https://via.placeholder.com/150',
              fit: BoxFit.cover,
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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product?.title ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
  }

 void _saveForm() async {
  if (_formKey.currentState!.validate()) {
    final collection = FirebaseFirestore.instance.collection('products');
    
    if (widget.product != null) {
      // Edit mode
      await collection.doc(widget.product!.id).update({
        'title': _titleController.text,
        'price': double.parse(_priceController.text),
      });
    } else {
      // Add mode
      await collection.add({
        'title': _titleController.text,
        'price': double.parse(_priceController.text),
      });
    }
    
    Navigator.pop(context);
  }
}


  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product != null ? 'Edit Product' : 'Add Product'),
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
              ElevatedButton(
                child: Text('Save'),
                onPressed: _saveForm,
              )
            ],
          ),
        ),
      ),
    );
  }
}