// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, unnecessary_import, use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_Home/componente_home/butoane_livrare.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_Home/componente_home/pagina_produs.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_Home/componente_home/pagina_selectare_adresa.dart';
import 'package:gastrogrid_app/aplicatie_client/clase/produs.dart';



class HomePage extends StatelessWidget {

void _selectAddress(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => AddressSelector(),
    ),
  );
}


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
              title: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end, // Alinează la baza spațiului flexibil
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      GestureDetector(
      onTap: () => _selectAddress(context),
      child: Row(
        children: [
          Icon(Icons.pin_drop_outlined),
          SizedBox(width: 8),
          Text('Selectează Adresa', style: TextStyle(fontSize: 16, color: Colors.white)),
        ],
      ),
    ),
                    
                    SizedBox(height: 6), // Spațiu între text și butoane
                    DeliveryToggleButtons(), // Includem butoanele aici
                  ],
                ),
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
            // Înlocuiește SliverList cu SliverGrid
          SliverPadding(
            padding: EdgeInsets.all(10),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Numărul de coloane
                crossAxisSpacing: 10, // Spațierea orizontală între elemente
                mainAxisSpacing: 10, // Spațierea verticală între elemente
                childAspectRatio: 4 / 3, // Aspect ratio pentru dimensiunea cardurilor
              ),
              delegate: SliverChildBuilderDelegate(
     (BuildContext context, int index) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('products').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return CircularProgressIndicator();
                      var docs = snapshot.data!.docs;
                      if (index < docs.length) {
                        var product = Product.fromMap(docs[index].data() as Map<String, dynamic>, docs[index].id);
                        return Card(
                          child: ListTile(
                            title: Text(product.title),
                            subtitle: Text(product.price.toString() + " lei"),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailPage(product: product),
                                ),
                              );
                            },
                          ),
                        );
                      } else {
                        return SizedBox.shrink(); // Optionally handle this condition
                      }
                    },
                  );
                },
  childCount: 10, // numărul de produse
),
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