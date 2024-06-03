// pdf_helper_web.dart
import 'dart:html' as html;

void viewPdf(List<int> bytes) {
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('target', '_blank')
    ..click();
  html.Url.revokeObjectUrl(url);
}
