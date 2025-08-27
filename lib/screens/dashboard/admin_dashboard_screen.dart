import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:mobile_phone_sales_management_system/models/product_model.dart';
import 'package:mobile_phone_sales_management_system/services/auth_service.dart';
import 'package:mobile_phone_sales_management_system/services/firestore_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 4.0,
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColorDark,
                    ],
                  ),
                ),
                child: const Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 20, bottom: 16),
                    child: Text(
                      'Welcome, Admin!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  AuthService().signOut();
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(),
                  const SizedBox(height: 16),
                  _buildDashboardGrid(context),
                  const SizedBox(height: 16),
                  _buildTopSellingProductsCard(),
                  const SizedBox(height: 16),
                  _buildCashierPerformanceCard(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Total Sales',
            value: '\$12,458',
            icon: Icons.attach_money_rounded,
            color: Colors.green,
            stream: _firestoreService.getTotalSales(),
            formatter: (value) => '\$${value?.toStringAsFixed(2) ?? '0.00'}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Total Products',
            value: '48',
            icon: Icons.shopping_bag_rounded,
            color: Colors.orange,
            stream: _firestoreService.getProducts(),
            formatter: (value) => '${value?.length ?? 0}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Today\'s Orders',
            value: '24',
            icon: Icons.shopping_cart_rounded,
            color: Colors.purple,
            stream: Stream.value(24), // Replace with actual stream
            formatter: (value) => '$value',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Stream<dynamic> stream,
    required String Function(dynamic) formatter,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          StreamBuilder(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(
                  'Error',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }
              return Text(
                formatter(snapshot.data),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12.0,
      mainAxisSpacing: 12.0,
      children: [
        _buildDashboardButton(context, 'Users', Iconsax.profile_2user, () {
          Navigator.pushNamed(context, '/settings/users');
        }),
        _buildDashboardButton(context, 'Products', Iconsax.shop, () {
          Navigator.pushNamed(context, '/products');
        }),
        _buildDashboardButton(context, 'Customers', Iconsax.profile_circle, () {
          Navigator.pushNamed(context, '/customers');
        }),
        _buildDashboardButton(context, 'POS', Iconsax.card_pos, () {
          Navigator.pushNamed(context, '/pos');
        }),
        _buildDashboardButton(context, 'Returns', Iconsax.arrow_swap, () {
          Navigator.pushNamed(context, '/returns');
        }),
        _buildDashboardButton(context, 'Reports', Iconsax.chart_2, () {
          Navigator.pushNamed(context, '/reports');
        }),
      ],
    );
  }

  Widget _buildDashboardButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSellingProductsCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Iconsax.chart_1, size: 24, color: Colors.amber[700]),
                const SizedBox(width: 10),
                const Text(
                  'Top Selling Products',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 15),
            StreamBuilder<List<ProductModel>>(
              stream: _firestoreService.getTopSellingProducts(5),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error loading top products.');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final products = snapshot.data ?? [];
                if (products.isEmpty) {
                  return const Text('No top selling products yet.');
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 16),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ' ${product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Sold: ${product.quantitySold ?? 0}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashierPerformanceCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Iconsax.graph, size: 24, color: Colors.blue[700]),
                const SizedBox(width: 10),
                const Text(
                  'Cashier Performance',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Iconsax.filter, size: 20, color: Colors.grey[600]),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 15),
            StreamBuilder<Map<String, double>>(
              stream: _firestoreService.getCashierPerformance(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final performance = snapshot.data ?? {};
                if (performance.isEmpty) {
                  return const Text('No cashier performance data yet.');
                }
                return SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY:
                          (performance.values.reduce((a, b) => a > b ? a : b) *
                                  1.2)
                              .ceilToDouble(),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => Colors.blueGrey,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final cashier = 
                                performance.keys.elementAt(group.x.toInt());
                            return BarTooltipItem(
                              '$cashier\n',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text:
                                      'Sales: \$${rod.toY.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.yellow,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              if (value.toInt() >= performance.keys.length) {
                                return const Text('');
                              }
                              final cashier = 
                                  performance.keys.elementAt(value.toInt());
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  cashier
                                      .split(' ')
                                      .map((e) => e.isNotEmpty ? e[0] : '')
                                      .join(),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              return Text(
                                '\$${value.toInt()}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 10,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey[200],
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      barGroups: performance.entries
                          .map(
                            (entry) => BarChartGroupData(
                              x: performance.keys.toList().indexOf(entry.key),
                              barRods: [
                                BarChartRodData(
                                  toY: entry.value,
                                  width: 16,
                                  borderRadius: BorderRadius.circular(4),
                                  color: Theme.of(context).primaryColor,
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
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
