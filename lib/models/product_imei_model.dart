class ProductImeiModel {
  final String id;
  final String productId;
  final String imei;
  bool isSold;

  ProductImeiModel({
    required this.id,
    required this.productId,
    required this.imei,
    this.isSold = false,
  });

  // Add copyWith method
  ProductImeiModel copyWith({
    String? id,
    String? productId,
    String? imei,
    bool? isSold,
  }) {
    return ProductImeiModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      imei: imei ?? this.imei,
      isSold: isSold ?? this.isSold,
    );
  }
}