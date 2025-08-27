import 'package:flutter/material.dart';
import 'package:mobile_phone_sales_management_system/models/installment_model.dart'; // Assuming you have this model
import 'package:mobile_phone_sales_management_system/services/firestore_service.dart'; // Assuming you have this service

class InstallmentScreen extends StatefulWidget {
  const InstallmentScreen({super.key});

  @override
  State<InstallmentScreen> createState() => _InstallmentScreenState();
}

class _InstallmentScreenState extends State<InstallmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _totalAmountController = TextEditingController();
  final _downPaymentController = TextEditingController();
  final _monthsController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  double _monthlyInstallment = 0.0;
  bool _isLoading = false;

  @override
  void dispose() {
    _totalAmountController.dispose();
    _downPaymentController.dispose();
    _monthsController.dispose();
    super.dispose();
  }

  void _calculateInstallment() {
    if (_formKey.currentState!.validate()) {
      final totalAmount = double.parse(_totalAmountController.text);
      final downPayment = double.parse(_downPaymentController.text);
      final months = int.parse(_monthsController.text);

      if (months > 0) {
        setState(() {
          _monthlyInstallment = (totalAmount - downPayment) / months;
        });
      } else {
        setState(() {
          _monthlyInstallment = 0.0;
        });
      }
    }
  }

  Future<void> _saveInstallment() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final totalAmount = double.parse(_totalAmountController.text);
      final downPayment = double.parse(_downPaymentController.text);
      final months = int.parse(_monthsController.text);

      final installment = InstallmentModel(
        id: '', // Firestore will generate ID
        saleId: '', // Placeholder: You'll need to get the actual saleId
        dueDate: DateTime.now().add(Duration(days: 30 * months)), // Placeholder: Calculate actual due date
        amount: _monthlyInstallment, // This is the monthly amount
        isPaid: false, // Initial state
        totalAmount: totalAmount,
        downPayment: downPayment,
        numberOfMonths: months,
        monthlyInstallment: _monthlyInstallment,
        dateCreated: DateTime.now(),
        status: 'active', // or 'pending'
      );

      await _firestoreService.addInstallment(installment);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Installment plan saved successfully!')),
      );
      Navigator.pop(context); // Go back after saving
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Installment Payment'),
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
                  labelText: 'Total Amount',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter total amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _downPaymentController,
                decoration: InputDecoration(
                  labelText: 'Down Payment',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.money_off),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter down payment';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _monthsController,
                decoration: InputDecoration(
                  labelText: 'Number of Months',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter number of months';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid number of months (>0)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _calculateInstallment,
                icon: const Icon(Icons.calculate),
                label: const Text('Calculate Monthly Installment'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
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
                        'Monthly Installment:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '\$${_monthlyInstallment.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _saveInstallment,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Installment Plan'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),                    ),
            ],
          ),
        ),
      ),
    );
  }
}