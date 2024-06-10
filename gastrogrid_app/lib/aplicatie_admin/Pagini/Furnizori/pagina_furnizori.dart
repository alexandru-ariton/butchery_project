import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SupplierManagementPage extends StatefulWidget {
  const SupplierManagementPage({super.key});

  @override
  _SupplierManagementPageState createState() => _SupplierManagementPageState();
}

class _SupplierManagementPageState extends State<SupplierManagementPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Future<void> _addSupplier() async {
    if (_nameController.text.isNotEmpty && _emailController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('suppliers').add({
        'name': _nameController.text,
        'email': _emailController.text,
      });
      _nameController.clear();
      _emailController.clear();
    }
  }

  Future<void> _deleteSupplier(String supplierId) async {
    await FirebaseFirestore.instance.collection('suppliers').doc(supplierId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Supplier Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Supplier Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _addSupplier,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text('Add Supplier'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('suppliers').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      var suppliers = snapshot.data!.docs.map((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text(data['name']),
                          subtitle: Text(data['email']),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteSupplier(doc.id),
                          ),
                        );
                      }).toList();

                      if (suppliers.isEmpty) {
                        return Center(
                          child: Text(
                            'No suppliers found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        );
                      }

                      return ListView(children: suppliers);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
