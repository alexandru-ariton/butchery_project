import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gastrogrid_app/providers/provider_adresa_plata_cart.dart';
import 'package:gastrogrid_app/providers/provider_themes.dart';

class PaymentMethodSection extends StatelessWidget {
  final SelectedOptionsProvider optionsProvider;
  final Function(String?) onSelectPaymentMethod;

  const PaymentMethodSection({super.key, 
    required this.optionsProvider,
    required this.onSelectPaymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: themeProvider.themeData.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPaymentOption(
            context,
            'Cash',
            optionsProvider.selectedPaymentMethod == 'Cash',
            Icons.money,
            () {
              onSelectPaymentMethod('Cash');
            },
          ),
          _buildPaymentOption(
            context,
            'Card',
            optionsProvider.selectedPaymentMethod == 'Card',
            Icons.credit_card,
            () {
              onSelectPaymentMethod('Card');
            },
          ),
          if (optionsProvider.selectedPaymentMethod == 'Card' && optionsProvider.selectedCardDetails != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Icon(Icons.credit_card, color: themeProvider.themeData.colorScheme.primary),
                  SizedBox(width: 8),
                  Text(
                    'Card selectat: ${optionsProvider.selectedCardDetails!['last4']}',
                    style: TextStyle(
                      fontSize: 16,
                      color: themeProvider.themeData.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(BuildContext context, String title, bool selected, IconData icon, VoidCallback onTap) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? themeProvider.themeData.colorScheme.primary.withOpacity(0.1) : themeProvider.themeData.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? themeProvider.themeData.colorScheme.primary : themeProvider.themeData.colorScheme.onSurface.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? themeProvider.themeData.colorScheme.primary : themeProvider.themeData.colorScheme.onSurface),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: selected ? themeProvider.themeData.colorScheme.primary : themeProvider.themeData.colorScheme.onSurface,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
