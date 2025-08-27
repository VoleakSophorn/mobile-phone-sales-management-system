import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_phone_sales_management_system/models/customer_model.dart';
import 'package:mobile_phone_sales_management_system/screens/customers/add_edit_customer_screen.dart';
import 'package:mobile_phone_sales_management_system/screens/customers/purchase_history_screen.dart';
import 'package:mobile_phone_sales_management_system/services/firestore_service.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search customers...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 18),
                cursorColor: Colors.white,
              )
            : const Text('Customers'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditCustomerScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<CustomerModel>>(
        stream: _firestoreService.getCustomers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final customers = snapshot.data ?? [];
          final filteredCustomers = customers.where((customer) {
            final nameLower = customer.name.toLowerCase();
            final phoneLower = customer.phone.toLowerCase();
            final searchQueryLower = _searchQuery.toLowerCase();
            return nameLower.contains(searchQueryLower) ||
                   phoneLower.contains(searchQueryLower);
          }).toList();

          if (filteredCustomers.isEmpty) {
            return Center(
              child: Text(
                _searchQuery.isEmpty
                    ? 'No customers found.'
                    : 'No customers found for "$_searchQuery".',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: filteredCustomers.length,
            itemBuilder: (context, index) {
              final customer = filteredCustomers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: customer.imageBase64 != null
                      ? CircleAvatar(
                          backgroundImage: MemoryImage(base64Decode(customer.imageBase64!)),
                          radius: 25,
                        )
                      : const CircleAvatar(
                          radius: 25,
                          child: Icon(Icons.person, size: 30),
                        ),
                  title: Text(
                    customer.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(customer.phone, style: const TextStyle(fontSize: 15)),
                      if (customer.address != null && customer.address!.isNotEmpty)
                        Text(customer.address!, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.history, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PurchaseHistoryScreen(customer: customer),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditCustomerScreen(customer: customer),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _confirmDeleteCustomer(context, customer);
                        },
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

  void _confirmDeleteCustomer(BuildContext context, CustomerModel customer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete ${customer.name}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                _firestoreService.deleteCustomer(customer.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}