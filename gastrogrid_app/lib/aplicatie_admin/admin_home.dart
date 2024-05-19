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
          title: Text('Admin Dashboard'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
              Tab(icon: Icon(Icons.shopping_bag), text: 'Products'),
              Tab(icon: Icon(Icons.receipt), text: 'Orders'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ProductManagement(),
            OrderManagement(),
          ],
        ),
      ),
    );
  }
}
