import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SupplierList extends StatefulWidget {
  final Map<String, TextEditingController> supplierControllers;
  final Map<String, Map<String, dynamic>> selectedSuppliers;

  const SupplierList({
    required this.supplierControllers,
    required this.selectedSuppliers,
    Key? key,
  }) : super(key: key);

  @override
  _SupplierListState createState() => _SupplierListState();
}

class _SupplierListState extends State<SupplierList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selectează Furnizorii',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('suppliers').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            var suppliers = snapshot.data!.docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              String supplierId = doc.id;
              widget.supplierControllers[supplierId] ??= TextEditingController();

              return ListTile(
                title: Text(data['name']),
                subtitle: Text(data['email']),
                trailing: Checkbox(
                  value: widget.selectedSuppliers.containsKey(supplierId),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        widget.selectedSuppliers[supplierId] = {
                          'controller': widget.supplierControllers[supplierId]!.text,
                          'email': data['email'],
                          'name': data['name']
                        };
                      } else {
                        widget.selectedSuppliers.remove(supplierId);
                      }
                    });
                  },
                ),
              );
            }).toList();

            return ListView(
              shrinkWrap: true,
              children: suppliers,
            );
          },
        ),
      ],
    );
  }
}
