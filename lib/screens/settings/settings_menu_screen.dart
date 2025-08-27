import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:mobile_phone_sales_management_system/services/auth_service.dart';
import 'package:mobile_phone_sales_management_system/services/firestore_service.dart';

class SettingsMenuScreen extends StatefulWidget {
  const SettingsMenuScreen({super.key});

  @override
  State<SettingsMenuScreen> createState() => _SettingsMenuScreenState();
}

class _SettingsMenuScreenState extends State<SettingsMenuScreen> {
  @override
  Widget build(BuildContext context) {
    final items = <_SettingsItem>[
      _SettingsItem(
        title: 'Security',
        subtitle: 'Password & authentication settings',
        icon: Icons.lock,
        onTap: () => Navigator.pushNamed(context, '/settings/security'),
      ),
      _SettingsItem(
        title: 'Currency',
        subtitle: 'Configure currency symbol and format',
        icon: Icons.monetization_on,
        onTap: () => Navigator.pushNamed(context, '/settings/currency'),
      ),
      _SettingsItem(
        title: 'Tax & Discount',
        subtitle: 'Tax rates and default discounts',
        icon: Icons.percent,
        onTap: () => Navigator.pushNamed(context, '/settings/tax'),
      ),
      _SettingsItem(
        title: 'Invoice Template',
        subtitle: 'Edit invoice layout and footer',
        icon: Icons.description,
        onTap: () => Navigator.pushNamed(context, '/settings/invoice'),
      ),
    ];

    return ListView.builder(
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
                    child: Icon(it.icon, color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          it.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (it.subtitle != null)
                          Text(
                            it.subtitle!,
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SettingsItem {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;

  _SettingsItem({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.onTap,
  });
}