import 'package:flutter/material.dart';
import 'package:mobile_phone_sales_management_system/services/auth_service.dart';
import 'package:mobile_phone_sales_management_system/services/firestore_service.dart';
import 'package:mobile_phone_sales_management_system/screens/dashboard/admin_dashboard_screen.dart';
import 'package:mobile_phone_sales_management_system/screens/dashboard/cashier_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final userCredential =
                        await _authService.signInWithEmailAndPassword(
                      _emailController.text.trim(),
                      _passwordController.text.trim(),
                    );
                    if (userCredential == null || userCredential.user == null) {
                      if (!mounted) return;
                      setState(() {
                        _errorMessage = 'Invalid email or password';
                      });
                      return;
                    }

                    // Get role from Firestore and navigate to the correct dashboard
                    final uid = userCredential.user!.uid;
                    final role = await FirestoreService().getUserRole(uid);
                    if (!mounted) return;
                    if (role == 'Admin') {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const AdminDashboardScreen(),
                        ),
                      );
                    } else {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const CashierDashboardScreen(),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
