import 'package:flutter/material.dart';
// Assuming you have a service to save/load settings, e.g., SharedPreferences or FirestoreService
// import 'package:shared_preferences/shared_preferences.dart';

class CurrencySettingsScreen extends StatefulWidget {
  const CurrencySettingsScreen({super.key});

  @override
  State<CurrencySettingsScreen> createState() => _CurrencySettingsScreenState();
}

class _CurrencySettingsScreenState extends State<CurrencySettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currencySymbolController = TextEditingController();
  final _decimalPlacesController = TextEditingController();
  String _thousandSeparator = ',';
  String _decimalSeparator = '.';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _currencySymbolController.dispose();
    _decimalPlacesController.dispose();
    super.dispose();
  }

  // Simulate loading settings
  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    // In a real app, load from SharedPreferences or Firestore
    _currencySymbolController.text = '\$'; // Default
    _decimalPlacesController.text = '2'; // Default
    _thousandSeparator = ','; // Default
    _decimalSeparator = '.'; // Default
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
        const SnackBar(content: Text('Currency settings saved successfully!')),
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
        title: const Text('Currency Settings'),
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
                              'Currency Display Options',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _currencySymbolController,
                              decoration: InputDecoration(
                                labelText: 'Currency Symbol',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                prefixIcon: const Icon(Icons.attach_money),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a currency symbol';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _decimalPlacesController,
                              decoration: InputDecoration(
                                labelText: 'Number of Decimal Places',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                prefixIcon: const Icon(Icons.numbers),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter number of decimal places';
                                }
                                final int? num = int.tryParse(value);
                                if (num == null || num < 0 || num > 4) {
                                  return 'Enter a number between 0 and 4';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            DropdownButtonFormField<String>(
                              initialValue: _thousandSeparator,
                              decoration: InputDecoration(
                                labelText: 'Thousand Separator',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                prefixIcon: const Icon(Icons.format_list_numbered),
                              ),
                              items: const [
                                DropdownMenuItem(value: ',', child: Text('Comma (,)')),
                                DropdownMenuItem(value: '.', child: Text('Period (.)')),
                                DropdownMenuItem(value: ' ', child: Text('Space ( )')),
                                DropdownMenuItem(value: '', child: Text('None')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _thousandSeparator = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 15),
                            DropdownButtonFormField<String>(
                              initialValue: _decimalSeparator,
                              decoration: InputDecoration(
                                labelText: 'Decimal Separator',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                prefixIcon: const Icon(Icons.format_list_numbered_rtl),
                              ),
                              items: const [
                                DropdownMenuItem(value: '.', child: Text('Period (.)')),
                                DropdownMenuItem(value: ',', child: Text('Comma (,)')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _decimalSeparator = value!;
                                });
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