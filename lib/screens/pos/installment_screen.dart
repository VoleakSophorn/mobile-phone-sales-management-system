import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_phone_sales_management_system/models/installment_model.dart';
import 'package:mobile_phone_sales_management_system/models/sale_model.dart';
import 'package:mobile_phone_sales_management_system/services/firestore_service.dart';

class InstallmentScreen extends StatefulWidget {
  final SaleModel sale;

  const InstallmentScreen({super.key, required this.sale});

  @override
  State<InstallmentScreen> createState() => _InstallmentScreenState();
}

class _InstallmentScreenState extends State<InstallmentScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Installments'),
      ),
      body: ListView.builder(
        itemCount: widget.sale.installments.length,
        itemBuilder: (context, index) {
          final installment = widget.sale.installments[index];
          return ListTile(
            title: Text('Due Date: ${DateFormat.yMd().format(installment.dueDate)}'),
            subtitle: Text('Amount: \$${installment.amount.toStringAsFixed(2)}'),
            trailing: Checkbox(
              value: installment.isPaid,
              onChanged: (value) async {
                final updatedInstallment = InstallmentModel(
                  id: installment.id,
                  saleId: installment.saleId,
                  dueDate: installment.dueDate,
                  amount: installment.amount,
                  isPaid: value!,
                  totalAmount: installment.totalAmount,
                  downPayment: installment.downPayment,
                  numberOfMonths: installment.numberOfMonths,
                  monthlyInstallment: installment.monthlyInstallment,
                  dateCreated: installment.dateCreated,
                  status: installment.status,
                );
                await _firestoreService.updateInstallment(updatedInstallment);
              },
            ),
          );
        },
      ),
    );
  }
}
