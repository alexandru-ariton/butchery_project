import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:fl_chart/fl_chart.dart';

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

        return charts.TimeSeriesChart(
          series,
          animate: true,
          dateTimeFactory: const charts.LocalDateTimeFactory(),
          behaviors: [charts.ChartTitle('Daily Orders')],
        );
      },
    );
  }
}

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



class HeatmapChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        Map<String, int> orderCounts = {};
        for (var doc in snapshot.data!.docs) {
          var timestamp = (doc['timestamp'] as Timestamp).toDate();
          var dateStr = "${timestamp.year}-${timestamp.month}-${timestamp.day}";
          if (orderCounts.containsKey(dateStr)) {
            orderCounts[dateStr] = orderCounts[dateStr]! + 1;
          } else {
            orderCounts[dateStr] = 1;
          }
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: AspectRatio(
            aspectRatio: 1.5,
            child: Heatmap(
              data: orderCounts,
              startDate: DateTime.now().subtract(Duration(days: 30)),
              endDate: DateTime.now(),
            ),
          ),
        );
      },
    );
  }
}

class Heatmap extends StatelessWidget {
  final Map<String, int> data;
  final DateTime startDate;
  final DateTime endDate;

  Heatmap({
    required this.data,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = [];
    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      var dateStr = "${currentDate.year}-${currentDate.month}-${currentDate.day}";
      if (data.containsKey(dateStr)) {
        spots.add(FlSpot(currentDate.difference(startDate).inDays.toDouble(), data[dateStr]!.toDouble()));
      } else {
        spots.add(FlSpot(currentDate.difference(startDate).inDays.toDouble(), 0));
      }
      currentDate = currentDate.add(Duration(days: 1));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: endDate.difference(startDate).inDays.toDouble(),
        minY: 0,
        maxY: data.values.reduce((a, b) => a > b ? a : b).toDouble(),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 4,
            belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
          ),
        ],
      ),
    );
  }
}



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


