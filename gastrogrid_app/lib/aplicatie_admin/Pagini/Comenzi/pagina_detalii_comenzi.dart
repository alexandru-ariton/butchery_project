import 'package:GastroGrid/aplicatie_admin/Pagini/Comenzi/componente/order_items.dart';
import 'package:GastroGrid/aplicatie_admin/Pagini/Comenzi/componente/pdf_generator.dart';
import 'package:GastroGrid/aplicatie_admin/Pagini/Comenzi/componente/user_details.dart';
import 'package:flutter/material.dart';


class OrderDetailsPage extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> orderData;

  const OrderDetailsPage({super.key, required this.orderId, required this.orderData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _buildOrderDetailRow('Order ID:', orderId),
                _buildOrderDetailRow('Status:', orderData['status'] ?? 'Unknown'),
                _buildOrderDetailRow('Total:', '${orderData['total'] ?? 'Unknown'} lei'),
                SizedBox(height: 16),
                Text('Items:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                OrderItems(orderItems: orderData['items'] ?? []),
                SizedBox(height: 16),
                _buildOrderDetailRow('Address:', orderData['address'] ?? 'No address provided'),
                _buildOrderDetailRow('Payment Method:', orderData['paymentMethod'] ?? 'Unknown'),
                SizedBox(height: 16),
                Text('User Details:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                UserDetails(userId: orderData['userId']),
                SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () => generateAndViewPDF(context, orderId, orderData),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    ),
                    child: Text('Print Receipt', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text('$label ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: TextStyle(fontSize: 18))),
        ],
      ),
    );
  }
}
