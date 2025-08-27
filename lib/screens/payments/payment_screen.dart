import 'package:flutter/material.dart';
import 'package:mobile_phone_sales_management_system/screens/payments/installment_screen.dart';
import 'package:mobile_phone_sales_management_system/screens/payments/mixed_payment_screen.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Payment Method'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPaymentMethodCard(
              context,
              title: 'Cash Payment',
              icon: Icons.money,
              onTap: () {
                // Implement cash payment logic or navigate to a dedicated cash payment screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cash Payment selected (Not yet implemented)')),
                );
              },
            ),
            const SizedBox(height: 15),
            _buildPaymentMethodCard(
              context,
              title: 'Card Payment',
              icon: Icons.credit_card,
              onTap: () {
                // Implement card payment logic or navigate to a dedicated card payment screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Card Payment selected (Not yet implemented)')),
                );
              },
            ),
            const SizedBox(height: 15),
            _buildPaymentMethodCard(
              context,
              title: 'Installment Payment',
              icon: Icons.calendar_month,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InstallmentScreen()),
                );
              },
            ),
            const SizedBox(height: 15),
            _buildPaymentMethodCard(
              context,
              title: 'Mixed Payment',
              icon: Icons.payments,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MixedPaymentScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(width: 20),
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}