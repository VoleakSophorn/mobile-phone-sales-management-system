import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mobile_phone_sales_management_system/firebase_options.dart';
import 'package:mobile_phone_sales_management_system/providers/cart_provider.dart';
import 'package:mobile_phone_sales_management_system/screens/analytics/analytics_screen.dart';
import 'package:mobile_phone_sales_management_system/screens/auth/auth_gate.dart';
import 'package:mobile_phone_sales_management_system/screens/dashboard/admin_dashboard_screen.dart';
import 'package:mobile_phone_sales_management_system/screens/orders/orders_screen.dart';
import 'package:mobile_phone_sales_management_system/screens/settings/settings_menu_screen.dart';
import 'package:mobile_phone_sales_management_system/screens/reports/reports_menu_screen.dart';
import 'package:mobile_phone_sales_management_system/screens/returns/returns_list_screen.dart';
import 'package:mobile_phone_sales_management_system/screens/reports/sales_reports_screen.dart';
import 'package:mobile_phone_sales_management_system/screens/reports/daily_sales_screen.dart';
import 'package:mobile_phone_sales_management_system/screens/reports/cashier_performance_screen.dart';
import 'package:mobile_phone_sales_management_system/screens/reports/top_products_screen.dart';
import 'package:mobile_phone_sales_management_system/screens/users/user_list_screen.dart';
import 'package:mobile_phone_sales_management_system/screens/returns/return_detail_screen.dart';
import 'package:mobile_phone_sales_management_system/models/return_model.dart';
import 'package:mobile_phone_sales_management_system/screens/settings/security_settings_screen.dart';
import 'package:mobile_phone_sales_management_system/screens/settings/currency_settings_screen.dart';
import 'package:mobile_phone_sales_management_system/screens/settings/tax_discount_config_screen.dart';
import 'package:mobile_phone_sales_management_system/screens/settings/invoice_template_screen.dart';

import 'package:mobile_phone_sales_management_system/screens/products/product_list_screen.dart';
import 'package:mobile_phone_sales_management_system/screens/customers/customer_list_screen.dart';
import 'package:mobile_phone_sales_management_system/screens/pos/pos_main_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase. On Android/iOS, native configs (google-services.json / GoogleService-Info.plist) are used.
  // For Web/Windows/Linux, run `flutterfire configure` to generate firebase_options.dart and use options.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Global Flutter errors
  FlutterError.onError = (FlutterErrorDetails details) {
    // Print full Flutter error and stack to console
    FlutterError.dumpErrorToConsole(details);
  };

  // Capture any uncaught errors and print stack traces (development helper)
  runZonedGuarded(() {
    runApp(const MyApp());
  }, (error, stack) {
    // Print to console so you can paste the full stack trace here
    // ignore: avoid_print
    print('Uncaught error: $error');
    // ignore: avoid_print
    print(stack);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MaterialApp(
        title: 'Mobile Phone Sales Management System',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const AuthGate(),
        routes: {
          '/dashboard': (context) => const AdminDashboardScreen(),
          '/settings': (context) => const SettingsMenuScreen(),
          '/settings/users': (context) => const UserListScreen(),
          '/settings/security': (context) => const SecuritySettingsScreen(),
          '/settings/currency': (context) => const CurrencySettingsScreen(),
          '/settings/tax': (context) => const TaxDiscountConfigScreen(),
          '/settings/invoice': (context) => const InvoiceTemplateScreen(),
          '/orders': (context) => const OrdersScreen(),
          '/analytics': (context) => const AnalyticsScreen(),
          '/reports': (context) => const ReportsMenuScreen(),
          '/reports/sales': (context) => const SalesReportsScreen(),
          '/reports/daily': (context) => const DailySalesScreen(),
          '/reports/cashier': (context) => const CashierPerformanceScreen(),
          '/reports/top': (context) => const TopProductsScreen(),
          '/returns': (context) => const ReturnsListScreen(),
          '/products': (context) => const ProductListScreen(),
          '/customers': (context) => const CustomerListScreen(),
          '/pos': (context) => const POSMainScreen(),
        },
        onGenerateRoute: (settings) {
          // Handle routes that require arguments
          if (settings.name == '/returns/detail') {
            final args = settings.arguments;
            if (args is ReturnModel) {
              return MaterialPageRoute(
                  builder: (ctx) => ReturnDetailScreen(returnModel: args));
            }
            return MaterialPageRoute(
                builder: (ctx) => const Scaffold(
                    body: Center(child: Text('Return not found'))));
          }
          return null;
        },
      ),
    );
  }
}
