import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Product/componente/quantity_button.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Product/componente/stock_notifications.dart';
import 'package:provider/provider.dart';
import 'package:gastrogrid_app/providers/provider_notificareStoc.dart';
import 'package:gastrogrid_app/providers/provider_cart.dart';
import 'package:gastrogrid_app/providers/provider_livrare.dart';
import 'package:gastrogrid_app/clase/clasa_cart.dart';
import 'package:gastrogrid_app/clase/clasa_produs.dart';
import 'package:intl/intl.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 100; // Initial quantity set to 100 grams
  bool isAddingToCart = false;
  String selectedUnit = 'Kilograms';

  double get price {
    if (selectedUnit == 'Grams') {
      return widget.product.price / 1000 * quantity;
    } else {
      return widget.product.price * quantity;
    }
  }

  double get quantityInStockUnits {
    if (selectedUnit == 'Grams') {
      return quantity / 1000.0; // Convert grams to kilograms for stock comparison
    } else {
      return quantity.toDouble();
    }
  }

  Future<void> addToCart() async {
    if (isAddingToCart) return;
    setState(() {
      isAddingToCart = true;
    });

    try {
      final deliveryProvider = Provider.of<DeliveryProvider>(context, listen: false);

      if (deliveryProvider.isDelivery && deliveryProvider.deliveryTime > 60) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Livrarea nu poate fi efectuată pentru această adresă.')),
        );
        return;
      }

      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product.id)
          .get();

      if (productSnapshot.exists) {
        int currentStock = (productSnapshot['quantity'] as num).toInt();
        Timestamp? expiryTimestamp = productSnapshot['expiryDate'] as Timestamp?;
        DateTime? expiryDate = expiryTimestamp?.toDate();

        if (currentStock == 0) {
          await notifyOutOfStock(context, widget.product);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Produsul este epuizat')),
          );
          return;
        }

        if (expiryDate != null && DateTime.now().isAfter(expiryDate)) {
          await notifyExpired(context, widget.product);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Produsul a expirat')),
          );
          return;
        }

        if (quantityInStockUnits > currentStock) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cantitate indisponibila')),
          );
          return;
        }

        var cartProvider = Provider.of<CartProvider>(context, listen: false);
        var existingCartItem = cartProvider.cartItems.firstWhere(
          (item) => item.product.id == widget.product.id,
          orElse: () => CartItem(product: widget.product, quantity: 0.0, unit: 'Kilograms'),
        );

        double quantityToAdd = selectedUnit == 'Grams' ? quantity / 1000.0 : quantity.toDouble();

        if (existingCartItem.quantity > 0) {
          existingCartItem.quantity += quantityToAdd;
          cartProvider.updateProductQuantity(existingCartItem, existingCartItem.quantity);
        } else {
          var cartItem = CartItem(
            product: widget.product,
            quantity: quantityToAdd,
            unit: 'Kilograms',
          );
          await cartProvider.addProductToCart(cartItem, context);
        }

        if (currentStock - quantityInStockUnits < 3) {
          await notifyLowStock(context, widget.product);
        } else {
          await Provider.of<NotificationProviderStoc>(context, listen: false)
              .removeNotification(widget.product.id);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produsul ${widget.product.title} a fost adaugat in cos')),
        );

        setState(() {
          quantity = selectedUnit == 'Grams' ? 100 : 1; // Reset quantity based on unit
        });
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
              child: DropdownButton<String>(
                value: selectedUnit,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedUnit = newValue!;
                    quantity = selectedUnit == 'Grams' ? 100 : 1; // Reset quantity based on unit
                  });
                },
                items: <String>['Kilograms', 'Grams']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: [
                      QuantityButton(
                        icon: Icons.remove,
                        onPressed: () {
                          setState(() {
                            if (selectedUnit == 'Grams' && quantity > 100) {
                              quantity -= 100;
                            } else if (selectedUnit == 'Kilograms' && quantity > 1) {
                              quantity -= 1;
                            }
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          (selectedUnit == 'Grams' ? (quantity / 1000.0).toStringAsFixed(3) : quantity.toStringAsFixed(2)),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      QuantityButton(
                        icon: Icons.add,
                        onPressed: () {
                          setState(() {
                            if (selectedUnit == 'Grams') {
                              quantity += 100;
                            } else {
                              quantity += 1;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  Text(
                    '${price.toStringAsFixed(2)} lei',
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
                  child: Text('Adauga in Cos', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
