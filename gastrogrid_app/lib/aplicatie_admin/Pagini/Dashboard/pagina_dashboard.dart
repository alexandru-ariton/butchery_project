// ignore_for_file: unused_import, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart'; // Importă biblioteca principală Flutter pentru utilizarea widget-urilor.
import 'package:cloud_firestore/cloud_firestore.dart'; // Importă biblioteca Cloud Firestore pentru accesul la baza de date Firestore.
import 'package:gastrogrid_app/aplicatie_admin/Pagini/Dashboard/Grafice/grafic_ComenziZi.dart'; // Importă graficul pentru comenzi pe zi.
import 'package:gastrogrid_app/aplicatie_admin/Pagini/Dashboard/Grafice/grafic_FrecventaComenziUtilizatori.dart'; // Importă graficul pentru frecvența comenzilor utilizatorilor.
import 'package:gastrogrid_app/aplicatie_admin/Pagini/Dashboard/Grafice/grafic_TotalComenziPeZi.dart'; // Importă graficul pentru comenzi zilnice.
import 'package:gastrogrid_app/aplicatie_admin/Pagini/Dashboard/Grafice/grafic_IncasariLunare.dart'; // Importă graficul pentru încasări lunare.
import 'package:gastrogrid_app/aplicatie_admin/Pagini/Dashboard/Grafice/grafic_ProduseSiFurnizori.dart'; // Importă graficul pentru produse și furnizori.

class Dashboard extends StatelessWidget {
  const Dashboard({super.key}); // Constructorul clasei, care folosește o cheie opțională.

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // Setează numărul de tab-uri.
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(104, 99, 62, 62), // Setează culoarea de fundal a AppBar-ului.
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight), // Setează înălțimea preferată a TabBar-ului.
            child: Container(
              alignment: Alignment.center,
              child: TabBar(
                indicatorColor: Colors.white, // Setează culoarea indicatorului tab-ului selectat.
                labelColor: Colors.white, // Setează culoarea textului tab-ului selectat.
                unselectedLabelColor: Colors.white70, // Setează culoarea textului tab-ului ne-selectat.
                tabs: [
                  Tab(icon: Icon(Icons.bar_chart, size: 28), text: 'Comenzi pe zile'), // Tab-ul pentru Comenzi pe Zile.
                  Tab(icon: Icon(Icons.show_chart, size: 28), text: 'Incasari lunare'), // Tab-ul pentru Încasări Lunare.
                  Tab(icon: Icon(Icons.pie_chart, size: 28), text: 'Numar comenzi'), // Tab-ul pentru Numar Comenzi.
                  Tab(icon: Icon(Icons.check_box_outline_blank_outlined, size: 28), text: 'Produse si furnizori'), // Tab-ul pentru Produse si Furnizori.
                  Tab(icon: Icon(Icons.people, size: 28), text: 'Comenzi clienti'), // Tab-ul pentru Comenzi Clienti.
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            DailyOrdersChart(), // Widget-ul pentru graficul comenzilor pe zi.
            MonthlyRevenueChart(), // Widget-ul pentru graficul încasărilor lunare.
            OrderLineChart(), // Widget-ul pentru graficul numărului de comenzi.
            ProductsAndSuppliersChart(), // Widget-ul pentru graficul produselor și furnizorilor.
            CustomerOrderFrequencyChart(), // Widget-ul pentru graficul frecvenței comenzilor clienților.
          ],
        ),
      ),
    );
  }
}
