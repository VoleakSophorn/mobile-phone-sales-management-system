import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_phone_sales_management_system/models/customer_model.dart';
import 'package:mobile_phone_sales_management_system/models/installment_model.dart';
import 'package:mobile_phone_sales_management_system/models/payment_model.dart';
import 'package:mobile_phone_sales_management_system/models/sale_item_model.dart';
import 'package:mobile_phone_sales_management_system/models/sale_model.dart';
import 'package:mobile_phone_sales_management_system/providers/cart_provider.dart';
import 'package:mobile_phone_sales_management_system/screens/pos/receipt_screen.dart';
import 'package:mobile_phone_sales_management_system/services/firestore_service.dart';

class CheckoutScreen extends StatefulWidget {
  final CustomerModel? customer;
  final CartProvider cart;

  const CheckoutScreen({super.key, this.customer, required this.cart});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final List<PaymentModel> _payments = [];
  double get _totalPaid =>
      _payments.fold(0.0, (sum, item) => sum + item.amount);
  double get _remainingBalance => widget.cart.total - _totalPaid;

  bool _isInstallment = false;
  final _numberOfInstallmentsController = TextEditingController();
  String _installmentInterval = 'Monthly';
  bool _isLoading = false; // New loading state

  @override
  void dispose() {
    _numberOfInstallmentsController.dispose();
    super.dispose();
  }

