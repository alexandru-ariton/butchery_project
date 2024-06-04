import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:GastroGrid/aplicatie_admin/pagina_editare_materiiPrime.dart';
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
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('rawMaterials').snapshots(),
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
                    String imageUrl = rawMaterial['imageUrl'];
                    Map<String, dynamic> data = rawMaterial.data() as Map<String, dynamic>;
                    String unit = data.containsKey('unit') ? data['unit'] : 'unit';

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
                              rawMaterial['name'],
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('Quantity: ${rawMaterial['quantity']} $unit', style: TextStyle(fontSize: fontSize * 0.8)),
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
                                        currentUnit: unit,
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
