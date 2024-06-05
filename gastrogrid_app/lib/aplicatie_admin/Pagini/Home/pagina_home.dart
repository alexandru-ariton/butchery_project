import 'package:flutter/material.dart';
import 'package:GastroGrid/Autentificare/pagini/pagina_login.dart';
import 'package:GastroGrid/aplicatie_admin/Pagini/Materii%20Prime/pagina_materii_prime.dart';
import 'package:GastroGrid/aplicatie_admin/Pagini/Notificari/pagina_notificari.dart';
import '../Produs/pagina_produse.dart';
import '../Comenzi/pagina_comenzi.dart';
import '../Dashboard/pagina_dashboard.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              'Admin Dashboard',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
          backgroundColor: Colors.teal,
          actions: [
            PopupMenuButton<String>(
              onSelected: (String result) {
                if (result == 'Logout') {
                  _logout(context);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'Logout',
                  child: Text('Logout'),
                ),
              ],
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Container(
              alignment: Alignment.center,
              child: TabBar(
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(icon: Icon(Icons.dashboard, size: 28), text: 'Dashboard'),
                  Tab(icon: Icon(Icons.shopping_bag, size: 28), text: 'Products'),
                  Tab(icon: Icon(Icons.receipt, size: 28), text: 'Orders'),
                  Tab(icon: Icon(Icons.notifications, size: 28), text: 'Notifications'),
                  Tab(icon: Icon(Icons.check_box_outline_blank_rounded, size: 28), text: 'Materii Prime'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: const [
            Dashboard(),
            ProductManagement(),
            OrderManagement(),
            LowStockNotificationPage(),
            RawMaterialsManagement(),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PaginaLogin()), // Navigate to your login page
    );
  }
}
