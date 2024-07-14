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

  double _convertToKg(double quantity, String unit) {
    if (unit == 'gr') {
      return quantity % 100;
    } else {
      return quantity;
    }
  }

  double _convertFromKg(double quantityKg, String unit) {
    if (unit == 'gr') {
      return quantityKg * 1000;
    } else {
      return quantityKg;
    }
  }

  Future<void> addProductToCart(CartItem cartItem, BuildContext context) async {
    DocumentSnapshot productSnapshot = await FirebaseFirestore.instance.collection('products').doc(cartItem.product.id).get();
    if (!productSnapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product does not exist in the database.')),
      );
      return;
    }
    double currentStockKg = (productSnapshot['quantity'] as num).toDouble();
    double cartItemQuantityKg = _convertToKg(cartItem.quantity, cartItem.unit);

    if (currentStockKg < cartItemQuantityKg) {
      notifyOutOfStock(context, cartItem.product);
      return;
    }

    final existingCartItem = _items.firstWhere(
      (item) => item.product.id == cartItem.product.id && item.unit == cartItem.unit,
      orElse: () => CartItem(product: cartItem.product, quantity: 0.0, unit: cartItem.unit),
    );

    if (existingCartItem.quantity > 0) {
      existingCartItem.quantity += cartItem.quantity;
    } else {
      _items.add(CartItem(
        product: cartItem.product,
        quantity: cartItem.quantity,
        unit: cartItem.unit,
      ));
    }

    await _updateProductStock(cartItem.product.id, -cartItemQuantityKg);

    if (currentStockKg - cartItemQuantityKg < 3) {
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
    double oldQuantityKg = _convertToKg(cartItem.quantity, cartItem.unit);
    double newQuantityKg = _convertToKg(newQuantity, cartItem.unit);
    double differenceKg = newQuantityKg - oldQuantityKg;

    if (differenceKg <= 0 || await isStockAvailable(cartItem.product.id, differenceKg)) {
      cartItem.quantity = newQuantity;

      if (cartItem.quantity <= 0) {
        _items.remove(cartItem);
      }

      await _updateProductStock(cartItem.product.id, -differenceKg);

      notifyListeners();
    } else {
      print('Stoc insuficient pentru acest produs.');
    }
  }

  Future<void> removeProduct(CartItem cartItem) async {
    double cartItemQuantityKg = _convertToKg(cartItem.quantity, cartItem.unit);
    _items.remove(cartItem);

    await _updateProductStock(cartItem.product.id, cartItemQuantityKg);

    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  double get totalItemsQuantity {
    return _items.fold(0, (sum, item) => sum + _convertToKg(item.quantity, item.unit));
  }

  double get total {
    return _items.fold(0, (sum, item) => sum + item.product.price * _convertToKg(item.quantity, item.unit));
  }

  Future<void> _updateProductStock(String productId, double quantityChangeKg) async {
    DocumentReference productRef = FirebaseFirestore.instance.collection('products').doc(productId);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(productRef);
      if (snapshot.exists) {
        double newStock = ((snapshot['quantity'] as num).toDouble() + quantityChangeKg).clamp(0, double.infinity);
        transaction.update(productRef, {'quantity': newStock});
      }
    });
  }

  Future<bool> isStockAvailable(String productId, double requestedQuantityKg) async {
    DocumentSnapshot productSnapshot = await FirebaseFirestore.instance.collection('products').doc(productId).get();
    if (!productSnapshot.exists) {
      return false;
    }
    double currentStock = (productSnapshot['quantity'] as num).toDouble();
    return currentStock >= requestedQuantityKg;
  }
}
