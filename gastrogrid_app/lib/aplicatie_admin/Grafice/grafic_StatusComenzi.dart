import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;


class OrderStatusDistributionChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').limit(100).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        Map<String, int> orderStatusCount = {};
        for (var doc in snapshot.data!.docs) {
          var status = doc['status'] as String?;
          orderStatusCount[status!] = (orderStatusCount[status] ?? 0) + 1;
        }

        var series = [
          charts.Series<MapEntry<String, int>, String>(
            id: 'OrderStatusDistribution',
            domainFn: (MapEntry<String, int> entry, _) => entry.key,
            measureFn: (MapEntry<String, int> entry, _) => entry.value,
            data: orderStatusCount.entries.toList(),
          )
        ];

        return charts.BarChart(
          series,
          animate: true,
          vertical: false,
          barRendererDecorator: charts.BarLabelDecorator<String>(),
          behaviors: [charts.ChartTitle('Order Status Distribution')],
          domainAxis: charts.OrdinalAxisSpec(renderSpec: charts.SmallTickRendererSpec(labelRotation: 60)),
        );
      },
    );
  }
}