import 'package:gastrogrid_app/clase/clasa_produs.dart';

class CartItem {
  final Product product;
  double quantity;  // Changed to double
  String unit;

  CartItem({required this.product, required this.quantity, required this.unit});

  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'quantity': quantity,
      'unit': unit,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> data) {
    return CartItem(
      product: Product.fromMap(data['product'], data['product']['id']),
      quantity: (data['quantity'] as num).toDouble(), // Ensure conversion to double
      unit: data['unit'],
    );
  }
}
