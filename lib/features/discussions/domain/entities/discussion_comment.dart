import 'package:cloud_firestore/cloud_firestore.dart';

/// Discussion comment entity
class DiscussionComment {
  final String id;
  final String discussionId;
  final String content;
  final String authorId;
  final String authorName;
  final String? authorPhotoURL;
  final int likesCount;
  final List<String> likedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const DiscussionComment({
    required this.id,
    required this.discussionId,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.authorPhotoURL,
    this.likesCount = 0,
    this.likedBy = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  DiscussionComment copyWith({
    String? id,
    String? discussionId,
    String? content,
    String? authorId,
    String? authorName,
    String? authorPhotoURL,
    int? likesCount,
    List<String>? likedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return DiscussionComment(
      id: id ?? this.id,
      discussionId: discussionId ?? this.discussionId,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorPhotoURL: authorPhotoURL ?? this.authorPhotoURL,
      likesCount: likesCount ?? this.likesCount,
      likedBy: likedBy ?? this.likedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
