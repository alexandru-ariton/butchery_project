import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gastrogrid_app/aplicatie_admin/Pagini/Comenzi/pagina_detalii_comenzi.dart';

class OrderManagement extends StatelessWidget {
  void _deleteOrder(String id) async {
    await FirebaseFirestore.instance.collection('orders').doc(id).delete();
  }

  void _updateOrderStatus(String orderId, String newStatus, String userId) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({'status': newStatus});

      if (newStatus == 'Completed') {
        // Trimite notificarea doar când statusul este "Completed"
        await FirebaseFirestore.instance.collection('notifications').add({
          'userId': userId,
          'orderId': orderId,
          'message': 'Your order has been completed. Please rate our services.',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
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
          return ListView.builder(
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
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text('Order $orderId'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: $currentOrderStatus'),
                      Text('Payment Status: $currentPaymentStatus'),
                      Text('Total: ${orderData['total'] ?? 'Unknown'} lei'),
                      _buildOrderItems(orderData['items'] ?? []),
                    ],
                  ),
                  trailing: Container(
                    width: 240, // Ajustează lățimea pentru a se potrivi conținutului
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DropdownButton<String>(
                          value: currentOrderStatus,
                          items: ['Pending', 'In Progress', 'Completed']
                              .map((status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
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
                                    child: Text(status),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              _updatePaymentStatus(orderId, value);
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
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
          );
        },
      ),
    );
  }

  Widget _buildOrderItems(List<dynamic> items) {
    if (items.isEmpty) {
      return Text('No items found.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        var productData = item['product'] ?? {};
        var productName = productData['title'] ?? 'Unknown Product';
        var quantity = item['quantity'] ?? 'Unknown Quantity';
        return Text('$productName x $quantity');
      }).toList(),
    );
  }
}
