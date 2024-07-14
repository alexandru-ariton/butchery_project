import 'package:flutter/material.dart'; // Importă biblioteca principală Flutter pentru utilizarea widget-urilor.
import 'package:cloud_firestore/cloud_firestore.dart'; // Importă biblioteca Cloud Firestore pentru accesul la baza de date Firestore.
import 'package:charts_flutter/flutter.dart' as charts; // Importă biblioteca charts_flutter pentru utilizarea graficelor.

class DailyOrdersChart extends StatelessWidget {
  const DailyOrdersChart({super.key}); // Constructorul clasei, care folosește o cheie opțională.

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').limit(100).snapshots(), // Creează un stream de instantanee din colecția 'orders', limitat la 100 documente.
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator()); // Afișează un indicator de încărcare dacă nu sunt date disponibile.

        Map<DateTime, int> dailyOrders = {}; // Creează un map pentru a stoca numărul de comenzi pe zi.
        for (var doc in snapshot.data!.docs) {
          Timestamp timestamp = doc['timestamp']; // Obține timestamp-ul fiecărui document.
          DateTime date = DateTime(timestamp.toDate().year, timestamp.toDate().month, timestamp.toDate().day); // Convertește timestamp-ul într-un obiect DateTime.
          dailyOrders[date] = (dailyOrders[date] ?? 0) + 1; // Incrementează numărul de comenzi pentru ziua respectivă.
        }

        var series = [
          charts.Series<MapEntry<DateTime, int>, DateTime>(
            id: 'Comenzi pe zile',
            domainFn: (MapEntry<DateTime, int> entry, _) => entry.key, // Setează cheia pentru fiecare intrare.
            measureFn: (MapEntry<DateTime, int> entry, _) => entry.value, // Setează valoarea pentru fiecare intrare.
            data: dailyOrders.entries.toList(), // Setează datele pentru grafic.
            colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault, // Setează culoarea graficului.
            labelAccessorFn: (MapEntry<DateTime, int> entry, _) => '${entry.value}', // Setează eticheta pentru fiecare intrare.
          )
        ];

        return Padding(
          padding: const EdgeInsets.all(8.0), // Adaugă padding de 8 pixeli la toate marginile.
          child: Card(
            elevation: 5, // Setează umbra cardului.
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Adaugă padding de 16 pixeli la toate marginile containerului interior.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Comenzi pe zile',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // Stilizează textul.
                  ),
                  SizedBox(height: 8), // Adaugă un spațiu vertical de 8 pixeli.
                  Expanded(
                    child: charts.TimeSeriesChart(
                      series,
                      animate: true, // Activează animația.
                      dateTimeFactory: const charts.LocalDateTimeFactory(), // Setează fabrica de date și ore.
                      behaviors: [
                        charts.ChartTitle(
                          'Data',
                          behaviorPosition: charts.BehaviorPosition.bottom,
                          titleOutsideJustification: charts.OutsideJustification.middleDrawArea,
                        ),
                        charts.ChartTitle(
                          'Numar comenzi',
                          behaviorPosition: charts.BehaviorPosition.start,
                          titleOutsideJustification: charts.OutsideJustification.middleDrawArea,
                        ),
                      ],
                      primaryMeasureAxis: charts.NumericAxisSpec(
                        renderSpec: charts.GridlineRendererSpec(
                          labelStyle: charts.TextStyleSpec(
                            fontSize: 12,
                            color: charts.MaterialPalette.black,
                          ),
                        ),
                      ),
                      domainAxis: charts.DateTimeAxisSpec(
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
