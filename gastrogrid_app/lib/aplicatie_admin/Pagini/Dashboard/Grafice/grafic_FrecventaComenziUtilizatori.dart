import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class CustomerOrderFrequencyChart extends StatelessWidget {
  const CustomerOrderFrequencyChart({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').limit(100).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        Map<String, int> customerOrderFrequency = {};
        for (var doc in snapshot.data!.docs) {
          var data = doc.data() as Map<String, dynamic>?;

          String? userId = data != null ? data['userId'] as String? : null;
          String? username = data != null ? data['username'] as String? : null;
          String? email = data != null ? data['email'] as String? : null;

          String displayName = username ?? email ?? '-';

          if (userId != null) {
            customerOrderFrequency[displayName] = (customerOrderFrequency[displayName] ?? 0) + 1;
          }
        }

        var series = [
          charts.Series<MapEntry<String, int>, String>(
            id: 'Comenzi Clienti',
            domainFn: (MapEntry<String, int> entry, _) => entry.key,
            measureFn: (MapEntry<String, int> entry, _) => entry.value,
            data: customerOrderFrequency.entries.toList(),
            labelAccessorFn: (MapEntry<String, int> entry, _) => '${entry.value}',
            colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          )
        ];

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Comenzi Clienti',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 8.0),
                  Expanded(
                    child: charts.BarChart(
                      series,
                      animate: true,
                      animationDuration: Duration(seconds: 1),
                      vertical: true, // Set to true for vertical bars, false for horizontal bars
                      barRendererDecorator: charts.BarLabelDecorator<String>(
                        insideLabelStyleSpec: charts.TextStyleSpec(
                            fontSize: 14, color: charts.MaterialPalette.white),
                        outsideLabelStyleSpec: charts.TextStyleSpec(
                            fontSize: 14, color: charts.MaterialPalette.black),
                      ),
                      domainAxis: charts.OrdinalAxisSpec(
                        renderSpec: charts.SmallTickRendererSpec(
                          labelRotation: 45,
                          labelStyle: charts.TextStyleSpec(
                            fontSize: 12,
                            color: charts.MaterialPalette.black,
                          ),
                          lineStyle: charts.LineStyleSpec(
                            color: charts.MaterialPalette.gray.shadeDefault,
                          ),
                        ),
                      ),
                      primaryMeasureAxis: charts.NumericAxisSpec(
                        renderSpec: charts.GridlineRendererSpec(
                          labelStyle: charts.TextStyleSpec(
                            fontSize: 12,
                            color: charts.MaterialPalette.black,
                          ),
                          lineStyle: charts.LineStyleSpec(
                            color: charts.MaterialPalette.gray.shadeDefault,
                          ),
                        ),
                      ),
                      behaviors: [
                        charts.SeriesLegend(
                          position: charts.BehaviorPosition.bottom,
                          horizontalFirst: true,
                          desiredMaxColumns: 1,
                          cellPadding: EdgeInsets.only(right: 4.0, bottom: 4.0),
                          entryTextStyle: charts.TextStyleSpec(
                            color: charts.MaterialPalette.black,
                            fontSize: 12,
                          ),
                        ),
                        charts.ChartTitle(
                          'Numar Comenzi',
                          behaviorPosition: charts.BehaviorPosition.start,
                          titleOutsideJustification:
                              charts.OutsideJustification.middleDrawArea,
                          innerPadding: 16,
                          titleStyleSpec: charts.TextStyleSpec(
                              fontSize: 14, fontWeight: 'bold'),
                        ),
                      ],
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
