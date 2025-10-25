import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository_impl.dart';

/// Current user model provider that fetches full user data from Firestore
final currentUserModelProvider = StreamProvider<UserModel?>((ref) {
  final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
  
  if (firebaseUser == null) {
    return Stream.value(null);
  }
  
  return FirebaseFirestore.instance
      .collection('users')
      .doc(firebaseUser.uid)
      .snapshots()
      .map((doc) {
        if (!doc.exists || doc.data() == null) return null;
        
        final data = doc.data()!;
        return UserModel(
          uid: doc.id,
          email: data['email'] as String? ?? '',
          displayName: data['displayName'] as String? ?? '',
          phoneNumber: data['phoneNumber'] as String?,
          role: data['role'] as String? ?? 'citizen',
          ward: data['ward'] as String?,
          municipality: data['municipality'] as String?,
          photoURL: data['photoURL'] as String?,
          points: (data['points'] as int?) ?? 0,
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          isActive: (data['isActive'] as bool?) ?? true,
          notificationTokens: List<String>.from(data['notificationTokens'] as List? ?? []),
          achievements: List<String>.from(data['achievements'] as List? ?? []),
        );
      });
});

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  return AuthRepositoryImpl();
});
