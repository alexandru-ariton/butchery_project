import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GastroGrid/providers/provider_adresa_plata_cart.dart';
import 'package:GastroGrid/providers/provider_livrare.dart';
import 'package:GastroGrid/providers/provider_themes.dart';

class DeliveryInfoSection extends StatelessWidget {
  final DeliveryProvider deliveryInfo;
  final SelectedOptionsProvider optionsProvider;
  final VoidCallback onSelectDeliveryAddress;

  DeliveryInfoSection({
    required this.deliveryInfo,
    required this.optionsProvider,
    required this.onSelectDeliveryAddress,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: themeProvider.themeData.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: deliveryInfo.isDelivery
          ? ListTile(
              title: Text('Adresa selectată'),
              subtitle: Text(optionsProvider.selectedAddress ?? 'Nu a fost selectată nicio adresă'),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: onSelectDeliveryAddress,
            )
          : ListTile(
              title: Text('Ridicare personală activată'),
              subtitle: Text('Produsele vor fi ridicate de la magazin'),
            ),
    );
  }
}
