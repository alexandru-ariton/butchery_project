import 'package:flutter/material.dart'; // Importă biblioteca principală Flutter pentru utilizarea widget-urilor.

class OrderItems extends StatelessWidget {
  final List<dynamic> orderItems; // Lista articolelor din comandă.

  const OrderItems({super.key, required this.orderItems}); // Constructorul clasei, care primește lista articolelor din comandă.

  @override
  Widget build(BuildContext context) {
    if (orderItems.isEmpty) {
      return Text('No items found.', style: TextStyle(fontSize: 16)); // Afișează un mesaj dacă nu sunt articole în comandă.
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Alinierea la început pe axa transversală.
      children: orderItems.map((item) {
        var productData = item['product'] ?? {}; // Obține datele produsului din articol.
        var productName = productData['title'] ?? 'Unknown Product'; // Obține numele produsului sau 'Unknown Product' dacă nu există.
        var quantity = item['quantity'] ?? 'Unknown Quantity'; // Obține cantitatea sau 'Unknown Quantity' dacă nu există.
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0), // Adaugă padding vertical de 4 pixeli.
          child: Text('$productName x $quantity', style: TextStyle(fontSize: 16)), // Afișează numele produsului și cantitatea.
        );
      }).toList(), // Transformă fiecare articol din lista orderItems într-un widget Text.
    );
  }
}
