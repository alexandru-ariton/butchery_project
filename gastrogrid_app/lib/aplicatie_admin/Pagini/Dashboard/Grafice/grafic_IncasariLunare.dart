import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class MonthlyRevenueChart extends StatelessWidget {
  const MonthlyRevenueChart({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').limit(100).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        Map<String, double> monthlyRevenue = {};
        for (var doc in snapshot.data!.docs) {
          Timestamp timestamp = doc['timestamp'];
          String month = "${timestamp.toDate().year}-${timestamp.toDate().month.toString().padLeft(2, '0')}";
          monthlyRevenue[month] = (monthlyRevenue[month] ?? 0) + (doc['total'] ?? 0);
        }

        var series = [
          charts.Series<MapEntry<String, double>, String>(
            id: 'MonthlyRevenue',
            domainFn: (MapEntry<String, double> entry, _) => entry.key,
            measureFn: (MapEntry<String, double> entry, _) => entry.value,
            data: monthlyRevenue.entries.toList(),
            colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
            labelAccessorFn: (MapEntry<String, double> entry, _) => entry.value.toStringAsFixed(2),
          )
        ];

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Monthly Revenue',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: charts.BarChart(
                      series,
                      animate: true,
                      vertical: true,
                      barRendererDecorator: charts.BarLabelDecorator<String>(
                        insideLabelStyleSpec: charts.TextStyleSpec(fontSize: 12, color: charts.MaterialPalette.white),
                        outsideLabelStyleSpec: charts.TextStyleSpec(fontSize: 12, color: charts.MaterialPalette.black),
                      ),
                      behaviors: [
                        charts.ChartTitle(
                          'Month',
                          behaviorPosition: charts.BehaviorPosition.bottom,
                          titleOutsideJustification: charts.OutsideJustification.middleDrawArea,
                          innerPadding: 16,
                          titleStyleSpec: charts.TextStyleSpec(fontSize: 14),
                        ),
                        charts.ChartTitle(
                          'Revenue',
                          behaviorPosition: charts.BehaviorPosition.start,
                          titleOutsideJustification: charts.OutsideJustification.middleDrawArea,
                          innerPadding: 16,
                          titleStyleSpec: charts.TextStyleSpec(fontSize: 14),
                        ),
                      ],
                      domainAxis: charts.OrdinalAxisSpec(
                        renderSpec: charts.SmallTickRendererSpec(
                          labelRotation: 45,
                          labelStyle: charts.TextStyleSpec(
                            fontSize: 12,
                            color: charts.MaterialPalette.black,
                          ),
                        ),
                      ),
                      primaryMeasureAxis: charts.NumericAxisSpec(
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
