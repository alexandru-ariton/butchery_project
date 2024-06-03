import 'package:flutter/material.dart';
import 'package:gastrogrid_app/aplicatie_admin/Pagini/pagina_materiiPrime.dart';
import 'package:gastrogrid_app/aplicatie_admin/Pagini/pagina_notificari.dart';
import 'Produs/pagina_produse.dart';
import 'Comenzi/pagina_comenzi.dart';
import 'pagina_dashboard.dart';

class AdminHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Center(child: Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24))),
          backgroundColor: Colors.teal,
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.dashboard, size: 28), text: 'Dashboard'),
              Tab(icon: Icon(Icons.shopping_bag, size: 28), text: 'Products'),
              Tab(icon: Icon(Icons.receipt, size: 28), text: 'Orders'),
              Tab(icon: Icon(Icons.notifications, size: 28), text: 'Notifications'),
              Tab(icon: Icon(Icons.check_box_outline_blank_rounded, size: 28), text: 'Materii Prime'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
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
}
