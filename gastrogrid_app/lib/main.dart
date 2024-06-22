// ignore_for_file: prefer_const_constructors, unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gastrogrid_app/providers/provider_adresa_plata_cart.dart';
import 'package:gastrogrid_app/providers/provider_comenzi.dart';
import 'package:gastrogrid_app/providers/provider_notificareStoc.dart';
import 'package:provider/provider.dart';
import 'package:gastrogrid_app/providers/provider_autentificare.dart' as local;
import 'package:gastrogrid_app/providers/provider_cart.dart';
import 'package:gastrogrid_app/Autentificare/pagini/tranzitor_login_sau_inregistrare.dart';
import 'package:gastrogrid_app/providers/provider_livrare.dart';
import 'package:gastrogrid_app/providers/provider_themes.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


Future<void> initializeUserDocuments() async {
  final firestore = FirebaseFirestore.instance;

  final userDocuments = await firestore.collection('users').get();
  for (var doc in userDocuments.docs) {
    try {
      if (!doc.exists || doc.data().containsKey('isLoggedIn')) continue;
      await doc.reference.update({'isLoggedIn': false});
    } catch (e) {
      print('Eroare la actualizarea documentului din users: ${doc.id}, eroare: $e');
    }
  }


  final adminDocuments = await firestore.collection('admin_users').get();
  for (var doc in adminDocuments.docs) {
    try {
      if (!doc.exists || doc.data().containsKey('isLoggedIn')) continue;
      await doc.reference.update({'isLoggedIn': false});
    } catch (e) {
      print('Eroare la actualizarea documentului din admin_users: ${doc.id}, eroare: $e');
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
   FirebaseAppCheck firebaseAppCheck = FirebaseAppCheck.instance;
  await firebaseAppCheck.activate(
    //webRecaptchaSiteKey: 'YOUR_RECAPTCHA_SITE_KEY',
    androidProvider: AndroidProvider.playIntegrity,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(), 
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
    ChangeNotifierProvider(create: (_) => DeliveryProvider()),
        ChangeNotifierProvider(create: (_) => local.AuthProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProviderStoc()),
         ChangeNotifierProvider(create: (_) => SelectedOptionsProvider()),
        ChangeNotifierProxyProvider<NotificationProviderStoc, CartProvider>(
          create: (context) => CartProvider(context.read<NotificationProviderStoc>()),
          update: (context, notificationProviderStoc, cartProvider) => CartProvider(notificationProviderStoc),
        ),
        ChangeNotifierProvider(create: (_) => OrderStatusProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: LoginSauInregistrare(),
            theme: themeProvider.themeData,
          );
        },
      ),
    );
  }
}


