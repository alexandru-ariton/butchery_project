import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gastrogrid_app/aplicatie_admin/Pagini/Comenzi/pagina_detalii_comenzi.dart';

class OrderManagement extends StatelessWidget {
  const OrderManagement({super.key});

  void _deleteOrder(String id) async {
    await FirebaseFirestore.instance.collection('orders').doc(id).delete();
  }

  void _updateOrderStatus(String orderId, String newStatus) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({'status': newStatus});
  }

  void _updatePreparationStatus(String orderId, String newStatus) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({'preparationStatus': newStatus});
  }

  void _updatePaymentStatus(String orderId, String newStatus) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({'paymentStatus': newStatus});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var orders = snapshot.data!.docs;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                var order = orders[index];
                var orderId = order.id;
                var orderData = order.data() as Map<String, dynamic>;

                String currentPreparationStatus = orderData['preparationStatus'] ?? 'Receptionata';
                String currentPaymentStatus = orderData['paymentStatus'] ?? 'Neplatit';

                if (!['Receptionata', 'In curs de procesare', 'In curs de livrare', 'Finalizata'].contains(currentPreparationStatus)) {
                  currentPreparationStatus = 'Receptionata';
                }

                if (!['Platit', 'Neplatit'].contains(currentPaymentStatus)) {
                  currentPaymentStatus = 'Neplatit';
                }

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => OrderDetailsPage(orderId: orderId, orderData: orderData),
                      ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Comanda $orderId',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Status preparare: $currentPreparationStatus',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Status plată: $currentPaymentStatus',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: currentPreparationStatus,
                                  decoration: InputDecoration(
                                    labelText: 'Status preparare',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  items: ['Receptionata', 'In curs de procesare', 'In curs de livrare', 'Finalizata']
                                      .map((status) => DropdownMenuItem(
                                            value: status,
                                            child: Text(status, style: TextStyle(fontSize: 16)),
                                          ))
                                      .toList(),
                                  onChanged: (String? value) {
                                    if (value != null) {
                                      _updatePreparationStatus(orderId, value);
                                    }
                                  },
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: currentPaymentStatus,
                                  decoration: InputDecoration(
                                    labelText: 'Status plată',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  items: currentPaymentStatus == 'Platit'
                                      ? [
                                          DropdownMenuItem(
                                            value: 'Platit',
                                            child: Text('Platit', style: TextStyle(fontSize: 16)),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Neplatit',
                                            child: Text('Neplatit', style: TextStyle(fontSize: 16)),
                                          ),
                                        ]
                                      : ['Platit', 'Neplatit']
                                          .map((status) => DropdownMenuItem(
                                                value: status,
                                                child: Text(status, style: TextStyle(fontSize: 16)),
                                              ))
                                          .toList(),
                                  onChanged: currentPaymentStatus == 'Platit'
                                      ? null
                                      : (String? value) {
                                          if (value != null) {
                                            _updatePaymentStatus(orderId, value);
                                          }
                                        },
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, size: 24, color: Colors.red),
                                onPressed: () => _deleteOrder(orderId),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
