// Ignoră anumite avertismente de la analizatorul de cod Dart.
 // ignore_for_file: prefer_const_constructors, unused_import

// Importă diverse pachete necesare pentru funcționarea aplicației.
import 'package:cloud_firestore/cloud_firestore.dart'; // Pachet pentru interacțiunea cu baza de date Firestore.
import 'package:firebase_app_check/firebase_app_check.dart'; // Pachet pentru verificarea aplicației Firebase.
import 'package:firebase_auth/firebase_auth.dart'; // Pachet pentru autentificare Firebase.
import 'package:firebase_core/firebase_core.dart'; // Pachet pentru inițializarea Firebase.
import 'package:flutter/material.dart'; // Pachet principal pentru construirea UI-ului în Flutter.
import 'package:gastrogrid_app/providers/provider_adresa_plata_cart.dart'; // Importă un provider specific aplicației.
import 'package:gastrogrid_app/providers/provider_comenzi.dart'; // Importă un provider specific aplicației.
import 'package:gastrogrid_app/providers/provider_notificareStoc.dart'; // Importă un provider specific aplicației.
import 'package:provider/provider.dart'; // Pachet pentru gestionarea stării în Flutter.
import 'package:gastrogrid_app/providers/provider_autentificare.dart' as local; // Importă și redenumește un provider specific aplicației pentru a evita conflictele de nume.
import 'package:gastrogrid_app/providers/provider_cart.dart'; // Importă un provider specific aplicației.
import 'package:gastrogrid_app/Autentificare/pagini/tranzitor_login_sau_inregistrare.dart'; // Importă o pagină specifică aplicației pentru autentificare.
import 'package:gastrogrid_app/providers/provider_livrare.dart'; // Importă un provider specific aplicației.
import 'package:gastrogrid_app/providers/provider_themes.dart'; // Importă un provider specific aplicației pentru gestionarea temelor.
import 'firebase_options.dart'; // Importă opțiunile de configurare Firebase.
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Importă pachetul pentru notificări locale în Flutter.

// Funcție asincronă pentru inițializarea documentelor utilizatorilor.
Future<void> initializeUserDocuments() async {
  final firestore = FirebaseFirestore.instance; // Obține instanța Firestore.

  // Obține toate documentele din colecția 'users'.
  final userDocuments = await firestore.collection('users').get();
  // Parcurge fiecare document din colecția 'users'.
  for (var doc in userDocuments.docs) {
    try {
      // Dacă documentul nu există sau deja conține cheia 'isLoggedIn', trece la următorul.
      if (!doc.exists || doc.data().containsKey('isLoggedIn')) continue;
      // Actualizează documentul setând 'isLoggedIn' la false.
      await doc.reference.update({'isLoggedIn': false});
    } catch (e) {
      // Print și afișează erorile.
      print('Eroare la actualizarea documentului din users: ${doc.id}, eroare: $e');
    }
  }

  // Obține toate documentele din colecția 'admin_users'.
  final adminDocuments = await firestore.collection('admin_users').get();
  // Parcurge fiecare document din colecția 'admin_users'.
  for (var doc in adminDocuments.docs) {
    try {
      // Dacă documentul nu există sau deja conține cheia 'isLoggedIn', trece la următorul.
      if (!doc.exists || doc.data().containsKey('isLoggedIn')) continue;
      // Actualizează documentul setând 'isLoggedIn' la false.
      await doc.reference.update({'isLoggedIn': false});
    } catch (e) {
      // Prinde și afișează erorile.
      print('Eroare la actualizarea documentului din admin_users: ${doc.id}, eroare: $e');
    }
  }
}

// Funcția principală a aplicației, de unde începe execuția.
Future<void> main() async {
  // Asigură inițializarea corectă a binding-urilor Flutter.
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inițializează Firebase cu opțiunile specifice platformei curente.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
 
  // Rulează aplicația principală folosind un provider pentru gestionarea temelor.
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(), // Creează un provider pentru gestionarea temelor.
      child: MyApp(), // Rulează aplicația principală.
    ),
  );
}

// Clasă care definește aplicația principală.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider pentru livrare.
        ChangeNotifierProvider(create: (_) => DeliveryProvider()),
        // Provider pentru autentificare.
        ChangeNotifierProvider(create: (_) => local.AuthProvider()),
        // Provider pentru notificări de stoc.
        ChangeNotifierProvider(create: (_) => NotificationProviderStoc()),
        // Provider pentru opțiuni selectate.
        ChangeNotifierProvider(create: (_) => SelectedOptionsProvider()),
        // Provider pentru coș, dependent de NotificationProviderStoc.
        ChangeNotifierProxyProvider<NotificationProviderStoc, CartProvider>(
          create: (context) => CartProvider(context.read<NotificationProviderStoc>()),
          update: (context, notificationProviderStoc, cartProvider) => CartProvider(notificationProviderStoc),
        ),
        // Provider pentru starea comenzilor.
        ChangeNotifierProvider(create: (_) => OrderStatusProvider()),
      ],
      // Consumer folosit pentru a accesa tema curentă și a construi interfața utilizatorului în consecință.
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            // Dezactivează bannerul de debug.
            debugShowCheckedModeBanner: false,
            // Setează pagina de start a aplicației.
            home: LoginSauInregistrare(),
            // Aplică tema curentă.
            theme: themeProvider.themeData,
          );
        },
      ),
    );
  }
}
