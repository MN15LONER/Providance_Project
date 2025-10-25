import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository_impl.dart';

/// Current user model provider that fetches full user data from Firestore
final currentUserModelProvider = StreamProvider<UserModel?>((ref) {
  return firebase_auth.FirebaseAuth.instance
      .authStateChanges()
      .asyncMap((firebaseUser) async {
        if (firebaseUser == null) return null;
        
        try {
          final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();
        
          if (!doc.exists || doc.data() == null) return null;
          
          final data = doc.data()!;
          return UserModel(
            uid: doc.id,
            email: data['email'] as String? ?? firebaseUser.email ?? '',
            displayName: data['displayName'] as String? ?? firebaseUser.displayName ?? '',
            phoneNumber: data['phoneNumber'] as String?,
            role: data['role'] as String? ?? 'citizen',
            ward: data['ward'] as String?,
            municipality: data['municipality'] as String?,
            photoURL: data['photoURL'] as String? ?? firebaseUser.photoURL,
            points: (data['points'] as int?) ?? 0,
            createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            isActive: (data['isActive'] as bool?) ?? true,
            notificationTokens: List<String>.from(data['notificationTokens'] as List? ?? []),
            achievements: List<String>.from(data['achievements'] as List? ?? []),
          );
        } catch (e) {
          print('Error fetching user data: $e');
          return null;
        }
      });
});

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  return AuthRepositoryImpl();
});
