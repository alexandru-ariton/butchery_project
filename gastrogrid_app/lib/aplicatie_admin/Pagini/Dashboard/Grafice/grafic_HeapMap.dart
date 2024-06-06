import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class OrderLineChart extends StatelessWidget {
  const OrderLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Eroare'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('-'));
        }

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
            child: OrderLineChartWidget(
              data: orderCounts,
              startDate: DateTime.now().subtract(Duration(days: 7)),
              endDate: DateTime.now(),
            ),
          ),
        );
      },
    );
  }
}

class OrderLineChartWidget extends StatelessWidget {
  final Map<String, int> data;
  final DateTime startDate;
  final DateTime endDate;

  const OrderLineChartWidget({
    super.key,
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
              final date = startDate.add(Duration(days: spot.x.toInt()));
              return LineTooltipItem(
                '${date.day}/${date.month}: ${spot.y.toInt()} comenzi',
                TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
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
            axisNameWidget: Text('Data', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final date = startDate.add(Duration(days: value.toInt()));
                return Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text('${date.day}/${date.month}', style: TextStyle(color: Colors.black, fontSize: 12)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: Text('Comenzi', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: Text('${value.toInt()}', style: TextStyle(color: Colors.black, fontSize: 12)),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.black, width: 1),
        ),
        minX: 0,
        maxX: endDate.difference(startDate).inDays.toDouble(),
        minY: 0,
        maxY: (data.values.isNotEmpty ? data.values.reduce((a, b) => a > b ? a : b).toDouble() : 0) + 1,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blueAccent,
            barWidth: 3,
            belowBarData: BarAreaData(show: true, color: Colors.blueAccent.withOpacity(0.2)),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(radius: 3, color: Colors.blue, strokeWidth: 2, strokeColor: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
