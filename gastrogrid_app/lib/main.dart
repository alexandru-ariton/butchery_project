// ignore_for_file: prefer_const_constructors, unused_import

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gastrogrid_app/providers/order_provider.dart';
import 'package:provider/provider.dart';
import 'package:gastrogrid_app/providers/provider_notificari.dart'; // Import corect pentru NotificationProvider
import 'package:gastrogrid_app/providers/provider_autentificare.dart' as local; // Adaugă alias pentru AuthProvider local
import 'package:gastrogrid_app/providers/provider_cart.dart';
import 'package:gastrogrid_app/Autentificare/authentificare/login_sau_inregistrare.dart';
import 'package:gastrogrid_app/providers/provider_livrare.dart';
import 'package:gastrogrid_app/providers/theme_provider.dart';
import 'firebase_options.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Rating/pagina_rating.dart'; // Import corect pentru RatingPage

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => DeliveryProvider()),
        ChangeNotifierProvider(create: (_) => local.AuthProvider()), // Utilizează aliasul pentru AuthProvider local
        ChangeNotifierProvider(create: (_) => NotificationProvider()),// Adaugă NotificationProvider
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


