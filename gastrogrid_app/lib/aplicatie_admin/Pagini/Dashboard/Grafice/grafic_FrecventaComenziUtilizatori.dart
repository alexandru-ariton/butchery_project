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

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Customer Order Frequency',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8.0),
                  Expanded(
                    child: charts.BarChart(
                      series,
                      animate: true,
                      vertical: false, // Set to true for vertical bars, false for horizontal bars
                      behaviors: [charts.ChartTitle('Customer Order Frequency')],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
