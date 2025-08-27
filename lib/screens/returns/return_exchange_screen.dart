import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_phone_sales_management_system/models/product_model.dart'; // Assuming ProductModel
import 'package:mobile_phone_sales_management_system/models/return_model.dart';
import 'package:mobile_phone_sales_management_system/models/sale_item_model.dart';
import 'package:mobile_phone_sales_management_system/models/return_item_model.dart';
import 'package:mobile_phone_sales_management_system/models/sale_model.dart';
import 'package:mobile_phone_sales_management_system/services/firestore_service.dart';

class ReturnExchangeScreen extends StatefulWidget {
  const ReturnExchangeScreen({super.key});

  @override
  State<ReturnExchangeScreen> createState() => _ReturnExchangeScreenState();
}

class _ReturnExchangeScreenState extends State<ReturnExchangeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _saleIdController = TextEditingController();
  final _firestoreService = FirestoreService();
  SaleModel? _sale;
  final List<SaleItemModel> _selectedItems = [];
  bool _isLoadingSale = false;
  bool _saleNotFound = false;
  bool _isSubmittingReturn = false;

  @override
  void dispose() {
    _saleIdController.dispose();
    super.dispose();
  }

  void _findSale() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoadingSale = true;
        _saleNotFound = false;
        _sale = null;
        _selectedItems.clear();
      });

      final sale = await _firestoreService.getSaleById(_saleIdController.text);

      setState(() {
        _isLoadingSale = false;
        if (sale != null) {
          _sale = sale;
        } else {
          _saleNotFound = true;
        }
      });
    }
  }

  void _onItemSelected(SaleItemModel item, bool? selected) {
    setState(() {
      if (selected == true) {
        _selectedItems.add(item);
      } else {
        _selectedItems.removeWhere((i) => i.productId == item.productId && i.imei == item.imei);
      }
    });
  }

  double get _refundAmount {
    return _selectedItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  void _submitReturn() async {
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one item to return.')),
      );
      return;
    }

    setState(() {
      _isSubmittingReturn = true;
    });

    final returnModel = ReturnModel(
      id: '', // Firestore will generate ID
      saleId: _sale!.id,
      date: DateTime.now(), 
      returnedItems: _selectedItems.map((item) => ReturnItemModel(
        productId: item.productId,
        quantity: item.quantity,
        price: item.price,
        imei: item.imei,
      )).toList(),
      refundAmount: _refundAmount,
      status: 'Pending', // Initial status
    );
    await _firestoreService.addReturn(returnModel);

    // Mark returned IMEIs as available again (if applicable)
    for (var item in _selectedItems) {
      if (item.imei != null && item.imei!.isNotEmpty) {
        final imei = await _firestoreService.getImeiByNumber(item.imei!);
        if (imei != null) {
          await _firestoreService.updateImei(imei.copyWith(isSold: false));
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _isSubmittingReturn = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Return request submitted successfully!')),
    );
    Navigator.pop(context); // Go back after submitting
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Return/Exchange'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _saleIdController,
                decoration: InputDecoration(
                  labelText: 'Enter Sale ID',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.receipt),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a sale ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              _isLoadingSale
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _findSale,
                      icon: const Icon(Icons.search),
                      label: const Text('Find Sale'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
              if (_saleNotFound)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'Sale not found. Please check the ID.',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_sale != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Sale Details:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              Text('Sale ID: ${_sale!.id}', style: const TextStyle(fontSize: 16)),
                              Text('Date: ${DateFormat.yMMMd().add_jm().format(_sale!.date)}', style: const TextStyle(fontSize: 16)),
                              Text('Total Amount: \$${_sale!.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Select items to return:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _sale!.items.length,
                          itemBuilder: (context, index) {
                            final item = _sale!.items[index];
                            return FutureBuilder<ProductModel?>(
                              future: _firestoreService.getProductById(item.productId),
                              builder: (context, snapshot) {
                                String productName = 'Product ID: ${item.productId}';
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  productName = 'Loading Product...';
                                } else if (snapshot.hasData && snapshot.data != null) {
                                  productName = snapshot.data!.name;
                                }
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  child: CheckboxListTile(
                                    title: Text(productName),
                                    subtitle: Text('Quantity: ${item.quantity} | Price: \$${item.price.toStringAsFixed(2)}${item.imei != null ? ' | IMEI: ${item.imei}' : ''}'),
                                    value: _selectedItems.any((i) => i.productId == item.productId && i.imei == item.imei),
                                    onChanged: (selected) => _onItemSelected(item, selected),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Estimated Refund Amount:',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '\$${_refundAmount.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _isSubmittingReturn
                          ? const Center(child: CircularProgressIndicator())
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _submitReturn,
                                icon: const Icon(Icons.send),
                                label: const Text('Submit Return Request'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  backgroundColor: Colors.redAccent,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}