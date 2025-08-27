import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_phone_sales_management_system/models/product_imei_model.dart';
import 'package:mobile_phone_sales_management_system/models/product_model.dart';
import 'package:mobile_phone_sales_management_system/providers/cart_provider.dart';
import 'package:mobile_phone_sales_management_system/screens/pos/cart_invoice_screen.dart';
import 'package:mobile_phone_sales_management_system/screens/pos/customer_selection_screen.dart';
import 'package:mobile_phone_sales_management_system/services/firestore_service.dart';
import 'package:provider/provider.dart';

class POSMainScreen extends StatefulWidget {
  const POSMainScreen({super.key});

  @override
  State<POSMainScreen> createState() => _POSMainScreenState();
}

class _POSMainScreenState extends State<POSMainScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onProductTapped(ProductModel product, CartProvider cart) async {
    final imeis = await _firestoreService.getImeisForProduct(product.id).first;
    final availableImeis = imeis.where((imei) => !imei.isSold).toList();

    if (!mounted) return;

    if (availableImeis.isNotEmpty) {
      final selectedImei = await showDialog<ProductImeiModel>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Select IMEI for ${product.name}'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: availableImeis.length,
                itemBuilder: (context, index) {
                  final imei = availableImeis[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    elevation: 2,
                    child: ListTile(
                      title: Text(imei.imei),
                      onTap: () {
                        Navigator.of(context).pop(imei);
                      },
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );

      if (selectedImei != null) {
        cart.addItem(product, imei: selectedImei.imei);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product.name} (IMEI: ${selectedImei.imei}) added to cart!')),
        );
      }
    } else {
      cart.addItem(product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} added to cart!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search products...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 18),
                cursorColor: Colors.white,
              )
            : const Text('Point of Sale'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartInvoiceScreen(),
                    ),
                  );
                },
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cart.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ProductModel>>(
              stream: _firestoreService.getProducts(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final products = snapshot.data ?? [];
                final filteredProducts = products.where((product) {
                  final nameLower = product.name.toLowerCase();
                  final searchQueryLower = _searchQuery.toLowerCase();
                  return nameLower.contains(searchQueryLower);
                }).toList();

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'No products found.'
                          : 'No products found for "$_searchQuery".',
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8, // Adjusted for better content fit
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      clipBehavior: Clip.antiAlias, // Ensures image respects border radius
                      child: InkWell(
                        onTap: () => _onProductTapped(product, cart),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: product.imageBase64 != null
                                  ? Image.memory(
                                      base64Decode(product.imageBase64!),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    )
                                  : Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Icon(Icons.image, size: 60, color: Colors.grey),
                                      ),
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${product.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  if (product.promotionText != null && product.promotionText!.isNotEmpty)
                                    Text(
                                      product.promotionText!,
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                                child: IconButton(
                                  icon: const Icon(Icons.add_shopping_cart, color: Colors.blue),
                                  onPressed: () => _onProductTapped(product, cart),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
                    Text(
                      'Items: ${cart.itemCount}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Total: \$${cart.total.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
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
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Checkout'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
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