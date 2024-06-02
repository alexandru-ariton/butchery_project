import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class MonthlyRevenueChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').limit(100).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        Map<String, double> monthlyRevenue = {};
        for (var doc in snapshot.data!.docs) {
          Timestamp timestamp = doc['timestamp'];
          String month = "${timestamp.toDate().year}-${timestamp.toDate().month}";
          monthlyRevenue[month] = (monthlyRevenue[month] ?? 0) + (doc['total'] ?? 0);
        }

        var series = [
          charts.Series<MapEntry<String, double>, String>(
            id: 'MonthlyRevenue',
            domainFn: (MapEntry<String, double> entry, _) => entry.key,
            measureFn: (MapEntry<String, double> entry, _) => entry.value,
            data: monthlyRevenue.entries.toList(),
          )
        ];

        return charts.BarChart(
          series,
          animate: true,
          behaviors: [charts.ChartTitle('Monthly Revenue')],
        );
      },
    );
  }
}
