// ignore_for_file: unused_import, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:GastroGrid/aplicatie_admin/Grafice/grafic_ComenziPeZile.dart';
import 'package:GastroGrid/aplicatie_admin/Grafice/grafic_FrecventaComenziUtilizatori.dart';
import 'package:GastroGrid/aplicatie_admin/Grafice/grafic_HeapMap.dart';
import 'package:GastroGrid/aplicatie_admin/Grafice/grafic_IncasariLunare.dart';
import 'package:GastroGrid/aplicatie_admin/Grafice/grafic_StatusComenzi.dart';

class Dashboard extends StatelessWidget {
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
              child: TabBar(
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(icon: Icon(Icons.bar_chart, size: 28), text: 'Daily Orders'),
                  Tab(icon: Icon(Icons.show_chart, size: 28), text: 'Monthly Revenue'),
                  Tab(icon: Icon(Icons.pie_chart, size: 28), text: 'Product Sales'),
                  Tab(icon: Icon(Icons.timeline, size: 28), text: 'Order Status'),
                  Tab(icon: Icon(Icons.people, size: 28), text: 'Customer Orders'),
                ],
              ),
              alignment: Alignment.center,
            ),
          ),
        ),
        body: TabBarView(
          children: [
            DailyOrdersChart(),
            MonthlyRevenueChart(),
            OrderLineChart(),
            OrderStatusDistributionChart(),
            CustomerOrderFrequencyChart(),
          ],
        ),
      ),
    );
  }
}
