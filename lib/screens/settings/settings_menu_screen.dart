import 'package:flutter/material.dart';
// ...existing code... (settings subpage imports removed — navigation uses named routes)
import 'package:mobile_phone_sales_management_system/services/auth_service.dart';
import 'package:mobile_phone_sales_management_system/services/firestore_service.dart';

class SettingsMenuScreen extends StatelessWidget {
  const SettingsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final firestore = FirestoreService();

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
      _SettingsItem(
        title: 'Backup & Restore',
        subtitle: 'Backup database or restore from backup',
        icon: Icons.backup,
        onTap: () => Navigator.pushNamed(context, '/settings/backup'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: FutureBuilder<String?>(
        future: auth.currentUser == null
            ? Future.value(null)
            : firestore.getUserRole(auth.currentUser!.uid),
        builder: (context, snapshot) {
          final role = snapshot.data; // could be null while loading
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length + (role == 'Admin' ? 1 : 0),
            itemBuilder: (context, index) {
              if (role == 'Admin' && index == 0) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(context, '/settings/users'),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                            child: const Icon(Icons.people, color: Colors.blue),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Manage Users',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Create or edit admin/cashier accounts',
                                  style: TextStyle(fontSize: 14, color: Colors.grey),
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
              }
              final it = items[role == 'Admin' ? index - 1 : index];
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
        },
      ),
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