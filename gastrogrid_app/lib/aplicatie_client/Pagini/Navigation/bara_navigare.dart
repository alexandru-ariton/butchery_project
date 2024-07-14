// Ignoră anumite reguli de stilizare pentru acest fișier.
 // ignore_for_file: prefer_final_fields, use_key_in_widget_constructors, prefer_const_constructors, prefer_const_literals_to_create_immutables

 // Importă biblioteca principală Flutter pentru a crea interfețe de utilizator.
 import 'package:flutter/material.dart';

 // Importă paginile necesare pentru aplicație.
 import 'package:gastrogrid_app/aplicatie_client/Pagini/Cart/pagina_cos_cumparaturi.dart';
 import 'package:gastrogrid_app/aplicatie_client/Pagini/Home/pagina_principala_home.dart';
 import 'package:gastrogrid_app/aplicatie_client/Pagini/Orders/pagina_order.dart';
 import 'package:gastrogrid_app/aplicatie_client/Pagini/Profile/pagina_principala_profil.dart';

 // Importă providerul pentru teme.
 import 'package:gastrogrid_app/providers/provider_themes.dart';

 // Importă pachetul provider pentru gestionarea stării.
 import 'package:provider/provider.dart';

 // Declarația unei clase stateful pentru bara de navigare.
 class BaraNavigare extends StatefulWidget {
   @override
   State<BaraNavigare> createState() => _BaraNavigareState();
 }

 // Declarația stării pentru clasa BaraNavigare.
 class _BaraNavigareState extends State<BaraNavigare> {
   // Declarația unui index pentru elementul selectat din bara de navigare.
   int _selectedIndex = 0;

   // Declarația unei liste de widgeturi pentru paginile aplicației.
   List<Widget> _pages = [
     HomePage(),
     PaginaOrder(),
     ShoppingCartPage(),
     ProfilePage(),
   ];

   // Metodă care actualizează indexul elementului selectat din bara de navigare.
   void _onItemTapped(int index) {
     setState(() {
       _selectedIndex = index;
     });
   }

   // Metodă care construiește interfața de utilizator a widgetului.
   @override
   Widget build(BuildContext context) {
     // Obține tema curentă folosind providerul.
     final themeProvider = Provider.of<ThemeProvider>(context);
     return Scaffold(
       // Setează culoarea de fundal a paginii.
       backgroundColor: themeProvider.themeData.colorScheme.surface,
       // Afișează pagina selectată din lista de pagini.
       body: _pages.elementAt(_selectedIndex),
       // Construiește bara de navigare.
       bottomNavigationBar: Container(
         decoration: BoxDecoration(
           // Setează culoarea de fundal a barei de navigare.
           color: themeProvider.themeData.colorScheme.surface,
           // Adaugă o umbră pentru bara de navigare.
           boxShadow: [
             BoxShadow(
               color: Colors.black12,
               blurRadius: 10,
               spreadRadius: 1,
             )
           ],
         ),
         // Construiește elementele barei de navigare.
         child: BottomNavigationBar(
           items: <BottomNavigationBarItem>[
             BottomNavigationBarItem(
               icon: Icon(Icons.home, size: 30),
               label: 'Acasa',
             ),
             BottomNavigationBarItem(
               icon: Icon(Icons.receipt, size: 30),
               label: 'Comenzi',
             ),
             BottomNavigationBarItem(
               icon: Icon(Icons.shopping_cart, size: 30),
               label: 'Cos',
             ),
             BottomNavigationBarItem(
               icon: Icon(Icons.person, size: 30),
               label: 'Profil',
             ),
           ],
           // Setează indexul curent al elementului selectat.
           currentIndex: _selectedIndex,
           // Setează culoarea elementului selectat.
           selectedItemColor: themeProvider.themeData.colorScheme.primary,
           // Setează culoarea elementelor ne-selectate.
           unselectedItemColor: themeProvider.themeData.colorScheme.onSurface.withOpacity(0.6),
           // Metodă care se apelează când se selectează un element din bara de navigare.
           onTap: _onItemTapped,
           // Setează elevarea barei de navigare.
           elevation: 10.0,
           // Ascunde etichetele elementelor ne-selectate.
           showUnselectedLabels: false,
           // Setează tipul barei de navigare.
           type: BottomNavigationBarType.fixed,
           // Setează stilul etichetelor elementelor selectate.
           selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
         ),
       ),
     );
   }
 }
