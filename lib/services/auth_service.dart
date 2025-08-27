import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException {
      // Handle specific Firebase auth errors
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Register with email and password (for admin to create users)
  Future<UserCredential?> registerWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Change password
  Future<void> changePassword(String newPassword) async {
    try {
      await _auth.currentUser!.updatePassword(newPassword);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}