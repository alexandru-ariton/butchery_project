import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Dashboard'),
          bottom: TabBar(
            indicatorColor: Colors.teal,
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.bar_chart), text: 'Total Orders'),
              Tab(icon: Icon(Icons.show_chart), text: 'Total Revenue'),
              Tab(icon: Icon(Icons.pie_chart), text: 'Product Sales'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TotalOrdersChart(),
            TotalRevenueChart(),
            ProductSalesChart(),
          ],
        ),
      ),
    );
  }
}

class TotalOrdersChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        int totalOrders = snapshot.data!.docs.length;
        return Center(
          child: Text('Total Orders: $totalOrders', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        );
      },
    );
  }
}

class TotalRevenueChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        double totalRevenue = snapshot.data!.docs.fold(0, (sum, doc) => sum + doc['total']);
        return Center(
          child: Text('Total Revenue: ${totalRevenue.toStringAsFixed(2)} lei', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        );
      },
    );
  }
}

class ProductSalesChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        var data = snapshot.data!.docs.map((doc) {
          return SalesData(
            title: doc['title'],
            price: doc['price'],
          );
        }).toList();

        var series = [
          charts.Series<SalesData, String>(
            id: 'Sales',
            domainFn: (SalesData sales, _) => sales.title,
            measureFn: (SalesData sales, _) => sales.price,
            data: data,
          )
        ];

        return charts.BarChart(
          series,
          animate: true,
        );
      },
    );
  }
}

class SalesData {
  final String title;
  final double price;

  SalesData({required this.title, required this.price});
}
