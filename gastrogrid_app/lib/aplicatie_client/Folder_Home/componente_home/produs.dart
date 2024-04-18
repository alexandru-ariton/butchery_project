class Product {
  final String title;
  final String description;
  final double price;
  final String imageUrl;

  Product({
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  factory Product.fromMap(Map<String, dynamic> data) {
    return Product(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] as num).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}
