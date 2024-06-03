import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gastrogrid_app/aplicatie_admin/Pagini/Produs/pagina_editare_produs.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ProductManagement extends StatelessWidget {
  void _addProduct(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductPage(),
      ),
    );
  }

  void _deleteProduct(String id) async {
    await FirebaseFirestore.instance.collection('products').doc(id).delete();
  }

  Future<void> loadImage(BuildContext context) async {
    try {
      String imageUrl = await firebase_storage.FirebaseStorage.instance
          .ref('product_images/imaginea1.jpeg')
          .getDownloadURL();

      // Use the imageUrl in an Image widget or however you need
      print('Download URL: $imageUrl');
    } catch (e) {
      print('Error occurred while loading the image: $e');
      // Handle errors or set a state to show an error image
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
            return LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = (constraints.maxWidth ~/ 250).clamp(2, 6);
                double fontSize = constraints.maxWidth / 60;

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 2 / 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: snapshot.data!.docs.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return GestureDetector(
                        onTap: () => _addProduct(context),
                        child: Card(
                          color: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          child: Center(
                            child: Icon(Icons.add, size: fontSize * 2, color: Colors.white),
                          ),
                        ),
                      );
                    }

                    var product = snapshot.data!.docs[index - 1];
                    String imageUrl = product['imageUrl'];

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                              child: Image.network(
                                product['imageUrl'],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                 return Center(child: Icon(Icons.broken_image, size: fontSize * 2));
                                  
                                
                                },
                                
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: Text(
                              product['title'],
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('${product['price']} lei', style: TextStyle(fontSize: fontSize * 0.8)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('Quantity: ${product['quantity']}', style: TextStyle(fontSize: fontSize * 0.8)),
                          ),
                          ButtonBar(
                            alignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditProductPage(
                                        productId: product.id,
                                        currentTitle: product['title'],
                                        currentPrice: product['price'].toString(),
                                        currentDescription: product['description'],
                                        currentImageUrl: imageUrl,
                                        currentQuantity: product['quantity'].toString(),
                                      ),
                                    ),
                                  );
                                },
                                child: Text('Edit', style: TextStyle(fontSize: fontSize * 0.8)),
                              ),
                              TextButton(
                                onPressed: () => _deleteProduct(product.id),
                                child: Text('Delete', style: TextStyle(fontSize: fontSize * 0.8)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
