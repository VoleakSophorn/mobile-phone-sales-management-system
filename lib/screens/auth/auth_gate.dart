import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_phone_sales_management_system/screens/auth/login_screen.dart';
import 'package:mobile_phone_sales_management_system/screens/dashboard/admin_dashboard_screen.dart';
import 'package:mobile_phone_sales_management_system/screens/dashboard/cashier_dashboard_screen.dart';
import 'package:mobile_phone_sales_management_system/services/firestore_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {

          return FutureBuilder<String?>(
            future: FirestoreService().getUserRole(snapshot.data!.uid),
            builder: (context, roleSnapshot) {

              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (roleSnapshot.hasData) {
                if (roleSnapshot.data == 'Admin') {
                  return const AdminDashboardScreen();
                } else {
                  return const CashierDashboardScreen();
                }
              }
              // If user is authenticated but no role, sign out and show login
              FirebaseAuth.instance.signOut();
              return const LoginScreen();
            },
          );
        }

        return const LoginScreen();
      },
    );
  }
}
