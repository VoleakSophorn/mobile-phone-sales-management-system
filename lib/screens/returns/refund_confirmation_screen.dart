import 'package:flutter/material.dart';
import 'package:mobile_phone_sales_management_system/models/return_model.dart';
import 'package:mobile_phone_sales_management_system/screens/returns/returns_list_screen.dart';

class RefundConfirmationScreen extends StatelessWidget {
  final ReturnModel returnModel;

  const RefundConfirmationScreen({super.key, required this.returnModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refund Confirmation'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 120),
                  const SizedBox(height: 20),
                  const Text(
                    'Refund Confirmed!',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Amount Refunded:',
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '\$${returnModel.refundAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReturnsListScreen(),
                          ),
                          (route) => route.isFirst,
                        );
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Close'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}