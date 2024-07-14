import 'package:flutter/material.dart'; // Importă biblioteca principală Flutter pentru utilizarea widget-urilor.
import 'package:cloud_firestore/cloud_firestore.dart'; // Importă biblioteca Cloud Firestore pentru accesul la baza de date Firestore.
import 'package:charts_flutter/flutter.dart' as charts; // Importă biblioteca charts_flutter pentru utilizarea graficelor.

class CustomerOrderFrequencyChart extends StatelessWidget {
  const CustomerOrderFrequencyChart({super.key}); // Constructorul clasei, care folosește o cheie opțională.

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').limit(100).snapshots(), // Creează un stream de instantanee din colecția 'orders', limitat la 100 documente.
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator()); // Afișează un indicator de încărcare dacă nu sunt date disponibile.

        Map<String, int> customerOrderFrequency = {}; // Creează un map pentru a stoca frecvența comenzilor clienților.
        for (var doc in snapshot.data!.docs) {
          var data = doc.data() as Map<String, dynamic>?;

          String? userId = data != null ? data['userId'] as String? : null;
          String? username = data != null ? data['username'] as String? : null;
          String? email = data != null ? data['email'] as String? : null;

          String displayName = username ?? email ?? '-'; // Afișează numele utilizatorului sau emailul, dacă sunt disponibile.

          if (userId != null) {
            customerOrderFrequency[displayName] = (customerOrderFrequency[displayName] ?? 0) + 1; // Incrementează frecvența comenzilor pentru clientul respectiv.
          }
        }

        var series = [
          charts.Series<MapEntry<String, int>, String>(
            id: 'Comenzi clienti',
            domainFn: (MapEntry<String, int> entry, _) => entry.key, // Setează cheia pentru fiecare intrare.
            measureFn: (MapEntry<String, int> entry, _) => entry.value, // Setează valoarea pentru fiecare intrare.
            data: customerOrderFrequency.entries.toList(), // Setează datele pentru grafic.
            labelAccessorFn: (MapEntry<String, int> entry, _) => '${entry.value}', // Setează eticheta pentru fiecare intrare.
            colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault, // Setează culoarea graficului.
          )
        ];

        return Padding(
          padding: const EdgeInsets.all(8.0), // Adaugă padding de 8 pixeli la toate marginile.
          child: Card(
            elevation: 5, // Setează umbra cardului.
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Setează colțurile rotunjite ale cardului.
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Adaugă padding de 16 pixeli la toate marginile containerului interior.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Comenzi clienti',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 8.0), // Adaugă un spațiu vertical de 8 pixeli.
                  Expanded(
                    child: charts.BarChart(
                      series,
                      animate: true, // Activează animația.
                      animationDuration: Duration(seconds: 1), // Setează durata animației la 1 secundă.
                      vertical: true,
                      barRendererDecorator: charts.BarLabelDecorator<String>(
                        insideLabelStyleSpec: charts.TextStyleSpec(
                            fontSize: 14, color: charts.MaterialPalette.white), // Stilul etichetei interioare.
                        outsideLabelStyleSpec: charts.TextStyleSpec(
                            fontSize: 14, color: charts.MaterialPalette.black), // Stilul etichetei exterioare.
                      ),
                      domainAxis: charts.OrdinalAxisSpec(
                        renderSpec: charts.SmallTickRendererSpec(
                          labelRotation: 45, // Rotirea etichetelor.
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
                        charts.SeriesLegend(
                          position: charts.BehaviorPosition.bottom,
                          horizontalFirst: true,
                          desiredMaxColumns: 1,
                          cellPadding: EdgeInsets.only(right: 4.0, bottom: 4.0), // Setează padding pentru celule.
                          entryTextStyle: charts.TextStyleSpec(
                            color: charts.MaterialPalette.black,
                            fontSize: 12,
                          ),
                        ),
                        charts.ChartTitle(
                          'Numar comenzi',
                          behaviorPosition: charts.BehaviorPosition.start,
                          titleOutsideJustification:
                              charts.OutsideJustification.middleDrawArea,
                          innerPadding: 16,
                          titleStyleSpec: charts.TextStyleSpec(
                              fontSize: 14, fontWeight: 'bold'),
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
