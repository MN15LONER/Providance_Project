import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/discussion_model.dart';
import '../models/discussion_comment_model.dart';
import '../../domain/entities/discussion.dart';
import '../../domain/entities/discussion_comment.dart';

/// Repository for managing discussions and comments
class DiscussionsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DiscussionsRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Get all discussions stream
  Stream<List<Discussion>> getDiscussions({
    String? municipality,
    String? ward,
    int limit = 50,
  }) {
    Query query = _firestore
        .collection('discussions')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    if (municipality != null) {
      query = query.where('municipality', isEqualTo: municipality);
    }

    if (ward != null) {
      query = query.where('ward', isEqualTo: ward);
    }

    return query.limit(limit).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => DiscussionModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get a single discussion by ID
  Stream<Discussion?> getDiscussion(String discussionId) {
    return _firestore
        .collection('discussions')
        .doc(discussionId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return DiscussionModel.fromFirestore(doc);
    });
  }

  /// Create a new discussion
  Future<String> createDiscussion({
    required String title,
    required String content,
    required String municipality,
    String? ward,
    List<String> tags = const [],
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get user data
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data();

    final now = DateTime.now();
    final discussion = DiscussionModel(
      id: '',
      title: title,
      content: content,
      authorId: user.uid,
      authorName: userData?['displayName'] as String? ?? 'Anonymous',
      authorPhotoURL: userData?['photoURL'] as String?,
      municipality: municipality,
      ward: ward,
      tags: tags,
      createdAt: now,
      updatedAt: now,
    );

    final docRef = await _firestore
        .collection('discussions')
        .add(discussion.toFirestore());

    return docRef.id;
  }

  /// Update a discussion
  Future<void> updateDiscussion({
    required String discussionId,
    String? title,
    String? content,
    List<String>? tags,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final updates = <String, dynamic>{
      'updatedAt': Timestamp.now(),
    };

    if (title != null) updates['title'] = title;
    if (content != null) updates['content'] = content;
    if (tags != null) updates['tags'] = tags;

    await _firestore.collection('discussions').doc(discussionId).update(updates);
  }

  /// Delete a discussion (soft delete)
  Future<void> deleteDiscussion(String discussionId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('discussions').doc(discussionId).update({
      'isActive': false,
      'updatedAt': Timestamp.now(),
    });
  }

  /// Toggle like on a discussion
  Future<void> toggleLikeDiscussion(String discussionId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final docRef = _firestore.collection('discussions').doc(discussionId);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) throw Exception('Discussion not found');

      final data = snapshot.data()!;
      final likedBy = List<String>.from(data['likedBy'] as List? ?? []);
      final likesCount = data['likesCount'] as int? ?? 0;

      if (likedBy.contains(user.uid)) {
        // Unlike
        likedBy.remove(user.uid);
        transaction.update(docRef, {
          'likedBy': likedBy,
          'likesCount': likesCount - 1,
          'updatedAt': Timestamp.now(),
        });
      } else {
        // Like
        likedBy.add(user.uid);
        transaction.update(docRef, {
          'likedBy': likedBy,
          'likesCount': likesCount + 1,
          'updatedAt': Timestamp.now(),
        });
      }
    });
  }

  /// Get comments for a discussion
  Stream<List<DiscussionComment>> getComments(String discussionId) {
    return _firestore
        .collection('discussion_comments')
        .where('discussionId', isEqualTo: discussionId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DiscussionCommentModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Add a comment to a discussion
  Future<String> addComment({
    required String discussionId,
    required String content,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get user data
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data();

    final now = DateTime.now();
    final comment = DiscussionCommentModel(
      id: '',
      discussionId: discussionId,
      content: content,
      authorId: user.uid,
      authorName: userData?['displayName'] as String? ?? 'Anonymous',
      authorPhotoURL: userData?['photoURL'] as String?,
      createdAt: now,
      updatedAt: now,
    );

    final docRef = await _firestore
        .collection('discussion_comments')
        .add(comment.toFirestore());

    // Update comment count on discussion
    await _firestore.collection('discussions').doc(discussionId).update({
      'commentsCount': FieldValue.increment(1),
      'updatedAt': Timestamp.now(),
    });

    return docRef.id;
  }

  /// Delete a comment (soft delete)
  Future<void> deleteComment(String commentId, String discussionId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('discussion_comments').doc(commentId).update({
      'isActive': false,
      'updatedAt': Timestamp.now(),
    });

    // Update comment count on discussion
    await _firestore.collection('discussions').doc(discussionId).update({
      'commentsCount': FieldValue.increment(-1),
      'updatedAt': Timestamp.now(),
    });
  }

  /// Toggle like on a comment
  Future<void> toggleLikeComment(String commentId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final docRef = _firestore.collection('discussion_comments').doc(commentId);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) throw Exception('Comment not found');

      final data = snapshot.data()!;
      final likedBy = List<String>.from(data['likedBy'] as List? ?? []);
      final likesCount = data['likesCount'] as int? ?? 0;

      if (likedBy.contains(user.uid)) {
        // Unlike
        likedBy.remove(user.uid);
        transaction.update(docRef, {
          'likedBy': likedBy,
          'likesCount': likesCount - 1,
          'updatedAt': Timestamp.now(),
        });
      } else {
        // Like
        likedBy.add(user.uid);
        transaction.update(docRef, {
          'likedBy': likedBy,
          'likesCount': likesCount + 1,
          'updatedAt': Timestamp.now(),
        });
      }
    });
  }
}
