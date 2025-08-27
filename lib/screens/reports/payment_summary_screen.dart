import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_phone_sales_management_system/models/sale_model.dart';
import 'package:mobile_phone_sales_management_system/services/firestore_service.dart';

class PaymentSummaryScreen extends StatefulWidget {
  const PaymentSummaryScreen({super.key});

  @override
  State<PaymentSummaryScreen> createState() => _PaymentSummaryScreenState();
}

class _PaymentSummaryScreenState extends State<PaymentSummaryScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Summary'),
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                      });
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear Date Filters'),
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
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final sales = snapshot.data ?? [];
                final Map<String, double> paymentMethodTotals = {};
                double grandTotal = 0.0;

                for (var sale in sales) {
                  for (var payment in sale.payments) {
                    paymentMethodTotals.update(
                      payment.method,
                      (value) => value + payment.amount,
                      ifAbsent: () => payment.amount,
                    );
                  }
                  grandTotal += sale.totalAmount;
                }

                if (sales.isEmpty) {
                  return const Center(
                    child: Text(
                      'No sales found for the selected date range.',
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Summary by Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            ...paymentMethodTotals.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      '\$${entry.value.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const Divider(height: 20, thickness: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Grand Total:',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '\$${grandTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Individual Sales:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                              subtitle: Text(
                                'Date: ${DateFormat.yMMMd().add_jm().format(sale.date)} | Total: \$${sale.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                              onTap: () {
                                // Navigate to Sale Details Screen
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