class Product {
  final String id;
  final String name;
  final int price;
  final String imagePath;
  final String barcode;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.barcode,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'imagePath': imagePath,
        'barcode': barcode,
        'category': category,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        price: json['price'],
        imagePath: json['imagePath'],
        barcode: json['barcode'],
        category: json['category'] ?? '',
      );
}
