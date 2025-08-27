import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_phone_sales_management_system/models/customer_model.dart';
import 'package:mobile_phone_sales_management_system/services/firestore_service.dart';

class AddEditCustomerScreen extends StatefulWidget {
  final CustomerModel? customer;

  const AddEditCustomerScreen({super.key, this.customer});

  @override
  State<AddEditCustomerScreen> createState() => _AddEditCustomerScreenState();
}

class _AddEditCustomerScreenState extends State<AddEditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController(); // New controller for address
  final _firestoreService = FirestoreService();
  String? _imageBase64;
  bool _isLoading = false; // New loading state

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _nameController.text = widget.customer!.name;
      _phoneController.text = widget.customer!.phone;
      _addressController.text = widget.customer!.address ?? ''; // Initialize address
      _imageBase64 = widget.customer!.imageBase64;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose(); // Dispose new controller
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      setState(() {
        _imageBase64 = base64Encode(bytes);
      });
    }
  }

  void _clearImage() {
    setState(() {
      _imageBase64 = null;
    });
  }

  Future<void> _saveCustomer() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final customer = CustomerModel(
        id: widget.customer?.id ?? '',
        name: _nameController.text,
        phone: _phoneController.text,
        address: _addressController.text.isEmpty ? null : _addressController.text, // Save address
        imageBase64: _imageBase64,
      );

      if (widget.customer == null) {
        await _firestoreService.addCustomer(customer);
      } else {
        await _firestoreService.updateCustomer(customer);
      }

      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer == null ? 'Add Customer' : 'Edit Customer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _imageBase64 != null
                          ? MemoryImage(base64Decode(_imageBase64!))
                          : null,
                      child: _imageBase64 == null
                          ? Icon(Icons.person, size: 60, color: Colors.grey[700])
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: const Icon(Icons.camera_alt, color: Colors.white),
                        ),
                      ),
                    ),
                    if (_imageBase64 != null)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _clearImage,
                          child: const CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.red,
                            child: Icon(Icons.clear, size: 15, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.home),
                ),
                maxLines: 3,
                keyboardType: TextInputType.streetAddress,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveCustomer,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        widget.customer == null ? 'Add Customer' : 'Update Customer',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
