import 'package:flutter/material.dart';
import 'package:mobile_phone_sales_management_system/services/firestore_service.dart';
import 'package:mobile_phone_sales_management_system/models/product_model.dart'; // Assuming ProductModel has quantitySold

class TopProductsScreen extends StatelessWidget {
  const TopProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    return Scaffold(
      appBar: AppBar(title: const Text('Top Selling Products')),
      body: StreamBuilder<List<ProductModel>>(
        stream: service.getTopSellingProducts(10), // Assuming this fetches products with quantitySold
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load top products.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snapshot.data!;
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.trending_down, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  const Text(
                    'No top selling products found yet.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final p = list[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Text(
                      '#${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  title: Text(
                    p.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Price: \$${p.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15)),
                      Text('Stock: ${p.stock}', style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Sold:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(
                        '${p.quantitySold ?? 'N/A'}', // Assuming quantitySold is available
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}