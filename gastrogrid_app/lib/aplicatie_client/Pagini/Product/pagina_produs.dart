// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, prefer_const_constructors, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gastrogrid_app/providers/provider_cart.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Navigation/bara_navigare.dart';
import 'package:gastrogrid_app/aplicatie_client/clase/cart.dart';
import 'package:provider/provider.dart';
import 'package:gastrogrid_app/aplicatie_client/clase/produs.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  ProductDetailPage({required this.product});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;


  void addToCart() {
    var cartItem = CartItem(
      title: widget.product.title,
      price: widget.product.price,
      quantity: quantity, 
    );
   
    Provider.of<CartProvider>(context, listen: false).addProduct(cartItem);

   
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BaraNavigare(),
      ),
    );

   
    setState(() {
      quantity = 1;
    });
  }

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
              fit: BoxFit.fill,
              height: 300,
              width: double.infinity,
              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.error, color: Colors.red, size: 60),
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text('Failed to load image', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 60,),
            Center(
              child: Text(
                widget.product.title,
                style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 70,),
            Center(
              child: Text(
                widget.product.description,
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ),
          
          SizedBox(height: 80,),
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
                  SizedBox(width: 150,),
                  Text(
                '\$${widget.product.price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headline6?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
                ],
              ),
            ),
            SizedBox(height: 80,),
            Padding(
              padding: const EdgeInsets.only(left: 150.0),
              child: ElevatedButton(
                
                onPressed: addToCart,
                child: Text('Add to Cart'),
              ),
            ),
          ],
        ),
      ),
    );
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
