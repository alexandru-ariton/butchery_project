// Importă pachetele necesare.
import 'package:gastrogrid_app/clase/clasa_cart.dart';
import 'package:gastrogrid_app/providers/provider_cart.dart'; // Importă providerul pentru gestionarea coșului de cumpărături.
import 'package:flutter/material.dart'; // Importă pachetul Flutter Material pentru UI.
import 'package:provider/provider.dart'; // Importă pachetul Provider pentru gestionarea stării.
import 'package:gastrogrid_app/providers/provider_themes.dart'; // Importă providerul pentru gestionarea temei aplicației.

// Declarația unui widget stateless pentru afișarea sumarului comenzii.
class OrderSummary extends StatelessWidget {
  final CartProvider cart; // Variabilă finală pentru a stoca providerul coșului de cumpărături.
  final double deliveryFee; // Variabilă finală pentru a stoca taxa de livrare.
  final double total; // Variabilă finală pentru a stoca totalul comenzii.
  final VoidCallback onFinalizeOrder; // Callback pentru finalizarea comenzii.

  // Constructorul widget-ului.
  const OrderSummary({
    super.key, 
    required this.cart,
    required this.deliveryFee,
    required this.total,
    required this.onFinalizeOrder, 
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Accesarea Providerului pentru tema aplicației.
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24), // Definirea padding-ului interior al containerului.
      decoration: BoxDecoration(
        color: themeProvider.themeData.colorScheme.surface, // Culoarea de fundal a containerului.
        borderRadius: BorderRadius.circular(12), // Definirea formelor colțurilor containerului.
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2), // Culoarea umbrei containerului.
            spreadRadius: 1, // Raza de răspândire a umbrei.
            blurRadius: 5, // Raza de blur a umbrei.
            offset: Offset(0, -3), // Offset-ul umbrei.
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Setarea dimensiunii minime a coloanei.
          children: [
            _buildSummaryLine(context, 'Produse în cos:', '${cart.totalItemsQuantity.toStringAsFixed(2)} kg'), // Afișează linia de sumar pentru produsele din coș.
            _buildSummaryLine(context, 'Subtotal:', '${cart.total.toStringAsFixed(2)} lei'), // Afișează linia de sumar pentru subtotal.
            _buildSummaryLine(context, 'Livrare:', cart.items.isEmpty ? '0.00 lei' : '${deliveryFee.toStringAsFixed(2)} lei'), // Afișează linia de sumar pentru livrare.
            Divider(), // Linie de separare.
            _buildSummaryLine(context, 'Total:', '${total.toStringAsFixed(2)} lei', isTotal: true), // Afișează linia de sumar pentru total.
            SizedBox(height: 20), // Spațiu vertical de 20px.
            if (cart.items.isNotEmpty)
              ElevatedButton(
                onPressed: onFinalizeOrder, // Callback-ul pentru finalizarea comenzii.
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24), // Definirea padding-ului butonului.
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Definirea formelor colțurilor butonului.
                  ),
                ),
                child: Text(
                  'Finalizeaza comanda',
                  style: TextStyle(color: themeProvider.themeData.colorScheme.onSurface, fontSize: 16), // Stilul textului butonului.
                ),
              ),
            SizedBox(height: 40), // Spațiu vertical de 40px.
          ],
        ),
      ),
    );
  }

  // Metodă pentru a construi o linie de sumar.
  Widget _buildSummaryLine(BuildContext context, String title, String value, {bool isTotal = false}) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Accesarea Providerului pentru tema aplicației.
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4), // Definirea padding-ului vertical.
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Alinierea spațiată a elementelor din rând.
        children: [
          Text(
            title, // Titlul liniei de sumar.
            style: TextStyle(
              fontSize: isTotal ? 18 : 16, // Dimensiunea fontului.
              color: isTotal ? themeProvider.themeData.colorScheme.primary : themeProvider.themeData.colorScheme.onSurface, // Culoarea textului.
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, // Greutatea fontului.
            ),
          ),
          Text(
            value, // Valoarea liniei de sumar.
            style: TextStyle(
              fontSize: isTotal ? 18 : 16, // Dimensiunea fontului.
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, // Greutatea fontului.
              color: themeProvider.themeData.colorScheme.onSurface, // Culoarea textului.
            ),
          ),
        ],
      ),
    );
  }
}
