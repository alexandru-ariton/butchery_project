import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:GastroGrid/aplicatie_admin/Pagini/pagina_notificari.dart';
import 'package:GastroGrid/providers/provider_notificareStoc.dart';
import 'package:provider/provider.dart';
import 'package:GastroGrid/providers/provider_cart.dart';
import 'package:GastroGrid/aplicatie_client/clase/cart.dart';
import 'package:GastroGrid/aplicatie_client/clase/produs.dart';


class ProductDetailPage extends StatefulWidget {
  final Product product;
  ProductDetailPage({required this.product});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;
  bool isAddingToCart = false;

  Future<void> addToCart() async {
    if (isAddingToCart) return; // Prevent multiple rapid clicks
    setState(() {
      isAddingToCart = true;
    });

    try {
      // Verifică cantitatea actuală din Firestore
      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product.id)
          .get();

      if (productSnapshot.exists) {
        int currentStock = productSnapshot['quantity'];

        if (currentStock == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Stoc Epuizat')),
          );
          notifyOutOfStock(widget.product);
          return;
        }

        if (quantity > currentStock) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cantitate indisponibilă')),
          );
          return;
        }

        var cartItem = CartItem(
          product: widget.product,
          quantity: quantity,
        );

        // Add the product to the cart
        await Provider.of<CartProvider>(context, listen: false).addProductToCart(cartItem);

        if (currentStock - quantity < 3) {
          // Notifică clientul și adminul pentru stoc redus
          notifyLowStock(widget.product);
        } else {
          // Șterge notificarea dacă stocul este suficient
          Provider.of<NotificationProviderStoc>(context, listen: false).removeNotification(widget.product.id);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added ${widget.product.title} to cart')),
        );

        // Resetăm quantity după ce am făcut toate operațiunile
        setState(() {
          quantity = 1;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produsul nu există')),
        );
      }
    } finally {
      setState(() {
        isAddingToCart = false;
      });
    }
  }

  void notifyLowStock(Product product) {
    // Notifică clientul
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Stoc redus pentru ${product.title}')),
    );

    // Notifică adminul - salvați notificarea în Firestore
    Provider.of<NotificationProviderStoc>(context, listen: false).addNotification(
      'Stoc redus pentru ${product.title}',
      product.id,
    );

    // Navighează la pagina notificărilor de stoc redus
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LowStockNotificationPage()),
    );
  }

  void notifyOutOfStock(Product product) {
    // Notifică clientul
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Stoc Epuizat pentru ${product.title}')),
    );

    // Notifică adminul - salvați notificarea în Firestore
    Provider.of<NotificationProviderStoc>(context, listen: false).addNotification(
      'Stoc Epuizat pentru ${product.title}',
      product.id,
    );

    // Navighează la pagina notificărilor de stoc epuizat
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LowStockNotificationPage()),
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
                    '${widget.product.price.toStringAsFixed(2)}\ lei',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.only(left: 140.0, top: 30),
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
