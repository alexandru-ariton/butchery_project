import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';


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