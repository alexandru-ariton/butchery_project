import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gastrogrid_app/aplicatie_client/clase/cart.dart';


class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double total;
  final String status;
  final String address;
  final DateTime timestamp;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    required this.address,
    required this.timestamp,
  });

  factory Order.fromMap(Map<String, dynamic> data, String id) {
    return Order(
      id: id,
      userId: data['userId'],
      items: (data['items'] as List).map((item) => CartItem.fromMap(item)).toList(),
      total: data['total'],
      status: data['status'],
      address: data['address'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'status': status,
      'address': address,
      'timestamp': timestamp,
    };
  }
}
