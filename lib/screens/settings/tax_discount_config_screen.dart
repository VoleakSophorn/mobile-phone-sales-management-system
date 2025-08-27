import 'package:flutter/material.dart';
// Assuming you have a service to save/load settings, e.g., SharedPreferences or FirestoreService
// import 'package:shared_preferences/shared_preferences.dart';

class TaxDiscountConfigScreen extends StatefulWidget {
  const TaxDiscountConfigScreen({super.key});

  @override
  State<TaxDiscountConfigScreen> createState() => _TaxDiscountConfigScreenState();
}

class _TaxDiscountConfigScreenState extends State<TaxDiscountConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _taxRateController = TextEditingController();
  final _defaultDiscountController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _taxRateController.dispose();
    _defaultDiscountController.dispose();
    super.dispose();
  }

  // Simulate loading settings
  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    // In a real app, load from SharedPreferences or Firestore
    _taxRateController.text = '5.0'; // Default 5% tax
    _defaultDiscountController.text = '0.0'; // Default 0% discount
    setState(() {
      _isLoading = false;
    });
  }

  // Simulate saving settings
  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      // In a real app, save to SharedPreferences or Firestore
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tax & Discount settings saved successfully!')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax & Discount Configuration'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Global Tax Rate',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _taxRateController,
                              decoration: InputDecoration(
                                labelText: 'Tax Rate (%)',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                prefixIcon: const Icon(Icons.percent),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a tax rate';
                                }
                                final double? rate = double.tryParse(value);
                                if (rate == null || rate < 0 || rate > 100) {
                                  return 'Enter a number between 0 and 100';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Default Discount',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _defaultDiscountController,
                              decoration: InputDecoration(
                                labelText: 'Default Discount (%)',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                prefixIcon: const Icon(Icons.discount),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a default discount';
                                }
                                final double? discount = double.tryParse(value);
                                if (discount == null || discount < 0 || discount > 100) {
                                  return 'Enter a number between 0 and 100';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveSettings,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Settings'),
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
    );
  }
}