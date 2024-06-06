import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:GastroGrid/aplicatie_admin/Pagini/Materii%20Prime/pagina_editare_materii_prime.dart';

class RawMaterialsManagement extends StatelessWidget {
  const RawMaterialsManagement({super.key});

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

  String formatQuantity(double quantity) {
    return quantity.toStringAsFixed(3);
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
                int crossAxisCount = (constraints.maxWidth ~/ 300).clamp(1, 3);
                double fontSize = constraints.maxWidth / 60;

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var rawMaterial = snapshot.data!.docs[index];
                    Map<String, dynamic> data = rawMaterial.data() as Map<String, dynamic>;
                    String unit = data.containsKey('unit') ? data['unit'] : 'unit';
                    double quantity = rawMaterial['quantity'].toDouble();

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: fontSize,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Cantitate: ${formatQuantity(quantity)} $unit',
                              style: TextStyle(
                                fontSize: fontSize * 0.8,
                              ),
                            ),
                            Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditRawMaterialPage(
                                          rawMaterialId: rawMaterial.id,
                                          currentName: data['name'],
                                          currentQuantity: data['quantity'].toString(),
                                          currentUnit: unit,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Editeaza',
                                    style: TextStyle(fontSize: fontSize * 0.8),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _deleteRawMaterial(rawMaterial.id),
                                  child: Text(
                                    'Sterge',
                                    style: TextStyle(fontSize: fontSize * 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addRawMaterial(context),
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
    
  }
}
