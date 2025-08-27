import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_phone_sales_management_system/models/product_model.dart'; // Assuming ProductModel is used for promotions
import 'package:mobile_phone_sales_management_system/services/firestore_service.dart'; // Assuming FirestoreService

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
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

  void _addPromotion() {
    final promotionNameController = TextEditingController();
    final discountPercentageController = TextEditingController();
    final promotionTextController = TextEditingController();
    ProductModel? selectedProduct;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Promotion', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: promotionNameController,
                  decoration: InputDecoration(
                    labelText: 'Promotion Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.label),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a promotion name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: discountPercentageController,
                  decoration: InputDecoration(
                    labelText: 'Discount Percentage (%)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.percent),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a discount percentage';
                    }
                    final percentage = double.tryParse(value);
                    if (percentage == null || percentage < 0 || percentage > 100) {
                      return 'Please enter a valid percentage (0-100)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: promotionTextController,
                  decoration: InputDecoration(
                    labelText: 'Promotion Text (e.g., "Limited Time Offer")',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.text_fields),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 15),
                // Product selection for promotion
                StreamBuilder<List<ProductModel>>(
                  stream: _firestoreService.getProducts(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Error loading products.');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    final products = snapshot.data ?? [];
                    return DropdownButtonFormField<ProductModel>(
                      decoration: InputDecoration(
                        labelText: 'Apply to Product (Optional)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      value: selectedProduct,
                      items: products.map((product) {
                        return DropdownMenuItem(
                          value: product,
                          child: Text(product.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        selectedProduct = value;
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                promotionNameController.clear();
                discountPercentageController.clear();
                promotionTextController.clear();
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // In a real app, you'd save this promotion to Firestore
                // For now, we'll just update the selected product's promotionText
                if (selectedProduct != null) {
                  final updatedProduct = selectedProduct!.copyWith(
                    promotionText: promotionTextController.text.isNotEmpty
                        ? promotionTextController.text
                        : null,
                    // You might want to add a discount field to ProductModel
                    // discountPercentage: double.parse(_discountPercentageController.text),
                  );
                  await _firestoreService.updateProduct(updatedProduct);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Promotion applied to ${selectedProduct!.name}')),
                  );
                } else {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Promotion added (not applied to product)')),
                  );
                }
                promotionNameController.clear();
                discountPercentageController.clear();
                promotionTextController.clear();
                if (!mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeletePromotion(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Clear Promotion'),
          content: Text('Are you sure you want to clear the promotion for ${product.name}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Clear', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                final updatedProduct = product.copyWith(promotionText: null);
                await _firestoreService.updateProduct(updatedProduct);
                if (!mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Promotion cleared for ${product.name}')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search promotions...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 18),
                cursorColor: Colors.white,
              )
            : const Text('Promotions'),
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
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addPromotion,
          ),
        ],
      ),
      body: StreamBuilder<List<ProductModel>>(
        stream: _firestoreService.getProducts(), // Fetch all products to show their promotions
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final productsWithPromotions = (snapshot.data ?? [])
              .where((product) => product.promotionText != null && product.promotionText!.isNotEmpty)
              .where((product) {
                final nameLower = product.name.toLowerCase();
                final promoTextLower = product.promotionText!.toLowerCase();
                final searchQueryLower = _searchQuery.toLowerCase();
                return nameLower.contains(searchQueryLower) ||
                       promoTextLower.contains(searchQueryLower);
              })
              .toList();

          if (productsWithPromotions.isEmpty) {
            return Center(
              child: Text(
                _searchQuery.isEmpty
                    ? 'No active promotions found.'
                    : 'No promotions found for "$_searchQuery".',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            itemCount: productsWithPromotions.length,
            itemBuilder: (context, index) {
              final product = productsWithPromotions[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: product.imageBase64 != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.memory(
                            base64Decode(product.imageBase64!),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Icon(Icons.image, size: 40, color: Colors.grey),
                        ),
                  title: Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Original Price: \$${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15)),
                      Text(
                        'Promotion: ${product.promotionText}',
                        style: const TextStyle(fontSize: 15, color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.red),
                    onPressed: () {
                      _confirmDeletePromotion(context, product);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}