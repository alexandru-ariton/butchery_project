import 'package:GastroGrid/providers/provider_cart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GastroGrid/providers/provider_themes.dart';

class OrderSummary extends StatelessWidget {
  final CartProvider cart;
  final double deliveryFee;
  final double total;
  final VoidCallback onFinalizeOrder;

  OrderSummary({
    required this.cart,
    required this.deliveryFee,
    required this.total,
    required this.onFinalizeOrder,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: themeProvider.themeData.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSummaryLine(context, 'Produse în coș:', '${cart.totalItemsQuantity}'),
            _buildSummaryLine(context, 'Subtotal:', '${cart.total.toStringAsFixed(2)} lei'),
            _buildSummaryLine(context, 'Livrare:', cart.items.isEmpty ? '0 lei' : '${deliveryFee.toStringAsFixed(2)} lei'),
            Divider(),
            _buildSummaryLine(context, 'Total:', '${total.toStringAsFixed(2)} lei', isTotal: true),
            SizedBox(height: 20),
            if (!cart.items.isEmpty)
              ElevatedButton(
                onPressed: onFinalizeOrder,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'FINALIZEAZĂ COMANDA',
                  style: TextStyle(color: themeProvider.themeData.colorScheme.onSurface, fontSize: 16),
                ),
              ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryLine(BuildContext context, String title, String value, {bool isTotal = false}) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              color: isTotal ? themeProvider.themeData.colorScheme.primary : themeProvider.themeData.colorScheme.onSurface,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: themeProvider.themeData.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
