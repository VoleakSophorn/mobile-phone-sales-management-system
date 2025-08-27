import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_phone_sales_management_system/models/sale_model.dart';

class SaleDetailsScreen extends StatelessWidget {
  final SaleModel sale;

  const SaleDetailsScreen({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sale Details'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sale ID: ${sale.id}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Date: ${DateFormat.yMMMd().add_jm().format(sale.date)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Amount: \$${sale.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    // You might want to add customer name here if available in SaleModel
                    // if (sale.customerName != null)
                    //   const SizedBox(height: 8),
                    //   Text(
                    //     'Customer: ${sale.customerName}',
                    //     style: const TextStyle(fontSize: 16),
                    //   ),
                  ],
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Items Sold:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: sale.items.isEmpty
                ? const Center(
                    child: Text(
                      'No items found for this sale.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: sale.items.length,
                    itemBuilder: (context, index) {
                      final item = sale.items[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                            child: const Icon(Icons.phone_android, color: Colors.blue), // Placeholder icon
                          ),
                          title: Text(
                            item.productName ?? 'Product ID: ${item.productId}', // Use product name if available
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text(
                            'Quantity: ${item.quantity} | Price: \$${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: Text(
                            'Total: \$${(item.quantity * item.price).toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}