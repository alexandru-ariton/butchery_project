// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gastrogrid_app/aplicatie_client/clase/cart.dart';
import 'package:gastrogrid_app/providers/provider_notificareStoc.dart';

class CartProvider with ChangeNotifier {
  final NotificationProviderStoc notificationProviderStoc;
  List<CartItem> _items = [];

  CartProvider(this.notificationProviderStoc);

  List<CartItem> get items => _items;

  Future<void> addProductToCart(CartItem cartItem) async {
    final existingCartItem = _items.firstWhere(
      (item) => item.product.id == cartItem.product.id,
      orElse: () => CartItem(product: cartItem.product, quantity: 0),
    );

    if (existingCartItem.quantity > 0) {
      existingCartItem.quantity += cartItem.quantity;
    } else {
      _items.add(cartItem);
    }

    await _updateProductStock(cartItem.product.id, -cartItem.quantity);

    if (cartItem.product.quantity < 3) {
      notificationProviderStoc.addNotification('Stoc redus pentru ${cartItem.product.title}', cartItem.product.id);
    }

    notifyListeners();
  }

  Future<void> updateProductQuantity(CartItem cartItem, int newQuantity) async {
    int difference = newQuantity - cartItem.quantity;
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

  int get totalItemsQuantity {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get total {
    return _items.fold(0, (sum, item) => sum + item.product.price * item.quantity);
  }

  Future<void> _updateProductStock(String productId, int quantityChange) async {
    DocumentReference productRef = FirebaseFirestore.instance.collection('products').doc(productId);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(productRef);
      if (snapshot.exists) {
        int newStock = (snapshot['quantity'] + quantityChange).clamp(0, double.infinity).toInt();
        transaction.update(productRef, {'quantity': newStock});
      }
    });
  }
}
