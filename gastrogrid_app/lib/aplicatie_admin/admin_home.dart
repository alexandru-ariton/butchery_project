import 'package:flutter/material.dart';
import 'product_management.dart';
import 'order_management.dart';
import 'dashboard.dart';

class AdminHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
          backgroundColor: Colors.teal,
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.dashboard, size: 28), text: 'Dashboard'),
              Tab(icon: Icon(Icons.shopping_bag, size: 28), text: 'Products'),
              Tab(icon: Icon(Icons.receipt, size: 28), text: 'Orders'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Dashboard(),
            ProductManagement(),
            OrderManagement(),
          ],
        ),
      ),
    );
  }
}
