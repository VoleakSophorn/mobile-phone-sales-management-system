import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_phone_sales_management_system/models/return_model.dart';
import 'package:mobile_phone_sales_management_system/services/firestore_service.dart';
import 'package:mobile_phone_sales_management_system/screens/returns/return_detail_screen.dart';

class ReturnsListScreen extends StatefulWidget {
  const ReturnsListScreen({super.key});

  @override
  State<ReturnsListScreen> createState() => _ReturnsListScreenState();
}

class _ReturnsListScreenState extends State<ReturnsListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  String? _selectedStatusFilter; // New state for status filter

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
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search returns...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 18),
                cursorColor: Colors.white,
              )
            : const Text('Returns'),
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (String? newValue) {
              setState(() {
                _selectedStatusFilter = newValue;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: null,
                child: Text('All Statuses'),
              ),
              const PopupMenuItem<String>(
                value: 'Pending',
                child: Text('Pending'),
              ),
              const PopupMenuItem<String>(
                value: 'Approved',
                child: Text('Approved'),
              ),
              const PopupMenuItem<String>(
                value: 'Refunded',
                child: Text('Refunded'),
              ),
              const PopupMenuItem<String>(
                value: 'Rejected',
                child: Text('Rejected'),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<ReturnModel>>(
        stream: _firestoreService.getReturns(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load returns'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allReturns = snapshot.data ?? [];
          final filteredReturns = allReturns.where((r) {
            final matchesSearch = r.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                                  r.saleId.toLowerCase().contains(_searchQuery.toLowerCase()); // Assuming saleId is searchable
            final matchesStatus = _selectedStatusFilter == null || r.status == _selectedStatusFilter;
            return matchesSearch && matchesStatus;
          }).toList();

          if (filteredReturns.isEmpty) {
            return Center(
              child: Text(
                _searchQuery.isEmpty && _selectedStatusFilter == null
                    ? 'No returns yet.'
                    : 'No returns found for the selected filters.',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: filteredReturns.length,
            itemBuilder: (context, index) {
              final r = filteredReturns[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReturnDetailScreen(returnModel: r),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Return ID: ${r.id}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(r.status).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                r.status,
                                style: TextStyle(
                                  color: _getStatusColor(r.status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sale ID: ${r.saleId}',
                          style: const TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Date: ${DateFormat.yMMMd().add_jm().format(r.date)}',
                          style: const TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            'Refund: \$${r.refundAmount.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ),
                      ],
                    ),
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