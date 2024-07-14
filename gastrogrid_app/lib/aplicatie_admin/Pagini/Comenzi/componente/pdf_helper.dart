// Declară o funcție numită `viewPdf` care primește un parametru de tip `List<int>` numit `bytes`.
// Această funcție nu returnează nimic (`void`).
void viewPdf(List<int> bytes) {
  // Aruncă o excepție `UnsupportedError` cu mesajul "Cannot view PDF on this platform".
  // `throw` este utilizat pentru a arunca o excepție.
  // `UnsupportedError` este un tip de excepție specifică în Dart, utilizată pentru a indica
  // faptul că o anumită operațiune nu este suportată pe platforma curentă.
  // Mesajul `"Cannot view PDF on this platform"` oferă informații suplimentare despre motivul
  // pentru care a fost aruncată excepția.
  throw UnsupportedError("Cannot view PDF on this platform");
}
