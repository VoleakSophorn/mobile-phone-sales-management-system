import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_phone_sales_management_system/models/customer_model.dart'; // Import CustomerModel
import 'package:mobile_phone_sales_management_system/models/product_model.dart'; // Import ProductModel
import 'package:mobile_phone_sales_management_system/models/sale_model.dart';
import 'package:mobile_phone_sales_management_system/screens/pos/pos_main_screen.dart';
import 'package:mobile_phone_sales_management_system/services/firestore_service.dart'; // Import FirestoreService

class ReceiptScreen extends StatelessWidget {
  final SaleModel sale;

  const ReceiptScreen({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt'),
      ),
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
                    const Center(
                      child: Text(
                        'SALE RECEIPT',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                    ),
                    const Divider(height: 30, thickness: 2),
                    _buildReceiptRow('Date:', DateFormat.yMMMd().add_jm().format(sale.date)),
                    _buildReceiptRow('Sale ID:', sale.id),
                    FutureBuilder<CustomerModel?>(
                      future: sale.customerId.isNotEmpty
                          ? firestoreService.getCustomerById(sale.customerId)
                          : Future.value(null),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return _buildReceiptRow('Customer:', 'Loading...');
                        }
                        if (snapshot.hasData && snapshot.data != null) {
                          return _buildReceiptRow('Customer:', snapshot.data!.name);
                        }
                        return _buildReceiptRow('Customer:', 'Guest');
                      },
                    ),
                    const Divider(height: 30, thickness: 1),
                    const Text(
                      'Items Sold:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sale.items.length,
                      itemBuilder: (context, index) {
                        final item = sale.items[index];
                        return FutureBuilder<ProductModel?>(
                          future: firestoreService.getProductById(item.productId),
                          builder: (context, snapshot) {
                            String productName = 'Product ID: ${item.productId}';
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              productName = 'Loading Product...';
                            } else if (snapshot.hasData && snapshot.data != null) {
                              productName = snapshot.data!.name;
                            }
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          productName,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                        ),
                                        if (item.imei != null && item.imei!.isNotEmpty)
                                          Text('IMEI: ${item.imei}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${item.quantity} x \$${item.price.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '\$${(item.quantity * item.price).toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const Divider(height: 30, thickness: 1),
                    _buildReceiptRow('Subtotal:', '\$${sale.totalAmount.toStringAsFixed(2)}', isTotal: true),
                    const SizedBox(height: 20),
                    const Text(
                      'Payments:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sale.payments.length,
                      itemBuilder: (context, index) {
                        final payment = sale.payments[index];
                        return _buildReceiptRow(payment.method, '\$${payment.amount.toStringAsFixed(2)}');
                      },
                    ),
                    if (sale.installments.isNotEmpty) ...[
                      const Divider(height: 30, thickness: 1),
                      const Text(
                        'Installments:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sale.installments.length,
                        itemBuilder: (context, index) {
                          final installment = sale.installments[index];
                          return _buildReceiptRow(
                            'Due ${DateFormat.yMd().format(installment.dueDate)}',
                            '\$${installment.amount.toStringAsFixed(2)} (${installment.isPaid ? 'Paid' : 'Pending'})',
                          );
                        },
                      ),
                    ],
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
                    onPressed: () {
                      // Implement print functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Print functionality not yet implemented')),
                      );
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('Print'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Implement share functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Share functionality not yet implemented')),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const POSMainScreen(),
                    ),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('New Sale'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: Colors.green, // Highlight new sale button
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}