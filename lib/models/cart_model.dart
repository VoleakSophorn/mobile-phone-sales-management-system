import 'package:mobile_phone_sales_management_system/models/cart_item_model.dart';

class CartModel {
  final List<CartItemModel> items;
  final double total;

  CartModel({required this.items, required this.total});
}