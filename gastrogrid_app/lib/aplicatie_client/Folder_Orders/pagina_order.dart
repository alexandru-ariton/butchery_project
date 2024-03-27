// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, unnecessary_string_escapes, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';



class OrderPage extends StatefulWidget {
  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final List<Order> orders = [
    Order('Marios Pizza', 38.02, '09 Mar, 2024 16:23', 'Delivered', 'C:\Users\arito\Documents\GitHub\licenta\assets\images\account_icon.svg'),
    Order('Bodrum Turkish Kitchen', 31.12, '05 Mar, 2024 16:56', 'Delivered', 'C:\Users\arito\Documents\GitHub\licenta\assets\images\account_icon.svg'),
    // Adăugați restul comenzilor aici
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return OrderWidget(order: orders[index]);
        },
      ),
    );
  }
}

class Order {
  String restaurantName;
  double price;
  String date;
  String status;
  String imagePath;

  Order(this.restaurantName, this.price, this.date, this.status, this.imagePath);
}

class OrderWidget extends StatelessWidget {
  final Order order;

  OrderWidget({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.asset(order.imagePath, width: 60, height: 60, fit: BoxFit.cover), // Ensure you have an image for the path provided
        ),
        title: Text(order.restaurantName),
        subtitle: Text('${order.price.toStringAsFixed(2)} lei'),
        trailing: SizedBox(
          width: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(order.date, style: TextStyle(color: Colors.white70)),
              Text(order.status, style: TextStyle(color: Colors.green)),
            ],
          ),
        ),
      ),
    );
  }
}
