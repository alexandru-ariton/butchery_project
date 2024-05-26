import 'package:flutter/material.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Cart/pagina_cos_cumparaturi.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Home/pagina_principala_home.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Notificare/notificare_page.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Orders/pagina_order.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Profile/pagina_principala_profil.dart';
import 'package:gastrogrid_app/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:gastrogrid_app/providers/provider_notificari.dart';

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
    NotificationPage(),
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
      bottomNavigationBar: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, _) {
          return BottomNavigationBar(
            items: <BottomNavigationBarItem>[
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
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    Icon(Icons.notifications),
                    if (notificationProvider.hasNewNotifications)
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Center(
                            child: Text(
                              '!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Notifications',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.blueAccent[700],
            unselectedItemColor: Colors.grey[500],
            onTap: _onItemTapped,
            elevation: 5.0,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
          );
        },
      ),
    );
  }
}
