// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gastrogrid_app/providers/provider_cart.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Navigation/bara_navigare.dart';
import 'package:gastrogrid_app/aplicatie_client/clase/cart.dart';
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
      product: widget.product,
      quantity: quantity,
    );
    Provider.of<CartProvider>(context, listen: false).addProductToCart(cartItem);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${widget.product.title} to cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: [
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.product.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.product.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.product.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    ),
              ),
            ),
            SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: [
                      _buildQuantityButton(Icons.remove, () {
                        setState(() {
                          if (quantity > 1) quantity--;
                        });
                      }),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          quantity.toString(),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      _buildQuantityButton(Icons.add, () {
                        setState(() {
                          quantity++;
                        });
                      }),
                    ],
                  ),
                  Text(
                    '\$${widget.product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.only(left: 140.0,top: 30),
              child: SizedBox(
                
                child: ElevatedButton(
                  onPressed: addToCart,
                  
                  child: Text('Add to Cart', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: IconButton(
        icon: Icon(icon, color: Theme.of(context).colorScheme.surface),
        onPressed: onPressed,
      ),
    );
  }
}
