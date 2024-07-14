// Importă pachetul pentru interacțiunea cu baza de date Firestore.
import 'package:cloud_firestore/cloud_firestore.dart';

// Clasă care reprezintă un produs.
class Product {
  // ID-ul unic al produsului.
  final String id;
  // Titlul produsului.
  final String title;
  // Descrierea produsului.
  final String description;
  // Prețul produsului.
  final double price;
  // URL-ul imaginii produsului.
  final String imageUrl;
  // Cantitatea disponibilă a produsului.
  int quantity;
  // ID-ul furnizorului produsului.
  final String supplierId;
  // Data de expirare a produsului (poate fi null).
  final DateTime? expiryDate; 

  // Constructor pentru clasa Product.
  Product({
    required this.id, // ID-ul produsului.
    required this.title, // Titlul produsului.
    required this.description, // Descrierea produsului.
    required this.price, // Prețul produsului.
    required this.imageUrl, // URL-ul imaginii produsului.
    this.quantity = 0, // Cantitatea produsului, implicit 0.
    required this.supplierId, // ID-ul furnizorului.
    required this.expiryDate, // Data de expirare a produsului.
  });

  // Metodă factory pentru crearea unui obiect Product dintr-o hartă de date și un ID.
  factory Product.fromMap(Map<String, dynamic> data, String id) {
    return Product(
      id: id, // ID-ul produsului.
      title: data['title'] ?? '', // Titlul produsului sau șir gol dacă nu există.
      description: data['description'] ?? '', // Descrierea produsului sau șir gol dacă nu există.
      price: (data['price'] as num).toDouble(), // Prețul produsului convertit la double.
      imageUrl: data['imageUrl'] ?? '', // URL-ul imaginii produsului sau șir gol dacă nu există.
      quantity: (data['quantity'] ?? 0).toInt(), // Cantitatea produsului convertită la int, implicit 0.
      supplierId: data['supplierId'] ?? '', // ID-ul furnizorului sau șir gol dacă nu există.
      expiryDate: data['expiryDate'] != null ? (data['expiryDate'] as Timestamp).toDate() : null, // Data de expirare convertită la DateTime sau null dacă nu există.
    );
  }

  // Metodă pentru convertirea unui obiect Product într-o hartă de date.
  Map<String, dynamic> toMap() {
    return {
      'title': title, // Titlul produsului.
      'description': description, // Descrierea produsului.
      'price': price, // Prețul produsului.
      'imageUrl': imageUrl, // URL-ul imaginii produsului.
      'quantity': quantity, // Cantitatea produsului.
      'supplierId': supplierId, // ID-ul furnizorului.
      if (expiryDate != null) 'expiryDate': expiryDate, // Data de expirare, dacă există.
    };
  }
}
