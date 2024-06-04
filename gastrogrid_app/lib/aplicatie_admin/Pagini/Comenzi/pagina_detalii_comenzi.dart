// ignore_for_file: unused_import

import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// Conditional import
import 'file_handler.dart' if (dart.library.html) 'chrome_file_handler.dart';

void _generateAndViewPDF(BuildContext context, String orderId, Map<String, dynamic> orderData) async {
  final userId = orderData['userId'];
  final userData = await FirebaseFirestore.instance.collection('users').doc(userId).get();
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Padding(
        padding: pw.EdgeInsets.all(16),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Receipt', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
            pw.SizedBox(height: 16),
            _buildDivider(),
            _buildKeyValueRow('Order ID:', orderId),
            _buildKeyValueRow('Total:', '${orderData['total'] ?? 'Unknown'} lei'),
            pw.SizedBox(height: 16),
            _buildDivider(),
            pw.Text('Items:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            _buildOrderItemsPDF(orderData['items'] ?? []),
            pw.SizedBox(height: 16),
            _buildDivider(),
            _buildKeyValueRow('Address:', orderData['address'] ?? 'No address provided'),
            _buildKeyValueRow('Payment Method:', orderData['paymentMethod'] ?? 'Unknown'),
            pw.SizedBox(height: 16),
            _buildDivider(),
            pw.Text('User Details:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            _buildUserDetailsPDF(userData.data() as Map<String, dynamic>),
            _buildDivider(),
          ],
        ),
      ),
    ),
  );

  final bytes = await pdf.save();

  if (kIsWeb) {
    viewPdf(bytes);
  } else {
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => bytes);
  }
}

pw.Widget _buildKeyValueRow(String key, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 4.0),
    child: pw.Row(
      children: [
        pw.Expanded(
          flex: 2,
          child: pw.Text('$key ', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
        ),
        pw.Expanded(
          flex: 3,
          child: pw.Text(value, style: pw.TextStyle(fontSize: 18, color: PdfColors.grey700)),
        ),
      ],
    ),
  );
}

pw.Widget _buildOrderItemsPDF(List<dynamic> items) {
  if (items.isEmpty) {
    return pw.Text('No items found.', style: pw.TextStyle(fontSize: 16, color: PdfColors.red));
  }

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: items.map((item) {
      var productData = item['product'] ?? {};
      var productName = productData['title'] ?? 'Unknown Product';
      var quantity = item['quantity'] ?? 'Unknown Quantity';
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4.0),
        child: pw.Text('$productName x $quantity', style: pw.TextStyle(fontSize: 16, color: PdfColors.grey700)),
      );
    }).toList(),
  );
}

pw.Widget _buildUserDetailsPDF(Map<String, dynamic> userData) {
  if (userData.isEmpty) {
    return pw.Text('No user details available.', style: pw.TextStyle(fontSize: 16, color: PdfColors.red));
  }

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _buildKeyValueRow('Name:', userData['username'] ?? 'Unknown'),
      _buildKeyValueRow('Email:', userData['email'] ?? 'Unknown'),
      _buildKeyValueRow('Phone:', userData['phoneNumber'] ?? 'Unknown'),
      _buildKeyValueRow('Address:', userData['address'] ?? 'Unknown'),
    ],
  );
}

pw.Widget _buildDivider() {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 8.0),
    child: pw.Divider(color: PdfColors.grey400),
  );
}


class OrderDetailsPage extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> orderData;

  OrderDetailsPage({required this.orderId, required this.orderData});

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
                _buildOrderItems(orderData['items'] ?? []),
                SizedBox(height: 16),
                _buildOrderDetailRow('Address:', orderData['address'] ?? 'No address provided'),
                _buildOrderDetailRow('Payment Method:', orderData['paymentMethod'] ?? 'Unknown'),
                SizedBox(height: 16),
                Text('User Details:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _buildUserDetails(orderData['userId']),
                SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _generateAndViewPDF(context, orderId, orderData),
                    child: Text('Print Receipt', style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    ),
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
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text('$productName x $quantity', style: TextStyle(fontSize: 16)),
        );
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
            _buildOrderDetailRow('Name:', userData['username'] ?? 'Unknown'),
            _buildOrderDetailRow('Email:', userData['email'] ?? 'Unknown'),
            _buildOrderDetailRow('Phone:', userData['phoneNumber'] ?? 'Unknown'),
            _buildOrderDetailRow('Address:', userData['address'] ?? 'Unknown'),
          ],
        );
      },
    );
  }
}
