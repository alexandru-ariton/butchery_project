class Product {
  final String id;  
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  int quantity; // Adăugăm acest câmp
  

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
   this.quantity = 0
  });

    factory Product.fromMap(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] as num).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
       quantity: data['cantitate'] ?? 0,
    );
  } 

   Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'cantitate': quantity,
    };
  }

}

