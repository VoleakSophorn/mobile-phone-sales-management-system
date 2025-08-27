class ProductModel {
  final String id;
  final String name;
  final double price;
  final int stock;
  final String? imageBase64;
  final String? promotionText;
  final int? quantitySold; // New field for top selling products

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.imageBase64,
    this.promotionText,
    this.quantitySold, // New field
  });

  // Add copyWith method
  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    int? stock,
    String? imageBase64,
    String? promotionText,
    int? quantitySold,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imageBase64: imageBase64 ?? this.imageBase64,
      promotionText: promotionText ?? this.promotionText,
      quantitySold: quantitySold ?? this.quantitySold,
    );
  }
}