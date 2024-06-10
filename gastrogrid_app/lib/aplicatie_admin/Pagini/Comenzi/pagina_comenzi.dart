import 'package:gastrogrid_app/providers/helper_notificari.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gastrogrid_app/aplicatie_admin/Pagini/Comenzi/pagina_detalii_comenzi.dart';

class OrderManagement extends StatelessWidget {
  const OrderManagement({super.key});

  void _deleteOrder(String id) async {
    await FirebaseFirestore.instance.collection('orders').doc(id).delete();
  }

  void _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({'status': newStatus});
      NotificationHelper.showNotification('Order Status Updated', 'Order $orderId status is now $newStatus');
    } catch (e) {
      print("Nu s-a putut incarca status-ul comenzii: $e");
    }
  }

  void _updatePaymentStatus(String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({'paymentStatus': newStatus});
      NotificationHelper.showNotification('Payment Status Updated', 'Order $orderId payment status is now $newStatus');
    } catch (e) {
      print("Nu s-a putut incarca status-ul platii: $e");
    }
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

                String currentOrderStatus = orderData['status'] ?? 'In asteptare';
                String currentPaymentStatus = orderData['paymentStatus'] ?? 'Neplatit';

                if (!['In asteptare', 'In curs de procesare', 'Finalizata'].contains(currentOrderStatus)) {
                  currentOrderStatus = 'In asteptare';
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
                            'Status: $currentOrderStatus',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Status plata: $currentPaymentStatus',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: currentOrderStatus,
                                  decoration: InputDecoration(
                                    labelText: 'Status',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  items: ['In asteptare', 'In curs de procesare', 'Finalizata']
                                      .map((status) => DropdownMenuItem(
                                            value: status,
                                            child: Text(status, style: TextStyle(fontSize: 16)),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      _updateOrderStatus(orderId, value);
                                    }
                                  },
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: currentPaymentStatus,
                                  decoration: InputDecoration(
                                    labelText: 'Status plata',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  items: ['Platit', 'Neplatit']
                                      .map((status) => DropdownMenuItem(
                                            value: status,
                                            child: Text(status, style: TextStyle(fontSize: 16)),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
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
