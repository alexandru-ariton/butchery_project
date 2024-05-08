import 'package:flutter/material.dart';
import 'package:gastrogrid_app/aplicatie_client/clase/cart.dart';


class CartModel extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  CartItem? findItemByTitle(String title) {
    try {
      return _items.firstWhere((element) => element.title == title);
    } catch (e) {
      // If no item is found, return null
      return null;
    }
  }

 void addProduct(CartItem newItem) {
  // Check if the item is already in the cart.
  var existingItemIndex = _items.indexWhere((item) => item.title == newItem.title);
  if (existingItemIndex != -1) {
    // If the item exists, increase its quantity by the new item's quantity.
    _items[existingItemIndex].quantity += newItem.quantity;
  } else {
    // If the item is new, add it to the cart with the provided quantity.
    _items.add(newItem);
  }
  notifyListeners();
}


  void removeProduct(CartItem item) {
    var existingItem = findItemByTitle(item.title);
    if (existingItem != null && existingItem.quantity > 1) {
      // If item exists and quantity is more than one, decrement it
      existingItem.decrementQuantity();
    } else if (existingItem != null) {
      // Remove the item if quantity is 1
      _items.remove(existingItem);
    }
    notifyListeners();
  }

  void updateProductQuantity(CartItem item, int newQuantity) {
    var existingItemIndex = _items.indexWhere((element) => element.title == item.title);
    if (existingItemIndex != -1) {
      _items[existingItemIndex].quantity = newQuantity;
      notifyListeners();
    }
  }

   int get totalItemsQuantity => _items.fold(0, (total, current) => total + current.quantity);

  double get total => _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
}
