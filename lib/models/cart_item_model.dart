import 'package:mobile_phone_sales_management_system/models/product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;
  String? imei;
  double? discountPrice;

  CartItemModel(
      {required this.product,
      this.quantity = 1,
      this.imei,
      this.discountPrice});
}
