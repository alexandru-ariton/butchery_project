import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ProductsAndSuppliersChart extends StatefulWidget {
  const ProductsAndSuppliersChart({super.key});

  @override
  _ProductsAndSuppliersChartState createState() => _ProductsAndSuppliersChartState();
}

class _ProductsAndSuppliersChartState extends State<ProductsAndSuppliersChart> {
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

        Map<String, Map<String, dynamic>> productsData = {};
        for (var doc in snapshot.data!.docs) {
          var data = doc.data() as Map<String, dynamic>?;
          String? productName = data != null ? data['title'] as String? : null;
          var quantity = data != null ? data['quantity'] : null;
          String? unit = data != null ? data['unit'] as String? : null;

          if (productName != null && quantity != null && unit != null) {
            productsData[productName] = {'quantity': quantity, 'unit': unit};
          }
        }

        var series = [
          charts.Series<MapEntry<String, Map<String, dynamic>>, String>(
            id: 'Products',
            domainFn: (MapEntry<String, Map<String, dynamic>> entry, _) => entry.key,
            measureFn: (MapEntry<String, Map<String, dynamic>> entry, _) => entry.value['quantity'],
            data: productsData.entries.toList(),
            labelAccessorFn: (MapEntry<String, Map<String, dynamic>> entry, _) => '${entry.key}: ${(entry.value['quantity'] as num).toStringAsFixed(2)} ${entry.value['unit']}',
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

  Future<Map<String, Map<String, dynamic>>> _getSuppliersData() async {
    Map<String, Map<String, dynamic>> suppliersData = {};

    QuerySnapshot productsSnapshot = await FirebaseFirestore.instance.collection('products').get();

    for (var productDoc in productsSnapshot.docs) {
      var productData = productDoc.data() as Map<String, dynamic>?;
      if (productData != null) {
        String productName = productData['title'];
        QuerySnapshot suppliersSnapshot = await productDoc.reference.collection('suppliers').get();

        for (var supplierDoc in suppliersSnapshot.docs) {
          var supplierData = supplierDoc.data() as Map<String, dynamic>?;
          String? supplierId = supplierData != null ? supplierData['controller'] as String? : null;

          if (supplierId != null) {
            DocumentSnapshot supplierSnapshot = await FirebaseFirestore.instance.collection('suppliers').doc(supplierId).get();
            String? supplierName = supplierSnapshot.data() != null ? supplierSnapshot['name'] as String? : null;

            if (supplierName != null) {
              if (suppliersData.containsKey(supplierName)) {
                suppliersData[supplierName]?['count'] = (suppliersData[supplierName]?['count'] ?? 0) + 1;
              } else {
                suppliersData[supplierName] = {
                  'count': 1,
                };
              }
            }
          }
        }
      }
    }

    return suppliersData;
  }

  Widget _buildSuppliersChart() {
    return FutureBuilder<Map<String, Map<String, dynamic>>>(
      future: _getSuppliersData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        var suppliersData = snapshot.data!;
        var series = [
          charts.Series<MapEntry<String, Map<String, dynamic>>, String>(
            id: 'Suppliers',
            domainFn: (MapEntry<String, Map<String, dynamic>> entry, _) => entry.key,
            measureFn: (MapEntry<String, Map<String, dynamic>> entry, _) => entry.value['count'],
            data: suppliersData.entries.toList(),
            labelAccessorFn: (MapEntry<String, Map<String, dynamic>> entry, _) => '${entry.key}: ${entry.value['count']} produse',
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
                              final count = suppliersData[supplierName]!['count'];

                              print('Furnizorul selectat: $supplierName, Produse: $count');
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
  final Map<String, Map<String, dynamic>> suppliersData;

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

    final textStyle = charts.TextStyleSpec(color: charts.MaterialPalette.white, fontSize: 12);
    final selectedSupplier = suppliersData.keys.elementAt(bounds.left.toInt() % suppliersData.length);
    final count = suppliersData[selectedSupplier]!['count'];

    final textElementSupplier = canvas.graphicsFactory.createTextElement(selectedSupplier)
      ..textStyle = textStyle as charts.TextStyle?;
    final textElementCount = canvas.graphicsFactory.createTextElement('$count produse')
      ..textStyle = textStyle as charts.TextStyle?;

    final backgroundBounds = Rectangle(bounds.left, bounds.top, bounds.width, bounds.height);
    canvas.drawRect(
      backgroundBounds,
      fill: charts.MaterialPalette.blue.shadeDefault,
      stroke: charts.MaterialPalette.blue.shadeDefault,
    );

    canvas.drawText(
      textElementSupplier,
      (bounds.left + 5).round(),
      (bounds.top + 5).round(),
    );

    canvas.drawText(
      textElementCount,
      (bounds.left + 5).round(),
      (bounds.top + 20).round(),
    );
  }
}
