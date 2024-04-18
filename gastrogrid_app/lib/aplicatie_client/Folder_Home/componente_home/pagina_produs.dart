// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, prefer_const_constructors, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_Home/componente_home/pagina_cart.dart';
import 'package:gastrogrid_app/aplicatie_client/bara_navigare.dart';
import 'package:provider/provider.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_Home/componente_home/produs.dart';



class ProductDetailPage extends StatefulWidget {
  final Product product;
  ProductDetailPage({required this.product});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Image.network(
              widget.product.imageUrl,
              fit: BoxFit.cover,
              height: 300,
              width: double.infinity,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.product.title,
                style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.product.description,
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '\$${widget.product.price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headline6?.copyWith(color: Theme.of(context).colorScheme.secondary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildQuantityButton(Icons.remove, () {
                    setState(() {
                      if (quantity > 1) quantity--;
                    });
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      quantity.toString(),
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  _buildQuantityButton(Icons.add, () {
                    setState(() {
                      quantity++;
                    });
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onPrimary, backgroundColor: Theme.of(context).colorScheme.primary,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: addToCart,
                child: Text('Add to Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }

   void addToCart() {
    var cartItem = CartItem(
      title: widget.product.title,
      price: widget.product.price,
      quantity: quantity, // Use the current quantity value
    );
    // Use the current quantity to add or update the cart item
    Provider.of<CartModel>(context, listen: false).addProduct(cartItem);

    // Navigate to the ShoppingCartPage without resetting the quantity
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BaraNavigare(),
      ),
    );

    // Reset the quantity to 1 for the next product detail visit
    setState(() {
      quantity = 1;
    });
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return CircleAvatar(
      backgroundColor: Colors.grey[200],
      child: IconButton(
        icon: Icon(icon, color: Theme.of(context).colorScheme.onBackground),
        onPressed: onPressed,
      ),
    );
  }
}
