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
          orderCounts[dateStr] = (orderCounts[dateStr] ?? 0) + 1;
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
      spots.add(FlSpot(currentDate.difference(startDate).inDays.toDouble(), data[dateStr]?.toDouble() ?? 0));
      currentDate = currentDate.add(Duration(days: 1));
    }

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
              return LineTooltipItem(
                '${spot.x.toInt() + startDate.day}/${startDate.month}: ${spot.y.toInt()} orders',
                TextStyle(color: Colors.white),
              );
            }).toList(),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey[300], strokeWidth: 1);
          },
          getDrawingVerticalLine: (value) {
            return FlLine(color: Colors.grey[300], strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final date = startDate.add(Duration(days: value.toInt()));
                return Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text('${date.day}/${date.month}', style: TextStyle(color: Colors.black, fontSize: 10)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}', style: TextStyle(color: Colors.black, fontSize: 10));
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        minX: 0,
        maxX: endDate.difference(startDate).inDays.toDouble(),
        minY: 0,
        maxY: data.values.reduce((a, b) => a > b ? a : b).toDouble() + 1,
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
