import 'package:flutter/material.dart';

class MixedPaymentScreen extends StatefulWidget {
  const MixedPaymentScreen({super.key});

  @override
  State<MixedPaymentScreen> createState() => _MixedPaymentScreenState();
}

class _MixedPaymentScreenState extends State<MixedPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _totalAmountController = TextEditingController();
  final _cashAmountController = TextEditingController();
  final _cardAmountController = TextEditingController();

  double _remainingBalance = 0.0;

  @override
  void dispose() {
    _totalAmountController.dispose();
    _cashAmountController.dispose();
    _cardAmountController.dispose();
    super.dispose();
  }

  void _calculateRemainingBalance() {
    if (_formKey.currentState!.validate()) {
      final totalAmount = double.tryParse(_totalAmountController.text) ?? 0.0;
      final cashAmount = double.tryParse(_cashAmountController.text) ?? 0.0;
      final cardAmount = double.tryParse(_cardAmountController.text) ?? 0.0;

      setState(() {
        _remainingBalance = totalAmount - (cashAmount + cardAmount);
      });
    }
  }

  void _processMixedPayment() {
    if (_formKey.currentState!.validate()) {
      _calculateRemainingBalance(); // Recalculate before processing

      if (_remainingBalance == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mixed payment processed successfully!')),
        );
        Navigator.pop(context); // Go back after successful payment
      } else if (_remainingBalance > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Remaining balance: \$${_remainingBalance.toStringAsFixed(2)}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paid amount exceeds total amount!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mixed Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _totalAmountController,
                decoration: InputDecoration(
                  labelText: 'Total Transaction Amount',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter total amount';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid total amount (>0)';
                  }
                  return null;
                },
                onChanged: (_) => _calculateRemainingBalance(),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _cashAmountController,
                decoration: InputDecoration(
                  labelText: 'Cash Amount',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter cash amount (0 if none)';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onChanged: (_) => _calculateRemainingBalance(),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _cardAmountController,
                decoration: InputDecoration(
                  labelText: 'Card Amount',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter card amount (0 if none)';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onChanged: (_) => _calculateRemainingBalance(),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Remaining Balance:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '\$${_remainingBalance.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _remainingBalance > 0 ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _processMixedPayment,
                icon: const Icon(Icons.check_circle),
                label: const Text('Process Mixed Payment'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}