import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_phone_sales_management_system/models/customer_model.dart';
import 'package:mobile_phone_sales_management_system/models/installment_model.dart';
import 'package:mobile_phone_sales_management_system/models/payment_model.dart';
import 'package:mobile_phone_sales_management_system/models/product_imei_model.dart';
import 'package:mobile_phone_sales_management_system/models/product_model.dart';
import 'package:mobile_phone_sales_management_system/models/return_item_model.dart';
import 'package:mobile_phone_sales_management_system/models/return_model.dart';
import 'package:mobile_phone_sales_management_system/models/sale_item_model.dart';
import 'package:mobile_phone_sales_management_system/models/sale_model.dart';
import 'package:mobile_phone_sales_management_system/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // User Management
  Stream<List<UserModel>> getUsers() {
    return _db.collection('users').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => UserModel(
          uid: doc.id,
          email: doc['email'],
          role: doc['role'],
        )).toList());
  }

  Future<void> addUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set({
      'email': user.email,
      'role': user.role,
    });
  }

  Future<void> updateUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).update({
      'email': user.email,
      'role': user.role,
    });
  }

  Future<void> deleteUser(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }

  Future<String?> getUserRole(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? doc['role'] : null;
  }

  // Product Management
  Stream<List<ProductModel>> getProducts() {
    return _db.collection('products').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => ProductModel(
          id: doc.id,
          name: doc['name'],
          price: (doc['price'] as num).toDouble(),
          stock: doc['stock'],
          imageBase64: doc['imageBase64'],
          promotionText: doc['promotionText'],
          quantitySold: doc['quantitySold'] ?? 0, // Default to 0 if not exists
        )).toList());
  }

  Future<void> addProduct(ProductModel product) async {
    await _db.collection('products').add({
      'name': product.name,
      'price': product.price,
      'stock': product.stock,
      'imageBase64': product.imageBase64,
      'promotionText': product.promotionText,
      'quantitySold': product.quantitySold ?? 0,
    });
  }

  Future<void> updateProduct(ProductModel product) async {
    await _db.collection('products').doc(product.id).update({
      'name': product.name,
      'price': product.price,
      'stock': product.stock,
      'imageBase64': product.imageBase64,
      'promotionText': product.promotionText,
      'quantitySold': product.quantitySold,
    });
  }

  Future<void> deleteProduct(String id) async {
    await _db.collection('products').doc(id).delete();
  }

  // Customer Management
  Stream<List<CustomerModel>> getCustomers() {
    return _db.collection('customers').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => CustomerModel(
          id: doc.id,
          name: doc['name'],
          phone: doc['phone'],
          address: doc['address'],
          imageBase64: doc['imageBase64'],
        )).toList());
  }

  Future<void> addCustomer(CustomerModel customer) async {
    await _db.collection('customers').add({
      'name': customer.name,
      'phone': customer.phone,
      'address': customer.address,
      'imageBase64': customer.imageBase64,
    });
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    await _db.collection('customers').doc(customer.id).update({
      'name': customer.name,
      'phone': customer.phone,
      'address': customer.address,
      'imageBase64': customer.imageBase64,
    });
  }

  Future<void> deleteCustomer(String id) async {
    await _db.collection('customers').doc(id).delete();
  }

  // Sale Management
  Future<SaleModel> addSale(SaleModel sale, String cashierId) async {
    final saleRef = await _db.collection('sales').add({
      'customerId': sale.customerId,
      'date': sale.date,
      'totalAmount': sale.totalAmount,
      'cashierId': cashierId,
      'items': sale.items.map((item) => {
        'productId': item.productId,
        'quantity': item.quantity,
        'price': item.price,
        'imei': item.imei,
        'productName': item.productName, // Include productName
      }).toList(),
      'payments': sale.payments.map((payment) => {
        'method': payment.method,
        'amount': payment.amount,
      }).toList(),
      'installments': sale.installments.map((installment) {
        // Generate a unique ID for each installment if it's new
        final installmentId = installment.id.isEmpty ? _db.collection('installments').doc().id : installment.id;
        return {
          'id': installmentId,
          'saleId': installment.saleId,
          'dueDate': installment.dueDate,
          'amount': installment.amount,
          'isPaid': installment.isPaid,
          'totalAmount': installment.totalAmount,
          'downPayment': installment.downPayment,
          'numberOfMonths': installment.numberOfMonths,
          'monthlyInstallment': installment.monthlyInstallment,
          'dateCreated': installment.dateCreated,
          'status': installment.status,
        };
      }).toList(),
    });

    // Update product stock and quantitySold
    for (var item in sale.items) {
      final productDoc = await _db.collection('products').doc(item.productId).get();
      if (productDoc.exists) {
        final currentStock = productDoc['stock'] as int;
        final currentQuantitySold = productDoc['quantitySold'] as int? ?? 0;
        await _db.collection('products').doc(item.productId).update({
          'stock': currentStock - item.quantity,
          'quantitySold': currentQuantitySold + item.quantity,
        });
      }
      // Mark IMEI as sold
      if (item.imei != null && item.imei!.isNotEmpty) {
        final imeiQuery = await _db.collection('imeis')
            .where('imei', isEqualTo: item.imei)
            .limit(1)
            .get();
        if (imeiQuery.docs.isNotEmpty) {
          await _db.collection('imeis').doc(imeiQuery.docs.first.id).update({
            'isSold': true,
          });
        }
      }
    }

    return SaleModel(
      id: saleRef.id,
      customerId: sale.customerId,
      date: sale.date,
      totalAmount: sale.totalAmount,
      items: sale.items,
      payments: sale.payments,
      installments: sale.installments,
    );
  }

  Stream<List<SaleModel>> getSales(String? customerId) {
    Query query = _db.collection('sales');
    if (customerId != null && customerId.isNotEmpty) {
      query = query.where('customerId', isEqualTo: customerId);
    }
    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => SaleModel(
          id: doc.id,
          customerId: doc['customerId'],
          date: (doc['date'] as Timestamp).toDate(),
          totalAmount: doc['totalAmount'],
          items: (doc['items'] as List).map((item) => SaleItemModel(
            productId: item['productId'],
            quantity: item['quantity'],
            price: item['price'],
            imei: item['imei'],
            productName: item['productName'],
          )).toList(),
          payments: (doc['payments'] as List).map((payment) => PaymentModel(
            method: payment['method'],
            amount: payment['amount'],
          )).toList(),
          installments: (doc['installments'] as List? ?? []).map((installment) => InstallmentModel(
            id: installment['id'],
            saleId: installment['saleId'],
            dueDate: (installment['dueDate'] as Timestamp).toDate(),
            amount: installment['amount'],
            isPaid: installment['isPaid'],
            totalAmount: installment['totalAmount'],
            downPayment: installment['downPayment'],
            numberOfMonths: installment['numberOfMonths'],
            monthlyInstallment: installment['monthlyInstallment'],
            dateCreated: (installment['dateCreated'] as Timestamp).toDate(),
            status: installment['status'],
          )).toList(),
        )).toList());
  }

  Stream<List<SaleModel>> getSalesByFilter({
    DateTime? startDate,
    DateTime? endDate,
    String? cashierId,
  }) {
    Query query = _db.collection('sales');

    if (startDate != null) {
      query = query.where('date', isGreaterThanOrEqualTo: startDate);
    }
    if (endDate != null) {
      query = query.where('date', isLessThanOrEqualTo: endDate);
    }
    if (cashierId != null && cashierId.isNotEmpty) {
      query = query.where('cashierId', isEqualTo: cashierId);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => SaleModel(
          id: doc.id,
          customerId: doc['customerId'],
          date: (doc['date'] as Timestamp).toDate(),
          totalAmount: doc['totalAmount'],
          items: (doc['items'] as List).map((item) => SaleItemModel(
            productId: item['productId'],
            quantity: item['quantity'],
            price: item['price'],
            imei: item['imei'],
            productName: item['productName'],
          )).toList(),
          payments: (doc['payments'] as List).map((payment) => PaymentModel(
            method: payment['method'],
            amount: payment['amount'],
          )).toList(),
          installments: (doc['installments'] as List? ?? []).map((installment) => InstallmentModel(
            id: installment['id'],
            saleId: installment['saleId'],
            dueDate: (installment['dueDate'] as Timestamp).toDate(),
            amount: installment['amount'],
            isPaid: installment['isPaid'],
            totalAmount: installment['totalAmount'],
            downPayment: installment['downPayment'],
            numberOfMonths: installment['numberOfMonths'],
            monthlyInstallment: installment['monthlyInstallment'],
            dateCreated: (installment['dateCreated'] as Timestamp).toDate(),
            status: installment['status'],
          )).toList(),
        )).toList());
  }

  Future<SaleModel?> getSaleById(String saleId) async {
    final doc = await _db.collection('sales').doc(saleId).get();
    if (doc.exists) {
      return SaleModel(
        id: doc.id,
        customerId: doc['customerId'],
        date: (doc['date'] as Timestamp).toDate(),
        totalAmount: doc['totalAmount'],
        items: (doc['items'] as List).map((item) => SaleItemModel(
          productId: item['productId'],
          quantity: item['quantity'],
          price: item['price'],
          imei: item['imei'],
          productName: item['productName'],
        )).toList(),
        payments: (doc['payments'] as List).map((payment) => PaymentModel(
          method: payment['method'],
          amount: payment['amount'],
        )).toList(),
        installments: (doc['installments'] as List? ?? []).map((installment) => InstallmentModel(
          id: installment['id'],
          saleId: installment['saleId'],
          dueDate: (installment['dueDate'] as Timestamp).toDate(),
          amount: installment['amount'],
          isPaid: installment['isPaid'],
          totalAmount: installment['totalAmount'],
          downPayment: installment['downPayment'],
          numberOfMonths: installment['numberOfMonths'],
          monthlyInstallment: installment['monthlyInstallment'],
          dateCreated: (installment['dateCreated'] as Timestamp).toDate(),
          status: installment['status'],
        )).toList(),
      );
    }
    return null;
  }

  // Return Management
  // Return Management
  Stream<List<ReturnModel>> getReturns() {
    return _db.collection('returns').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => ReturnModel(
          id: doc.id,
          saleId: doc['saleId'],
          date: (doc['date'] as Timestamp).toDate(),
          returnedItems: (doc['returnedItems'] as List).map((item) => ReturnItemModel(
            productId: item['productId'],
            quantity: item['quantity'],
            price: item['price'],
            imei: item['imei'],
          )).toList(),
          refundAmount: doc['refundAmount'],
          status: doc['status'],
        )).toList());
  }

  Future<void> addReturn(ReturnModel returnModel) async {
    await _db.collection('returns').add({
      'saleId': returnModel.saleId,
      'date': returnModel.date,
      'returnedItems': returnModel.returnedItems.map((item) => {
        'productId': item.productId,
        'quantity': item.quantity,
        'price': item.price,
        'imei': item.imei,
      }).toList(),
      'refundAmount': returnModel.refundAmount,
      'status': returnModel.status,
    });
  }

  Future<void> updateReturn(ReturnModel returnModel) async {
    await _db.collection('returns').doc(returnModel.id).update({
      'saleId': returnModel.saleId,
      'date': returnModel.date,
      'returnedItems': returnModel.returnedItems.map((item) => {
        'productId': item.productId,
        'quantity': item.quantity,
        'price': item.price,
        'imei': item.imei,
      }).toList(),
      'refundAmount': returnModel.refundAmount,
      'status': returnModel.status,
    });
  }

  // IMEI Management
  Stream<List<ProductImeiModel>> getImeisForProduct(String productId) {
    return _db.collection('imeis')
        .where('productId', isEqualTo: productId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ProductImeiModel(
          id: doc.id,
          productId: doc['productId'],
          imei: doc['imei'],
          isSold: doc['isSold'],
        )).toList());
  }

  Future<void> addImei(ProductImeiModel imei) async {
    await _db.collection('imeis').add({
      'productId': imei.productId,
      'imei': imei.imei,
      'isSold': imei.isSold,
    });
  }

  Future<void> deleteImei(String id) async {
    await _db.collection('imeis').doc(id).delete();
  }

  // New methods to implement based on errors
  Stream<double> getTotalSales() {
    return _db.collection('sales').snapshots().map((snapshot) {
      double total = 0.0;
      for (var doc in snapshot.docs) {
        total += doc['totalAmount'] as double;
      }
      return total;
    });
  }

  Stream<double> getDailySales(String cashierId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return _db.collection('sales')
        .where('cashierId', isEqualTo: cashierId)
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .snapshots()
        .map((snapshot) {
      double total = 0.0;
      for (var doc in snapshot.docs) {
        total += doc['totalAmount'] as double;
      }
      return total;
    });
  }

  Future<CustomerModel?> getCustomerById(String customerId) async {
    final doc = await _db.collection('customers').doc(customerId).get();
    if (doc.exists) {
      return CustomerModel(
        id: doc.id,
        name: doc['name'],
        phone: doc['phone'],
        address: doc['address'],
        imageBase64: doc['imageBase64'],
      );
    }
    return null;
  }

  Future<ProductModel?> getProductById(String productId) async {
    final doc = await _db.collection('products').doc(productId).get();
    if (doc.exists) {
      return ProductModel(
        id: doc.id,
        name: doc['name'],
        price: doc['price'],
        stock: doc['stock'],
        imageBase64: doc['imageBase64'],
        promotionText: doc['promotionText'],
        quantitySold: doc['quantitySold'] ?? 0,
      );
    }
    return null;
  }

  Future<ProductImeiModel?> getImeiByNumber(String imeiNumber) async {
    final query = await _db.collection('imeis')
        .where('imei', isEqualTo: imeiNumber)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      return ProductImeiModel(
        id: doc.id,
        productId: doc['productId'],
        imei: doc['imei'],
        isSold: doc['isSold'],
      );
    }
    return null;
  }

  Stream<List<ProductImeiModel>> getAllImeis() {
    return _db.collection('imeis').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => ProductImeiModel(
          id: doc.id,
          productId: doc['productId'],
          imei: doc['imei'],
          isSold: doc['isSold'],
        )).toList());
  }

  Future<void> updateSaleInstallments(String saleId, List<InstallmentModel> installments) async {
    await _db.collection('sales').doc(saleId).update({
      'installments': installments.map((installment) => {
        'id': installment.id,
        'saleId': installment.saleId,
        'dueDate': installment.dueDate,
        'amount': installment.amount,
        'isPaid': installment.isPaid,
        'totalAmount': installment.totalAmount,
        'downPayment': installment.downPayment,
        'numberOfMonths': installment.numberOfMonths,
        'monthlyInstallment': installment.monthlyInstallment,
        'dateCreated': installment.dateCreated,
        'status': installment.status,
      }).toList(),
    });
  }

  Future<void> addInstallment(InstallmentModel installment) async {
    await _db.collection('installments').add({
      'saleId': installment.saleId,
      'dueDate': installment.dueDate,
      'amount': installment.amount,
      'isPaid': installment.isPaid,
      'totalAmount': installment.totalAmount,
      'downPayment': installment.downPayment,
      'numberOfMonths': installment.numberOfMonths,
      'monthlyInstallment': installment.monthlyInstallment,
      'dateCreated': installment.dateCreated,
      'status': installment.status,
    });
  }

  Future<void> updateInstallment(InstallmentModel installment) async {
    await _db.collection('installments').doc(installment.id).update({
      'saleId': installment.saleId,
      'dueDate': installment.dueDate,
      'amount': installment.amount,
      'isPaid': installment.isPaid,
      'totalAmount': installment.totalAmount,
      'downPayment': installment.downPayment,
      'numberOfMonths': installment.numberOfMonths,
      'monthlyInstallment': installment.monthlyInstallment,
      'dateCreated': installment.dateCreated,
      'status': installment.status,
    });
  }

  Future<void> updateImei(ProductImeiModel imei) async {
    await _db.collection('imeis').doc(imei.id).update({
      'productId': imei.productId,
      'imei': imei.imei,
      'isSold': imei.isSold,
    });
  }

  Stream<List<ProductModel>> getTopSellingProducts(int limit) {
    // This method needs to be implemented to get top selling products based on quantitySold
    // For now, returning a dummy list
    return _db.collection('products')
        .orderBy('quantitySold', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ProductModel(
          id: doc.id,
          name: doc['name'],
          price: (doc['price'] as num).toDouble(),
          stock: doc['stock'],
          imageBase64: doc['imageBase64'],
          promotionText: doc['promotionText'],
          quantitySold: doc['quantitySold'] ?? 0,
        )).toList());
  }

  Stream<double> getTotalSalesForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _db.collection('sales')
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .snapshots()
        .map((snapshot) {
      double total = 0.0;
      for (var doc in snapshot.docs) {
        total += doc['totalAmount'] as double;
      }
      return total;
    });
  }

  Stream<Map<String, double>> getCashierPerformance() {
    return _db.collection('sales').snapshots().map((snapshot) {
      final Map<String, double> performance = {};
      for (var doc in snapshot.docs) {
        final cashierId = doc['cashierId'] as String;
        final totalAmount = doc['totalAmount'] as double;
        performance.update(
          cashierId,
          (value) => value + totalAmount,
          ifAbsent: () => totalAmount,
        );
      }
      return performance;
    });
  }
}