import 'package:flutter/material.dart';
import 'package:mobile_phone_sales_management_system/providers/cart_provider.dart';
import 'package:mobile_phone_sales_management_system/screens/pos/customer_selection_screen.dart';
import 'package:provider/provider.dart';

class CartInvoiceScreen extends StatelessWidget {
  const CartInvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart & Invoice'),
      ),
      body: Column(
        children: [
          Expanded(
            child: cart.items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 20),
                        const Text(
                          'Your cart is empty. Add some products!',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      final originalPrice = item.product.price;
                      final displayPrice = item.discountPrice != null && item.discountPrice! > 0
                          ? item.discountPrice!
                          : originalPrice;
                      final itemSubtotal = displayPrice * item.quantity;

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10),
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                            child: const Icon(Icons.phone_android, color: Colors.blue), // Placeholder icon
                          ),
                          title: Text(
                            item.product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item.imei != null)
                                Text('IMEI: ${item.imei}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                              Row(
                                children: [
                                  Text(
                                    'Price: \$${originalPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      decoration: item.discountPrice != null && item.discountPrice! > 0
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                      color: item.discountPrice != null && item.discountPrice! > 0
                                          ? Colors.grey
                                          : Colors.black,
                                    ),
                                  ),
                                  if (item.discountPrice != null && item.discountPrice! > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        'Discounted: \$${item.discountPrice!.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                ],
                              ),
                              Text('Quantity: ${item.quantity}', style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '\$${itemSubtotal.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                    onPressed: () {
                                      cart.decreaseItemQuantity(item.product.id);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                    onPressed: () {
                                      cart.increaseItemQuantity(item.product.id);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                                    onPressed: () {
                                      cart.removeItem(item.product.id);
                                    },
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () async {
                                  final controller = TextEditingController(
                                      text: item.discountPrice?.toStringAsFixed(2) ?? '');
                                  final result = await showDialog<double?>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text('Set Discount Price for ${item.product.name}'),
                                      content: TextField(
                                        controller: controller,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                            labelText: 'Discount Price',
                                            border: OutlineInputBorder()),
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () => Navigator.pop(ctx, null),
                                            child: const Text('Cancel')),
                                        TextButton(
                                          onPressed: () {
                                            final txt = controller.text.trim();
                                            if (txt.isEmpty) {
                                              Navigator.pop(ctx, -1); // sentinel for clear
                                              return;
                                            }
                                            final v = double.tryParse(txt);
                                            Navigator.pop(ctx, v);
                                          },
                                          child: const Text('Set'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (result == null) return; // canceled
                                  if (result == -1) {
                                    cart.setItemDiscount(item.product.id, null);
                                  } else {
                                    cart.setItemDiscount(item.product.id, result);
                                  }
                                },
                                child: const Text('Apply Discount', style: TextStyle(color: Colors.blue)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3), // changes position of shadow
                ),
              ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cart Total:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '\$${cart.total.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: cart.itemCount > 0
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CustomerSelectionScreen(),
                            ),
                          );
                        }
                      : null, // Disable button if cart is empty
                  icon: const Icon(Icons.payment),
                  label: const Text('Proceed to Checkout'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}