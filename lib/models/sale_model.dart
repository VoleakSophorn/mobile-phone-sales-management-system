import 'package:mobile_phone_sales_management_system/models/installment_model.dart';
import 'package:mobile_phone_sales_management_system/models/payment_model.dart';
import 'package:mobile_phone_sales_management_system/models/sale_item_model.dart';

class SaleModel {
  final String id;
  final String customerId;
  final DateTime date;
  final double totalAmount;
  final List<SaleItemModel> items;
  final List<PaymentModel> payments;
  final List<InstallmentModel> installments;

  SaleModel({
    required this.id,
    required this.customerId,
    required this.date,
    required this.totalAmount,
    required this.items,
    required this.payments,
    required this.installments,
  });

  SaleModel copyWith({
    String? id,
    String? customerId,
    DateTime? date,
    double? totalAmount,
    List<SaleItemModel>? items,
    List<PaymentModel>? payments,
    List<InstallmentModel>? installments,
  }) {
    return SaleModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      date: date ?? this.date,
      totalAmount: totalAmount ?? this.totalAmount,
      items: items ?? this.items,
      payments: payments ?? this.payments,
      installments: installments ?? this.installments,
    );
  }
}