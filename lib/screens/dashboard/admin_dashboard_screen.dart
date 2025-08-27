import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:mobile_phone_sales_management_system/models/product_model.dart';
import 'package:mobile_phone_sales_management_system/services/auth_service.dart';

import 'package:mobile_phone_sales_management_system/screens/analytics/analytics_screen.dart';
import 'package:mobile_phone_sales_management_system/screens/orders/orders_screen.dart';
import 'package:mobile_phone_sales_management_system/screens/settings/settings_menu_screen.dart';
import 'package:mobile_phone_sales_management_system/screens/dashboard/dashboard_content.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardContent(),
    OrdersScreen(),
    AnalyticsScreen(),
    SettingsMenuScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Colors.grey[50],
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar? _buildAppBar() {
    switch (_currentIndex) {
      case 0: // Dashboard
        return null; // DashboardContent has its own SliverAppBar
      case 1: // Orders
        return AppBar(title: const Text('Orders'));
      case 2: // Analytics
        return AppBar(title: const Text('Analytics'));
      case 3: // Settings
        return AppBar(title: const Text('Settings'));
      default:
        return null;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey[600],
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Iconsax.home),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Iconsax.shopping_cart),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Iconsax.chart_2),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Iconsax.setting_2),
          label: 'Settings',
        ),
      ],
    );
  }
}