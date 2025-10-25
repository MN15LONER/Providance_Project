import 'package:cloud_firestore/cloud_firestore.dart';

/// Idea entity representing a community idea
class Idea {
  final String id;
  final String createdBy;
  final String creatorName;
  final String? creatorPhoto;
  final String title;
  final String description;
  final String category;
  final String budget;
  final String status;
  final GeoPoint? location;
  final String? locationName;
  final String? ward;
  final List<String> photos;
  final int voteCount;
  final List<String> voters;
  final int commentCount;
  final String? officialResponse;
  final DateTime? respondedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Idea({
    required this.id,
    required this.createdBy,
    required this.creatorName,
    this.creatorPhoto,
    required this.title,
    required this.description,
    required this.category,
    required this.budget,
    required this.status,
    this.location,
    this.locationName,
    this.ward,
    required this.photos,
    required this.voteCount,
    required this.voters,
    required this.commentCount,
    this.officialResponse,
    this.respondedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy with updated fields
  Idea copyWith({
    String? id,
    String? createdBy,
    String? creatorName,
    String? creatorPhoto,
    String? title,
    String? description,
    String? category,
    String? budget,
    String? status,
    GeoPoint? location,
    String? locationName,
    String? ward,
    List<String>? photos,
    int? voteCount,
    List<String>? voters,
    int? commentCount,
    String? officialResponse,
    DateTime? respondedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Idea(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      creatorName: creatorName ?? this.creatorName,
      creatorPhoto: creatorPhoto ?? this.creatorPhoto,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      budget: budget ?? this.budget,
      status: status ?? this.status,
      location: location ?? this.location,
      locationName: locationName ?? this.locationName,
      ward: ward ?? this.ward,
      photos: photos ?? this.photos,
      voteCount: voteCount ?? this.voteCount,
      voters: voters ?? this.voters,
      commentCount: commentCount ?? this.commentCount,
      officialResponse: officialResponse ?? this.officialResponse,
      respondedAt: respondedAt ?? this.respondedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Idea && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Idea(id: $id, title: $title, status: $status, votes: $voteCount)';
  }
}
