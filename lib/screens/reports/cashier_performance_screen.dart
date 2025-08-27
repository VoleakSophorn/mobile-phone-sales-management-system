import 'package:flutter/material.dart';
import 'package:mobile_phone_sales_management_system/services/firestore_service.dart';

class CashierPerformanceScreen extends StatelessWidget {
  const CashierPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    return Scaffold(
      appBar: AppBar(title: const Text('Cashier Performance')),
      body: StreamBuilder<Map<String, double>>(
        stream: service.getCashierPerformance(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load cashier performance data.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          if (data.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  const Text(
                    'No cashier performance data available yet.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          final entries = data.entries.toList();
          final totalSalesAllCashiers = entries.fold(0.0, (sum, entry) => sum + entry.value);

          return Column(
            children: [
              Card(
                margin: const EdgeInsets.all(16),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Total Cashiers', style: TextStyle(fontSize: 16, color: Colors.grey)),
                          Text(
                            '${entries.length}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Total Sales (All)', style: TextStyle(fontSize: 16, color: Colors.grey)),
                          Text(
                            '\$${totalSalesAllCashiers.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final e = entries[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          child: const Icon(Icons.person, color: Colors.blue),
                        ),
                        title: Text(
                          e.key, // Cashier Name/Email
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        trailing: Text(
                          '\$${e.value.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}