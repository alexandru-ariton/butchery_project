import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RawMaterialList extends StatefulWidget {
  final Map<String, TextEditingController> rawMaterialControllers;
  final Map<String, int> selectedRawMaterials;

  RawMaterialList({
    required this.rawMaterialControllers,
    required this.selectedRawMaterials,
  });

  @override
  _RawMaterialListState createState() => _RawMaterialListState();
}

class _RawMaterialListState extends State<RawMaterialList> {
  Future<List<Map<String, dynamic>>> _fetchRawMaterials() async {
    final rawMaterialsSnapshot = await FirebaseFirestore.instance.collection('rawMaterials').get();
    return rawMaterialsSnapshot.docs.map((doc) => {'id': doc.id, 'name': doc['name'], 'quantity': doc['quantity']}).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchRawMaterials(),
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        return Column(
          children: snapshot.data!.map((rawMaterial) {
            final controller = widget.rawMaterialControllers.putIfAbsent(
              rawMaterial['id'],
              () => TextEditingController(),
            );
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      rawMaterial['name'],
                      style: TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: controller,
                      decoration: InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final quantity = int.tryParse(value);
                        if (quantity != null) {
                          widget.selectedRawMaterials[rawMaterial['id']] = quantity;
                        } else {
                          widget.selectedRawMaterials.remove(rawMaterial['id']);
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
