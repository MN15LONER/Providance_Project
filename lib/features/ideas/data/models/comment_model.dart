import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/comment.dart';

/// Comment model for Firestore serialization
class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.userId,
    required super.userName,
    super.userPhoto,
    required super.comment,
    required super.likes,
    required super.likedBy,
    required super.timestamp,
  });

  /// Create from Firestore document
  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel.fromJson(data, doc.id);
  }

  /// Create from JSON
  factory CommentModel.fromJson(Map<String, dynamic> json, [String? id]) {
    return CommentModel(
      id: id ?? json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userPhoto: json['userPhoto'] as String?,
      comment: json['comment'] as String,
      likes: json['likes'] as int? ?? 0,
      likedBy: List<String>.from(json['likedBy'] as List? ?? []),
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'comment': comment,
      'likes': likes,
      'likedBy': likedBy,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  /// Convert to JSON for creation (uses server timestamp)
  Map<String, dynamic> toJsonForCreate() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'comment': comment,
      'likes': 0,
      'likedBy': [],
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  /// Convert entity to model
  factory CommentModel.fromEntity(Comment comment) {
    return CommentModel(
      id: comment.id,
      userId: comment.userId,
      userName: comment.userName,
      userPhoto: comment.userPhoto,
      comment: comment.comment,
      likes: comment.likes,
      likedBy: comment.likedBy,
      timestamp: comment.timestamp,
    );
  }

  /// Convert to entity
  Comment toEntity() {
    return Comment(
      id: id,
      userId: userId,
      userName: userName,
      userPhoto: userPhoto,
      comment: comment,
      likes: likes,
      likedBy: likedBy,
      timestamp: timestamp,
    );
  }
}
