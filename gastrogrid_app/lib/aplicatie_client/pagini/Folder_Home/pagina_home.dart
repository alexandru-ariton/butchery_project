// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, unnecessary_import, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gastrogrid_app/aplicatie_client/pagini/Folder_Home/componente_home/butoane_livrare.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
       SliverAppBar(
            floating: true,
            pinned: true,
            snap: false,
            expandedHeight: 80, // Înălțimea când este expandat
            collapsedHeight: 100,
            toolbarHeight: 60, // Înălțimea când este collapsed
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.all(16), // Ajustează padding după preferințe
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end, // Alinează la baza spațiului flexibil
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap:() {},
                    child: Row(
                    children:[
                      Icon(Icons.pin_drop_outlined),
                      SizedBox(width: 8),
                      Text('Selectează Adresa', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ]
                    
                                    ),
                  ),
                  
                  SizedBox(height: 8), // Spațiu între text și butoane
                  DeliveryToggleButtons(), // Includem butoanele aici
                ],
              ),
              background: Container(
                color: Theme.of(context).primaryColor, // Alege o culoare pentru fundal sau un gradient
              ),
            ),
          ),

       
        SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              minHeight: 80.0,
              maxHeight: 80.0,
              child: Container(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                alignment: Alignment.center,
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(30.0),
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
                      hintText: 'Caută produse',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    
                  ),
                ),
              ),
            ),
            pinned: false,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Card(
                  child: ListTile(
                    title: Text('Produs $index'),
                    subtitle: Text('Descriere produs $index'),
                    onTap: () {
                      // Logica pentru deschiderea detaliilor produsului
                    },
                  ),
                );
              },
              childCount: 10, // numărul de produse
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight > minHeight ? maxHeight : minHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}