import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  // Authentication
  Future<void> signIn(String email, String password);
  Future<void> signUp(String email, String password);
  Future<void> completeProfileSetup(
    String uid,
    String displayName,
    String phoneNumber,
    String role,
    String? ward,
    String? municipality,
  );
  
  // User Management
  Future<User?> getCurrentUser();
  
  // Auth State
  Stream<User?> authStateChanges();
  
  // Additional Auth Methods
  Future<void> signInWithGoogle();
  Future<void> signOut();
  Future<void> resetPassword(String email);
}
