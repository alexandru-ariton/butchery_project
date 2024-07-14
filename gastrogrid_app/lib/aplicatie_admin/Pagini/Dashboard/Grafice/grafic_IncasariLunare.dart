import 'package:flutter/material.dart'; // Importă biblioteca principală Flutter pentru utilizarea widget-urilor.
import 'package:cloud_firestore/cloud_firestore.dart'; // Importă biblioteca Cloud Firestore pentru accesul la baza de date Firestore.
import 'package:charts_flutter/flutter.dart' as charts; // Importă biblioteca charts_flutter pentru utilizarea graficelor.

class MonthlyRevenueChart extends StatelessWidget {
  const MonthlyRevenueChart({super.key}); // Constructorul clasei, care folosește o cheie opțională.

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').limit(100).snapshots(), // Creează un stream de instantanee din colecția 'orders', limitat la 100 documente.
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator()); // Afișează un indicator de încărcare dacă nu sunt date disponibile.

        Map<String, double> monthlyRevenue = {}; // Creează un map pentru a stoca încasările lunare.
        for (var doc in snapshot.data!.docs) {
          Timestamp timestamp = doc['timestamp']; // Obține timestamp-ul fiecărui document.
          String month = "${timestamp.toDate().year}-${timestamp.toDate().month.toString().padLeft(2, '0')}"; // Formatează timestamp-ul pentru a obține luna.
          monthlyRevenue[month] = (monthlyRevenue[month] ?? 0) + (doc['total'] ?? 0); // Adaugă încasările totale la luna corespunzătoare.
        }

        var series = [
          charts.Series<MapEntry<String, double>, String>(
            id: 'Incasari lunare',
            domainFn: (MapEntry<String, double> entry, _) => entry.key, // Setează cheia pentru fiecare intrare.
            measureFn: (MapEntry<String, double> entry, _) => entry.value, // Setează valoarea pentru fiecare intrare.
            data: monthlyRevenue.entries.toList(), // Setează datele pentru grafic.
            colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault, // Setează culoarea graficului.
            labelAccessorFn: (MapEntry<String, double> entry, _) => entry.value.toStringAsFixed(2), // Setează eticheta pentru fiecare intrare.
          )
        ];

        return Padding(
          padding: const EdgeInsets.all(16.0), // Adaugă padding de 16 pixeli la toate marginile.
          child: Card(
            elevation: 5, // Setează umbra cardului.
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Adaugă padding de 16 pixeli la toate marginile containerului interior.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Incasari lunare',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // Stilizează textul.
                    textAlign: TextAlign.center, // Centrează textul.
                  ),
                  SizedBox(height: 16), // Adaugă un spațiu vertical de 16 pixeli.
                  Expanded(
                    child: charts.BarChart(
                      series,
                      animate: true, // Activează animația.
                      vertical: true,
                      barRendererDecorator: charts.BarLabelDecorator<String>(
                        insideLabelStyleSpec: charts.TextStyleSpec(fontSize: 12, color: charts.MaterialPalette.white), // Stilul etichetei interioare.
                        outsideLabelStyleSpec: charts.TextStyleSpec(fontSize: 12, color: charts.MaterialPalette.black), // Stilul etichetei exterioare.
                      ),
                      behaviors: [
                        charts.ChartTitle(
                          'Luna',
                          behaviorPosition: charts.BehaviorPosition.bottom, // Setează poziția titlului.
                          titleOutsideJustification: charts.OutsideJustification.middleDrawArea, // Setează justificarea titlului.
                          innerPadding: 16, // Setează padding interior.
                          titleStyleSpec: charts.TextStyleSpec(fontSize: 14), // Stilizează titlul.
                        ),
                        charts.ChartTitle(
                          'Total incasari',
                          behaviorPosition: charts.BehaviorPosition.start, // Setează poziția titlului.
                          titleOutsideJustification: charts.OutsideJustification.middleDrawArea, // Setează justificarea titlului.
                          innerPadding: 16, // Setează padding interior.
                          titleStyleSpec: charts.TextStyleSpec(fontSize: 14), // Stilizează titlul.
                        ),
                      ],
                      domainAxis: charts.OrdinalAxisSpec(
                        renderSpec: charts.SmallTickRendererSpec(
                          labelRotation: 45, // Rotirea etichetelor.
                          labelStyle: charts.TextStyleSpec(
                            fontSize: 12,
                            color: charts.MaterialPalette.black,
                          ),
                        ),
                      ),
                      primaryMeasureAxis: charts.NumericAxisSpec(
                        renderSpec: charts.GridlineRendererSpec(
                          labelStyle: charts.TextStyleSpec(
                            fontSize: 12,
                            color: charts.MaterialPalette.black,
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
}
