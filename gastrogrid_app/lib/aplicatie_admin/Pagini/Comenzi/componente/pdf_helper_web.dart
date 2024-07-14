// ignore_for_file: unused_local_variable

import 'dart:html' as html; // Importă biblioteca HTML pentru utilizarea specifică a API-urilor web.

void viewPdf(List<int> bytes) {
  final blob = html.Blob([bytes], 'application/pdf'); // Creează un blob din lista de bytes, specificând tipul de conținut ca 'application/pdf'.
  final url = html.Url.createObjectUrlFromBlob(blob); // Creează o adresă URL pentru blob-ul creat.
  final anchor = html.AnchorElement(href: url) // Creează un element de ancorare cu atributul href setat la adresa URL generată.
    ..setAttribute('target', '_blank') // Setează atributul 'target' al elementului de ancorare la '_blank' pentru a deschide PDF-ul într-o nouă fereastră.
    ..click(); // Simulează un clic pe elementul de ancorare pentru a deschide PDF-ul.
  html.Url.revokeObjectUrl(url); // Revocă adresa URL creată pentru a elibera resursele.
}
