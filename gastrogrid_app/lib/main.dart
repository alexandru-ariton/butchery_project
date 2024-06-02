// ignore_for_file: prefer_const_constructors, unused_import

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gastrogrid_app/providers/provider_comenzi.dart';
import 'package:gastrogrid_app/providers/provider_notificareStoc.dart';
import 'package:provider/provider.dart';
import 'package:gastrogrid_app/providers/provider_autentificare.dart' as local;
import 'package:gastrogrid_app/providers/provider_cart.dart';
import 'package:gastrogrid_app/Autentificare/pagini/tranzitor_login_sau_inregistrare.dart';
import 'package:gastrogrid_app/providers/provider_livrare.dart';
import 'package:gastrogrid_app/providers/provider_themes.dart';
import 'firebase_options.dart';

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
    ChangeNotifierProvider(create: (_) => DeliveryProvider()),
        ChangeNotifierProvider(create: (_) => local.AuthProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProviderStoc()),
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


