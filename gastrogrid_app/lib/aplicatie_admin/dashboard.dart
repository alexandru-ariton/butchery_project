import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Column(
        children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('orders').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();
              int totalOrders = snapshot.data!.docs.length;
              double totalRevenue = snapshot.data!.docs.fold(0, (sum, doc) => sum + doc['total']);
              return Column(
                children: [
                  Text('Total Orders: $totalOrders'),
                  Text('Total Revenue: ${totalRevenue.toStringAsFixed(2)} lei'),
                ],
              );
            },
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                var data = snapshot.data!.docs.map((doc) {
                  return charts.Series(
                    id: 'Sales',
                    data: [doc],
                    domainFn: (dynamic sales, _) => sales['title'],
                    measureFn: (dynamic sales, _) => sales['price'],
                  );
                }).toList();
                return charts.BarChart(data.cast<charts.Series<dynamic, String>>());
              },
            ),
          ),
        ],
      ),
    );
  }
}
