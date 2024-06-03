import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gastrogrid_app/aplicatie_admin/pagina_editare_materiiPrime.dart';
import 'package:universal_html/html.dart' as html;

class RawMaterialsManagement extends StatelessWidget {
  void _addRawMaterial(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRawMaterialPage(),
      ),
    );
  }

  void _deleteRawMaterial(String id) async {
    await FirebaseFirestore.instance.collection('rawMaterials').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('rawMaterials').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
            return LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = (constraints.maxWidth ~/ 200).clamp(2, 6);
                double fontSize = constraints.maxWidth / 50;

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 1 / 1.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: snapshot.data!.docs.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return GestureDetector(
                        onTap: () => _addRawMaterial(context),
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

                    var rawMaterial = snapshot.data!.docs[index - 1];
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
                                rawMaterial['imageUrl'],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(child: Icon(Icons.broken_image, size: fontSize * 2));
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: Text(
                              rawMaterial['name'],
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('Quantity: ${rawMaterial['quantity']}', style: TextStyle(fontSize: fontSize * 0.8)),
                          ),
                          ButtonBar(
                            alignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditRawMaterialPage(
                                        rawMaterialId: rawMaterial.id,
                                        currentName: rawMaterial['name'],
                                        currentQuantity: rawMaterial['quantity'].toString(),
                                        currentImageUrl: rawMaterial['imageUrl'],
                                      ),
                                    ),
                                  );
                                },
                                child: Text('Edit', style: TextStyle(fontSize: fontSize * 0.8)),
                              ),
                              TextButton(
                                onPressed: () => _deleteRawMaterial(rawMaterial.id),
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
