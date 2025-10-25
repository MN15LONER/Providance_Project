import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/failures.dart';
import '../models/comment_model.dart';
import '../../domain/entities/comment.dart';

/// Repository for comment operations
class CommentRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CommentRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Add a comment to an idea
  Future<String> addComment(String ideaId, String commentText) async {
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

      // Create comment document
      final commentData = {
        'userId': user.uid,
        'userName': userData['displayName'] ?? 'Unknown',
        'userPhoto': userData['photoURL'],
        'comment': commentText,
        'likes': 0,
        'likedBy': [],
        'timestamp': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore
          .collection('ideas')
          .doc(ideaId)
          .collection('comments')
          .add(commentData);

      // Increment comment count
      await _firestore.collection('ideas').doc(ideaId).update({
        'commentCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      if (e is Failure) rethrow;
      throw DataFailure('Failed to add comment: $e');
    }
  }

  /// Get comments stream for an idea
  Stream<List<Comment>> getComments(String ideaId) {
    try {
      return _firestore
          .collection('ideas')
          .doc(ideaId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return CommentModel.fromFirestore(doc).toEntity();
        }).toList();
      });
    } catch (e) {
      throw DataFailure('Failed to get comments: $e');
    }
  }

  /// Like a comment
  Future<void> likeComment(String ideaId, String commentId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthFailure('User not authenticated');
      }

      final commentRef = _firestore
          .collection('ideas')
          .doc(ideaId)
          .collection('comments')
          .doc(commentId);

      final comment = await commentRef.get();

      if (!comment.exists) {
        throw const DataFailure('Comment not found');
      }

      final likedBy = List<String>.from(comment.data()!['likedBy'] ?? []);

      // Check if user already liked
      if (likedBy.contains(user.uid)) {
        throw const DataFailure('You have already liked this comment');
      }

      // Add like
      likedBy.add(user.uid);

      await commentRef.update({
        'likedBy': likedBy,
        'likes': likedBy.length,
      });
    } catch (e) {
      if (e is Failure) rethrow;
      throw DataFailure('Failed to like comment: $e');
    }
  }

  /// Unlike a comment
  Future<void> unlikeComment(String ideaId, String commentId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthFailure('User not authenticated');
      }

      final commentRef = _firestore
          .collection('ideas')
          .doc(ideaId)
          .collection('comments')
          .doc(commentId);

      final comment = await commentRef.get();

      if (!comment.exists) {
        throw const DataFailure('Comment not found');
      }

      final likedBy = List<String>.from(comment.data()!['likedBy'] ?? []);

      // Check if user has liked
      if (!likedBy.contains(user.uid)) {
        throw const DataFailure('You have not liked this comment');
      }

      // Remove like
      likedBy.remove(user.uid);

      await commentRef.update({
        'likedBy': likedBy,
        'likes': likedBy.length,
      });
    } catch (e) {
      if (e is Failure) rethrow;
      throw DataFailure('Failed to unlike comment: $e');
    }
  }

  /// Check if user has liked a comment
  Future<bool> hasLikedComment(String ideaId, String commentId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final comment = await _firestore
          .collection('ideas')
          .doc(ideaId)
          .collection('comments')
          .doc(commentId)
          .get();

      if (!comment.exists) return false;

      final likedBy = List<String>.from(comment.data()!['likedBy'] ?? []);
      return likedBy.contains(user.uid);
    } catch (e) {
      return false;
    }
  }

  /// Delete a comment (owner or admin only)
  Future<void> deleteComment(String ideaId, String commentId) async {
    try {
      await _firestore
          .collection('ideas')
          .doc(ideaId)
          .collection('comments')
          .doc(commentId)
          .delete();

      // Decrement comment count
      await _firestore.collection('ideas').doc(ideaId).update({
        'commentCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw DataFailure('Failed to delete comment: $e');
    }
  }

  /// Get comment count for an idea
  Future<int> getCommentCount(String ideaId) async {
    try {
      final idea = await _firestore.collection('ideas').doc(ideaId).get();

      if (!idea.exists) {
        throw const DataFailure('Idea not found');
      }

      return idea.data()!['commentCount'] as int? ?? 0;
    } catch (e) {
      throw DataFailure('Failed to get comment count: $e');
    }
  }
}
