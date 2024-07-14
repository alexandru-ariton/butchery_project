// Importă clasa Product.
import 'package:gastrogrid_app/clase/clasa_produs.dart';

// Clasă care reprezintă un articol din coșul de cumpărături.
class CartItem {
  // Produsul adăugat în coș.
  final Product product;
  // Cantitatea produsului (poate fi exprimată în unități sau greutate).
  double quantity;  // Modificat la double pentru a permite valori decimale.
  // Unitatea de măsură pentru cantitate (ex. 'gr' pentru grame).
  String unit;

  // Constructor pentru clasa CartItem.
  CartItem({required this.product, required this.quantity, required this.unit});

  // Metodă pentru convertirea unui obiect CartItem într-o hartă de date.
  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(), // Convertirea obiectului Product într-o hartă de date.
      'quantity': quantity, // Cantitatea produsului.
      'unit': unit, // Unitatea de măsură.
    };
  }

  // Metodă factory pentru crearea unui obiect CartItem dintr-o hartă de date.
  factory CartItem.fromMap(Map<String, dynamic> data) {
    return CartItem(
      product: Product.fromMap(data['product'], data['product']['id']), // Crearea obiectului Product din hartă.
      quantity: (data['quantity'] as num).toDouble(), // Asigurarea conversiei cantității la double.
      unit: data['unit'], // Unitatea de măsură.
    );
  }
}
