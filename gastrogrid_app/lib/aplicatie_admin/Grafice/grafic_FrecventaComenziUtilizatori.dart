import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;




class CustomerOrderFrequencyChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').limit(100).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        Map<String, int> customerOrderFrequency = {};
        for (var doc in snapshot.data!.docs) {
          var userId = doc['userId'] as String?;
          customerOrderFrequency[userId!] = (customerOrderFrequency[userId] ?? 0) + 1;
        }

        var series = [
          charts.Series<MapEntry<String, int>, String>(
            id: 'CustomerOrderFrequency',
            domainFn: (MapEntry<String, int> entry, _) => entry.key,
            measureFn: (MapEntry<String, int> entry, _) => entry.value,
            data: customerOrderFrequency.entries.toList(),
          )
        ];

        return charts.BarChart(
          series,
          animate: true,
          behaviors: [charts.ChartTitle('Customer Order Frequency')],
        );
      },
    );
  }
}