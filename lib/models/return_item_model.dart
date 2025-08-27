class ReturnItemModel {
  final String productId;
  final int quantity;
  final double price;
  final String? imei;

  ReturnItemModel({
    required this.productId,
    required this.quantity,
    required this.price,
    this.imei,
  });
}