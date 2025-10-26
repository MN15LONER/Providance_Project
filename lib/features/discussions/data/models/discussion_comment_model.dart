import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/discussion_comment.dart';

/// Discussion comment model for Firestore serialization
class DiscussionCommentModel extends DiscussionComment {
  const DiscussionCommentModel({
    required super.id,
    required super.discussionId,
    required super.content,
    required super.authorId,
    required super.authorName,
    super.authorPhotoURL,
    super.likesCount,
    super.likedBy,
    required super.createdAt,
    required super.updatedAt,
    super.isActive,
  });

  /// Create from Firestore document
  factory DiscussionCommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DiscussionCommentModel(
      id: doc.id,
      discussionId: data['discussionId'] as String? ?? '',
      content: data['content'] as String? ?? '',
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? 'Anonymous',
      authorPhotoURL: data['authorPhotoURL'] as String?,
      likesCount: data['likesCount'] as int? ?? 0,
      likedBy: List<String>.from(data['likedBy'] as List? ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'discussionId': discussionId,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoURL': authorPhotoURL,
      'likesCount': likesCount,
      'likedBy': likedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
    };
  }

  /// Convert from entity
  factory DiscussionCommentModel.fromEntity(DiscussionComment comment) {
    return DiscussionCommentModel(
      id: comment.id,
      discussionId: comment.discussionId,
      content: comment.content,
      authorId: comment.authorId,
      authorName: comment.authorName,
      authorPhotoURL: comment.authorPhotoURL,
      likesCount: comment.likesCount,
      likedBy: comment.likedBy,
      createdAt: comment.createdAt,
      updatedAt: comment.updatedAt,
      isActive: comment.isActive,
    );
  }
}
