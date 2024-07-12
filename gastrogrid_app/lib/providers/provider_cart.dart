import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Product/componente/stock_notifications.dart';
import 'package:gastrogrid_app/clase/clasa_cart.dart';
import 'package:gastrogrid_app/providers/provider_notificareStoc.dart';

class CartProvider with ChangeNotifier {
  final NotificationProviderStoc notificationProviderStoc;
  List<CartItem> _items = [];

  CartProvider(this.notificationProviderStoc);

  List<CartItem> get items => _items;

  List<CartItem> get cartItems => _items;

  Future<void> addProductToCart(CartItem cartItem, BuildContext context) async {
    DocumentSnapshot productSnapshot = await FirebaseFirestore.instance.collection('products').doc(cartItem.product.id).get();
    if (!productSnapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product does not exist in the database.')),
      );
      return;
    }
    int currentStock = (productSnapshot['quantity'] as num).toInt();

    double cartItemQuantityKg = cartItem.unit == 'Grams' ? cartItem.quantity / 1000 : cartItem.quantity;

    if (currentStock < cartItemQuantityKg) {
      notifyOutOfStock(context, cartItem.product);
      return;
    }

    final existingCartItem = _items.firstWhere(
      (item) => item.product.id == cartItem.product.id,
      orElse: () => CartItem(product: cartItem.product, quantity: 0.0, unit: 'Kilograms'),
    );

    if (existingCartItem.quantity > 0) {
      existingCartItem.quantity += cartItemQuantityKg;
    } else {
      _items.add(CartItem(
        product: cartItem.product,
        quantity: cartItemQuantityKg,
        unit: 'Kilograms',
      ));
    }

    await _updateProductStock(cartItem.product.id, -(cartItemQuantityKg));

    if (currentStock - cartItemQuantityKg < 3) {
      notificationProviderStoc.addNotification(
        'Stoc redus pentru ${cartItem.product.title}',
        cartItem.product.id,
        cartItem.product.supplierId,
        cartItem.product.title,
      );
    }

    notifyListeners();
  }

  Future<void> updateProductQuantity(CartItem cartItem, double newQuantity) async {
    double difference = newQuantity - cartItem.quantity;
    cartItem.quantity = newQuantity;

    if (cartItem.quantity <= 0) {
      _items.remove(cartItem);
    }

    await _updateProductStock(cartItem.product.id, -difference);

    notifyListeners();
  }

  Future<void> removeProduct(CartItem cartItem) async {
    _items.remove(cartItem);

    await _updateProductStock(cartItem.product.id, cartItem.quantity);

    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  double get totalItemsQuantity {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get total {
    return _items.fold(0, (sum, item) => sum + item.product.price * item.quantity);
  }

  Future<void> _updateProductStock(String productId, double quantityChange) async {
    DocumentReference productRef = FirebaseFirestore.instance.collection('products').doc(productId);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(productRef);
      if (snapshot.exists) {
        double newStock = (snapshot['quantity'] + quantityChange).clamp(0, double.infinity);
        transaction.update(productRef, {'quantity': newStock});
      }
    });
  }
}
