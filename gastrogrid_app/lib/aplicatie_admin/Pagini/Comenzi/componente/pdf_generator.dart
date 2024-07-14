import 'package:flutter/foundation.dart' show kIsWeb; // Importă o bibliotecă specifică pentru a determina dacă aplicația rulează pe web.
import 'package:flutter/material.dart'; // Importă biblioteca principală Flutter pentru utilizarea widget-urilor.
import 'package:pdf/pdf.dart'; // Importă biblioteca PDF pentru manipularea documentelor PDF.
import 'package:pdf/widgets.dart' as pw; // Importă widget-urile PDF cu aliasul 'pw' pentru a evita conflictele cu widget-urile Flutter.
import 'package:printing/printing.dart'; // Importă biblioteca Printing pentru a imprima documente PDF.
import 'package:cloud_firestore/cloud_firestore.dart'; // Importă biblioteca Cloud Firestore pentru a interacționa cu baza de date Firestore.
import 'pdf_helper.dart' if (dart.library.html) 'pdf_helper_web.dart'; // Importă ajutoare pentru PDF în funcție de platformă.

Future<void> generateAndViewPDF(BuildContext context, String orderId, Map<String, dynamic> orderData) async {
  final userId = orderData['userId']; // Obține ID-ul utilizatorului din datele comenzii.
  final userData = await FirebaseFirestore.instance.collection('users').doc(userId).get(); // Obține datele utilizatorului din Firestore.
  final pdf = pw.Document(); // Creează un nou document PDF.

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Padding(
        padding: pw.EdgeInsets.all(16),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Chitanta', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)), // Adaugă titlul chitanței.
            pw.SizedBox(height: 16), // Adaugă un spațiu vertical de 16.
            buildDivider(), // Adaugă un separator.
            buildKeyValueRow('ID comanda:', orderId), // Adaugă rândul cu ID-ul comenzii.
            buildKeyValueRow('Total:', '${orderData['total'] ?? '-'} lei'), // Adaugă rândul cu totalul comenzii.
            pw.SizedBox(height: 16), // Adaugă un spațiu vertical de 16.
            buildDivider(), // Adaugă un separator.
            pw.Text('Produse:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)), // Adaugă titlul secțiunii de produse.
            buildOrderItemsPDF(orderData['items'] ?? []), // Adaugă lista produselor.
            pw.SizedBox(height: 16), // Adaugă un spațiu vertical de 16.
            buildDivider(), // Adaugă un separator.
            buildKeyValueRow('Adresa:', orderData['address'] ?? '-'), // Adaugă rândul cu adresa.
            buildKeyValueRow('Modalitate de plata:', orderData['paymentMethod'] ?? 'Unknown'), // Adaugă rândul cu modalitatea de plată.
            pw.SizedBox(height: 16), // Adaugă un spațiu vertical de 16.
            buildDivider(), // Adaugă un separator.
            pw.Text('Detalii client:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)), // Adaugă titlul secțiunii de detalii client.
            buildUserDetailsPDF(userData.data() as Map<String, dynamic>), // Adaugă detaliile clientului.
            buildDivider(), // Adaugă un separator.
          ],
        ),
      ),
    ),
  );

  final bytes = await pdf.save(); // Salvează documentul PDF ca bytes.

  if (kIsWeb) {
    viewPdf(bytes); // Dacă aplicația rulează pe web, vizualizează PDF-ul folosind funcția specifică pentru web.
  } else {
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => bytes); // Dacă aplicația nu rulează pe web, deschide interfața de imprimare.
  }
}

// Funcție pentru a construi un rând cheie-valoare în PDF.
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

// Funcție pentru a construi lista produselor în PDF.
pw.Widget buildOrderItemsPDF(List<dynamic> items) {
  if (items.isEmpty) {
    return pw.Text('-', style: pw.TextStyle(fontSize: 16, color: PdfColors.red)); // Dacă nu sunt produse, afișează un text gol.
  }

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: items.map((item) {
      var productData = item['product'] ?? {};
      var productName = productData['title'] ?? '-';
      var quantity = item['quantity'] ?? '-';
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4.0),
        child: pw.Text('$productName x $quantity', style: pw.TextStyle(fontSize: 16, color: PdfColors.grey700)),
      );
    }).toList(),
  );
}

// Funcție pentru a construi detaliile utilizatorului în PDF.
pw.Widget buildUserDetailsPDF(Map<String, dynamic> userData) {
  if (userData.isEmpty) {
    return pw.Text('-', style: pw.TextStyle(fontSize: 16, color: PdfColors.red)); // Dacă nu sunt date despre utilizator, afișează un text gol.
  }

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      buildKeyValueRow('Nume:', userData['username'] ?? '-'),
      buildKeyValueRow('Email:', userData['email'] ?? '-'),
      buildKeyValueRow('Telefon:', userData['phoneNumber'] ?? '-'),
     
    ],
  );
}

// Funcție pentru a construi un separator în PDF.
pw.Widget buildDivider() {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 8.0),
    child: pw.Divider(color: PdfColors.grey400),
  );
}
