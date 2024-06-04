import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GastroGrid/clase/clasa_produs.dart';
import 'package:GastroGrid/providers/provider_notificareStoc.dart';
import 'package:GastroGrid/aplicatie_admin/Pagini/Notificari/pagina_notificari.dart';

void notifyLowStock(BuildContext context, Product product) {
  // Notifică clientul
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Stoc redus pentru ${product.title}')),
  );

  // Notifică adminul - salvați notificarea în Firestore
  Provider.of<NotificationProviderStoc>(context, listen: false).addNotification(
    'Stoc redus pentru ${product.title}',
    product.id,
  );

  // Navighează la pagina notificărilor de stoc redus
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => LowStockNotificationPage()),
  );
}

void notifyOutOfStock(BuildContext context, Product product) {
  // Notifică clientul
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Stoc Epuizat pentru ${product.title}')),
  );

  // Notifică adminul - salvați notificarea în Firestore
  Provider.of<NotificationProviderStoc>(context, listen: false).addNotification(
    'Stoc Epuizat pentru ${product.title}',
    product.id,
  );

  // Navighează la pagina notificărilor de stoc epuizat
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => LowStockNotificationPage()),
  );
}
