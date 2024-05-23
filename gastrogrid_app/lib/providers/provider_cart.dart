import 'package:flutter/material.dart';
import 'package:gastrogrid_app/aplicatie_client/clase/cart.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  double get total {
    return _items.fold(0, (sum, item) => sum + item.product.price * item.quantity);
  }

  int get totalItemsQuantity {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  void addProductToCart(CartItem cartItem) {
    int index = _items.indexWhere((item) => item.product.id == cartItem.product.id);
    if (index >= 0) {
      _items[index].quantity += cartItem.quantity;
    } else {
      _items.add(cartItem);
    }
    notifyListeners();
  }

  void updateProductQuantity(CartItem cartItem, int quantity) {
    int index = _items.indexWhere((item) => item.product.id == cartItem.product.id);
    if (index >= 0) {
      _items[index].quantity = quantity;
      if (_items[index].quantity <= 0) {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeProduct(CartItem cartItem) {
    _items.removeWhere((item) => item.product.id == cartItem.product.id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
