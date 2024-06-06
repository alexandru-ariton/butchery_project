// ignore_for_file: unused_import, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:GastroGrid/aplicatie_admin/Pagini/Dashboard/Grafice/grafic_ComenziPeZile.dart';
import 'package:GastroGrid/aplicatie_admin/Pagini/Dashboard/Grafice/grafic_FrecventaComenziUtilizatori.dart';
import 'package:GastroGrid/aplicatie_admin/Pagini/Dashboard/Grafice/grafic_HeapMap.dart';
import 'package:GastroGrid/aplicatie_admin/Pagini/Dashboard/Grafice/grafic_IncasariLunare.dart';
import 'package:GastroGrid/aplicatie_admin/Pagini/Dashboard/Grafice/grafic_StatusComenzi.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(104, 99, 62, 62),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Container(
              alignment: Alignment.center,
              child: TabBar(
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(icon: Icon(Icons.bar_chart, size: 28), text: 'Comenzi pe Zile'),
                  Tab(icon: Icon(Icons.show_chart, size: 28), text: 'Incasari Lunare'),
                  Tab(icon: Icon(Icons.pie_chart, size: 28), text: 'Numar Comenzi'),
                  Tab(icon: Icon(Icons.check_box_outline_blank_outlined, size: 28), text: 'Produse si Materii Prime'),
                  Tab(icon: Icon(Icons.people, size: 28), text: 'Comenzi Clienti'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            DailyOrdersChart(),
            MonthlyRevenueChart(),
            OrderLineChart(),
            RawMaterialsAndProductsChart(),
            CustomerOrderFrequencyChart(),
          ],
        ),
      ),
    );
  }
}
