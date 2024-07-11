import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:math';

class ProductsAndSuppliersChart extends StatelessWidget {
  const ProductsAndSuppliersChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Column(
        children: [
          Expanded(
            child: _buildProductsChart(),
          ),
          Expanded(
            child: _buildSuppliersChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsChart() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

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
            id: 'Products',
            domainFn: (MapEntry<String, int> entry, _) => entry.key,
            measureFn: (MapEntry<String, int> entry, _) => entry.value,
            data: productsData.entries.toList(),
            labelAccessorFn: (MapEntry<String, int> entry, _) => '${entry.key}: ${entry.value}',
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
                    'Cantitatea produselor',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8.0),
                  Expanded(
                    child: charts.BarChart(
                      series,
                      animate: true,
                      animationDuration: const Duration(seconds: 1),
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
    );
  }

  Future<Map<String, List<String>>> _getSuppliersData() async {
    Map<String, List<String>> suppliersData = {};

    QuerySnapshot productsSnapshot = await FirebaseFirestore.instance.collection('products').get();

    for (var productDoc in productsSnapshot.docs) {
      var productData = productDoc.data() as Map<String, dynamic>?;
      String? productName = productData != null ? productData['title'] as String? : null;

      if (productName != null) {
        QuerySnapshot suppliersSnapshot = await productDoc.reference.collection('suppliers').get();

        for (var supplierDoc in suppliersSnapshot.docs) {
          var supplierData = supplierDoc.data() as Map<String, dynamic>?;
          String? supplierName = supplierData != null ? supplierData['name'] as String? : null;

          if (supplierName != null) {
            suppliersData[supplierName] = (suppliersData[supplierName] ?? [])..add(productName);
          }
        }
      }
    }

    return suppliersData;
  }

  Widget _buildSuppliersChart() {
    return FutureBuilder<Map<String, List<String>>>(
      future: _getSuppliersData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        var suppliersData = snapshot.data!;
        var series = [
          charts.Series<MapEntry<String, List<String>>, String>(
            id: 'Suppliers',
            domainFn: (MapEntry<String, List<String>> entry, _) => entry.key,
            measureFn: (MapEntry<String, List<String>> entry, _) => entry.value.length,
            data: suppliersData.entries.toList(),
            labelAccessorFn: (MapEntry<String, List<String>> entry, _) => '${entry.key}: ${entry.value.length}',
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
                    'Furnizorii produselor',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8.0),
                  Expanded(
                    child: charts.BarChart(
                      series,
                      animate: true,
                      animationDuration: const Duration(seconds: 1),
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
                      behaviors: [
                        charts.SelectNearest(
                          eventTrigger: charts.SelectionTrigger.tapAndDrag,
                        ),
                        charts.LinePointHighlighter(
                          showHorizontalFollowLine: charts.LinePointHighlighterFollowLineType.none,
                          showVerticalFollowLine: charts.LinePointHighlighterFollowLineType.nearest,
                          symbolRenderer: CustomCircleSymbolRenderer(suppliersData: suppliersData),
                        ),
                      ],
                      selectionModels: [
                        charts.SelectionModelConfig(
                          type: charts.SelectionModelType.info,
                          changedListener: (charts.SelectionModel model) {
                            if (model.hasDatumSelection) {
                              final selectedDatum = model.selectedDatum[0];
                              final supplierName = selectedDatum.datum.key;
                              final products = suppliersData[supplierName]!;
                              
                              print('Furnizorul selectat: $supplierName, Produsele: $products');
                            }
                          },
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

class CustomCircleSymbolRenderer extends charts.CircleSymbolRenderer {
  final Map<String, List<String>> suppliersData;

  CustomCircleSymbolRenderer({required this.suppliersData});

  @override
  void paint(
    charts.ChartCanvas canvas,
    Rectangle<num> bounds, {
    List<int>? dashPattern,
    charts.Color? fillColor,
    charts.FillPatternType? fillPattern,
    charts.Color? strokeColor,
    double? strokeWidthPx,
  }) {
    super.paint(
      canvas,
      bounds,
      dashPattern: dashPattern,
      fillColor: fillColor,
      fillPattern: fillPattern,
      strokeColor: strokeColor,
      strokeWidthPx: strokeWidthPx,
    );

   final textStyle = charts.TextStyleSpec(color: charts.MaterialPalette.black, fontSize: 12);
    final selectedSupplier = suppliersData.keys.elementAt(bounds.left.toInt() % suppliersData.length);
    final products = suppliersData[selectedSupplier]!.join(', ');

    final textElementSupplier = canvas.graphicsFactory.createTextElement(selectedSupplier)
      ..textStyle = textStyle as charts.TextStyle?;
    final textElementProducts = canvas.graphicsFactory.createTextElement(products)
      ..textStyle = textStyle as charts.TextStyle?;

    final backgroundBounds = Rectangle(bounds.left - 5, bounds.top - 25, bounds.width + 10, bounds.height + 25);
    canvas.drawRect(
      backgroundBounds,
      fill: charts.MaterialPalette.white,
      stroke: charts.MaterialPalette.black,
    );

    canvas.drawText(
      textElementSupplier,
      (bounds.left).round(),
      (bounds.top - 20).round(),
    );

    canvas.drawText(
      textElementProducts,
      (bounds.left).round(),
      (bounds.top - 5).round(),
    );
  }
}