class Product {
  String id;
  String name;
  int price;
  String imagePath; // path foto lokal

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imagePath,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'imagePath': imagePath,
  };
}
