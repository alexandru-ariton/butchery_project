// ignore_for_file: use_key_in_widget_constructors, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Cart/pagina_cos_cumparaturi.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Home/pagina_principala_home.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Orders/pagina_order.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Profile/pagina_principala_profil.dart';
import 'package:gastrogrid_app/providers/theme_provider.dart';
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
      backgroundColor: themeProvider.themeData.colorScheme.background,
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Acasă',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Comenzi',
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.add_shopping_cart_rounded),
            label: 'Cos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent[700],
        unselectedItemColor: Colors.grey[500],
        onTap: _onItemTapped,
        elevation: 5.0,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
       
      ),
    );
  }
}
