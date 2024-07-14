// Importă pachetele necesare.
import 'package:flutter/material.dart'; // Importă pachetul Flutter Material pentru UI.
import 'package:provider/provider.dart'; // Importă pachetul Provider pentru gestionarea stării.
import 'package:gastrogrid_app/providers/provider_adresa_plata_cart.dart'; // Importă Providerul pentru gestionarea adresei și plății coșului.
import 'package:gastrogrid_app/providers/provider_themes.dart'; // Importă Providerul pentru gestionarea temei aplicației.

// Declarația unui widget stateless pentru afișarea secțiunii de metodă de plată.
class PaymentMethodSection extends StatelessWidget {
  final SelectedOptionsProvider optionsProvider; // Variabilă finală pentru a stoca Providerul opțiunilor selectate.
  final Function(String?) onSelectPaymentMethod; // Callback pentru selectarea metodei de plată.

  // Constructorul widget-ului.
  const PaymentMethodSection({
    super.key, 
    required this.optionsProvider,
    required this.onSelectPaymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Accesarea Providerului pentru tema aplicației.
    return Container(
      padding: EdgeInsets.all(16.0), // Definirea padding-ului interior al containerului.
      decoration: BoxDecoration(
        color: themeProvider.themeData.colorScheme.surface, // Culoarea de fundal a containerului.
        borderRadius: BorderRadius.circular(12.0), // Definirea formelor colțurilor containerului.
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2), // Culoarea umbrei containerului.
            spreadRadius: 3, // Raza de răspândire a umbrei.
            blurRadius: 5, // Raza de blur a umbrei.
            offset: Offset(0, 3), // Offset-ul umbrei.
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Alinierea la stânga a elementelor din coloană.
        children: [
          _buildPaymentOption(
            context,
            'Cash', // Titlul opțiunii de plată.
            optionsProvider.selectedPaymentMethod == 'Cash', // Verifică dacă metoda de plată selectată este 'Cash'.
            Icons.money, // Pictograma pentru opțiunea 'Cash'.
            () {
              onSelectPaymentMethod('Cash'); // Callback-ul pentru selectarea metodei de plată 'Cash'.
            },
          ),
          _buildPaymentOption(
            context,
            'Card', // Titlul opțiunii de plată.
            optionsProvider.selectedPaymentMethod == 'Card', // Verifică dacă metoda de plată selectată este 'Card'.
            Icons.credit_card, // Pictograma pentru opțiunea 'Card'.
            () {
              onSelectPaymentMethod('Card'); // Callback-ul pentru selectarea metodei de plată 'Card'.
            },
          ),
          if (optionsProvider.selectedPaymentMethod == 'Card' && optionsProvider.selectedCardDetails != null)
            Padding(
              padding: const EdgeInsets.only(top: 16), // Definirea padding-ului superior.
              child: Row(
                children: [
                  Icon(Icons.credit_card, color: themeProvider.themeData.colorScheme.primary), // Pictograma pentru cardul selectat.
                  SizedBox(width: 8), // Spațiu orizontal de 8px.
                  Text(
                    'Card selectat: ${optionsProvider.selectedCardDetails!['last4']}', // Afișează ultimele 4 cifre ale cardului selectat.
                    style: TextStyle(
                      fontSize: 16,
                      color: themeProvider.themeData.colorScheme.onSurface, // Culoarea textului.
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Metodă pentru a construi o opțiune de plată.
  Widget _buildPaymentOption(BuildContext context, String title, bool selected, IconData icon, VoidCallback onTap) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false); // Accesarea Providerului pentru tema aplicației.
    return GestureDetector(
      onTap: onTap, // Callback-ul pentru selectarea opțiunii de plată.
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8), // Definirea marginilor verticale.
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Definirea padding-ului interior.
        decoration: BoxDecoration(
          color: selected ? themeProvider.themeData.colorScheme.primary.withOpacity(0.1) : themeProvider.themeData.colorScheme.surface, // Culoarea de fundal a containerului.
          borderRadius: BorderRadius.circular(8), // Definirea formelor colțurilor containerului.
          border: Border.all(
            color: selected ? themeProvider.themeData.colorScheme.primary : themeProvider.themeData.colorScheme.onSurface.withOpacity(0.5), // Culoarea graniței containerului.
            width: 1, // Lățimea graniței containerului.
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? themeProvider.themeData.colorScheme.primary : themeProvider.themeData.colorScheme.onSurface), // Pictograma opțiunii de plată.
            SizedBox(width: 12), // Spațiu orizontal de 12px.
            Text(
              title, // Titlul opțiunii de plată.
              style: TextStyle(
                fontSize: 16, // Dimensiunea fontului.
                color: selected ? themeProvider.themeData.colorScheme.primary : themeProvider.themeData.colorScheme.onSurface, // Culoarea textului.
                fontWeight: selected ? FontWeight.bold : FontWeight.normal, // Greutatea fontului.
              ),
            ),
          ],
        ),
      ),
    );
  }
}
