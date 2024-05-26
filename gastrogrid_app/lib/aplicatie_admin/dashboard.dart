import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6, // Update the length to 6 to include the new tab
      child: Scaffold(
        appBar: AppBar(
          title: Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
          bottom: TabBar(
            indicatorColor: Colors.teal,
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.bar_chart), text: 'Total Orders'),
              Tab(icon: Icon(Icons.show_chart), text: 'Total Revenue'),
              Tab(icon: Icon(Icons.pie_chart), text: 'Product Sales'),
              Tab(icon: Icon(Icons.timeline), text: 'Orders Over Time'),
              Tab(icon: Icon(Icons.star), text: 'Top Products'),
              Tab(icon: Icon(Icons.rate_review), text: 'Ratings'), // New tab for ratings
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TotalOrdersChart(),
            TotalRevenueChart(),
            ProductSalesChart(),
            OrdersOverTimeChart(),
            TopSellingProductsChart(),
            RatingsChart(), // New tab content for ratings
          ],
        ),
      ),
    );
  }
}

class TotalOrdersChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        int totalOrders = snapshot.data!.docs.length;
        return Center(
          child: Text('Total Orders: $totalOrders', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        );
      },
    );
  }
}

class TotalRevenueChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        double totalRevenue = snapshot.data!.docs.fold(0, (sum, doc) => sum + (doc['total'] ?? 0));
        return Center(
          child: Text('Total Revenue: ${totalRevenue.toStringAsFixed(2)} lei', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        );
      },
    );
  }
}

class ProductSalesChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          print('No data available.');
          return CircularProgressIndicator();
        }

        Map<String, double> productSales = {};

        for (var doc in snapshot.data!.docs) {
          var items = doc['items'] as List<dynamic>? ?? [];
          print('Order ID: ${doc.id}, Items: $items');  // Print order ID and items

          for (var item in items) {
            if (item is Map<String, dynamic>) {
              var productId = item['productId'] as String?;
              if (productId == null || productId.isEmpty) {
                productId = 'Unknown';
              }
              var quantity = (item['quantity'] ?? 0).toDouble();
              print('Product ID: $productId, Quantity: $quantity');  // Print product ID and quantity

              if (productSales.containsKey(productId)) {
                productSales[productId] = productSales[productId]! + quantity;
              } else {
                productSales[productId] = quantity;
              }
            } else {
              print('Invalid item format: $item');
            }
          }
        }

        print('Product Sales: $productSales');  // Print final product sales map

        if (productSales.isEmpty) {
          return Center(
            child: Text('No sales data available.'),
          );
        }

        var series = [
          charts.Series<MapEntry<String, double>, String>(
            id: 'ProductSales',
            domainFn: (MapEntry<String, double> entry, _) => entry.key,
            measureFn: (MapEntry<String, double> entry, _) => entry.value,
            data: productSales.entries.toList(),
          )
        ];

        return charts.BarChart(
          series,
          animate: true,
        );
      },
    );
  }
}

class OrdersOverTimeChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        var data = snapshot.data!.docs.map((doc) {
          Timestamp timestamp = doc['timestamp'] ?? Timestamp.now();
          return TimeSeriesSales(
            time: timestamp.toDate(),
            sales: doc['total'] ?? 0,
          );
        }).toList();

        var series = [
          charts.Series<TimeSeriesSales, DateTime>(
            id: 'SalesOverTime',
            domainFn: (TimeSeriesSales sales, _) => sales.time,
            measureFn: (TimeSeriesSales sales, _) => sales.sales,
            data: data,
          )
        ];

        return charts.TimeSeriesChart(
          series,
          animate: true,
        );
      },
    );
  }
}

class TopSellingProductsChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        Map<String, double> productSales = {};

        for (var doc in snapshot.data!.docs) {
          var items = doc['items'] as List<dynamic>;
          for (var item in items) {
            var productId = item['productId'] as String?;
            if (productId == null || productId.isEmpty) {
              productId = 'Unknown';
            }
            var quantity = (item['quantity'] ?? 0).toDouble();
            if (productSales.containsKey(productId)) {
              productSales[productId] = productSales[productId]! + quantity;
            } else {
              productSales[productId] = quantity;
            }
          }
        }

        var sortedProductSales = productSales.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        var topProductSales = sortedProductSales.take(5).toList();

        var series = [
          charts.Series<MapEntry<String, double>, String>(
            id: 'TopProducts',
            domainFn: (MapEntry<String, double> entry, _) => entry.key,
            measureFn: (MapEntry<String, double> entry, _) => entry.value,
            data: topProductSales,
          )
        ];

        return charts.PieChart(
          series,
          animate: true,
        );
      },
    );
  }
}

class RatingsChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('ratings').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        var ratings = snapshot.data!.docs.map((doc) {
          return Rating(
            rating: doc['rating'] ?? 0,
            timestamp: (doc['timestamp'] as Timestamp).toDate(),
          );
        }).toList();

        var groupedRatings = <int, int>{};
        for (var rating in ratings) {
          groupedRatings[rating.rating] = (groupedRatings[rating.rating] ?? 0) + 1;
        }

        var series = [
          charts.Series<MapEntry<int, int>, String>(
            id: 'Ratings',
            domainFn: (MapEntry<int, int> entry, _) => entry.key.toString(),
            measureFn: (MapEntry<int, int> entry, _) => entry.value,
            data: groupedRatings.entries.toList(),
          )
        ];

        return charts.BarChart(
          series,
          animate: true,
        );
      },
    );
  }
}

class Rating {
  final int rating;
  final DateTime timestamp;

  Rating({required this.rating, required this.timestamp});
}

class SalesData {
  final String title;
  final double price;

  SalesData({required this.title, required this.price});
}

class TimeSeriesSales {
  final DateTime time;
  final double sales;

  TimeSeriesSales({required this.time, required this.sales});
}
