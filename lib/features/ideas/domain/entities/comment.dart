/// Comment entity for ideas
class Comment {
  final String id;
  final String userId;
  final String userName;
  final String? userPhoto;
  final String comment;
  final int likes;
  final List<String> likedBy;
  final DateTime timestamp;

  const Comment({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.comment,
    required this.likes,
    required this.likedBy,
    required this.timestamp,
  });

  Comment copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhoto,
    String? comment,
    int? likes,
    List<String>? likedBy,
    DateTime? timestamp,
  }) {
    return Comment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhoto: userPhoto ?? this.userPhoto,
      comment: comment ?? this.comment,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Comment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Comment(id: $id, userName: $userName, likes: $likes)';
  }
}
