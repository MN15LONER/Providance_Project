import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/idea.dart';

/// Idea model for Firestore serialization
class IdeaModel extends Idea {
  const IdeaModel({
    required super.id,
    required super.createdBy,
    required super.creatorName,
    super.creatorPhoto,
    required super.title,
    required super.description,
    required super.category,
    required super.budget,
    required super.status,
    super.location,
    super.locationName,
    super.ward,
    required super.photos,
    required super.voteCount,
    required super.voters,
    required super.commentCount,
    super.officialResponse,
    super.respondedAt,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create from Firestore document
  factory IdeaModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return IdeaModel.fromJson(data, doc.id);
  }

  /// Create from JSON
  factory IdeaModel.fromJson(Map<String, dynamic> json, [String? id]) {
    // Handle budget - can be String or double from Firestore
    String budgetValue;
    if (json['budget'] is double) {
      budgetValue = (json['budget'] as double).toString();
    } else if (json['budget'] is int) {
      budgetValue = (json['budget'] as int).toString();
    } else {
      budgetValue = json['budget'] as String;
    }
    
    return IdeaModel(
      id: id ?? json['id'] as String,
      createdBy: json['createdBy'] as String,
      creatorName: json['creatorName'] as String,
      creatorPhoto: json['creatorPhoto'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      budget: budgetValue,
      status: json['status'] as String,
      location: json['location'] as GeoPoint?,
      locationName: json['locationName'] as String?,
      ward: json['ward'] as String?,
      photos: List<String>.from(json['photos'] as List? ?? []),
      voteCount: json['voteCount'] as int? ?? 0,
      voters: List<String>.from(json['voters'] as List? ?? []),
      commentCount: json['commentCount'] as int? ?? 0,
      officialResponse: json['officialResponse'] as String?,
      respondedAt: json['respondedAt'] != null
          ? (json['respondedAt'] as Timestamp).toDate()
          : null,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'createdBy': createdBy,
      'creatorName': creatorName,
      'creatorPhoto': creatorPhoto,
      'title': title,
      'description': description,
      'category': category,
      'budget': budget,
      'status': status,
      'location': location,
      'locationName': locationName,
      'ward': ward,
      'photos': photos,
      'voteCount': voteCount,
      'voters': voters,
      'commentCount': commentCount,
      'officialResponse': officialResponse,
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Convert to JSON for creation (uses server timestamp)
  Map<String, dynamic> toJsonForCreate() {
    return {
      'createdBy': createdBy,
      'creatorName': creatorName,
      'creatorPhoto': creatorPhoto,
      'title': title,
      'description': description,
      'category': category,
      'budget': budget,
      'status': 'open',
      'location': location,
      'locationName': locationName,
      'ward': ward,
      'photos': photos,
      'voteCount': 0,
      'voters': [],
      'commentCount': 0,
      'officialResponse': null,
      'respondedAt': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Convert entity to model
  factory IdeaModel.fromEntity(Idea idea) {
    return IdeaModel(
      id: idea.id,
      createdBy: idea.createdBy,
      creatorName: idea.creatorName,
      creatorPhoto: idea.creatorPhoto,
      title: idea.title,
      description: idea.description,
      category: idea.category,
      budget: idea.budget,
      status: idea.status,
      location: idea.location,
      locationName: idea.locationName,
      ward: idea.ward,
      photos: idea.photos,
      voteCount: idea.voteCount,
      voters: idea.voters,
      commentCount: idea.commentCount,
      officialResponse: idea.officialResponse,
      respondedAt: idea.respondedAt,
      createdAt: idea.createdAt,
      updatedAt: idea.updatedAt,
    );
  }

  /// Convert to entity
  Idea toEntity() {
    return Idea(
      id: id,
      createdBy: createdBy,
      creatorName: creatorName,
      creatorPhoto: creatorPhoto,
      title: title,
      description: description,
      category: category,
      budget: budget,
      status: status,
      location: location,
      locationName: locationName,
      ward: ward,
      photos: photos,
      voteCount: voteCount,
      voters: voters,
      commentCount: commentCount,
      officialResponse: officialResponse,
      respondedAt: respondedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
