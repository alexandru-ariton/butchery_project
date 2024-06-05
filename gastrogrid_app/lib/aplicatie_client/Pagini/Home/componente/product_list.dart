import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:GastroGrid/clase/clasa_produs.dart';
import 'product_card.dart';

class ProductList extends StatelessWidget {
  final String searchQuery;

  const ProductList({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
        var docs = snapshot.data!.docs;
        var filteredDocs = docs.where((doc) {
          var product = Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          return product.title.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

        return SliverPadding(
          padding: EdgeInsets.all(10),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isSmallScreen ? 1 : 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: isSmallScreen ? 1.5 / 1.2 : 1.0,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                if (index < filteredDocs.length) {
                  var product = Product.fromMap(filteredDocs[index].data() as Map<String, dynamic>, filteredDocs[index].id);
                  return ProductCard(product: product);
                } else {
                  return SizedBox.shrink();
                }
              },
              childCount: filteredDocs.length,
            ),
          ),
        );
      },
    );
  }
}
