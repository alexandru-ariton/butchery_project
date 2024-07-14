// Importă biblioteca Flutter pentru a crea interfețe de utilizator.
import 'package:flutter/material.dart';
// Importă pachetul Provider pentru gestionarea stării.
import 'package:provider/provider.dart';
// Importă clasa Product.
import 'package:gastrogrid_app/clase/clasa_produs.dart';
// Importă pagina detaliată a produsului.
import 'package:gastrogrid_app/aplicatie_client/Pagini/Product/pagina_produs.dart';
// Importă providerul pentru coșul de cumpărături.
import 'package:gastrogrid_app/providers/provider_cart.dart';

// Declarația unei clase stateless pentru cardul de produs.
class ProductCard extends StatelessWidget {
  // Declarația unui produs final.
  final Product product;

  // Constructorul pentru clasa ProductCard care primește un produs.
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      // Adaugă o umbră cardului.
      elevation: 4.0,
      // Definește forma cardului cu colțuri rotunjite.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: InkWell(
        // Definește colțurile rotunjite pentru gestul de apăsare.
        borderRadius: BorderRadius.circular(15.0),
        // Acțiunea de apăsare care verifică dacă produsul este în coș și navighează la pagina de detalii a produsului.
        onTap: () {
          var cartProvider = Provider.of<CartProvider>(context, listen: false);
          bool isInCart = cartProvider.cartItems.any((item) => item.product.id == product.id);

          if (isInCart) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Produsul este deja în cos. Finalizati comanda sau stergeti produsul.')),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProductDetailPage(product: product),
              ),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Widget expandabil pentru imaginea produsului.
            Expanded(
              child: Container(
                // Stilizează containerul cu colțuri rotunjite și imagine de fundal.
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
                  image: DecorationImage(
                    image: NetworkImage(product.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Adaugă un padding pentru text.
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Afișează titlul produsului.
                  Text(
                    product.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  // Afișează prețul produsului.
                  Text(
                    '${product.price} lei/kg',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
