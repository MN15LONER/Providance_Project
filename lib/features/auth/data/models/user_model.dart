import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';
import '../../../../core/constants/firebase_constants.dart';

/// User model for data layer
class UserModel extends User {
  const UserModel({
    required super.uid,
    required super.email,
    required super.displayName,
    super.phoneNumber,
    required super.role,
    super.ward,
    super.municipality,
    super.photoURL,
    super.points,
    required super.createdAt,
    required super.updatedAt,
    super.isActive,
    super.notificationTokens,
    super.achievements,
    super.lastLoginAt,
  });

  /// Create from User entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      phoneNumber: user.phoneNumber,
      role: user.role,
      ward: user.ward,
      municipality: user.municipality,
      photoURL: user.photoURL,
      points: user.points,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      isActive: user.isActive,
      notificationTokens: user.notificationTokens,
      achievements: user.achievements,
      lastLoginAt: user.lastLoginAt,
    );
  }

  /// Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>;
      
      return UserModel(
        uid: data[FirebaseFields.uid] as String? ?? doc.id,
        email: data[FirebaseFields.email] as String? ?? '',
        displayName: data[FirebaseFields.displayName] as String? ?? 'User',
        phoneNumber: data[FirebaseFields.phoneNumber] as String?,
        role: data[FirebaseFields.role] as String? ?? '',
        ward: data[FirebaseFields.ward] as String?,
        municipality: data[FirebaseFields.municipality] as String?,
        photoURL: data[FirebaseFields.photoURL] as String?,
        points: (data[FirebaseFields.points] as num?)?.toInt() ?? 0,
        createdAt: (data[FirebaseFields.createdAt] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (data[FirebaseFields.updatedAt] as Timestamp?)?.toDate() ?? DateTime.now(),
        isActive: data[FirebaseFields.isActive] as bool? ?? true,
        notificationTokens: _safeListCast<String>(data[FirebaseFields.notificationTokens]),
        achievements: _safeListCast<String>(data[FirebaseFields.achievements]),
        lastLoginAt: (data[FirebaseFields.lastLoginAt] as Timestamp?)?.toDate(),
      );
    } catch (e) {
      // If parsing fails, return a minimal user object
      return UserModel(
        uid: doc.id,
        email: '',
        displayName: 'User',
        role: '',
        points: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        notificationTokens: const [],
        achievements: const [],
      );
    }
  }

  /// Safely cast list data
  static List<T> _safeListCast<T>(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.whereType<T>().toList();
    }
    return [];
  }

  /// Create from map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map[FirebaseFields.uid] as String,
      email: map[FirebaseFields.email] as String,
      displayName: map[FirebaseFields.displayName] as String,
      phoneNumber: map[FirebaseFields.phoneNumber] as String?,
      role: map[FirebaseFields.role] as String,
      ward: map[FirebaseFields.ward] as String?,
      municipality: map[FirebaseFields.municipality] as String?,
      photoURL: map[FirebaseFields.photoURL] as String?,
      points: (map[FirebaseFields.points] as num?)?.toInt() ?? 0,
      createdAt: (map[FirebaseFields.createdAt] as Timestamp).toDate(),
      updatedAt: (map[FirebaseFields.updatedAt] as Timestamp).toDate(),
      isActive: map[FirebaseFields.isActive] as bool? ?? true,
      notificationTokens: List<String>.from(
        map[FirebaseFields.notificationTokens] as List? ?? [],
      ),
      achievements: List<String>.from(
        map[FirebaseFields.achievements] as List? ?? [],
      ),
      lastLoginAt: (map[FirebaseFields.lastLoginAt] as Timestamp?)?.toDate(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      FirebaseFields.uid: uid,
      FirebaseFields.email: email,
      FirebaseFields.displayName: displayName,
      FirebaseFields.phoneNumber: phoneNumber,
      FirebaseFields.role: role,
      FirebaseFields.ward: ward,
      FirebaseFields.municipality: municipality,
      FirebaseFields.photoURL: photoURL,
      FirebaseFields.points: points,
      FirebaseFields.createdAt: Timestamp.fromDate(createdAt),
      FirebaseFields.updatedAt: Timestamp.fromDate(updatedAt),
      FirebaseFields.isActive: isActive,
      FirebaseFields.notificationTokens: notificationTokens,
      FirebaseFields.achievements: achievements,
      FirebaseFields.lastLoginAt: lastLoginAt != null 
          ? Timestamp.fromDate(lastLoginAt!) 
          : null,
    };
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return toFirestore();
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return toMap();
  }

  /// Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel.fromMap(json);
  }

  @override
  UserModel copyWith({
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
    return UserModel(
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
}
