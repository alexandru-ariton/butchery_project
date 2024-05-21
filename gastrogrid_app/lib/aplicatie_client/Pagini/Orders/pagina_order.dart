// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, avoid_print, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';

class OrdersPage extends StatelessWidget {
  final List<Order> orders = [
    Order('Pizza Margherita', '12.99', 'În curs de livrare'),
    Order('Pasta Carbonara', '15.49', 'Livrată'),
    // Adaugă aici restul comenzilor
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text('Comenzile mele')),
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return OrderCard(order: orders[index], onReload: () {
            // Adaugă aici logica pentru reexecutarea comenzii
            print('Reexecută comanda: ${orders[index].name}');
          });
        },
      ),
    );
  }
}

class Order {
  String name;
  String price;
  String status;

  Order(this.name, this.price, this.status);
}

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onReload;

  OrderCard({required this.order, required this.onReload});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        title: Text(order.name),
        subtitle: Text('Preț: ${order.price}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min, // Asigură că elementele fiilor sunt alăturate
          children: [
            Text(order.status),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: onReload,
            ),
          ],
        ),
      ),
    );
  }
}