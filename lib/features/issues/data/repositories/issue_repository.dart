import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// storage is handled by ImageUtils; don't import FirebaseStorage here to avoid unused import warning
import 'package:uuid/uuid.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/errors/failures.dart';
import '../models/issue_model.dart';
import '../../domain/entities/issue.dart';

/// Repository for issue operations
class IssueRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final LocationService _locationService;

  IssueRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    LocationService? locationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        
        _auth = auth ?? FirebaseAuth.instance,
        _locationService = locationService ?? LocationService();

  /// Create a new issue
  Future<String> createIssue({
    required String title,
    required String description,
    required String category,
    required String severity,
    required GeoPoint location,
    required List<File> photos,
  }) async {
    try {
      // Get current user
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

      // Compress and upload photos
      final photoUrls = <String>[];
      for (int i = 0; i < photos.length; i++) {
        // Compress image
        final compressed = await ImageUtils.compressImage(
          photos[i],
          quality: 70,
        );

        if (compressed != null) {
          // Upload to storage
          final url = await ImageUtils.uploadToStorage(
            compressed,
            'issues/${const Uuid().v4()}',
            userId: user.uid,
            metadata: {
              'category': category,
              'severity': severity,
            },
          );
          photoUrls.add(url);

          // Clean up compressed file
          if (compressed.path != photos[i].path) {
            await compressed.delete();
          }
        }
      }

      if (photoUrls.isEmpty) {
        throw const DataFailure('Failed to upload photos');
      }

      // Get location name
      final locationName = await _locationService.getAddressFromCoordinates(
        location.latitude,
        location.longitude,
      );

      // Create issue document
      final issueData = {
        'reportedBy': user.uid,
        'reporterName': userData['displayName'] ?? 'Unknown',
        'reporterPhoto': userData['photoURL'],
        'title': title,
        'description': description,
        'category': category,
        'severity': severity,
        'status': 'pending',
        'location': location,
        'locationName': locationName,
        'ward': userData['ward'],
        'photos': photoUrls,
  'verifications': <String>[],
        'verificationCount': 0,
        'assignedTo': null,
        'assignedToName': null,
        'assignedAt': null,
        'officialResponse': null,
        'respondedAt': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection('issues').add(issueData);

      // Award points for reporting an issue
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'points': FieldValue.increment(10),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Create points history entry
        await _firestore.collection('points_history').add({
          'userId': user.uid,
          'points': 10,
          'action': 'Reported an issue',
          'referenceId': docRef.id,
          'referenceType': 'issue',
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        // Don't fail the issue creation if points fail
        print('Failed to award points: $e');
      }

      return docRef.id;
    } catch (e) {
      if (e is Failure) rethrow;
      throw DataFailure('Failed to create issue: $e');
    }
  }

  /// Get issues stream with optional filters
  Stream<List<Issue>> getIssues({
    String? status,
    String? category,
    String? severity,
    String? userId,
    String? ward,
    int? limit,
  }) {
    try {
      Query query = _firestore.collection('issues');

      // Apply filters
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }
      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }
      if (severity != null) {
        query = query.where('severity', isEqualTo: severity);
      }
      if (userId != null) {
        query = query.where('reportedBy', isEqualTo: userId);
      }
      if (ward != null) {
        query = query.where('ward', isEqualTo: ward);
      }

      // Order by creation date
      query = query.orderBy('createdAt', descending: true);

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      return query
          .snapshots()
          .handleError((Object error, StackTrace? stack) {
        print('🔴 Firestore getIssues error: $error');
        if (stack != null) print(stack);
      }).map((snapshot) {
        return snapshot.docs.map((doc) {
          return IssueModel.fromFirestore(doc).toEntity();
        }).toList();
      });
    } catch (e) {
      throw DataFailure('Failed to get issues: $e');
    }
  }

  /// Get single issue by ID
  Future<Issue> getIssueById(String issueId) async {
    try {
      final doc = await _firestore.collection('issues').doc(issueId).get();

      if (!doc.exists) {
        throw const DataFailure('Issue not found');
      }

      return IssueModel.fromFirestore(doc).toEntity();
    } catch (e) {
      if (e is Failure) rethrow;
      throw DataFailure('Failed to get issue: $e');
    }
  }

  /// Get issue stream by ID
  Stream<Issue> getIssueStream(String issueId) {
    try {
      return _firestore
          .collection('issues')
          .doc(issueId)
          .snapshots()
          .map((doc) {
        if (!doc.exists) {
          throw const DataFailure('Issue not found');
        }
        return IssueModel.fromFirestore(doc).toEntity();
      });
    } catch (e) {
      throw DataFailure('Failed to stream issue: $e');
    }
  }

  /// Update issue status
  Future<void> updateIssueStatus(String issueId, String status) async {
    try {
      await _firestore.collection('issues').doc(issueId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw DataFailure('Failed to update issue status: $e');
    }
  }

  /// Assign issue to official
  Future<void> assignIssue(
    String issueId,
    String officialId,
    String officialName,
  ) async {
    try {
      await _firestore.collection('issues').doc(issueId).update({
        'assignedTo': officialId,
        'assignedToName': officialName,
        'assignedAt': FieldValue.serverTimestamp(),
        'status': 'in_progress',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw DataFailure('Failed to assign issue: $e');
    }
  }

  /// Add official response
  Future<void> addOfficialResponse(
    String issueId,
    String response,
  ) async {
    try {
      await _firestore.collection('issues').doc(issueId).update({
        'officialResponse': response,
        'respondedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw DataFailure('Failed to add response: $e');
    }
  }

  /// Verify issue
  Future<void> verifyIssue(String issueId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthFailure('User not authenticated');
      }

      final issueRef = _firestore.collection('issues').doc(issueId);
      final issue = await issueRef.get();

      if (!issue.exists) {
        throw const DataFailure('Issue not found');
      }

  final verifications = List<String>.from((issue.data()!['verifications'] as List<dynamic>?) ?? []);

      // Check if user already verified
      if (verifications.contains(user.uid)) {
        throw const DataFailure('You have already verified this issue');
      }

      // Add verification
      verifications.add(user.uid);

      await issueRef.update({
        'verifications': verifications,
        'verificationCount': verifications.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create verification subcollection document
      await issueRef.collection('verifications').doc(user.uid).set({
        'verifiedBy': user.uid,
        'verifiedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (e is Failure) rethrow;
      throw DataFailure('Failed to verify issue: $e');
    }
  }

  /// Remove verification
  Future<void> removeVerification(String issueId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthFailure('User not authenticated');
      }

      final issueRef = _firestore.collection('issues').doc(issueId);
      final issue = await issueRef.get();

      if (!issue.exists) {
        throw const DataFailure('Issue not found');
      }

  final verifications = List<String>.from((issue.data()!['verifications'] as List<dynamic>?) ?? []);

      // Check if user has verified
      if (!verifications.contains(user.uid)) {
        throw const DataFailure('You have not verified this issue');
      }

      // Remove verification
      verifications.remove(user.uid);

      await issueRef.update({
        'verifications': verifications,
        'verificationCount': verifications.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Delete verification subcollection document
      await issueRef.collection('verifications').doc(user.uid).delete();
    } catch (e) {
      if (e is Failure) rethrow;
      throw DataFailure('Failed to remove verification: $e');
    }
  }

  /// Delete issue (admin only)
  Future<void> deleteIssue(String issueId) async {
    try {
      final issueDoc = await _firestore.collection('issues').doc(issueId).get();

      if (!issueDoc.exists) {
        throw const DataFailure('Issue not found');
      }

      final issue = IssueModel.fromFirestore(issueDoc);

      // Delete photos from storage
      await ImageUtils.deleteMultipleFromStorage(issue.photos);

      // Delete issue document
      await _firestore.collection('issues').doc(issueId).delete();
    } catch (e) {
      if (e is Failure) rethrow;
      throw DataFailure('Failed to delete issue: $e');
    }
  }

  /// Get issues count by status
  Future<Map<String, int>> getIssuesCountByStatus() async {
    try {
      final snapshot = await _firestore.collection('issues').get();

      final counts = <String, int>{
        'pending': 0,
        'in_progress': 0,
        'resolved': 0,
        'closed': 0,
      };

      for (final doc in snapshot.docs) {
        final status = doc.data()['status'] as String;
        counts[status] = (counts[status] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      throw DataFailure('Failed to get issues count: $e');
    }
  }
}
