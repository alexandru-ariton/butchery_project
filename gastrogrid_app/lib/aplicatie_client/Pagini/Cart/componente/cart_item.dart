// Declarația unui widget stateless pentru afișarea unui element din coșul de cumpărături
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gastrogrid_app/clase/clasa_cart.dart';
import 'package:gastrogrid_app/providers/provider_cart.dart';
import 'package:gastrogrid_app/providers/provider_themes.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem item; // Definirea unei variabile finale pentru a stoca item-ul din coș.

  const CartItemWidget({super.key, required this.item}); // Constructorul widget-ului.

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Accesarea Providerului pentru tema aplicației.
    double unitPrice = item.product.price;

    return Card(
      elevation: 4.0, // Definirea înălțimii umbrei cardului.
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Definirea marginilor cardului.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Definirea formelor colțurilor cardului.
      ),
      child: Padding(
        padding: EdgeInsets.all(16), // Definirea padding-ului interior al cardului.
        child: Row(
          children: <Widget>[
            if (item.product.imageUrl != null) // Verifică dacă URL-ul imaginii nu este null.
              ClipRRect(
                borderRadius: BorderRadius.circular(10), // Definirea formelor colțurilor imaginii.
                child: Image.network(
                  item.product.imageUrl, // URL-ul imaginii.
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover, // Imaginea se ajustează pentru a acoperi containerul.
                ),
              )
            else // Dacă URL-ul imaginii este null.
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Culoarea de fundal a containerului.
                  borderRadius: BorderRadius.circular(10), // Definirea formelor colțurilor containerului.
                ),
                child: Icon(Icons.image, size: 50, color: Colors.grey[400]), // Afișează o pictogramă default pentru imagine.
              ),
            SizedBox(width: 16), // Un spațiu de 16px între imagine și detaliile produsului.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.product.title, // Titlul produsului.
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: themeProvider.themeData.colorScheme.onSurface, // Culoarea textului.
                    ),
                  ),
                  SizedBox(height: 8), // Spațiu vertical de 8px.
                  Text(
                    'Pret: ${(unitPrice * item.quantity).toStringAsFixed(2)} lei', // Prețul produsului.
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600], // Culoarea textului.
                    ),
                  ),
                  SizedBox(height: 4), // Spațiu vertical de 4px.
                  Text(
                    'Cantitate: ${item.quantity.toStringAsFixed(3)} kg', // Cantitatea produsului.
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600], // Culoarea textului.
                    ),
                  ),
                ],
              ),
            ),
            _buildQuantityControls(context, item), // Afișează controalele pentru cantitate.
          ],
        ),
      ),
    );
  }

  // Metodă pentru a construi controalele de cantitate.
  Widget _buildQuantityControls(BuildContext context, CartItem item) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Accesarea Providerului pentru tema aplicației.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.remove), // Pictograma pentru a scădea cantitatea.
          color: themeProvider.themeData.colorScheme.primary, // Culoarea pictogramei.
          onPressed: () {
            double decrement = 0.1;
            double newQuantity = item.quantity - decrement;
            if (newQuantity > 0) { // Verifică dacă cantitatea este mai mare de 0.
              Provider.of<CartProvider>(context, listen: false).updateProductQuantity(item, newQuantity); // Scade cantitatea.
            } else {
              Provider.of<CartProvider>(context, listen: false).removeProduct(item); // Elimină produsul din coș dacă cantitatea este mai mică sau egală cu 0.
            }
          },
        ),
        Text(
          (item.quantity).toStringAsFixed(3), // Afișează cantitatea produsului.
          style: TextStyle(
            fontSize: 16,
            color: themeProvider.themeData.colorScheme.onSurface, // Culoarea textului.
          ),
        ),
        IconButton(
          icon: Icon(Icons.add), // Pictograma pentru a adăuga cantitatea.
          color: themeProvider.themeData.colorScheme.primary, // Culoarea pictogramei.
          onPressed: () {
            double increment = 0.1;
            double newQuantity = item.quantity + increment;
            Provider.of<CartProvider>(context, listen: false).updateProductQuantity(item, newQuantity); // Adaugă cantitatea.
          },
        ),
      ],
    );
  }
}
