
import 'package:mobile_phone_sales_management_system/models/return_item_model.dart';

class ReturnModel {
  final String id;
  final String saleId;
  final DateTime date;
  final List<ReturnItemModel> returnedItems;
  final double refundAmount;
  final String status;

  ReturnModel({
    required this.id,
    required this.saleId,
    required this.date,
    required this.returnedItems,
    required this.refundAmount,
    this.status = 'Pending',
  });
}
