import 'package:flutter/material.dart';
import 'package:mobile_phone_sales_management_system/models/cart_item_model.dart';
import 'package:mobile_phone_sales_management_system/models/product_model.dart';

class CartProvider with ChangeNotifier {
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => _items;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity); // New getter

  double get total {
    return _items.fold(0.0, (sum, item) {
      final price = item.discountPrice != null && item.discountPrice! > 0
          ? item.discountPrice!
          : item.product.price;
      return sum + (price * item.quantity);
    });
  }

  void addItem(ProductModel product, {String? imei}) {
    final existingItemIndex = _items.indexWhere(
        (item) => item.product.id == product.id && item.imei == imei);
    if (existingItemIndex != -1) {
      _items[existingItemIndex].quantity++;
    } else {
      _items.add(CartItemModel(product: product, imei: imei));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void increaseItemQuantity(String productId) {
    final existingItemIndex =
        _items.indexWhere((item) => item.product.id == productId);
    if (existingItemIndex != -1) {
      _items[existingItemIndex].quantity++;
      notifyListeners();
    }
  }

  void setItemDiscount(String productId, double? discountPrice) {
    final existingItemIndex =
        _items.indexWhere((item) => item.product.id == productId);
    if (existingItemIndex != -1) {
      _items[existingItemIndex].discountPrice = discountPrice;
      notifyListeners();
    }
  }

  void decreaseItemQuantity(String productId) {
    final existingItemIndex =
        _items.indexWhere((item) => item.product.id == productId);
    if (existingItemIndex != -1) {
      if (_items[existingItemIndex].quantity > 1) {
        _items[existingItemIndex].quantity--;
      } else {
        _items.removeAt(existingItemIndex);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}