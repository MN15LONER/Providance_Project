import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../models/user_model.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/services/notification_service.dart';

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    firebaseAuth: firebase_auth.FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
    notificationService: ref.read(notificationServiceProvider),
  );
});

/// Repository for authentication operations
class AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final NotificationService _notificationService;

  AuthRepository({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required NotificationService notificationService,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore,
        _notificationService = notificationService;

  /// Get current user stream
  Stream<User?> get authStateChanges {
    // Use idTokenChanges instead of authStateChanges to avoid PigeonUserDetails bug
    return _firebaseAuth.idTokenChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      try {
        return await getUserById(firebaseUser.uid);
      } catch (e) {
        print('Error in authStateChanges: $e');
        // Return null if we can't get user details
        return null;
      }
    }).handleError((error) {
      print('Stream error in authStateChanges: $error');
      return null;
    });
  }

  /// Get current user
  Future<User?> get currentUser async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    return await getUserById(firebaseUser.uid);
  }

  /// Sign in with email and password
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthFailure('Sign in failed');
      }

      // Get user document
      final user = await getUserById(credential.user!.uid);
      if (user == null) {
        throw const AuthFailure('User not found');
      }

      // Update last login and FCM token
      await _updateLastLogin(user.uid);

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ErrorHandler.handleAuthError(e);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  /// Sign up with email and password
  Future<User> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthFailure('Sign up failed');
      }

      // Update display name (non-blocking, ignore errors)
      try {
        await credential.user!.updateDisplayName(displayName);
        await credential.user!.reload();
      } catch (e) {
        // Ignore display name update errors - we'll use Firestore data instead
        print('Warning: Could not update display name: $e');
      }

      // Create user document
      final user = await _createUserDocument(
        uid: credential.user!.uid,
        email: email,
        displayName: displayName,
      );

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ErrorHandler.handleAuthError(e);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  /// Sign in with Google
  Future<User> signInWithGoogle() async {
    try {
      // TODO: Implement Google Sign-In
      // This requires google_sign_in package and additional setup
      throw const AuthFailure('Google Sign-In not implemented yet');
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      // Delete FCM token
      await _notificationService.deleteToken();
      
      // Sign out from Firebase
      await _firebaseAuth.signOut();
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ErrorHandler.handleAuthError(e);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  /// Update user profile
  Future<User> updateUserProfile({
    required String uid,
    String? displayName,
    String? phoneNumber,
    String? ward,
    String? municipality,
    String? photoURL,
  }) async {
    try {
      final updates = <String, dynamic>{
        FirebaseFields.updatedAt: FieldValue.serverTimestamp(),
      };

      if (displayName != null) updates[FirebaseFields.displayName] = displayName;
      if (phoneNumber != null) updates[FirebaseFields.phoneNumber] = phoneNumber;
      if (ward != null) updates[FirebaseFields.ward] = ward;
      if (municipality != null) updates[FirebaseFields.municipality] = municipality;
      if (photoURL != null) updates[FirebaseFields.photoURL] = photoURL;

      await _firestore
          .collection(FirebaseCollections.users)
          .doc(uid)
          .update(updates);

      final user = await getUserById(uid);
      if (user == null) {
        throw const AuthFailure('User not found');
      }

      return user;
    } on FirebaseException catch (e) {
      throw ErrorHandler.handleFirestoreError(e);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  /// Complete profile setup
  Future<User> completeProfileSetup({
    required String uid,
    required String role,
    required String ward,
    required String municipality,
    String? phoneNumber,
  }) async {
    try {
      await _firestore.collection(FirebaseCollections.users).doc(uid).update({
        FirebaseFields.role: role,
        FirebaseFields.ward: ward,
        FirebaseFields.municipality: municipality,
        FirebaseFields.phoneNumber: phoneNumber,
        FirebaseFields.updatedAt: FieldValue.serverTimestamp(),
      });

      // Subscribe to ward notifications
      await _notificationService.subscribeToWard(ward);
      await _notificationService.subscribeToMunicipality(municipality);

      final user = await getUserById(uid);
      if (user == null) {
        throw const AuthFailure('User not found');
      }

      return user;
    } on FirebaseException catch (e) {
      throw ErrorHandler.handleFirestoreError(e);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  /// Get user by ID
  Future<User?> getUserById(String uid) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.users)
          .doc(uid)
          .get();

      if (!doc.exists) return null;

      return UserModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ErrorHandler.handleFirestoreError(e);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  /// Create user document
  Future<User> _createUserDocument({
    required String uid,
    required String email,
    required String displayName,
  }) async {
    final now = DateTime.now();
    final fcmToken = _notificationService.fcmToken;

    final userData = UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      role: '', // Will be set during profile setup
      points: 0,
      createdAt: now,
      updatedAt: now,
      isActive: true,
      notificationTokens: fcmToken != null ? [fcmToken] : [],
      achievements: [],
      lastLoginAt: now,
    );

    await _firestore
        .collection(FirebaseCollections.users)
        .doc(uid)
        .set(userData.toFirestore());

    return userData;
  }

  /// Update last login
  Future<void> _updateLastLogin(String uid) async {
    final fcmToken = _notificationService.fcmToken;
    
    final updates = <String, dynamic>{
      FirebaseFields.lastLoginAt: FieldValue.serverTimestamp(),
    };

    if (fcmToken != null) {
      updates[FirebaseFields.notificationTokens] = FieldValue.arrayUnion([fcmToken]);
    }

    await _firestore
        .collection(FirebaseCollections.users)
        .doc(uid)
        .update(updates);
  }

  /// Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthFailure('No user signed in');
      }

      // Soft delete - mark as inactive
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(user.uid)
          .update({
        FirebaseFields.isActive: false,
        FirebaseFields.updatedAt: FieldValue.serverTimestamp(),
      });

      // Sign out
      await signOut();
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }
}
