import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../helper/pdf_helper.dart' if (dart.library.html) 'pdf_helper_web.dart';

Future<void> generateAndViewPDF(BuildContext context, String orderId, Map<String, dynamic> orderData) async {
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
            buildDivider(),
            buildKeyValueRow('Order ID:', orderId),
            buildKeyValueRow('Total:', '${orderData['total'] ?? 'Unknown'} lei'),
            pw.SizedBox(height: 16),
            buildDivider(),
            pw.Text('Items:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            buildOrderItemsPDF(orderData['items'] ?? []),
            pw.SizedBox(height: 16),
            buildDivider(),
            buildKeyValueRow('Address:', orderData['address'] ?? 'No address provided'),
            buildKeyValueRow('Payment Method:', orderData['paymentMethod'] ?? 'Unknown'),
            pw.SizedBox(height: 16),
            buildDivider(),
            pw.Text('User Details:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            buildUserDetailsPDF(userData.data() as Map<String, dynamic>),
            buildDivider(),
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

pw.Widget buildKeyValueRow(String key, String value) {
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

pw.Widget buildOrderItemsPDF(List<dynamic> items) {
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

pw.Widget buildUserDetailsPDF(Map<String, dynamic> userData) {
  if (userData.isEmpty) {
    return pw.Text('No user details available.', style: pw.TextStyle(fontSize: 16, color: PdfColors.red));
  }

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      buildKeyValueRow('Name:', userData['username'] ?? 'Unknown'),
      buildKeyValueRow('Email:', userData['email'] ?? 'Unknown'),
      buildKeyValueRow('Phone:', userData['phoneNumber'] ?? 'Unknown'),
      buildKeyValueRow('Address:', userData['address'] ?? 'Unknown'),
    ],
  );
}

pw.Widget buildDivider() {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 8.0),
    child: pw.Divider(color: PdfColors.grey400),
  );
}
