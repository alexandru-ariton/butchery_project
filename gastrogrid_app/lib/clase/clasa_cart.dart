import 'package:GastroGrid/clase/clasa_produs.dart';


class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});

  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> data) {
    return CartItem(
      product: Product.fromMap(data['product'], data['product']['id']),
      quantity: data['quantity'],
    );
  }
}
