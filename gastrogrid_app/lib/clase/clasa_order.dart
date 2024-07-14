// Importă pachetul pentru interacțiunea cu baza de date Firestore.
import 'package:cloud_firestore/cloud_firestore.dart';
// Importă clasa CartItem.
import 'package:gastrogrid_app/clase/clasa_cart.dart';

// Clasă care reprezintă o comandă.
class Order {
  // ID-ul unic al comenzii.
  final String id;
  // ID-ul utilizatorului care a plasat comanda.
  final String userId;
  // Lista de articole din coșul de cumpărături.
  final List<CartItem> items;
  // Totalul comenzii.
  final double total;
  // Starea comenzii.
  final String status;
  // Adresa de livrare.
  final String address;
  // Timpul la care a fost plasată comanda.
  final DateTime timestamp;

  // Constructor pentru clasa Order.
  Order({
    required this.id, // ID-ul comenzii.
    required this.userId, // ID-ul utilizatorului.
    required this.items, // Lista de articole din coș.
    required this.total, // Totalul comenzii.
    required this.status, // Starea comenzii.
    required this.address, // Adresa de livrare.
    required this.timestamp, // Timpul comenzii.
  });

  // Metodă factory pentru crearea unui obiect Order dintr-o hartă de date și un ID.
  factory Order.fromMap(Map<String, dynamic> data, String id) {
    return Order(
      id: id, // ID-ul comenzii.
      userId: data['userId'], // ID-ul utilizatorului.
      items: (data['items'] as List).map((item) => CartItem.fromMap(item)).toList(), // Lista de articole din coș.
      total: data['total'], // Totalul comenzii.
      status: data['status'], // Starea comenzii.
      address: data['address'], // Adresa de livrare.
      timestamp: (data['timestamp'] as Timestamp).toDate(), // Timpul comenzii convertit la DateTime.
    );
  }

  // Metodă pentru convertirea unui obiect Order într-o hartă de date.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId, // ID-ul utilizatorului.
      'items': items.map((item) => item.toMap()).toList(), // Lista de articole din coș convertită la hartă de date.
      'total': total, // Totalul comenzii.
      'status': status, // Starea comenzii.
      'address': address, // Adresa de livrare.
      'timestamp': timestamp, // Timpul comenzii.
    };
  }
}
