import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_phone_sales_management_system/models/product_model.dart'; // Import ProductModel
import 'package:mobile_phone_sales_management_system/models/return_model.dart';
import 'package:mobile_phone_sales_management_system/services/firestore_service.dart';

class ReturnDetailScreen extends StatelessWidget {
  final ReturnModel returnModel;
  const ReturnDetailScreen({super.key, required this.returnModel});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'refunded':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    return Scaffold(
      appBar: AppBar(title: const Text('Return Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Return ID: ${returnModel.id}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(returnModel.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            returnModel.status,
                            style: TextStyle(
                              color: _getStatusColor(returnModel.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Sale ID: ${returnModel.saleId}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('Date: ${DateFormat.yMMMd().add_jm().format(returnModel.date)}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        'Refund Amount: \$${returnModel.refundAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Returned Items:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    returnModel.returnedItems.isEmpty
                        ? const Text('No items returned.', style: TextStyle(color: Colors.grey))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: returnModel.returnedItems.length,
                            itemBuilder: (context, index) {
                              final item = returnModel.returnedItems[index];
                              return FutureBuilder<ProductModel?>(
                                future: service.getProductById(item.productId), // Assuming getProductById exists
                                builder: (context, snapshot) {
                                  String productName = 'Product ID: ${item.productId}';
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    productName = 'Loading Product...';
                                  } else if (snapshot.hasData && snapshot.data != null) {
                                    productName = snapshot.data!.name;
                                  }
                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                        child: const Icon(Icons.phone_android, color: Colors.blue),
                                      ),
                                      title: Text(
                                        productName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      subtitle: Text(
                                        'Quantity: ${item.quantity} | Price: \$${item.price.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      trailing: Text(
                                        'Subtotal: \$${(item.quantity * item.price).toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: returnModel.status == 'Processed'
                        ? null
                        : () async {
                            final updated = ReturnModel(
                              id: returnModel.id,
                              saleId: returnModel.saleId,
                              date: returnModel.date,
                              returnedItems: returnModel.returnedItems,
                              refundAmount: returnModel.refundAmount,
                              status: 'Processed',
                            );
                            await service.updateReturn(updated);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Return marked as Processed!')),
                            );
                            Navigator.pop(context);
                          },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Mark Processed'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}