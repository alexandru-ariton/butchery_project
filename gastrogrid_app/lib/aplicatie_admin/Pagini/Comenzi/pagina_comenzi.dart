import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:GastroGrid/aplicatie_admin/Pagini/Comenzi/pagina_detalii_comenzi.dart';

class OrderManagement extends StatelessWidget {
  void _deleteOrder(String id) async {
    await FirebaseFirestore.instance.collection('orders').doc(id).delete();
  }

  void _updateOrderStatus(String orderId, String newStatus, String userId) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({'status': newStatus});

    } catch (e) {
      print("Failed to update order status: $e");
    }
  }

  void _updatePaymentStatus(String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({'paymentStatus': newStatus});
    } catch (e) {
      print("Failed to update payment status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

                String currentOrderStatus = orderData['status'] ?? 'Pending';
                String currentPaymentStatus = orderData['paymentStatus'] ?? 'Unpaid';
                String userId = orderData['userId'] ?? ''; // Asumând că userId este stocat în orderData

                if (!['Pending', 'In Progress', 'Completed'].contains(currentOrderStatus)) {
                  currentOrderStatus = 'Pending'; // Setează valoarea implicită
                }

                if (!['Paid', 'Unpaid'].contains(currentPaymentStatus)) {
                  currentPaymentStatus = 'Unpaid'; // Setează valoarea implicită
                }

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text('Order $orderId', style: TextStyle(fontSize: 18)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status: $currentOrderStatus', style: TextStyle(fontSize: 16)),
                        Text('Payment Status: $currentPaymentStatus', style: TextStyle(fontSize: 16)),
                        Text('Total: ${orderData['total'] ?? 'Unknown'} lei', style: TextStyle(fontSize: 16)),
                        _buildOrderItems(orderData['items'] ?? []),
                      ],
                    ),
                    trailing: Container(
                      width: 300, // Ajustează lățimea pentru a se potrivi conținutului
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DropdownButton<String>(
                            value: currentOrderStatus,
                            items: ['Pending', 'In Progress', 'Completed']
                                .map((status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(status, style: TextStyle(fontSize: 16)),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                _updateOrderStatus(orderId, value, userId);
                              }
                            },
                          ),
                          DropdownButton<String>(
                            value: currentPaymentStatus,
                            items: ['Paid', 'Unpaid']
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
                          IconButton(
                            icon: Icon(Icons.delete, size: 24),
                            onPressed: () => _deleteOrder(orderId),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => OrderDetailsPage(orderId: orderId, orderData: orderData),
                      ));
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderItems(List<dynamic> items) {
    if (items.isEmpty) {
      return Text('No items found.', style: TextStyle(fontSize: 16));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        var productData = item['product'] ?? {};
        var productName = productData['title'] ?? 'Unknown Product';
        var quantity = item['quantity'] ?? 'Unknown Quantity';
        return Text('$productName x $quantity', style: TextStyle(fontSize: 16));
      }).toList(),
    );
  }
}
