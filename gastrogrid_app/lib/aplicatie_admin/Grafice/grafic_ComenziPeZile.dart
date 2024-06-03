import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class DailyOrdersChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').limit(100).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        Map<DateTime, int> dailyOrders = {};
        for (var doc in snapshot.data!.docs) {
          Timestamp timestamp = doc['timestamp'];
          DateTime date = DateTime(timestamp.toDate().year, timestamp.toDate().month, timestamp.toDate().day);
          dailyOrders[date] = (dailyOrders[date] ?? 0) + 1;
        }

        var series = [
          charts.Series<MapEntry<DateTime, int>, DateTime>(
            id: 'DailyOrders',
            domainFn: (MapEntry<DateTime, int> entry, _) => entry.key,
            measureFn: (MapEntry<DateTime, int> entry, _) => entry.value,
            data: dailyOrders.entries.toList(),
          )
        ];

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    'Daily Orders',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Expanded(
                    child: charts.TimeSeriesChart(
                      series,
                      animate: true,
                      dateTimeFactory: const charts.LocalDateTimeFactory(),
                      behaviors: [charts.ChartTitle('Daily Orders')],
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
