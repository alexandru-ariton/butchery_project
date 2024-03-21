import 'package:flutter/material.dart';



class SupportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pagina de Suport'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Salut, Alex! Cu ce te pot ajuta?',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            OrderCard(
              restaurantName: 'Marios Pizza',
              orderDate: 'Sâmbătă, 9 martie - 16:01',
              orderPrice: '38,02 lei',
            ),
            SizedBox(height: 20),
            SupportOptionCard(
              icon: Icons.person,
              title: 'Contactează un agent de suport',
            ),
            SizedBox(height: 10),
            SupportOptionCard(
              icon: Icons.article,
              title: 'Răsfoiește articolele de ajutor',
            ),
            Spacer(),
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: () {
                  // Navighează către inbox
                },
                child: Text('Inbox'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final String restaurantName;
  final String orderDate;
  final String orderPrice;

  const OrderCard({
    Key? key,
    required this.restaurantName,
    required this.orderDate,
    required this.orderPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comenzile mele',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              restaurantName,
              style: TextStyle(fontSize: 14),
            ),
            Text(
              orderDate,
              style: TextStyle(fontSize: 14),
            ),
            Text(
              orderPrice,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class SupportOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const SupportOptionCard({
    Key? key,
    required this.icon,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        SizedBox(width: 10),
        Text(title),
      ],
    );
  }
}
