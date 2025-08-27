import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_phone_sales_management_system/models/product_imei_model.dart';
import 'package:mobile_phone_sales_management_system/models/product_model.dart';
import 'package:mobile_phone_sales_management_system/services/firestore_service.dart';

class AddEditProductScreen extends StatefulWidget {
  final ProductModel? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _imeiController = TextEditingController();
  final _promotionTextController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  String? _imageBase64;
  bool _isLoading = false; // New loading state

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _stockController.text = widget.product!.stock.toString();
      _imageBase64 = widget.product!.imageBase64;
      _promotionTextController.text = widget.product!.promotionText ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imeiController.dispose();
    _promotionTextController.dispose();
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

  void _addImei() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New IMEI', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextFormField(
            controller: _imeiController,
            decoration: InputDecoration(
              labelText: 'IMEI Number',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              prefixIcon: const Icon(Icons.qr_code),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an IMEI number';
              }
              return null;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                _imeiController.clear();
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_imeiController.text.isNotEmpty && widget.product != null) {
                  _firestoreService.addImei(ProductImeiModel(
                    id: '',
                    productId: widget.product!.id,
                    imei: _imeiController.text,
                    isSold: false, // Default to not sold
                  ));
                  _imeiController.clear();
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid IMEI and ensure product is saved.')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteImei(BuildContext context, ProductImeiModel imei) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete IMEI'),
          content: Text('Are you sure you want to delete IMEI: ${imei.imei}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                _firestoreService.deleteImei(imei.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final product = ProductModel(
        id: widget.product?.id ?? '',
        name: _nameController.text,
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        imageBase64: _imageBase64,
        promotionText: _promotionTextController.text.isNotEmpty
            ? _promotionTextController.text
            : null,
      );

      if (widget.product == null) {
        await _firestoreService.addProduct(product);
      } else {
        await _firestoreService.updateProduct(product);
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
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
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                        image: _imageBase64 != null
                            ? DecorationImage(
                                image: MemoryImage(base64Decode(_imageBase64!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _imageBase64 == null
                          ? Icon(Icons.camera_alt, size: 60, color: Colors.grey[700])
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
                          child: const Icon(Icons.edit, color: Colors.white),
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
                  labelText: 'Product Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid price (>0)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _stockController,
                decoration: InputDecoration(
                  labelText: 'Stock Quantity',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.inventory),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the stock quantity';
                  }
                  if (int.tryParse(value) == null || int.parse(value) < 0) {
                    return 'Please enter a valid stock quantity (>=0)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _promotionTextController,
                decoration: InputDecoration(
                  labelText: 'Promotion Text (Optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.campaign),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _saveProduct,
                      icon: const Icon(Icons.save),
                      label: Text(widget.product == null ? 'Add Product' : 'Update Product'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
              if (widget.product != null) ...[
                const SizedBox(height: 30),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'IMEI Management',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                      onPressed: _addImei,
                      icon: const Icon(Icons.add),
                      label: const Text('Add IMEI'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        textStyle: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                StreamBuilder<List<ProductImeiModel>>(
                  stream: _firestoreService.getImeisForProduct(widget.product!.id),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Error loading IMEIs.');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final imeis = snapshot.data ?? [];
                    if (imeis.isEmpty) {
                      return const Text('No IMEIs added for this product yet.');
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: imeis.length,
                      itemBuilder: (context, index) {
                        final imei = imeis[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          child: ListTile(
                            title: Text(imei.imei),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _confirmDeleteImei(context, imei);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}