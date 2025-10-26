import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/discussion.dart';

/// Discussion model for Firestore serialization
class DiscussionModel extends Discussion {
  const DiscussionModel({
    required super.id,
    required super.title,
    required super.content,
    required super.authorId,
    required super.authorName,
    super.authorPhotoURL,
    required super.municipality,
    super.ward,
    super.tags,
    super.likesCount,
    super.commentsCount,
    super.likedBy,
    required super.createdAt,
    required super.updatedAt,
    super.isActive,
  });

  /// Create from Firestore document
  factory DiscussionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DiscussionModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? 'Anonymous',
      authorPhotoURL: data['authorPhotoURL'] as String?,
      municipality: data['municipality'] as String? ?? '',
      ward: data['ward'] as String?,
      tags: List<String>.from(data['tags'] as List? ?? []),
      likesCount: data['likesCount'] as int? ?? 0,
      commentsCount: data['commentsCount'] as int? ?? 0,
      likedBy: List<String>.from(data['likedBy'] as List? ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoURL': authorPhotoURL,
      'municipality': municipality,
      'ward': ward,
      'tags': tags,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'likedBy': likedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
    };
  }

  /// Convert from entity
  factory DiscussionModel.fromEntity(Discussion discussion) {
    return DiscussionModel(
      id: discussion.id,
      title: discussion.title,
      content: discussion.content,
      authorId: discussion.authorId,
      authorName: discussion.authorName,
      authorPhotoURL: discussion.authorPhotoURL,
      municipality: discussion.municipality,
      ward: discussion.ward,
      tags: discussion.tags,
      likesCount: discussion.likesCount,
      commentsCount: discussion.commentsCount,
      likedBy: discussion.likedBy,
      createdAt: discussion.createdAt,
      updatedAt: discussion.updatedAt,
      isActive: discussion.isActive,
    );
  }
}
