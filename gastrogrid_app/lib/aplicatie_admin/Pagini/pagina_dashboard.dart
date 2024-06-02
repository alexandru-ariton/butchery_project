// ignore_for_file: unused_import, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gastrogrid_app/aplicatie_admin/Grafice/grafic_ComenziPeZile.dart';
import 'package:gastrogrid_app/aplicatie_admin/Grafice/grafic_FrecventaComenziUtilizatori.dart';
import 'package:gastrogrid_app/aplicatie_admin/Grafice/grafic_HeapMap.dart';
import 'package:gastrogrid_app/aplicatie_admin/Grafice/grafic_IncasariLunare.dart';
import 'package:gastrogrid_app/aplicatie_admin/Grafice/grafic_StatusComenzi.dart';



class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            indicatorColor: Colors.teal,
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.bar_chart), text: 'Daily Orders'),
              Tab(icon: Icon(Icons.show_chart), text: 'Monthly Revenue'),
              Tab(icon: Icon(Icons.pie_chart), text: 'Product Sales'),
              Tab(icon: Icon(Icons.timeline), text: 'Order Status'),
              Tab(icon: Icon(Icons.people), text: 'Customer Orders'),
          
            ],
          ),
        ),
        body: TabBarView(
          children: [
            DailyOrdersChart(),
            MonthlyRevenueChart(),
            HeatmapChart(),
            OrderStatusDistributionChart(),
            CustomerOrderFrequencyChart(),
            
          ],
        ),
      ),
    );
  }
}
