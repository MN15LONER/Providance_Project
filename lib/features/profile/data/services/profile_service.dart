import 'package:cloud_firestore/cloud_firestore.dart';

/// Service to fetch profile-related data and statistics
class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get user statistics including issues and ideas count
  Future<UserStatistics> getUserStatistics(String userId) async {
    try {
      // Fetch issues count
      final issuesQuery = await _firestore
          .collection('issues')
          .where('createdBy', isEqualTo: userId)
          .get();
      
      final issuesCount = issuesQuery.docs.length;

      // Fetch ideas count
      final ideasQuery = await _firestore
          .collection('ideas')
          .where('createdBy', isEqualTo: userId)
          .get();
      
      final ideasCount = ideasQuery.docs.length;

      // Calculate total upvotes from ideas
      int totalUpvotes = 0;
      for (var doc in ideasQuery.docs) {
        final data = doc.data();
        totalUpvotes += (data['voteCount'] as int?) ?? 0;
      }

      return UserStatistics(
        issuesCount: issuesCount,
        ideasCount: ideasCount,
        totalUpvotes: totalUpvotes,
      );
    } catch (e) {
      print('Error fetching user statistics: $e');
      return UserStatistics(
        issuesCount: 0,
        ideasCount: 0,
        totalUpvotes: 0,
      );
    }
  }

  /// Update user profile picture URL
  Future<void> updateProfilePicture(String userId, String photoURL) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'photoURL': photoURL,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating profile picture: $e');
      rethrow;
    }
  }

  /// Update user profile data
  Future<void> updateUserProfile({
    required String userId,
    String? displayName,
    String? phoneNumber,
    String? role,
    String? ward,
    String? municipality,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) updates['displayName'] = displayName;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (role != null) updates['role'] = role;
      if (ward != null) updates['ward'] = ward;
      if (municipality != null) updates['municipality'] = municipality;

      await _firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }
}

/// User statistics model
class UserStatistics {
  final int issuesCount;
  final int ideasCount;
  final int totalUpvotes;

  UserStatistics({
    required this.issuesCount,
    required this.ideasCount,
    required this.totalUpvotes,
  });
}
