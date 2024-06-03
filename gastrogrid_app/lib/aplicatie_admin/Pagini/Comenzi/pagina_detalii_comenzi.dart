import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:html' as html;

class OrderDetailsPage extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> orderData;

  OrderDetailsPage({required this.orderId, required this.orderData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order Details')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Order ID: $orderId', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Status: ${orderData['status'] ?? 'Unknown'}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Total: ${orderData['total'] ?? 'Unknown'} lei', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text('Items:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _buildOrderItems(orderData['items'] ?? []),
            SizedBox(height: 16),
            Text('Address: ${orderData['address'] ?? 'No address provided'}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text('Payment Method: ${orderData['paymentMethod'] ?? 'Unknown'}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text('User Details:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _buildUserDetails(orderData['userId']),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _generateAndViewPDF(context),
              child: Text('Print Receipt', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blue, padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
            ),
          ],
        ),
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

  Widget _buildUserDetails(String userId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text('Loading user details...', style: TextStyle(fontSize: 16));
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>?;
        if (userData == null) {
          return Text('No user details available.', style: TextStyle(fontSize: 16));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${userData['username'] ?? 'Unknown'}', style: TextStyle(fontSize: 16)),
            Text('Email: ${userData['email'] ?? 'Unknown'}', style: TextStyle(fontSize: 16)),
            Text('Phone: ${userData['phoneNumber'] ?? 'Unknown'}', style: TextStyle(fontSize: 16)),
            Text('Address: ${userData['address'] ?? 'Unknown'}', style: TextStyle(fontSize: 16)),
          ],
        );
      },
    );
  }

  void _generateAndViewPDF(BuildContext context) async {
    final userId = orderData['userId'];
    final userData = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Receipt', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 16),
            pw.Text('Order ID: $orderId', style: pw.TextStyle(fontSize: 18)),
            pw.Text('Total: ${orderData['total'] ?? 'Unknown'} lei', style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 16),
            pw.Text('Items:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            _buildOrderItemsPDF(orderData['items'] ?? []),
            pw.SizedBox(height: 16),
            pw.Text('Address: ${orderData['address'] ?? 'No address provided'}', style: pw.TextStyle(fontSize: 18)),
            pw.Text('Payment Method: ${orderData['paymentMethod'] ?? 'Unknown'}', style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 16),
            pw.Text('User Details:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            _buildUserDetailsPDF(userData.data() as Map<String, dynamic>),
          ],
        ),
      ),
    );

    final bytes = await pdf.save();

    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('target', '_blank')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  pw.Widget _buildOrderItemsPDF(List<dynamic> items) {
    if (items.isEmpty) {
      return pw.Text('No items found.', style: pw.TextStyle(fontSize: 16));
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: items.map((item) {
        var productData = item['product'] ?? {};
        var productName = productData['title'] ?? 'Unknown Product';
        var quantity = item['quantity'] ?? 'Unknown Quantity';
        return pw.Text('$productName x $quantity', style: pw.TextStyle(fontSize: 16));
      }).toList(),
    );
  }

  pw.Widget _buildUserDetailsPDF(Map<String, dynamic> userData) {
    if (userData.isEmpty) {
      return pw.Text('No user details available.', style: pw.TextStyle(fontSize: 16));
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Name: ${userData['username'] ?? 'Unknown'}', style: pw.TextStyle(fontSize: 16)),
        pw.Text('Email: ${userData['email'] ?? 'Unknown'}', style: pw.TextStyle(fontSize: 16)),
        pw.Text('Phone: ${userData['phoneNumber'] ?? 'Unknown'}', style: pw.TextStyle(fontSize: 16)),
        pw.Text('Address: ${userData['address'] ?? 'Unknown'}', style: pw.TextStyle(fontSize: 16)),
      ],
    );
  }
}
