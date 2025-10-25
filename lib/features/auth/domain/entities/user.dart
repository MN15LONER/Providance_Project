import 'package:cloud_firestore/cloud_firestore.dart';

/// User entity
class User {
  final String uid;
  final String email;
  final String displayName;
  final String? phoneNumber;
  final String role; // 'citizen' or 'official'
  final String? ward;
  final String? municipality;
  final String? photoURL;
  final int points;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final List<String> notificationTokens;
  final List<String> achievements;
  final DateTime? lastLoginAt;

  const User({
    required this.uid,
    required this.email,
    required this.displayName,
    this.phoneNumber,
    required this.role,
    this.ward,
    this.municipality,
    this.photoURL,
    this.points = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.notificationTokens = const [],
    this.achievements = const [],
    this.lastLoginAt,
  });

  bool get isCitizen => role == 'citizen';
  bool get isOfficial => role == 'official';

  User copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? role,
    String? ward,
    String? municipality,
    String? photoURL,
    int? points,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    List<String>? notificationTokens,
    List<String>? achievements,
    DateTime? lastLoginAt,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      ward: ward ?? this.ward,
      municipality: municipality ?? this.municipality,
      photoURL: photoURL ?? this.photoURL,
      points: points ?? this.points,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      notificationTokens: notificationTokens ?? this.notificationTokens,
      achievements: achievements ?? this.achievements,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'User(uid: $uid, email: $email, displayName: $displayName, role: $role)';
  }
}
