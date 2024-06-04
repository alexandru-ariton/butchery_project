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
            colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
            labelAccessorFn: (MapEntry<DateTime, int> entry, _) => '${entry.value}',
          )
        ];

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Orders',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: charts.TimeSeriesChart(
                      series,
                      animate: true,
                      dateTimeFactory: const charts.LocalDateTimeFactory(),
                      behaviors: [
                        charts.ChartTitle(
                          'Date',
                          behaviorPosition: charts.BehaviorPosition.bottom,
                          titleOutsideJustification: charts.OutsideJustification.middleDrawArea,
                        ),
                        charts.ChartTitle(
                          'Number of Orders',
                          behaviorPosition: charts.BehaviorPosition.start,
                          titleOutsideJustification: charts.OutsideJustification.middleDrawArea,
                        ),
                      ],
                      primaryMeasureAxis: charts.NumericAxisSpec(
                        renderSpec: charts.GridlineRendererSpec(
                          labelStyle: charts.TextStyleSpec(
                            fontSize: 12,
                            color: charts.MaterialPalette.black,
                          ),
                        ),
                      ),
                      domainAxis: charts.DateTimeAxisSpec(
                        renderSpec: charts.GridlineRendererSpec(
                          labelStyle: charts.TextStyleSpec(
                            fontSize: 12,
                            color: charts.MaterialPalette.black,
                          ),
                        ),
                      ),
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
