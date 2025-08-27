import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_phone_sales_management_system/models/product_model.dart'; // Import ProductModel
import 'package:mobile_phone_sales_management_system/models/return_model.dart';
import 'package:mobile_phone_sales_management_system/screens/returns/refund_confirmation_screen.dart';
import 'package:mobile_phone_sales_management_system/services/firestore_service.dart';

class AdminApprovalScreen extends StatefulWidget {
  final ReturnModel returnModel;

  const AdminApprovalScreen({super.key, required this.returnModel});

  @override
  State<AdminApprovalScreen> createState() => _AdminApprovalScreenState();
}

class _AdminApprovalScreenState extends State<AdminApprovalScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'refunded':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Approval'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Return ID: ${widget.returnModel.id}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(widget.returnModel.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            widget.returnModel.status,
                            style: TextStyle(
                              color: _getStatusColor(widget.returnModel.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Sale ID: ${widget.returnModel.saleId}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('Date: ${DateFormat.yMMMd().add_jm().format(widget.returnModel.date)}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        'Refund Amount: \$${widget.returnModel.refundAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
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
                      'Returned Items:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    widget.returnModel.returnedItems.isEmpty
                        ? const Text('No items returned.', style: TextStyle(color: Colors.grey))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: widget.returnModel.returnedItems.length,
                            itemBuilder: (context, index) {
                              final item = widget.returnModel.returnedItems[index];
                              return FutureBuilder<ProductModel?>(
                                future: _firestoreService.getProductById(item.productId), // Assuming getProductById exists
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
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                        child: const Icon(Icons.phone_android, color: Colors.blue),
                                      ),
                                      title: Text(
                                        productName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      subtitle: Text(
                                        'Quantity: ${item.quantity} | Price: \$${item.price.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      trailing: Text(
                                        'Subtotal: \$${(item.quantity * item.price).toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: widget.returnModel.status != 'Pending'
                              ? null
                              : () async {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  final updatedReturn = ReturnModel(
                                    id: widget.returnModel.id,
                                    saleId: widget.returnModel.saleId,
                                    date: widget.returnModel.date,
                                    returnedItems: widget.returnModel.returnedItems,
                                    refundAmount: widget.returnModel.refundAmount,
                                    status: 'Approved',
                                  );
                                  await _firestoreService.updateReturn(updatedReturn);
                                  if (!mounted) return;
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RefundConfirmationScreen(returnModel: updatedReturn),
                                    ),
                                  );
                                },
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: widget.returnModel.status != 'Pending'
                              ? null
                              : () async {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  final updatedReturn = ReturnModel(
                                    id: widget.returnModel.id,
                                    saleId: widget.returnModel.saleId,
                                    date: widget.returnModel.date,
                                    returnedItems: widget.returnModel.returnedItems,
                                    refundAmount: widget.returnModel.refundAmount,
                                    status: 'Rejected',
                                  );
                                  await _firestoreService.updateReturn(updatedReturn);
                                  if (!mounted) return;
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Return request rejected.')),
                                  );
                                  Navigator.pop(context);
                                },
                          icon: const Icon(Icons.cancel),
                          label: const Text('Reject'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}