import 'package:flutter/material.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Product/componente/stock_notifications.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gastrogrid_app/clase/clasa_produs.dart';
import 'package:gastrogrid_app/clase/clasa_cart.dart';
import 'package:gastrogrid_app/providers/provider_cart.dart';
import 'package:gastrogrid_app/providers/provider_livrare.dart';
import 'package:gastrogrid_app/providers/provider_notificareStoc.dart';
import 'package:intl/intl.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool isAddingToCart = false;
  String selectedUnit = 'gr';

  double get price {
    return widget.product.price;
  }

  Future<void> addToCart() async {
    if (isAddingToCart) return;
    setState(() {
      isAddingToCart = true;
    });

    try {
      final deliveryProvider = Provider.of<DeliveryProvider>(context, listen: false);

      if (deliveryProvider.isDelivery && deliveryProvider.deliveryTime == 0  || deliveryProvider.pickupTime == 0 || deliveryProvider.deliveryTime > 60 ) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Livrarea nu poate fi efectuata pentru aceasta adresa.')),
        );
        return;
      }

      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product.id)
          .get();

      if (productSnapshot.exists) {
        double currentStockKg = (productSnapshot['quantity'] as num).toDouble();
        Timestamp? expiryTimestamp = productSnapshot['expiryDate'] as Timestamp?;
        DateTime? expiryDate = expiryTimestamp?.toDate();

        if (currentStockKg == 0) {
          await notifyOutOfStock(context, widget.product);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Stoc epuizat')),
          );
          return;
        }

        if (expiryDate != null && DateTime.now().isAfter(expiryDate)) {
          await notifyExpired(context, widget.product);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Produs expirat')),
          );
          return;
        }

        var cartProvider = Provider.of<CartProvider>(context, listen: false);
        var existingCartItemKg = cartProvider.cartItems.firstWhere(
          (item) => item.product.id == widget.product.id && item.unit == 'gr',
          orElse: () => CartItem(product: widget.product, quantity: 0.0, unit: 'gr'),
        );

        double quantityToAdd = 0.1; // 0.1 kilogram

        double quantityToAddInKg = quantityToAdd;

        if (existingCartItemKg.quantity > 0) { 
          existingCartItemKg.quantity += quantityToAdd;
          cartProvider.updateProductQuantity(existingCartItemKg, existingCartItemKg.quantity);
        } else {
          var cartItem = CartItem(
            product: widget.product,
            quantity: quantityToAdd,
            unit: selectedUnit,
          );
          await cartProvider.addProductToCart(cartItem, context);
        }

        if (currentStockKg - quantityToAddInKg < 3) {
          await notifyLowStock(context, widget.product);
        } else {
          await Provider.of<NotificationProviderStoc>(context, listen: false)
              .removeNotification(widget.product.id);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produsul ${widget.product.title} a fost adaugat in cos')),
        );

        Navigator.of(context).pop(); // Navigate back to the home page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produsul nu exista')),
        );
      }
    } finally {
      setState(() {
        isAddingToCart = false;
      });
    }
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
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.product.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
              ),
            ),
            SizedBox(height: 10),
            if (widget.product.expiryDate != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Data expirare: ${DateFormat('yyyy-MM-dd').format(widget.product.expiryDate!)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.red,
                      ),
                ),
              ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                 
                  Padding(
                    padding: const EdgeInsets.only(left:100.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${(price/10).toStringAsFixed(2)} lei/$selectedUnit',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
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
                  child: Text('Adauga in cos', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
