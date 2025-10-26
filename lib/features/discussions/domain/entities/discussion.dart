import 'package:cloud_firestore/cloud_firestore.dart';

/// Discussion entity representing a community discussion post
class Discussion {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final String? authorPhotoURL;
  final String municipality;
  final String? ward;
  final List<String> tags;
  final int likesCount;
  final int commentsCount;
  final List<String> likedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const Discussion({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.authorPhotoURL,
    required this.municipality,
    this.ward,
    this.tags = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    this.likedBy = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  Discussion copyWith({
    String? id,
    String? title,
    String? content,
    String? authorId,
    String? authorName,
    String? authorPhotoURL,
    String? municipality,
    String? ward,
    List<String>? tags,
    int? likesCount,
    int? commentsCount,
    List<String>? likedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Discussion(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorPhotoURL: authorPhotoURL ?? this.authorPhotoURL,
      municipality: municipality ?? this.municipality,
      ward: ward ?? this.ward,
      tags: tags ?? this.tags,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      likedBy: likedBy ?? this.likedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
