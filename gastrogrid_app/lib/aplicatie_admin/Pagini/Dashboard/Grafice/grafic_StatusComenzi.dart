import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class RawMaterialsAndProductsChart extends StatelessWidget {
  const RawMaterialsAndProductsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('rawMaterials').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                Map<String, int> rawMaterialsData = {};
                for (var doc in snapshot.data!.docs) {
                  var data = doc.data() as Map<String, dynamic>?;
                  String? materialName = data != null ? data['name'] as String? : null;
                  var quantity = data != null ? data['quantity'] : null;

                  if (materialName != null && quantity != null) {
                    rawMaterialsData[materialName] = (quantity is int) ? quantity : (quantity as double).toInt();
                  }
                }

                var series = [
                  charts.Series<MapEntry<String, int>, String>(
                    id: 'Materii Prime',
                    domainFn: (MapEntry<String, int> entry, _) => entry.key,
                    measureFn: (MapEntry<String, int> entry, _) => entry.value,
                    data: rawMaterialsData.entries.toList(),
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
                            'Cantitate',
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
                              vertical: true,
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                Map<String, int> productsData = {};
                for (var doc in snapshot.data!.docs) {
                  var data = doc.data() as Map<String, dynamic>?;
                  String? productName = data != null ? data['title'] as String? : null;
                  var quantity = data != null ? data['quantity'] : null;

                  if (productName != null && quantity != null) {
                    productsData[productName] = (quantity is int) ? quantity : (quantity as double).toInt();
                  }
                }

                var series = [
                  charts.Series<MapEntry<String, int>, String>(
                    id: 'Produse',
                    domainFn: (MapEntry<String, int> entry, _) => entry.key,
                    measureFn: (MapEntry<String, int> entry, _) => entry.value,
                    data: productsData.entries.toList(),
                    labelAccessorFn: (MapEntry<String, int> entry, _) => '${entry.value}',
                    colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
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
                            'Cantitate',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          SizedBox(height: 8.0),
                          Expanded(
                            child: charts.BarChart(
                              series,
                              animate: true,
                              animationDuration: Duration(seconds: 1),
                              vertical: true,
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
