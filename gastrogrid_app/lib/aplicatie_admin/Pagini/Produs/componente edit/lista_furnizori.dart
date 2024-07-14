import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Definirea unui widget Stateful numit SupplierList care primește două hărți: supplierControllers și selectedSuppliers.
class SupplierList extends StatefulWidget {
  final Map<String, TextEditingController> supplierControllers;
  final Map<String, Map<String, dynamic>> selectedSuppliers;

  // Constructorul pentru SupplierList primește supplierControllers și selectedSuppliers ca parametri necesari.
  const SupplierList({
    required this.supplierControllers,
    required this.selectedSuppliers,
    Key? key,
  }) : super(key: key);

  @override
  _SupplierListState createState() => _SupplierListState();
}

// Definirea stării pentru SupplierList.
class _SupplierListState extends State<SupplierList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Textul care indică utilizatorului să selecteze furnizorii.
        Text(
          'Selecteaza furnizorii',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        // StreamBuilder pentru a asculta modificările din colecția 'suppliers' din Firestore.
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('suppliers').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              // Afișează un indicator de progres dacă datele nu sunt încă disponibile.
              return Center(child: CircularProgressIndicator());
            }

            // Maparea documentelor din snapshot în widget-uri ListTile.
            var suppliers = snapshot.data!.docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;  // Obține datele din document.
              String supplierId = doc.id;  // ID-ul documentului.
              // Inițializează un TextEditingController pentru fiecare furnizor dacă nu există deja.
              widget.supplierControllers[supplierId] ??= TextEditingController();

              return ListTile(
                title: Text(data['name']),  // Afișează numele furnizorului.
                subtitle: Text(data['email']),  // Afișează email-ul furnizorului.
                trailing: Checkbox(
                  value: widget.selectedSuppliers.containsKey(supplierId),  // Starea checkbox-ului.
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        // Adaugă furnizorul în selectedSuppliers dacă este selectat.
                        widget.selectedSuppliers[supplierId] = {
                          'controller': widget.supplierControllers[supplierId]!.text,
                          'email': data['email'],
                          'name': data['name']
                        };
                      } else {
                        // Elimină furnizorul din selectedSuppliers dacă nu este selectat.
                        widget.selectedSuppliers.remove(supplierId);
                      }
                    });
                  },
                ),
              );
            }).toList();

            // Afișează lista de furnizori.
            return ListView(
              shrinkWrap: true,  // Permite listei să se micșoreze pentru a se potrivi cu conținutul.
              children: suppliers,  // Copiii ListView sunt widget-urile ListTile create mai sus.
            );
          },
        ),
      ],
    );
  }
}