  void _addPayment() {
    final amountController = TextEditingController();
    String paymentMethod = 'Cash';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Payment', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: paymentMethod,
                decoration: InputDecoration(
                  labelText: 'Payment Method',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: ['Cash', 'Bank', 'Mobile']
                    .map((method) =>
                        DropdownMenuItem(value: method, child: Text(method)))
                    .toList(),
                onChanged: (value) {
                  setState(() { // Use setState to update the dialog's internal state
                    paymentMethod = value!;
                  });
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid amount (>0)';
                  }
                  return null;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0) {
                  setState(() {
                    _payments.add(
                        PaymentModel(method: paymentMethod, amount: amount));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  List<InstallmentModel> _generateInstallments(
      String saleId, double totalAmount) {
    if (!_isInstallment || _numberOfInstallmentsController.text.isEmpty) {
      return [];
    }

    final numberOfInstallments =
        int.tryParse(_numberOfInstallmentsController.text);
    if (numberOfInstallments == null || numberOfInstallments <= 0) {
      return [];
    }

    final installmentAmount = totalAmount / numberOfInstallments;
    final installments = <InstallmentModel>[];
    DateTime dueDate = DateTime.now();

    for (int i = 0; i < numberOfInstallments; i++) {
      if (_installmentInterval == 'Monthly') {
        dueDate = DateTime(dueDate.year, dueDate.month + 1, dueDate.day);
      } else if (_installmentInterval == 'Weekly') {
        dueDate = dueDate.add(const Duration(days: 7));
      }
      installments.add(InstallmentModel(
        id: '',
        saleId: saleId,
        dueDate: dueDate,
        amount: installmentAmount,
        isPaid: i == 0, // First installment is paid immediately
        totalAmount: totalAmount, // Pass totalAmount
        downPayment: 0.0, // Assuming 0 down payment for individual installments
        numberOfMonths: numberOfInstallments, // Pass numberOfInstallments
        monthlyInstallment: installmentAmount, // Pass monthlyInstallment
        dateCreated: DateTime.now(), // Pass dateCreated
        status: 'pending', // Initial status for individual installments
      ));
    }
    return installments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Name: ${widget.customer?.name ?? 'Guest'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Phone: ${widget.customer?.phone ?? 'N/A'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.cart.items.length,
                      itemBuilder: (context, index) {
                        final item = widget.cart.items[index];
                        final price =
                            item.discountPrice != null && item.discountPrice! > 0
                                ? item.discountPrice!
                                : item.product.price;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.product.name} (${item.imei ?? 'N/A'})',
                                  style: const TextStyle(fontSize: 15),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${item.quantity} x \$${price.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:',
                            style:
                                TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('\$${widget.cart.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Payments',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton.icon(
                          onPressed: _addPayment,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Payment'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            textStyle: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _payments.isEmpty
                        ? const Text('No payments added yet.', style: TextStyle(color: Colors.grey))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _payments.length,
                            itemBuilder: (context, index) {
                              final payment = _payments[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${payment.method} Payment', style: const TextStyle(fontSize: 15)),
                                    Text('\$${payment.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              );
                            },
                          ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Paid:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        Text('\$${_totalPaid.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Remaining Balance:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          '\$${_remainingBalance.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _remainingBalance > 0 ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: const Text('Installment Plan', style: TextStyle(fontWeight: FontWeight.bold)),
                      value: _isInstallment,
                      onChanged: (value) {
                        setState(() {
                          _isInstallment = value;
                        });
                      },
                    ),
                    if (_isInstallment)
                      Column(
                        children: [
                          TextFormField(
                            controller: _numberOfInstallmentsController,
                            decoration: InputDecoration(
                                labelText: 'Number of Installments',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter number of installments';
                              }
                              if (int.tryParse(value) == null || int.parse(value) <= 0) {
                                return 'Please enter a valid number (>0)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          DropdownButtonFormField<String>(
                            initialValue: _installmentInterval,
                            decoration: InputDecoration(
                                labelText: 'Installment Interval',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                            items: ['Monthly', 'Weekly']
                                .map((interval) => DropdownMenuItem(
                                    value: interval, child: Text(interval)))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _installmentInterval = value!;
                              });
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _remainingBalance == 0 && !_isInstallment
                          ? () async {
                              setState(() { _isLoading = true; });
                              final cashierId = FirebaseAuth.instance.currentUser!.uid;
                              final sale = SaleModel(
                                id: '', // Firestore will generate this
                                customerId: widget.customer?.id ?? '',
                                date: DateTime.now(),
                                totalAmount: widget.cart.total,
                                items: widget.cart.items.map((cartItem) {
                                  final price = cartItem.discountPrice != null &&
                                          cartItem.discountPrice! > 0
                                      ? cartItem.discountPrice!
                                      : cartItem.product.price;
                                  return SaleItemModel(
                                    productId: cartItem.product.id,
                                    quantity: cartItem.quantity,
                                    price: price,
                                    imei: cartItem.imei,
                                  );
                                }).toList(),
                                payments: _payments,
                                installments: [], // No installments for full payment
                              );
                              final addedSale =
                                  await FirestoreService().addSale(sale, cashierId);
                              widget.cart.clear();
                              if (!mounted) return;
                              setState(() { _isLoading = false; });
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReceiptScreen(sale: addedSale),
                                ),
                                (route) => route.isFirst,
                              );
                            }
                          : (_isInstallment && _remainingBalance == 0) // Allow installment if remaining is 0 after down payment
                            ? () async {
                                setState(() { _isLoading = true; });
                                final cashierId = FirebaseAuth.instance.currentUser!.uid;
                                final sale = SaleModel(
                                  id: '', // Firestore will generate this
                                  customerId: widget.customer?.id ?? '',
                                  date: DateTime.now(),
                                  totalAmount: widget.cart.total,
                                  items: widget.cart.items.map((cartItem) {
                                    final price = cartItem.discountPrice != null &&
                                            cartItem.discountPrice! > 0
                                        ? cartItem.discountPrice!
                                        : cartItem.product.price;
                                    return SaleItemModel(
                                      productId: cartItem.product.id,
                                      quantity: cartItem.quantity,
                                      price: price,
                                      imei: cartItem.imei,
                                    );
                                  }).toList(),
                                  payments: _payments,
                                  installments: _generateInstallments('', widget.cart.total),
                                );
                                final addedSale =
                                    await FirestoreService().addSale(sale, cashierId);
                                // Update saleId for installments
                                final updatedInstallments = _generateInstallments(addedSale.id, widget.cart.total);
                                await FirestoreService().updateSaleInstallments(addedSale.id, updatedInstallments);

                                widget.cart.clear();
                                if (!mounted) return;
                                setState(() { _isLoading = false; });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Installment sale confirmed!')),
                                );
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReceiptScreen(sale: addedSale),
                                  ),
                                  (route) => route.isFirst,
                                );
                              }
                            : null, // Disable button if remaining balance is not 0 and not installment
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Confirm Sale'),
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
    );
  }
}