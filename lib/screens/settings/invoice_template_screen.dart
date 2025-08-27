import 'package:flutter/material.dart';
// Assuming you have a service to save/load settings, e.g., SharedPreferences or FirestoreService
// import 'package:shared_preferences/shared_preferences.dart';

class InvoiceTemplateScreen extends StatefulWidget {
  const InvoiceTemplateScreen({super.key});

  @override
  State<InvoiceTemplateScreen> createState() => _InvoiceTemplateScreenState();
}

class _InvoiceTemplateScreenState extends State<InvoiceTemplateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _companyAddressController = TextEditingController();
  final _companyPhoneController = TextEditingController();
  final _companyEmailController = TextEditingController();
  final _invoiceHeaderController = TextEditingController();
  final _invoiceFooterController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _companyPhoneController.dispose();
    _companyEmailController.dispose();
    _invoiceHeaderController.dispose();
    _invoiceFooterController.dispose();
    super.dispose();
  }

  // Simulate loading settings
  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    // In a real app, load from SharedPreferences or Firestore
    _companyNameController.text = 'Your Company Name';
    _companyAddressController.text = '123 Business St, City, Country';
    _companyPhoneController.text = '+123 456 7890';
    _companyEmailController.text = 'info@yourcompany.com';
    _invoiceHeaderController.text = 'Thank you for your business!';
    _invoiceFooterController.text = 'All sales are final.';
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
        const SnackBar(content: Text('Invoice template settings saved successfully!')),
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
        title: const Text('Invoice Template'),
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
                              'Company Information',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _companyNameController,
                              decoration: InputDecoration(
                                labelText: 'Company Name',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                prefixIcon: const Icon(Icons.business),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter company name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _companyAddressController,
                              decoration: InputDecoration(
                                labelText: 'Company Address',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                prefixIcon: const Icon(Icons.location_on),
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _companyPhoneController,
                              decoration: InputDecoration(
                                labelText: 'Company Phone',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                prefixIcon: const Icon(Icons.phone),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _companyEmailController,
                              decoration: InputDecoration(
                                labelText: 'Company Email',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                prefixIcon: const Icon(Icons.email),
                              ),
                              keyboardType: TextInputType.emailAddress,
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
                              'Invoice Header & Footer',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _invoiceHeaderController,
                              decoration: InputDecoration(
                                labelText: 'Invoice Header Message',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                prefixIcon: const Icon(Icons.text_fields),
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _invoiceFooterController,
                              decoration: InputDecoration(
                                labelText: 'Invoice Footer Message',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                prefixIcon: const Icon(Icons.text_fields),
                              ),
                              maxLines: 3,
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
                        label: const Text('Save Invoice Template'),
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