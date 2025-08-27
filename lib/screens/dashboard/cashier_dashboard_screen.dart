import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_phone_sales_management_system/screens/pos/pos_main_screen.dart';
import 'package:mobile_phone_sales_management_system/services/auth_service.dart';
import 'package:mobile_phone_sales_management_system/services/firestore_service.dart';

class CashierDashboardScreen extends StatefulWidget {
  const CashierDashboardScreen({super.key});

  @override
  State<CashierDashboardScreen> createState() => _CashierDashboardScreenState();
}

class _CashierDashboardScreenState extends State<CashierDashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String _cashierId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cashier Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => AuthService().signOut(),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildDailySalesCard(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const POSMainScreen(),
                ),
              );
            },
            child: const Text('Go to POS'),
          ),
        ],
      ),
    );
  }

  Widget _buildDailySalesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Today\'s Sales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            StreamBuilder<double>(
              stream: _firestoreService.getDailySales(_cashierId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                return Text('\$${snapshot.data?.toStringAsFixed(2) ?? '0.00'}', style: const TextStyle(fontSize: 24));
              },
            ),
          ],
        ),
      ),
    );
  }
}
