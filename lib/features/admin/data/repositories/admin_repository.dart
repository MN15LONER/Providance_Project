import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/failures.dart';
import '../models/announcement_model.dart';
import '../../domain/entities/announcement.dart';

class AdminRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AdminRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Create a new announcement
  Future<String> createAnnouncement({
    required String title,
    required String message,
    required String type,
    DateTime? scheduledFor,
    String? ward,
    String? municipality,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthFailure('User not authenticated');
      }

      // Get user profile
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        throw const DataFailure('User profile not found');
      }

      final userData = userDoc.data()!;
      
      // Check if user is admin
      if (userData['role'] != 'admin') {
        throw const AuthFailure('User is not authorized');
      }

      final announcementData = {
        'title': title,
        'message': message,
        'type': type,
        'createdBy': user.uid,
        'creatorName': userData['displayName'] ?? 'Admin',
        'creatorPhoto': userData['photoURL'],
        'createdAt': FieldValue.serverTimestamp(),
        'scheduledFor': scheduledFor != null ? Timestamp.fromDate(scheduledFor) : null,
        'ward': ward,
        'municipality': municipality ?? userData['municipality'],
        'isActive': true,
        'viewCount': 0,
      };

      final docRef = await _firestore.collection('announcements').add(announcementData);
      return docRef.id;
    } catch (e) {
      if (e is Failure) rethrow;
      throw DataFailure('Failed to create announcement: $e');
    }
  }

  /// Get all announcements
  Stream<List<Announcement>> getAnnouncements({
    String? ward,
    String? municipality,
    bool activeOnly = true,
  }) {
    try {
      Query query = _firestore.collection('announcements');

      if (activeOnly) {
        query = query.where('isActive', isEqualTo: true);
      }

      if (municipality != null) {
        query = query.where('municipality', isEqualTo: municipality);
      }

      if (ward != null) {
        query = query.where('ward', isEqualTo: ward);
      }

      query = query.orderBy('createdAt', descending: true);

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => AnnouncementModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw DataFailure('Failed to get announcements: $e');
    }
  }

  /// Update announcement
  Future<void> updateAnnouncement(String id, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('announcements').doc(id).update(updates);
    } catch (e) {
      throw DataFailure('Failed to update announcement: $e');
    }
  }

  /// Delete announcement
  Future<void> deleteAnnouncement(String id) async {
    try {
      await _firestore.collection('announcements').doc(id).delete();
    } catch (e) {
      throw DataFailure('Failed to delete announcement: $e');
    }
  }

  /// Update idea status (for admin review)
  Future<void> updateIdeaStatus({
    required String ideaId,
    required String status,
    String? adminResponse,
    double? budget,
    DateTime? timeline,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthFailure('User not authenticated');
      }

      final updates = <String, dynamic>{
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (adminResponse != null) {
        updates['officialResponse'] = adminResponse;
        updates['respondedAt'] = FieldValue.serverTimestamp();
      }

      if (budget != null) {
        updates['budget'] = budget;
      }

      if (timeline != null) {
        updates['timeline'] = Timestamp.fromDate(timeline);
      }

      await _firestore.collection('ideas').doc(ideaId).update(updates);
    } catch (e) {
      if (e is Failure) rethrow;
      throw DataFailure('Failed to update idea status: $e');
    }
  }

  /// Update issue status and assign
  Future<void> updateIssueStatus({
    required String issueId,
    required String status,
    String? assignedTo,
    String? assignedToName,
    String? officialResponse,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthFailure('User not authenticated');
      }

      final updates = <String, dynamic>{
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (assignedTo != null) {
        updates['assignedTo'] = assignedTo;
        updates['assignedToName'] = assignedToName;
        updates['assignedAt'] = FieldValue.serverTimestamp();
      }

      if (officialResponse != null) {
        updates['officialResponse'] = officialResponse;
        updates['respondedAt'] = FieldValue.serverTimestamp();
      }

      await _firestore.collection('issues').doc(issueId).update(updates);
    } catch (e) {
      if (e is Failure) rethrow;
      throw DataFailure('Failed to update issue status: $e');
    }
  }

  /// Get admin statistics
  Future<Map<String, dynamic>> getAdminStatistics() async {
    try {
      // Get total issues
      final issuesSnapshot = await _firestore.collection('issues').get();
      final totalIssues = issuesSnapshot.docs.length;
      
      final pendingIssues = issuesSnapshot.docs
          .where((doc) => doc.data()['status'] == 'pending')
          .length;
      
      final resolvedIssues = issuesSnapshot.docs
          .where((doc) => doc.data()['status'] == 'resolved')
          .length;

      // Get total ideas
      final ideasSnapshot = await _firestore.collection('ideas').get();
      final totalIdeas = ideasSnapshot.docs.length;
      
      final underReviewIdeas = ideasSnapshot.docs
          .where((doc) => doc.data()['status'] == 'under_review')
          .length;
      
      final approvedIdeas = ideasSnapshot.docs
          .where((doc) => doc.data()['status'] == 'approved')
          .length;

      // Get total users (excluding admins)
      final usersSnapshot = await _firestore.collection('users').get();
      final totalUsers = usersSnapshot.docs
          .where((doc) => doc.data()['role'] != 'admin')
          .length;

      return {
        'totalIssues': totalIssues,
        'pendingIssues': pendingIssues,
        'resolvedIssues': resolvedIssues,
        'totalIdeas': totalIdeas,
        'underReviewIdeas': underReviewIdeas,
        'approvedIdeas': approvedIdeas,
        'totalUsers': totalUsers,
      };
    } catch (e) {
      throw DataFailure('Failed to get statistics: $e');
    }
  }
}
