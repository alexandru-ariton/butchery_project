// Importă biblioteca Firestore pentru interacțiunea cu baza de date Firestore.
import 'package:cloud_firestore/cloud_firestore.dart';

// Importă biblioteca Flutter pentru a crea interfețe de utilizator.
import 'package:flutter/material.dart';

// Importă clasa Product.
import 'package:gastrogrid_app/clase/clasa_produs.dart';

// Importă widget-ul ProductCard.
import 'product_card.dart';

// Declarația unei clase stateless pentru lista de produse.
class ProductList extends StatelessWidget {
  // Declarația unei variabile finale pentru interogarea de căutare.
  final String searchQuery;

  // Constructorul pentru clasa ProductList care primește o interogare de căutare.
  const ProductList({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    // Obține dimensiunea ecranului.
    final screenSize = MediaQuery.of(context).size;
    // Verifică dacă ecranul este mic.
    final isSmallScreen = screenSize.width < 600;

    return StreamBuilder<QuerySnapshot>(
      // Creează un flux de date pentru colecția 'products' din Firestore.
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        // Afișează un indicator de încărcare dacă nu există date.
        if (!snapshot.hasData) return SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
        // Obține documentele din snapshot.
        var docs = snapshot.data!.docs;
        // Filtrează documentele în funcție de interogarea de căutare.
        var filteredDocs = docs.where((doc) {
          var product = Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          return product.title.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

        return SliverPadding(
          padding: EdgeInsets.all(10),
          sliver: SliverGrid(
            // Setează configurația grilei.
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isSmallScreen ? 1 : 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: isSmallScreen ? 1.5 / 1.2 : 1.0,
            ),
            // Setează delegatul care construiește elementele grilei.
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                // Verifică dacă indexul este în limitele listei filtrate.
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
