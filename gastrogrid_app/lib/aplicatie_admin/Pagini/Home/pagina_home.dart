import 'package:flutter/material.dart';
import 'package:gastrogrid_app/Autentificare/pagini/pagina_login.dart';
import 'package:gastrogrid_app/aplicatie_admin/Pagini/Furnizori/pagina_furnizori.dart';
import 'package:gastrogrid_app/aplicatie_admin/Pagini/Notificari/pagina_notificari.dart';
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
                  Tab(icon: Icon(Icons.shopping_bag, size: 28), text: 'Produse'),
                  Tab(icon: Icon(Icons.receipt, size: 28), text: 'Comenzi'),
                  Tab(icon: Icon(Icons.notifications, size: 28), text: 'Notificari'),
                  Tab(icon: Icon(Icons.public_rounded, size: 28), text: 'Furnizori'),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            Dashboard(),
            ProductManagement(),
            OrderManagement(),
            LowStockNotificationPage(),
            SupplierManagementPage(),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PaginaLogin()),
    );
  }
}
