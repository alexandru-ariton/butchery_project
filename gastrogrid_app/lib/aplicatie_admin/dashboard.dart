import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('orders').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                int totalOrders = snapshot.data!.docs.length;
                double totalRevenue = snapshot.data!.docs.fold(0, (sum, doc) => sum + doc['total']);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Orders: $totalOrders', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('Total Revenue: ${totalRevenue.toStringAsFixed(2)} lei', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                  ],
                );
              },
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SalesData {
  final String title;
  final double price;

  SalesData({required this.title, required this.price});
}
