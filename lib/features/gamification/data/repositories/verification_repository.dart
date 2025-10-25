import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/location_service.dart';

/// Repository for verification operations
class VerificationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final LocationService _locationService;

  VerificationRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    LocationService? locationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _locationService = locationService ?? LocationService();

  /// Verify an issue
  Future<void> verifyIssue(String issueId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthFailure('User not authenticated');
      }

      // Get issue
      final issueDoc = await _firestore.collection('issues').doc(issueId).get();
      if (!issueDoc.exists) {
        throw const DataFailure('Issue not found');
      }

      final issueData = issueDoc.data()!;

      // Check if user is not the reporter
      if (issueData['reportedBy'] == user.uid) {
        throw const DataFailure('Cannot verify your own report');
      }

      // Check if already verified
      final existingVerification = await _firestore
          .collection('verifications')
          .where('userId', isEqualTo: user.uid)
          .where('issueId', isEqualTo: issueId)
          .get();

      if (existingVerification.docs.isNotEmpty) {
        throw const DataFailure('You have already verified this issue');
      }

      // Get user's current location for proximity check (optional)
      Position? userLocation;
      try {
        userLocation = await _locationService.getCurrentPosition();
      } catch (e) {
        // Location not available, continue without proximity check
      }

      // Calculate distance if both locations available
      double? distance;
      if (userLocation != null && issueData['location'] != null) {
        final issueLocation = issueData['location'] as GeoPoint;
        distance = Geolocator.distanceBetween(
          userLocation.latitude,
          userLocation.longitude,
          issueLocation.latitude,
          issueLocation.longitude,
        );
      }

      // Create verification document
      await _firestore.collection('verifications').add({
        'userId': user.uid,
        'issueId': issueId,
        'distance': distance,
        'location': userLocation != null
            ? GeoPoint(userLocation.latitude, userLocation.longitude)
            : null,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update issue verification count
      final verifications = List<String>.from(issueData['verifications'] ?? []);
      verifications.add(user.uid);

      await _firestore.collection('issues').doc(issueId).update({
        'verifications': verifications,
        'verificationCount': verifications.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Award points to verifier
      await _awardPoints(
        userId: user.uid,
        points: 2,
        action: 'Verified issue',
        referenceId: issueId,
        referenceType: 'issue',
      );

      // Award points to reporter if verification threshold met
      if (verifications.length == 3) {
        await _awardPoints(
          userId: issueData['reportedBy'],
          points: 5,
          action: 'Issue verified by community',
          referenceId: issueId,
          referenceType: 'issue',
        );
      }
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

      // Find and delete verification
      final verification = await _firestore
          .collection('verifications')
          .where('userId', isEqualTo: user.uid)
          .where('issueId', isEqualTo: issueId)
          .get();

      if (verification.docs.isEmpty) {
        throw const DataFailure('Verification not found');
      }

      await verification.docs.first.reference.delete();

      // Update issue verification count
      final issueDoc = await _firestore.collection('issues').doc(issueId).get();
      if (issueDoc.exists) {
        final verifications = List<String>.from(issueDoc.data()!['verifications'] ?? []);
        verifications.remove(user.uid);

        await _firestore.collection('issues').doc(issueId).update({
          'verifications': verifications,
          'verificationCount': verifications.length,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Deduct points
      await _awardPoints(
        userId: user.uid,
        points: -2,
        action: 'Removed verification',
        referenceId: issueId,
        referenceType: 'issue',
      );
    } catch (e) {
      if (e is Failure) rethrow;
      throw DataFailure('Failed to remove verification: $e');
    }
  }

  /// Check if user has verified an issue
  Future<bool> hasVerified(String issueId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final verification = await _firestore
          .collection('verifications')
          .where('userId', isEqualTo: user.uid)
          .where('issueId', isEqualTo: issueId)
          .get();

      return verification.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get verification count for an issue
  Future<int> getVerificationCount(String issueId) async {
    try {
      final verifications = await _firestore
          .collection('verifications')
          .where('issueId', isEqualTo: issueId)
          .get();

      return verifications.docs.length;
    } catch (e) {
      throw DataFailure('Failed to get verification count: $e');
    }
  }

  /// Get user's verifications
  Future<List<String>> getUserVerifications(String userId) async {
    try {
      final verifications = await _firestore
          .collection('verifications')
          .where('userId', isEqualTo: userId)
          .get();

      return verifications.docs
          .map((doc) => doc.data()['issueId'] as String)
          .toList();
    } catch (e) {
      throw DataFailure('Failed to get user verifications: $e');
    }
  }

  /// Award points to user
  Future<void> _awardPoints({
    required String userId,
    required int points,
    required String action,
    String? referenceId,
    String? referenceType,
  }) async {
    try {
      // Update user points
      await _firestore.collection('users').doc(userId).update({
        'points': FieldValue.increment(points),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create points history entry
      await _firestore.collection('points_history').add({
        'userId': userId,
        'points': points,
        'action': action,
        'referenceId': referenceId,
        'referenceType': referenceType,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Don't throw, just log
      print('Failed to award points: $e');
    }
  }
}
