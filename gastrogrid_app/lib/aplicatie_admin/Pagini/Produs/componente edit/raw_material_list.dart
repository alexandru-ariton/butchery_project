import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RawMaterialList extends StatefulWidget {
  final Map<String, TextEditingController> rawMaterialControllers;
  final Map<String, Map<String, dynamic>> selectedRawMaterials;

  const RawMaterialList({
    Key? key,
    required this.rawMaterialControllers,
    required this.selectedRawMaterials,
  }) : super(key: key);

  @override
  _RawMaterialListState createState() => _RawMaterialListState();
}

class _RawMaterialListState extends State<RawMaterialList> {
  Future<List<Map<String, dynamic>>> _fetchRawMaterials() async {
    final rawMaterialsSnapshot = await FirebaseFirestore.instance.collection('rawMaterials').get();
    return rawMaterialsSnapshot.docs.map((doc) => {
      'id': doc.id,
      'name': doc['name'],
      'quantity': doc['quantity'],
      'unit': doc['unit'],  // Assuming unit is also stored in rawMaterials collection
    }).toList();
  }

  final List<String> units = ['kg', 'g', 'l', 'ml']; // Add more units as needed

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchRawMaterials(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 3.5,
          ),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            var rawMaterial = snapshot.data![index];
            final controller = widget.rawMaterialControllers.putIfAbsent(
              rawMaterial['id'],
              () => TextEditingController(),
            );

            if (!widget.selectedRawMaterials.containsKey(rawMaterial['id'])) {
              widget.selectedRawMaterials[rawMaterial['id']] = {
                'quantity': 0,
                'unit': units.contains(rawMaterial['unit']) ? rawMaterial['unit'] : units.first
              };
            }

            String selectedUnit = widget.selectedRawMaterials[rawMaterial['id']]!['unit'];

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rawMaterial['name'],
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Disponibil: ${rawMaterial['quantity']} ${rawMaterial['unit']}',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: controller,
                            decoration: InputDecoration(
                              labelText: 'Cantitate',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final quantity = double.tryParse(value);
                              if (quantity != null) {
                                widget.selectedRawMaterials[rawMaterial['id']]!['quantity'] = quantity;
                              } else {
                                widget.selectedRawMaterials[rawMaterial['id']]!['quantity'] = 0;
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: selectedUnit,
                            decoration: InputDecoration(
                              labelText: 'Unitate',
                              border: OutlineInputBorder(),
                            ),
                            items: units.map((String unit) {
                              return DropdownMenuItem<String>(
                                value: unit,
                                child: Text(unit),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                if (newValue != null) {
                                  widget.selectedRawMaterials[rawMaterial['id']]!['unit'] = newValue;
                                }
                              });
                            },
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
  }
}
