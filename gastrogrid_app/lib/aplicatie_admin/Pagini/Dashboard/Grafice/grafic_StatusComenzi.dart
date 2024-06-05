import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class OrderStatusDistributionChart extends StatelessWidget {
  const OrderStatusDistributionChart({super.key});

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
            labelAccessorFn: (MapEntry<String, int> entry, _) => '${entry.value}', // Label for data points
            colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault, // Bar color
          )
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            double chartWidth = constraints.maxWidth * 0.95;
            double chartHeight = constraints.maxHeight * 0.85;

            return Center(
              child: Container(
                width: chartWidth,
                height: chartHeight,
                padding: const EdgeInsets.all(16.0),
                child: charts.BarChart(
                  series,
                  animate: true,
                  vertical: true, // Vertical bar chart
                  barRendererDecorator: charts.BarLabelDecorator<String>(
                    insideLabelStyleSpec: charts.TextStyleSpec(fontSize: 14, color: charts.MaterialPalette.white),
                    outsideLabelStyleSpec: charts.TextStyleSpec(fontSize: 14, color: charts.MaterialPalette.black),
                  ),
                  behaviors: [
                    charts.ChartTitle(
                      'Order Status Distribution',
                      behaviorPosition: charts.BehaviorPosition.top,
                      titleOutsideJustification: charts.OutsideJustification.middleDrawArea,
                      innerPadding: 16,
                      titleStyleSpec: charts.TextStyleSpec(fontSize: 18, fontWeight: 'bold'),
                    ),
                  ],
                  domainAxis: charts.OrdinalAxisSpec(
                    renderSpec: charts.SmallTickRendererSpec(
                      labelRotation: 45,
                      labelStyle: charts.TextStyleSpec(
                        fontSize: 14,
                        color: charts.MaterialPalette.black,
                      ),
                    ),
                  ),
                  primaryMeasureAxis: charts.NumericAxisSpec(
                    renderSpec: charts.GridlineRendererSpec(
                      labelStyle: charts.TextStyleSpec(
                        fontSize: 14,
                        color: charts.MaterialPalette.black,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
