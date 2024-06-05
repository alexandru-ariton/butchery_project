// ignore_for_file: prefer_final_fields, use_key_in_widget_constructors, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:GastroGrid/aplicatie_client/Pagini/Cart/pagina_cos_cumparaturi.dart';
import 'package:GastroGrid/aplicatie_client/Pagini/Home/pagina_principala_home.dart';
import 'package:GastroGrid/aplicatie_client/Pagini/Orders/pagina_order.dart';
import 'package:GastroGrid/aplicatie_client/Pagini/Profile/pagina_principala_profil.dart';
import 'package:GastroGrid/providers/provider_themes.dart';
import 'package:provider/provider.dart';

class BaraNavigare extends StatefulWidget {
  @override
  State<BaraNavigare> createState() => _BaraNavigareState();
}

class _BaraNavigareState extends State<BaraNavigare> {
  int _selectedIndex = 0;
  List<Widget> _pages = [
    HomePage(),
    PaginaOrder(),
    ShoppingCartPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.themeData.colorScheme.surface,
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: themeProvider.themeData.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 1,
            )
          ],
        ),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 30),
              label: 'Acasă',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt, size: 30),
              label: 'Comenzi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart, size: 30),
              label: 'Coș',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 30),
              label: 'Profil',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: themeProvider.themeData.colorScheme.primary,
          unselectedItemColor: themeProvider.themeData.colorScheme.onSurface.withOpacity(0.6),
          onTap: _onItemTapped,
          elevation: 10.0,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }
}
