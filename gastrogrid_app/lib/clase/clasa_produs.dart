class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  int quantity;
  final String supplierId; 

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.quantity = 0,
    required this.supplierId, 
  });

  factory Product.fromMap(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] as num).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      quantity: data['quantity'] ?? 0,
      supplierId: data['supplierId'] ?? '', 
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
    };
  }
}
