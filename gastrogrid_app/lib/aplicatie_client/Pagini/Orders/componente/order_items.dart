// Importă biblioteca principală Flutter pentru a crea interfețe de utilizator.
import 'package:flutter/material.dart';

// Importă clasa pentru produse.
import 'package:gastrogrid_app/clase/clasa_produs.dart';

// Declarația unei clase stateless pentru afișarea elementelor din comandă.
class OrderItems extends StatelessWidget {
  // Declarația câmpului pentru lista de elemente.
  final List<dynamic> items;

  // Constructorul clasei OrderItems.
  const OrderItems({super.key, required this.items});

  // Metodă care construiește interfața de utilizator a widgetului.
  @override
  Widget build(BuildContext context) {
    return Column(
      // Maparea listei de elemente în widgeturi.
      children: items.map<Widget>((item) {
        // Extrage datele produsului din element.
        var productData = item['product'];
        if (productData == null) {
          return Text('-'); // Afișează un text gol dacă datele produsului sunt nule.
        }
        // Creează un obiect Product din datele produsului.
        var product = Product.fromMap(productData, productData['id'] ?? 'unknown');
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              // Afișează titlul produsului și cantitatea.
              Expanded(
                child: Text(
                  '${product.title} x ${item['quantity'].toStringAsFixed(2)} kg',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Afișează prețul total al produsului.
              Text(
                '${(product.price * item['quantity']).toStringAsFixed(2)} lei',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
