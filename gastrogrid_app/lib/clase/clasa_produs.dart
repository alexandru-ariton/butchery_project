import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  int quantity;
  final String supplierId;
  final DateTime? expiryDate; 
  

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.quantity = 0,
    required this.supplierId, 
    required this.expiryDate,
  });

  factory Product.fromMap(Map<String, dynamic> data, String id) {
  return Product(
    id: id,
    title: data['title'] ?? '',
    description: data['description'] ?? '',
    price: (data['price'] as num).toDouble(),
    imageUrl: data['imageUrl'] ?? '',
    quantity: (data['quantity'] ?? 0).toInt(), // Ensure quantity is an int
    supplierId: data['supplierId'] ?? '',
    expiryDate: data['expiryDate'] != null ? (data['expiryDate'] as Timestamp).toDate() : null,
  );
}


  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'supplierId': supplierId, 
       if (expiryDate != null) 'expiryDate': expiryDate,
    };
  }
}
