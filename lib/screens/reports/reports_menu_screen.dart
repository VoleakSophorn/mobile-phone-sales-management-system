import 'package:flutter/material.dart';
// ...existing code... (report screen imports removed — navigation uses named routes)

class ReportsMenuScreen extends StatelessWidget {
  const ReportsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_ReportItem>[
      _ReportItem(
          title: 'Sales Reports',
          icon: Icons.analytics,
          onTap: () => Navigator.pushNamed(context, '/reports/sales')),
      _ReportItem(
          title: 'Daily Sales',
          icon: Icons.today,
          onTap: () => Navigator.pushNamed(context, '/reports/daily')),
      _ReportItem(
          title: 'Cashier Performance',
          icon: Icons.show_chart,
          onTap: () => Navigator.pushNamed(context, '/reports/cashier')),
      _ReportItem(
          title: 'Top Products',
          icon: Icons.trending_up,
          onTap: () => Navigator.pushNamed(context, '/reports/top')),
      _ReportItem(
          title: 'Payment Summary',
          icon: Icons.payment,
          onTap: () => Navigator.pushNamed(context, '/reports/payment_summary')),
      _ReportItem(
          title: 'Profit & Loss',
          icon: Icons.money_off,
          onTap: () => Navigator.pushNamed(context, '/reports/profit_loss')),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final it = items[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: it.onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Icon(it.icon, color: Theme.of(context).primaryColor, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        it.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ReportItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  _ReportItem({required this.title, required this.icon, required this.onTap});
}