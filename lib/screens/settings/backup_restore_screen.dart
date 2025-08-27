import 'package:flutter/material.dart';
import 'package:mobile_phone_sales_management_system/services/firestore_service.dart'; // Assuming FirestoreService

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isBackingUp = false;
  bool _isRestoring = false;

  Future<void> _performBackup() async {
    setState(() {
      _isBackingUp = true;
    });
    try {
      // Simulate a backup operation
      await Future.delayed(const Duration(seconds: 2));
      // In a real app: await _firestoreService.backupData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup successful!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup failed: $e')),
      );
    } finally {
      setState(() {
        _isBackingUp = false;
      });
    }
  }

  Future<void> _performRestore() async {
    setState(() {
      _isRestoring = true;
    });
    try {
      // Simulate a restore operation
      await Future.delayed(const Duration(seconds: 2));
      // In a real app: await _firestoreService.restoreData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restore successful!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restore failed: $e')),
      );
    } finally {
      setState(() {
        _isRestoring = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Database Operations',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _isBackingUp ? null : _performBackup,
                      icon: _isBackingUp
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.cloud_upload),
                      label: Text(_isBackingUp ? 'Backing Up...' : 'Backup Data'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: _isRestoring ? null : _performRestore,
                      icon: _isRestoring
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.cloud_download),
                      label: Text(_isRestoring ? 'Restoring...' : 'Restore Data'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        textStyle: const TextStyle(fontSize: 18),
                        backgroundColor: Colors.orange, // Different color for restore
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Backup History',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    // Placeholder for backup history list
                    const Text(
                      'No backup history available yet.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    // In a real app, you would fetch and display a list of past backups here
                    // ListView.builder(
                    //   shrinkWrap: true,
                    //   itemCount: backupHistory.length,
                    //   itemBuilder: (context, index) {
                    //     final backup = backupHistory[index];
                    //     return ListTile(
                    //       title: Text('Backup on ${DateFormat.yMd().add_jm().format(backup.date)}'),
                    //       trailing: IconButton(
                    //         icon: Icon(Icons.restore),
                    //         onPressed: () => _restoreSpecificBackup(backup),
                    //       ),
                    //     );
                    //   },
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}