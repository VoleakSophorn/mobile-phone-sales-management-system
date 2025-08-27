import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_phone_sales_management_system/models/customer_model.dart';
import 'package:mobile_phone_sales_management_system/models/sale_model.dart';
import 'package:mobile_phone_sales_management_system/screens/customers/sale_details_screen.dart';
import 'package:mobile_phone_sales_management_system/services/firestore_service.dart';

class PurchaseHistoryScreen extends StatelessWidget {
  final CustomerModel customer;

  const PurchaseHistoryScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: Text('${customer.name}\'s Purchase History'),
      ),
      body: StreamBuilder<List<SaleModel>>(
        stream: firestoreService.getSales(customer.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong. Please try again later.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final sales = snapshot.data ?? [];

          if (sales.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  const Text(
                    'No purchase history found for this customer.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: sales.length,
            itemBuilder: (context, index) {
              final sale = sales[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Icon(Icons.receipt_long, color: Theme.of(context).primaryColor),
                  ),
                  title: Text(
                    'Sale on ${DateFormat.yMMMd().format(sale.date)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  subtitle: Text(
                    'Total: \$${sale.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 15, color: Colors.green),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SaleDetailsScreen(sale: sale),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}