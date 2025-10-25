import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/failures.dart';
import '../models/point_history_model.dart';
import '../../domain/entities/point_history.dart';
import '../../domain/entities/leaderboard_entry.dart';

/// Repository for points and gamification operations
class PointsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  PointsRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Get user points stream
  Stream<int> getUserPoints(String userId) {
    try {
      return _firestore
          .collection('users')
          .doc(userId)
          .snapshots()
          .map((doc) {
        if (!doc.exists) return 0;
        return doc.data()!['points'] as int? ?? 0;
      });
    } catch (e) {
      throw DataFailure('Failed to get user points: $e');
    }
  }

  /// Get current user points
  Future<int> getCurrentUserPoints() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return 0;

      return doc.data()!['points'] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get points history stream
  Stream<List<PointHistory>> getPointsHistory(String userId, {int limit = 50}) {
    try {
      return _firestore
          .collection('points_history')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return PointHistoryModel.fromFirestore(doc).toEntity();
        }).toList();
      });
    } catch (e) {
      throw DataFailure('Failed to get points history: $e');
    }
  }

  /// Get leaderboard
  Future<List<LeaderboardEntry>> getLeaderboard({
    String? ward,
    int limit = 50,
  }) async {
    try {
      Query query = _firestore.collection('users');

      // Filter by ward if specified
      if (ward != null && ward.isNotEmpty) {
        query = query.where('ward', isEqualTo: ward);
      }

      // Order by points
      query = query.orderBy('points', descending: true).limit(limit);

      final snapshot = await query.get();

      return snapshot.docs.asMap().entries.map((entry) {
        final data = entry.value.data() as Map<String, dynamic>;
        return LeaderboardEntry(
          rank: entry.key + 1,
          userId: entry.value.id,
          name: data['displayName'] as String? ?? 'Unknown',
          photoURL: data['photoURL'] as String?,
          points: data['points'] as int? ?? 0,
          ward: data['ward'] as String?,
        );
      }).toList();
    } catch (e) {
      throw DataFailure('Failed to get leaderboard: $e');
    }
  }

  /// Get user rank
  Future<int> getUserRank(String userId, {String? ward}) async {
    try {
      Query query = _firestore.collection('users');

      // Filter by ward if specified
      if (ward != null && ward.isNotEmpty) {
        query = query.where('ward', isEqualTo: ward);
      }

      // Get user's points
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return 0;

      final userPoints = userDoc.data()!['points'] as int? ?? 0;

      // Count users with more points
      query = query.where('points', isGreaterThan: userPoints);
      final snapshot = await query.get();

      return snapshot.docs.length + 1;
    } catch (e) {
      return 0;
    }
  }

  /// Award points to user
  Future<void> awardPoints({
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
      throw DataFailure('Failed to award points: $e');
    }
  }

  /// Get total points awarded
  Future<int> getTotalPointsAwarded() async {
    try {
      final snapshot = await _firestore.collection('users').get();

      int total = 0;
      for (final doc in snapshot.docs) {
        total += doc.data()['points'] as int? ?? 0;
      }

      return total;
    } catch (e) {
      return 0;
    }
  }

  /// Get points breakdown
  Future<Map<String, int>> getPointsBreakdown(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('points_history')
          .where('userId', isEqualTo: userId)
          .get();

      final breakdown = <String, int>{};

      for (final doc in snapshot.docs) {
        final action = doc.data()['action'] as String;
        final points = doc.data()['points'] as int;
        breakdown[action] = (breakdown[action] ?? 0) + points;
      }

      return breakdown;
    } catch (e) {
      throw DataFailure('Failed to get points breakdown: $e');
    }
  }

  /// Get points statistics
  Future<Map<String, dynamic>> getPointsStatistics(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        return {
          'totalPoints': 0,
          'rank': 0,
          'issuesReported': 0,
          'ideasProposed': 0,
          'verificationsGiven': 0,
          'votesGiven': 0,
        };
      }

      final userData = userDoc.data()!;

      // Get counts
      final issuesCount = await _firestore
          .collection('issues')
          .where('reportedBy', isEqualTo: userId)
          .get()
          .then((snapshot) => snapshot.docs.length);

      final ideasCount = await _firestore
          .collection('ideas')
          .where('createdBy', isEqualTo: userId)
          .get()
          .then((snapshot) => snapshot.docs.length);

      final verificationsCount = await _firestore
          .collection('verifications')
          .where('userId', isEqualTo: userId)
          .get()
          .then((snapshot) => snapshot.docs.length);

      final votesCount = await _firestore
          .collection('votes')
          .where('userId', isEqualTo: userId)
          .get()
          .then((snapshot) => snapshot.docs.length);

      final rank = await getUserRank(userId, ward: userData['ward']);

      return {
        'totalPoints': userData['points'] as int? ?? 0,
        'rank': rank,
        'issuesReported': issuesCount,
        'ideasProposed': ideasCount,
        'verificationsGiven': verificationsCount,
        'votesGiven': votesCount,
      };
    } catch (e) {
      throw DataFailure('Failed to get points statistics: $e');
    }
  }
}
