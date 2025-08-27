class SaleItemModel {
  final String productId;
  final int quantity;
  final double price;
  final String? imei;
  final String? productName; // New field

  SaleItemModel({
    required this.productId,
    required this.quantity,
    required this.price,
    this.imei,
    this.productName, // New field
  });
}