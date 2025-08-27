import 'package:flutter/material.dart';
import 'package:mobile_phone_sales_management_system/models/product_imei_model.dart';
import 'package:mobile_phone_sales_management_system/services/firestore_service.dart';

class IMEIManagementScreen extends StatefulWidget {
  const IMEIManagementScreen({super.key});

  @override
  State<IMEIManagementScreen> createState() => _IMEIManagementScreenState();
}

class _IMEIManagementScreenState extends State<IMEIManagementScreen> {
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

  void _toggleImeiSoldStatus(ProductImeiModel imei) async {
    await _firestoreService.updateImei(imei.copyWith(isSold: !imei.isSold));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('IMEI ${imei.imei} marked as ${imei.isSold ? 'Available' : 'Sold'}')),
    );
  }

  void _confirmDeleteImei(BuildContext context, ProductImeiModel imei) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete IMEI'),
          content: Text('Are you sure you want to delete IMEI: ${imei.imei}?'),
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
                _firestoreService.deleteImei(imei.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search IMEI...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 18),
                cursorColor: Colors.white,
              )
            : const Text('IMEI Management'),
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
        ],
      ),
      body: StreamBuilder<List<ProductImeiModel>>(
        stream: _firestoreService.getAllImeis(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final imeis = snapshot.data ?? [];
          final filteredImeis = imeis.where((imei) {
            final imeiLower = imei.imei.toLowerCase();
            final searchQueryLower = _searchQuery.toLowerCase();
            return imeiLower.contains(searchQueryLower);
          }).toList();

          if (filteredImeis.isEmpty) {
            return Center(
              child: Text(
                _searchQuery.isEmpty
                    ? 'No IMEIs found.'
                    : 'No IMEIs found for "$_searchQuery".',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            itemCount: filteredImeis.length,
            itemBuilder: (context, index) {
              final imei = filteredImeis[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: CircleAvatar(
                    backgroundColor: imei.isSold ? Colors.red[100] : Colors.green[100],
                    child: Icon(
                      imei.isSold ? Icons.block : Icons.check_circle,
                      color: imei.isSold ? Colors.red : Colors.green,
                    ),
                  ),
                  title: Text(
                    imei.imei,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(
                    imei.isSold ? 'Status: Sold' : 'Status: Available',
                    style: TextStyle(color: imei.isSold ? Colors.red : Colors.green),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(imei.isSold ? Icons.undo : Icons.sell, color: Colors.blue),
                        onPressed: () => _toggleImeiSoldStatus(imei),
                        tooltip: imei.isSold ? 'Mark as Available' : 'Mark as Sold',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDeleteImei(context, imei),
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