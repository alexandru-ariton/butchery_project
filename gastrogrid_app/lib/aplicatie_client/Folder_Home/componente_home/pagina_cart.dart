// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';

class CartItem {
  final String title;
  final double price;
  int quantity;

  CartItem({required this.title, required this.price, this.quantity = 1});

    void incrementQuantity() {
    quantity++;
  }

  void decrementQuantity() {
    if (quantity > 1) {
      quantity--;
    }
  }
}

class CartModel extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

void addProduct(CartItem item) {
    // Attempt to find the item in the cart
    var existingItemIndex = _items.indexWhere((element) => element.title == item.title);
    if (existingItemIndex != -1) {
      // If item exists, increment its quantity
      _items[existingItemIndex].incrementQuantity();
    } else {
      // If item doesn't exist, add it to the cart
      _items.add(item);
    }
    notifyListeners();
  }

  void removeProduct(CartItem item) {
    var existingItemIndex = _items.indexWhere((element) => element.title == item.title);
    if (existingItemIndex != -1 && _items[existingItemIndex].quantity > 1) {
      // If item exists and quantity is more than one, decrement it
      _items[existingItemIndex].decrementQuantity();
    } else {
      // Remove the item from the cart if quantity is 1 or it somehow wasn't found
      _items.removeAt(existingItemIndex);
    }
    notifyListeners();
  }

 double get total => _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
}
