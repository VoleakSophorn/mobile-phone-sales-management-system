import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_phone_sales_management_system/models/sale_model.dart';
import 'package:mobile_phone_sales_management_system/models/user_model.dart';
import 'package:mobile_phone_sales_management_system/services/firestore_service.dart';

class SalesReportsScreen extends StatefulWidget {
  const SalesReportsScreen({super.key});

  @override
  State<SalesReportsScreen> createState() => _SalesReportsScreenState();
}

class _SalesReportsScreenState extends State<SalesReportsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCashierId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Reports'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _startDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              _startDate = picked;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Start Date',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            prefixIcon: const Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _startDate == null ? 'Select Date' : DateFormat.yMd().format(_startDate!),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _endDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              _endDate = picked;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'End Date',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            prefixIcon: const Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _endDate == null ? 'Select Date' : DateFormat.yMd().format(_endDate!),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                StreamBuilder<List<UserModel>>(
                  stream: _firestoreService.getUsers(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    final cashiers = snapshot.data!.where((user) => user.role == 'Cashier').toList();
                    return DropdownButtonFormField<String>(
                      value: _selectedCashierId,
                      decoration: InputDecoration(
                        labelText: 'Filter by Cashier',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Cashiers')),
                        ...cashiers
                            .map((cashier) => DropdownMenuItem(value: cashier.uid, child: Text(cashier.email)))
                            ,
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCashierId = value;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                        _selectedCashierId = null;
                      });
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear Filters'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<SaleModel>>(
              stream: _firestoreService.getSalesByFilter(
                startDate: _startDate,
                endDate: _endDate,
                cashierId: _selectedCashierId,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final sales = snapshot.data ?? [];
                final totalRevenue = sales.fold(0.0, (sum, sale) => sum + sale.totalAmount);

                if (sales.isEmpty) {
                  return const Center(
                    child: Text(
                      'No sales found for the selected filters.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return Column(
                  children: [
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Text('Total Sales', style: TextStyle(fontSize: 16, color: Colors.grey)),
                                Text(
                                  '${sales.length}',
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Text('Total Revenue', style: TextStyle(fontSize: 16, color: Colors.grey)),
                                Text(
                                  '\$${totalRevenue.toStringAsFixed(2)}',
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
                              contentPadding: const EdgeInsets.all(10),
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                child: const Icon(Icons.receipt, color: Colors.blue),
                              ),
                              title: Text(
                                'Sale ID: ${sale.id}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Customer ID: ${sale.customerId.isEmpty ? 'Guest' : sale.customerId}', style: const TextStyle(fontSize: 14)),
                                  Text('Date: ${DateFormat.yMMMd().add_jm().format(sale.date)}', style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                              trailing: Text(
                                '\$${sale.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                              onTap: () {
                                // Navigate to Sale Details Screen
                                // You might need to pass the sale object to a SaleDetailsScreen
                                // Navigator.push(context, MaterialPageRoute(builder: (context) => SaleDetailsScreen(sale: sale)));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Tapped on Sale ID: ${sale.id}')),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}